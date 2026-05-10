*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# Valid data
${valid_channel_id}          1
${valid_app_code}            17fbab61-e43c-4e1e-a1e9-xxxxx
${valid_rate_limit}          20
${valid_period_seconds}      10
# Invalid / boundary data
${nonexistent_channel_id}    999999
${nonexistent_mapping_id}    999999
${invalid_app_code}          00000000-0000-0000-0000-000000000000
# App code that exists in partner_product_config but all its configs have status=false (disabled)
${disabled_app_code}         disabled-appcode-no-active-config
${zero_rate_limit}           0
${negative_rate_limit}       -1
${very_high_rate_limit}      99999

*** Test Cases ***
# NEGATIVE TEST CASES
# ============================================================

TC_05_NEG_Create_ChannelMapping_Missing_Channel_ID
    [Documentation]    Verify creating channel mapping without api_channel_id returns 400
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_05     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_05    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_05 PASS: Got 400 for missing api_channel_id

TC_06_NEG_Create_ChannelMapping_Missing_AppCode
    [Documentation]    Verify creating channel mapping without app_code returns 400
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_06     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_06    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_06 PASS: Got 400 for missing app_code

TC_07_NEG_Create_ChannelMapping_With_NonExistent_Channel_ID
    [Documentation]    Verify creating channel mapping with non-existent channel_id returns error
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_07     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${nonexistent_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_07    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_07 PASS: Got error ${status_code} for non-existent channel_id=${nonexistent_channel_id}

TC_08_NEG_Create_ChannelMapping_With_Invalid_AppCode
    [Documentation]    Verify creating channel mapping with invalid app_code returns error
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_08     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${invalid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_08    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_08 PASS: Got error ${status_code} for invalid app_code

TC_09_NEG_Create_ChannelMapping_With_Zero_Rate_Limit
    [Documentation]    Verify creating channel mapping with rate_limit=0 returns 400 Bad Request
    [Tags]    negative    channel-mapping    boundary    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_09     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${zero_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_09    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_09 PASS: Got 400 for rate_limit=0

TC_10_NEG_Create_ChannelMapping_With_Negative_Rate_Limit
    [Documentation]    Verify creating channel mapping with negative rate_limit returns 400 Bad Request
    [Tags]    negative    channel-mapping    boundary    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_10     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${negative_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_10    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for negative rate_limit=${negative_rate_limit}

TC_11_NEG_Create_ChannelMapping_Missing_Period_Seconds
    [Documentation]    Verify creating channel mapping without period_seconds returns 400
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_11     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ${response}=       POST On Session    cm_neg_11    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_11 PASS: Got 400 for missing period_seconds

TC_12_NEG_Create_Duplicate_ChannelMapping
    [Documentation]    Verify that mapping the same channel to the same app_code twice returns an error
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_12     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${3}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    # First mapping
    POST On Session    cm_neg_12    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate mapping
    ${response}=       POST On Session    cm_neg_12    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_12 PASS: Got error ${status_code} for duplicate channel mapping

TC_13_NEG_Create_ChannelMapping_Missing_Rate_Limit
    [Documentation]    Verify that creating a channel mapping without rate_limit field returns 400 Bad Request
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_13     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_13    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_13 PASS: Got 400 for missing rate_limit field

TC_14_NEG_Create_ChannelMapping_Zero_Period_Seconds
    [Documentation]    Verify that creating a channel mapping with period_seconds=0 returns 400 Bad Request
    [Tags]    negative    channel-mapping    boundary    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_14     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${0}
    ${response}=       POST On Session    cm_neg_14    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_14 PASS: Got 400 for period_seconds=0 (must be a positive integer)

TC_15_NEG_Create_ChannelMapping_Empty_Body
    [Documentation]    Verify that creating a channel mapping with an empty request body returns 400 Bad Request
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_15     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ${response}=       POST On Session    cm_neg_15    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_15 PASS: Got 400 for empty request body

TC_16_NEG_Update_ChannelMapping_NonExistent_Mapping_ID
    [Documentation]    Verify that updating a channel mapping using a non-existent api_channel_mapping_id returns error
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_16     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_mapping_id=${999999}
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       PUT On Session    cm_neg_16    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_16 PASS: Got error ${status_code} for update with non-existent mapping_id=999999

TC_17_NEG_Create_ChannelMapping_Negative_Period_Seconds
    [Documentation]    Verify that creating a channel mapping with a negative period_seconds value returns 400 Bad Request
    [Tags]    negative    channel-mapping    boundary    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_17     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${-1}
    ${response}=       POST On Session    cm_neg_17    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_17 PASS: Got 400 for negative period_seconds=-1

TC_18_NEG_Create_ChannelMapping_AppCode_Has_No_Active_PartnerConfig
    [Documentation]    Verify that creating a mapping with an appCode that has no active PartnerProductConfig
    ...                (status=false/disabled) returns error. ChannelMappingServiceImpl.configMapping() calls
    ...                findTop2ByAppCodeAndStatusOrderByCreatedAtDesc(appCode, true) and throws
    ...                IllegalStateException("AppCode not Available") when the result is null or empty.
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_18     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${disabled_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_18    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_18 PASS: Got error ${status_code} for mapping with appCode having no active PartnerConfig

TC_19_NEG_Create_ChannelMapping_ProductId_Has_No_Active_PartnerConfig
    [Documentation]    Verify that creating a mapping with a productId that has no active PartnerProductConfig
    ...                returns error. ChannelMappingServiceImpl.configMapping() calls
    ...                findTop2ByProducts_IdAndStatusOrderByCreatedAtDesc(productId, true) and throws
    ...                IllegalStateException("ProductId not Available") when configs list is empty.
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_19     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${valid_channel_id}
    ...    product_id=${nonexistent_channel_id}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_19    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_19 PASS: Got error ${status_code} for mapping with productId having no active PartnerConfig

TC_20_NEG_Delete_ChannelMapping_With_NonExistent_Mapping_ID
    [Documentation]    Verify that deleting a channel mapping with a non-existent mapping ID returns error.
    ...                ChannelMappingServiceImpl.deleteMapping() throws NoSuchElementException("mapping not found with id: X")
    ...                when productApiChannelMappingRepository.existsById() returns false.
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_20     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    cm_neg_20    /api/v1/gateway/channel-mapping/${nonexistent_mapping_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_20 PASS: Got error ${status_code} for DELETE channel mapping with non-existent id=${nonexistent_mapping_id}

TC_21_NEG_Update_ChannelMapping_With_NonExistent_Mapping_ID
    [Documentation]    Verify that updating a channel mapping using a non-existent api_channel_mapping_id returns error.
    ...                ChannelMappingServiceImpl.update() calls findById().orElseThrow() which throws
    ...                NoSuchElementException or IllegalStateException → ResponseStatus.BAD_REQUEST.
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_21     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_mapping_id=${nonexistent_mapping_id}
    ...    api_channel_id=${valid_channel_id}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       PUT On Session    cm_neg_21    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_21 PASS: Got error ${status_code} for UPDATE channel mapping with non-existent id=${nonexistent_mapping_id}

TC_22_NEG_Create_ChannelMapping_Channel_ID_Not_Found
    [Documentation]    Verify that creating a channel mapping when the api_channel_id exists in DB but
    ...                the appCode check passes yet the channel lookup fails in configMapping returns error.
    ...                This differs from TC_07 which tests a numeric non-existent channel ID — here the
    ...                channel_id string is 0 (invalid primary key) to trigger the existsById() false path.
    [Tags]    negative    channel-mapping    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     cm_neg_22     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${0}
    ...    app_code=${valid_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${valid_rate_limit}
    ...    period_seconds=${valid_period_seconds}
    ${response}=       POST On Session    cm_neg_22    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_22 PASS: Got error ${status_code} for channel mapping with channel_id=0 (invalid primary key)
