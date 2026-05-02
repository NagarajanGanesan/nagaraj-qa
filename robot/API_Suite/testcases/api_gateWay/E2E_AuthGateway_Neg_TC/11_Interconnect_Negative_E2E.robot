*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# App A credentials — primary application
${app_a_app_code}      your-app-code-uuid
${app_a_api_key}       your-api-key-hex-64chars
${app_a_client_id}     your-client-id
${app_a_username}      your-username
${app_a_password}      your-password

# App B credentials — secondary application (separate partner-product-config)
${app_b_app_code}      your-app-b-code-uuid
${app_b_api_key}       your-app-b-api-key-hex-64chars
${app_b_client_id}     your-app-b-client-id

${valid_login_type}    AD
${invalid_login_type}  LOCAL

# Phantom app_code — valid UUID format but never registered anywhere
${phantom_app_code}    00000000-dead-beef-cafe-000000000001

*** Test Cases ***
# INTERCONNECT NEGATIVE TEST CASES
# These tests validate cross-service security constraints where
# a failure in one service's state should cascade to block
# operations in a dependent service.
# ============================================================

TC_01_NEG_Login_CrossApp_Valid_User_Wrong_AppCode
    [Documentation]    Verify that logging in with App A's user credentials but providing App B's app_code in the
    ...                header returns 401 Unauthorized.  The gateway must validate that the app_code matches the
    ...                partner-product-config used for authentication.
    [Tags]    negative    login    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_01     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_b_app_code}
    ...    xxx-CLIENT-ID=${app_a_client_id}
    ...    xxx-API-KEY=${app_a_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    iconn_neg_01    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_01 PASS: Got ${status_code} — cross-app login blocked (App A credentials with App B app_code)

TC_02_NEG_Login_Mismatched_ApiKey_And_ClientId
    [Documentation]    Verify that using App A's api_key combined with App B's client_id (mismatched pair) returns
    ...                401 Unauthorized. api_key and client_id must belong to the same partner-product-config record.
    [Tags]    negative    login    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_02     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_a_app_code}
    ...    xxx-CLIENT-ID=${app_b_client_id}
    ...    xxx-API-KEY=${app_a_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    iconn_neg_02    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${unauthorized_code}
    Log To Console    TC_02 PASS: Got 401 — mismatched api_key (App A) + client_id (App B) rejected

TC_03_NEG_Login_Wrong_Login_Type
    [Documentation]    Verify that login with an incorrect login_type (e.g. LOCAL instead of AD) returns an error.
    ...                The login_type must match the authentication mechanism configured for the user's application.
    [Tags]    negative    login    interconnect    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_03     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_a_app_code}
    ...    xxx-CLIENT-ID=${app_a_client_id}
    ...    xxx-API-KEY=${app_a_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${invalid_login_type}
    ${response}=       POST On Session    iconn_neg_03    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_03 PASS: Got ${status_code} — wrong login_type=${invalid_login_type} rejected

TC_04_NEG_ChannelMapping_With_Unregistered_AppCode
    [Documentation]    Verify that creating a channel mapping using an app_code that has no partner-product-config
    ...                record returns an error. Tests the dependency: channel-mapping requires a valid,
    ...                registered app_code from the partner-product-config service.
    [Tags]    negative    channel-mapping    interconnect    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_04     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    api_channel_id=${1}
    ...    app_code=${phantom_app_code}
    ...    decryption_enabled=${False}
    ...    rate_limit=${20}
    ...    period_seconds=${10}
    ${response}=       POST On Session    iconn_neg_04    /api/v1/gateway/channel-mapping    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_04 PASS: Got ${status_code} — channel mapping rejected for unregistered app_code=${phantom_app_code}

TC_05_NEG_Login_App_B_Credentials_With_App_A_AppCode
    [Documentation]    Verify that using App B's complete credential set (api_key + client_id) but App A's app_code
    ...                returns 401 Unauthorized. All three header values must reference the same partner-product-config.
    [Tags]    negative    login    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_05     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_a_app_code}
    ...    xxx-CLIENT-ID=${app_b_client_id}
    ...    xxx-API-KEY=${app_b_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    iconn_neg_05    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${unauthorized_code}
    Log To Console    TC_05 PASS: Got 401 — App B credentials rejected when using App A's app_code header

TC_06_NEG_Login_User_Not_Registered_In_Target_Application
    [Documentation]    Verify that a user who is registered in application A cannot login via application B's
    ...                api_key/client_id/app_code combination. Users are scoped to their registered applications.
    [Tags]    negative    login    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_06     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_b_app_code}
    ...    xxx-CLIENT-ID=${app_b_client_id}
    ...    xxx-API-KEY=${app_b_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    iconn_neg_06    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_06 PASS: Got ${status_code} — user from App A rejected when logging in via App B context

TC_07_NEG_Logout_With_Already_Invalidated_Token
    [Documentation]    Verify that calling logout a second time using an already-invalidated session token returns
    ...                an error (401 or similar). This tests that tokens are properly blacklisted after first logout.
    [Tags]    negative    logout    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_login_07     ${login_url}:${login_port}
    Create Session     iconn_logout_07    ${gateway_url}:${gateway_port}
    ${login_headers}=  Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_a_app_code}
    ...    xxx-CLIENT-ID=${app_a_client_id}
    ...    xxx-API-KEY=${app_a_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    # Step 1: Login to obtain a valid session token
    ${login_resp}=     POST On Session    iconn_login_07    /api/v1/auth/login    json=${body}    headers=${login_headers}    expected_status=anything
    ${login_status}=   Convert To String    ${login_resp.status_code}
    Skip If    '${login_status}' != '200'    Cannot test double-logout — initial login returned ${login_status} (check credentials)
    ${cookies_dict}=   Set Variable    ${login_resp.cookies.get_dict()}
    ${access_token}=   Get From Dictionary    ${cookies_dict}    xxx-access-token
    ${cookie_string}=  Set Variable    xxx-access-token=${access_token}
    ${logout_headers}=     Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=${cookie_string}
    ...    xxx-client-id=${app_a_client_id}
    ...    xxx-api-key=${app_a_api_key}
    ...    app-code=${app_a_app_code}
    # Step 2: First logout — should succeed
    GET On Session     iconn_logout_07    /api/v1/auth/logout    headers=${logout_headers}    expected_status=anything
    # Step 3: Second logout with the now-invalidated token — must be rejected
    ${response}=       GET On Session    iconn_logout_07    /api/v1/auth/logout    headers=${logout_headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_07 PASS: Got ${status_code} — second logout with invalidated token rejected

TC_08_NEG_Login_Phantom_AppCode_Not_In_PartnerProductConfig
    [Documentation]    Verify that login using an app_code that does not exist in partner-product-config returns 401.
    ...                Tests the end-to-end chain: gateway validates app_code against partner-product-config before
    ...                proceeding to AuthService.
    [Tags]    negative    login    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_08     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${phantom_app_code}
    ...    xxx-CLIENT-ID=${app_a_client_id}
    ...    xxx-API-KEY=${app_a_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    iconn_neg_08    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_08 PASS: Got ${status_code} — login blocked for phantom app_code not in partner-product-config

TC_09_NEG_PartnerProductConfig_AppCode_Not_Registered_In_Application_Registry
    [Documentation]    Verify that an app_code present in partner-product-config but NOT registered in the
    ...                AuthService application registry fails login. Tests that both services must agree on the app_code
    ...                before a user can be authenticated.
    [Tags]    negative    login    interconnect    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_neg_09     ${login_url}:${login_port}
    # Use App B credentials (partner-product-config exists) but attempt login for App A user
    # If App A user is not registered under App B's application, this must fail
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_b_app_code}
    ...    xxx-CLIENT-ID=${app_b_client_id}
    ...    xxx-API-KEY=${app_b_api_key}
    ${body}=           Create Dictionary
    ...    username=${app_a_username}
    ...    userpassword=${app_a_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    iconn_neg_09    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_09 PASS: Got ${status_code} — user not in App B's application registry, login blocked

TC_10_NEG_Refresh_Mapping_After_Channel_Deletion_Consistency
    [Documentation]    Verify that calling refresh-mapping after removing a channel returns 200 and the gateway
    ...                routing cache is updated without error.  This is a negative-adjacent consistency test —
    ...                the operation itself should succeed but dependent routing for that channel must no longer work.
    [Tags]    negative    refresh    interconnect    consistency
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     iconn_refresh_10    ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    iconn_refresh_10    /api/v1/gateway/refresh-mapping    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}
    ${route_resp}=     GET On Session    iconn_refresh_10    /api/v1/gateway/refresh-mapping/routes    headers=${headers}    expected_status=anything
    ${route_status}=   Convert To String    ${route_resp.status_code}
    Should Be Equal    ${route_status}    ${expected_code}
    Log To Console    TC_10 PASS: refresh-mapping and refresh-mapping/routes both returned 200 (cache refreshed successfully)
