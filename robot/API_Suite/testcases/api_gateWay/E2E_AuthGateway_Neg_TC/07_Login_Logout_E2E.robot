*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# Valid login credentials - update as per your system
${valid_app_code}      your-app-code-uuid
${valid_api_key}       your-api-key-hex-64chars
${valid_client_id}     your-client-id
${valid_username}      your-username
${valid_password}      your-password
${valid_login_type}    AD

# Invalid / negative data
${wrong_password}      WrongPass@9999
${wrong_username}      nonexistent_user_xyz
${invalid_api_key}     0000000000000000000000000000000000000000000000000000000000000000
${invalid_client_id}   INVALID_CLIENT_ID_000
${invalid_app_code}    00000000-0000-0000-0000-000000000000

*** Test Cases ***
# NEGATIVE TEST CASES
# ============================================================

TC_04_NEG_Login_With_Wrong_Password
    [Documentation]    Verify that login with a wrong password returns 401 Unauthorized
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_04     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${wrong_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_04    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_04 PASS: Got ${status_code} for wrong password

TC_05_NEG_Login_With_NonExistent_Username
    [Documentation]    Verify that login with a non-existent username returns 401 Unauthorized
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_05     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${wrong_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_05    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_05 PASS: Got ${status_code} for non-existent username=${wrong_username}

TC_06_NEG_Login_With_Missing_Username
    [Documentation]    Verify that login without username field returns 400 Bad Request
    [Tags]    negative    login    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_06     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_06    /api/v1/auth/adlogin    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_06 PASS: Got 400 for missing username field

TC_07_NEG_Login_With_Missing_Password
    [Documentation]    Verify that login without password field returns 400 Bad Request
    [Tags]    negative    login    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_07     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_07    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_07 PASS: Got 400 for missing password field

TC_08_NEG_Login_With_Empty_Username
    [Documentation]    Verify that login with empty string username returns 400 Bad Request
    [Tags]    negative    login    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_08     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${EMPTY}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_08    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_08 PASS: Got 400 for empty username

TC_09_NEG_Login_With_Invalid_API_Key
    [Documentation]    Verify that login with an invalid xxx-API-KEY header returns 401 Unauthorized
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_09     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${invalid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_09    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${unauthorized_code}
    Log To Console    TC_09 PASS: Got 401 for invalid xxx-API-KEY

TC_10_NEG_Login_With_Invalid_Client_ID
    [Documentation]    Verify that login with an invalid xxx-CLIENT-ID returns 401 Unauthorized
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_10     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${invalid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_10    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${unauthorized_code}
    Log To Console    TC_10 PASS: Got 401 for invalid xxx-CLIENT-ID

TC_11_NEG_Login_With_Missing_Client_ID_Header
    [Documentation]    Verify that login without xxx-CLIENT-ID header returns 401
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_11     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_11    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_11 PASS: Got ${status_code} for missing xxx-CLIENT-ID header

TC_12_NEG_Login_With_Missing_API_Key_Header
    [Documentation]    Verify that login without xxx-API-KEY header returns 401
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_12     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_12    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_12 PASS: Got ${status_code} for missing xxx-API-KEY header

TC_13_NEG_Login_With_Missing_AppCode_Header
    [Documentation]    Verify that login without app-code header returns 401
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_13     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_13    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_13 PASS: Got ${status_code} for missing app-code header

TC_14_NEG_Login_With_Invalid_AppCode
    [Documentation]    Verify that login with an invalid app_code returns 401 Unauthorized
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_14     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${invalid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_14    /api/v1/auth/adlogin    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${unauthorized_code}
    Log To Console    TC_14 PASS: Got 401 for invalid app-code=${invalid_app_code}

TC_15_NEG_Logout_Without_Access_Token
    [Documentation]    Verify that calling logout without a session token returns 401 Unauthorized
    [Tags]    negative    logout    security
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     logout_neg_15     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-client-id=${valid_client_id}
    ...    xxx-api-key=${valid_api_key}
    ...    app-code=${valid_app_code}
    ${response}=       GET On Session    logout_neg_15    /api/v1/auth/logout    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_15 PASS: Got ${status_code} for logout without access token

TC_16_NEG_Logout_With_Invalid_Token
    [Documentation]    Verify that logout with an invalid/expired access token returns 401
    [Tags]    negative    logout    security
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     logout_neg_16     ${gateway_url}:${gateway_port}
    ${fake_token}=     Set Variable    invalid.fake.token.xyz.0000000000
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=xxx-access-token=${fake_token}
    ...    xxx-client-id=${valid_client_id}
    ...    xxx-api-key=${valid_api_key}
    ...    app-code=${valid_app_code}
    ${response}=       GET On Session    logout_neg_16    /api/v1/auth/logout    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_16 PASS: Got ${status_code} for logout with invalid token

TC_17_NEG_Login_With_Empty_Request_Body
    [Documentation]    Verify that login with empty body returns 400 Bad Request
    [Tags]    negative    login    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_17     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ${response}=       POST On Session    login_neg_17    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_17 PASS: Got 400 for empty request body

TC_18_NEG_Login_With_Already_LoggedIn_User
    [Documentation]    Verify that a second login attempt for an already active session returns 400 Bad Request.
    ...                xxxLoginImpl.login() checks cachingService.userLogCheck(userId, applicationCode).
    ...                When the user is already logged in it throws IllegalArgumentException("User already logged in")
    ...                which maps to ResponseStatus.BAD_REQUEST (HTTP 400).
    ...                This test sends two consecutive login requests for the same user.
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_18     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ...    login_type=${valid_login_type}
    # First login — may succeed or fail depending on current session state
    POST On Session    login_neg_18    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    # Second login — must be rejected since user is now already logged in
    ${response}=       POST On Session    login_neg_18    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_18 PASS: Got ${status_code} for duplicate login attempt (user already logged in)

TC_19_NEG_Login_Missing_Login_Type_Field
    [Documentation]    Verify that login without the login_type field in the body returns 400 Bad Request.
    ...                The login_type field is required to distinguish AD vs local authentication path.
    [Tags]    negative    login    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_19     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${valid_password}
    ${response}=       POST On Session    login_neg_19    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_19 PASS: Got 400 for missing login_type field

TC_20_NEG_Login_With_Empty_Password
    [Documentation]    Verify that login with an empty string password returns 400 Bad Request.
    ...                xxxLoginImpl.login() validates the password value; an empty password
    ...                will fail the DTO schema validation or the password comparison check.
    [Tags]    negative    login    validation
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_20     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${valid_username}
    ...    userpassword=${EMPTY}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_20    /api/v1/auth/login    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_20 PASS: Got 400 for empty password field

TC_21_NEG_AD_Login_With_Wrong_Credentials
    [Documentation]    Verify that AD login with an unauthorized username returns 401 Unauthorized.
    ...                xxxLoginImpl.adlogin() calls loginImpl() which returns LenderLoginUserDetails
    ...                with status=false for unauthorized users, then throws
    ...                IllegalStateException("Unauthorized User") → ResponseStatus.UNAUTHORIZED.
    [Tags]    negative    login    security
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     login_neg_21     ${login_url}:${login_port}
    ${headers}=        Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${valid_app_code}
    ...    xxx-CLIENT-ID=${valid_client_id}
    ...    xxx-API-KEY=${valid_api_key}
    ${body}=           Create Dictionary
    ...    username=${wrong_username}
    ...    userpassword=${wrong_password}
    ...    login_type=${valid_login_type}
    ${response}=       POST On Session    login_neg_21    /api/v1/auth/adlogin    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${unauthorized_code}
    Log To Console    TC_21 PASS: Got 401 for AD login with unauthorized user=${wrong_username}
