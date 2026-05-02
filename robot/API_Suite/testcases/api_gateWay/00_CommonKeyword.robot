*** Settings ***
Resource     ../../keywords/common.robot

*** Variables ***
${app_code}     your-app-code-uuid
${userName}     your-username
${password}     your-password

*** Keywords ***
Refresh
    [Documentation]    Triggers gateway route-mapping refresh.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     refresh_api    ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    refresh_api    /api/v1/gateway/refresh-mapping    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}

Refresh_route
    [Documentation]    Triggers gateway static-route refresh.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     refresh_route    ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    refresh_route    /api/v1/gateway/refresh-mapping/routes    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}

Compute Expiry Date
    [Documentation]    Returns a date 2-6 months from today in YYYY-MM-DD format.
    ${exp_date}=    Evaluate
    ...    (__import__('datetime').datetime.now() + __import__('datetime').timedelta(days=__import__('random').randint(60, 180))).strftime('%Y-%m-%d')
    Log To Console    Expiry date: ${exp_date}
    RETURN    ${exp_date}

Login As User
    [Documentation]    Fetches API credentials from DB then authenticates via normal login.
    ${login_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session   user_login    url=${login_url}:${login_port}

    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query    SELECT api_key, client_id FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code}';
    ${row}=         Get From List    ${rows}    0
    ${api_key}=     Get From List    ${row}    0
    ${client_Id}=   Get From List    ${row}    1
    Disconnect From Database

    Set Suite Variable    ${api_key}
    Set Suite Variable    ${client_Id}

    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${body}=    Create Dictionary
    ...    username=${userName}
    ...    userpassword=${password}

    ${response}=       POST On Session    user_login    /api/v1/auth/login    json=${body}    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}

    ${json_data}=    Convert String To Json    ${response.content}
    ${msg_list}=     Get Value From Json    ${json_data}    status.code
    ${msg}=          Get From List    ${msg_list}    0

    ${cookie_dict}=     Set Variable    ${response.cookies.get_dict()}
    ${refresh_token}=   Get From Dictionary    ${cookie_dict}    xxx-refresh-token
    Set Suite Variable  ${refresh_token}

    Log To Console    ${userName}: Login ${msg}
    RETURN    ${refresh_token}    ${client_Id}    ${api_key}    ${app_code}
