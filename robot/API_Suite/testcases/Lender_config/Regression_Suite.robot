*** Settings ***
Resource     ../../keywords/common.robot
Resource     ../Lender_Config/addLender_Positive.robot
Resource     ../Lender_Config/addDistributor_Positive.robot

*** Variables ***
${app_code}       your-app-code-uuid
${userName}       your-username
${password}       your-password
${userId}         1
${userRole}       1
${login_type}     NORMAL

*** Test Cases ***
Regression_Suite
    [Documentation]    End-to-end regression: Login → Lender → Distributor → Product → Logout
    ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${branchCode}=    Login As User
    ${lender_id}    ${lenderName}=    TC01_Lender Onboarding_Positive    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${Distributor_id}    ${DistributorName}=    TC02_Distributor Onboarding_Positive
    Logout    ${cookies}    ${client_Id}    ${api_key}    ${app_code}

*** Keywords ***
Login As User
    [Documentation]    Fetches API credentials from DB then authenticates; returns session cookies and auth headers.
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     user_login    url=${comServ_url}:${gateway_port}

    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query    SELECT api_key, client_id FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code}';
    ${row}=         Get From List    ${rows}       0
    ${api_key}=     Get From List    ${row}        0
    ${client_Id}=   Get From List    ${row}        1
    Disconnect From Database

    Set Suite Variable    ${api_key}
    Set Suite Variable    ${client_Id}

    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    CAPTIX-CLIENT-ID=${client_Id}
    ...    CAPTIX-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${body}=    Create Dictionary
    ...    username=${userName}
    ...    userpassword=${password}
    ...    login_type=${login_type}

    ${response}=       POST On Session    user_login    /api/v1/auth/login    json=${body}    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}

    ${json_data}=    Convert String To Json    ${response.content}
    ${msg_list}=     Get Value From Json    ${json_data}    status.code
    ${msg}=          Get From List    ${msg_list}    0
    ${branch}=       Get Value From Json    ${json_data}    data.branch_code
    ${branchCode}=   Get From List    ${branch}    0
    ${name_list}=    Get Value From Json    ${json_data}    data.user_name
    ${user_name}=    Get From List    ${name_list}    0

    ${cookie_dict}=       Set Variable    ${response.cookies.get_dict()}
    ${access_token}=      Get From Dictionary    ${cookie_dict}    captix-access-token
    ${refresh_token}=     Get From Dictionary    ${cookie_dict}    captix-refresh-token
    ${cookies}=           Set Variable    captix-access-token=${access_token}; captix-refresh-token=${refresh_token}; user_id=${userId}; user_roles=${userRole}

    Log To Console    ${user_name}: Login ${msg}
    RETURN    ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${branchCode}

Logout
    [Documentation]    Calls the logout endpoint to invalidate the current session.
    [Arguments]    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     logout    url=${comServ_url}:${gateway_port}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=${cookies}
    ...    CAPTIX-CLIENT-ID=${client_Id}
    ...    CAPTIX-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${response}=       GET On Session    logout    /api/v1/auth/logout    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${expected_code}
    ${json_data}=      Convert String To Json    ${response.content}
    ${msg_list}=       Get Value From Json    ${json_data}    status.message
    ${msg}=            Get From List    ${msg_list}    0
    Log To Console     Logout: ${msg}
