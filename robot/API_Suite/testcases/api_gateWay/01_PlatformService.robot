*** Settings ***
Resource     ../../keywords/common.robot
Resource     ../../testcases/Lender_Config/05_addProduct_Positive.robot
Resource     ../../testcases/Lender_Config/02_addDistributor_Positive.robot

*** Variables ***
# Service configuration
${service_name}          Platform-testing
${service_url}           lb://common-service

# Channel
${description}           Platform service testing
${api_method}            POST

# Partner-product configuration
${prod_id}               2
${exp_date}              2028-05-27

# Channel-Mapping
${rateLimit}             20
${periodSec}             1
${decryption_enabled}    False

*** Keywords ***
01_Get_serviceId
    [Documentation]    Register service; if already exists, fetch existing service_id via GET
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_session    ${gateway_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    status=${True}
    ...    service_name=${service_name}
    ...    service_url=${service_url}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    svc_session    /api/v1/gateway/service
    ...    json=${body}    headers=${headers}    expected_status=anything
    IF    '${response.status_code}' == '200'
        ${json_data}=    Convert String To Json    ${response.content}
        ${ids}=          Get Value From Json    ${json_data}    data.service_id
        ${service_id}=   Get From List    ${ids}    0
        Log To Console    Service created: id=${service_id}
    ELSE
        Log To Console    Service already exists, fetching via GET
        ${get_resp}=     GET On Session    svc_session    /api/v1/gateway/service
        ...    headers=${headers}    expected_status=anything
        ${get_json}=     Convert String To Json    ${get_resp.content}
        ${id_list}=      Get Value From Json    ${get_json}
        ...    $.data[?(@.service_name=='${service_name}')].service_id
        ${service_id}=   Get From List    ${id_list}    0
        Log To Console    Found existing service: id=${service_id}
    END
    Log To Console    Using service id=${service_id}
    Set Suite Variable    ${service_id}
    RETURN    ${service_id}

02_Get_channelID
    [Arguments]    ${service_id}
    [Documentation]    Create channel with unique path to avoid duplicate-path conflicts on re-runs
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_session    ${gateway_url}:${gateway_port}
    ${channel_name}=    FakerLibrary.Safe Domain Name
    ${rand_suffix}=    Generate Random String    4    [NUMBERS]
    ${channel_path}=    Set Variable    /lender-${rand_suffix}
    ${body}=    Create Dictionary
    ...    description=${description}
    ...    service_id=${service_id}
    ...    api_channel_name=${channel_name}
    ...    api_channel_path=${channel_path}
    ...    api_channel_method=${api_method}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    ch_session    /api/v1/gateway/channel
    ...    json=${body}    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}
    ${json_data}=    Convert String To Json    ${response.content}
    ${id}=           Get Value From Json    ${json_data}    data.api_channel_id
    ${channel_id}=   Get From List    ${id}    0
    Log To Console    Channel id=${channel_id}  path=${channel_path}
    Set Suite Variable    ${channel_id}
    Set Suite Variable    ${channel_path}
    RETURN    ${channel_id}

03_partnerProduct_Config
    [Arguments]    ${Product_id}
    [Documentation]    Create partner-product config (product mode, app_code_creation=False).
    ...                Fetches credentials from DB (handles already-exists gracefully).
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_session    ${gateway_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    product_id=${Product_id}
    ...    app_code_creation=${False}
    ...    expiry_date=${exp_date}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    ppc_session    /api/v1/gateway/partner-product-config
    ...    json=${body}    headers=${headers}    expected_status=anything
    Log To Console    Partner config status=${response.status_code}
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT api_key, client_id FROM ${schemeName}.partner_product_config
    ...    WHERE products_id = ${Product_id} AND app_code IS NULL AND status = true
    ...    ORDER BY created_at DESC LIMIT 1
    Disconnect From Database
    ${row}=        Get From List    ${rows}    0
    ${api_key}=    Get From List    ${row}     0
    ${client_Id}=  Get From List    ${row}     1
    Log To Console    apiKey=${api_key}  clientId=${client_Id}
    Set Suite Variable    ${api_key}
    Set Suite Variable    ${client_Id}
    RETURN    ${client_Id}    ${api_key}

04_ChannelMapping
    [Arguments]    ${channel_id}    ${Product_id}
    [Documentation]    Create channel mapping with rate-limit configuration
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     mapping_session    ${gateway_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    product_id=${Product_id}
    ...    decryption_enabled=${decryption_enabled}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    mapping_session    /api/v1/gateway/channel-mapping
    ...    json=${body}    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}
    ${json_data}=       Convert String To Json    ${response.content}
    ${id}=              Get Value From Json    ${json_data}    data.api_channel_mapping_id
    ${channelMap_id}=   Get From List    ${id}    0
    Log To Console    Channel mapping id=${channelMap_id}
    RETURN    ${channelMap_id}

05_refresh
    [Documentation]    Refresh gateway route mappings
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     refresh_session    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    refresh_session    /api/v1/gateway/refresh-mapping
    ...    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}

06_refresh_routes
    [Documentation]    Refresh gateway static routes
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     refresh_route    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    refresh_route    /api/v1/gateway/refresh-mapping/routes
    ...    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}


*** Test Cases ***
TC01_Get_ServiceId
    [Documentation]    End-to-end gateway platform setup:
    ...    service => channel => product => partner config => channel mapping => refresh
    ${service_id}=    01_Get_serviceId
    ${channel_id}=    02_Get_channelID    ${service_id}
    ${Product_id}=    TC05_Product_Positive     ${cookies}    ${client_id}    ${api_key}    ${app_code}    True    ${lender_id}    ${lender_name}
    ...    ${Distributor_id}    ${DistributorName}    True    True
    03_partnerProduct_Config    ${Product_id}
    04_ChannelMapping    ${channel_id}    ${Product_id}
    05_refresh
    06_refresh_routes
    Log To Console    Setup complete - channel_id=${channel_id}  
    # ...    client_id=${client_Id}  api_key=${api_key}
