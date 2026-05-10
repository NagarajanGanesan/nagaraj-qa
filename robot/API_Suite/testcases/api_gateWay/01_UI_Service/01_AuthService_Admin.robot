*** Settings ***
# Resource     ../../../../keywords/common.robot
Resource     ../00_CommonKeyword.robot

*** Variables ***
#Partner-product configuration
${appcode_Status}   true

#Variable for individual run
# ${service_count}    
${decryp}           False
${rateLimit}        20
${periodSec}        10

#Application_Registry
${app_code}        your-app-code-uuid
${api_key}         your-api-key-hex-64chars
${client_Id}       your-client-id
${loginType}       AD
${app_name}        Auth_Test_App
# ${app_Id}          1

#Create_User
${userName}        Test
${password}        test@1234
${email}           your_email
${user_Id}         ${1}

#Create_Role
${roleName}        Test_Role
${app_Id}          9
${role_Id}         ${1}

#Create_Permission
${EXCEL_PATH}      ${CURDIR}\\dataDriven\\Master_Channel.xlsx
${SHEET_NAME}      Sheet1

${channel_id's count}     147

*** Keywords ***
01_Read Data and Create Channels
    [Documentation]    Read data from excel and create channels dynamically
    # ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    # Create Session     create_channel         ${gateway_url}:${gateway_port}    verify=true
    Create Session     create_channel         ${URL}    verify=true
    ${headers}=        Create Dictionary      Content-Type=application/json
    Open Excel Document    ${EXCEL_PATH}      sheetname=${SHEET_NAME}
    ${service_ids}=   Read Excel Column    1    sheet_name=${SHEET_NAME}   #service_id is in column 0
    ${api_names}=     Read Excel Column    2    sheet_name=${SHEET_NAME}   #api_name is in column 1
    ${api_paths}=     Read Excel Column    3    sheet_name=${SHEET_NAME}   #api_path is in column 2
    ${api_methods}=   Read Excel Column    4    sheet_name=${SHEET_NAME}   #api_method is in column 3

    ${service_count}   Get Length    ${service_ids}
    ${name_count}      Get Length    ${api_names}
    ${path_count}      Get Length    ${api_paths}
    ${method_count}    Get Length    ${api_methods}
    Log To Console     Total Service ID: ${service_count}

    ${channel_id's}=    Create List    #Creating a empty channel id list to store channel ids

        FOR    ${i}    IN RANGE    ${service_count}
            ${service_id}=    Get From List    ${service_ids}    ${i}
            ${api_name}=      Get From List    ${api_names}      ${i}
            ${api_path}=      Get From List    ${api_paths}      ${i}
            ${api_method}=    Get From List    ${api_methods}    ${i}
            # Log To Console    API Name: ${api_name}, API Path: ${api_path}, API Method: ${api_method}

            ${payload}=    Create Dictionary
            ...    description=Automation Test
            ...    service_id=${service_id}
            ...    api_channel_name=${api_name}
            ...    api_channel_path=${api_path}
            ...    api_channel_method=${api_method}

            ${response}=       Post On Session      create_channel    /api/v1/gateway/channel    json=${payload}    headers=${headers}
            ${status_code}=    Convert To String    ${response.status_code}
            Should Be Equal    ${status_code}       ${expected_code}
            ${json_data}       Convert String To Json    ${response.content}
            ${id}              Get Value From Json     ${json_data}     data.api_channel_id
            ${channel_id}      Get From List     ${id}     0
            ${name}            Get Value From Json     ${json_data}     data.api_channel_name   
            ${channelName}     Get From List     ${name}     0

            Append To List    ${channel_id's}    ${channel_id}
        END

    Close Current Excel Document

    # ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    # Connect To Database    psycopg2     ${db.name}     ${db.Username}     ${db.Password}     ${db.Host}     ${db.Port}    None    
    # ${channel_id's}     Query     SELECT id FROM ${schemeName}.api_channels;
    ${channel_id's count}   Get Length   ${channel_id's}
    Set Suite Variable    ${channel_id's count}
    Set Suite Variable    ${service_count}
    Set Suite Variable    ${channel_id's}

    Log    Channel IDs: ${channel_id's}
    
    RETURN    ${payload}     ${channel_id's}    ${channel_id's count}

02_Partner_product_config_Reg
    [Documentation]    create partner product config using app_code
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     product_config     ${gateway_url}:${gateway_port}
    ${exp_date}     Compute Expiry Date
    ${body}    Create Dictionary
    ...        app_code_creation=${True}
    ...        expiry_date=${exp_date}
    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      product_config     /api/v1/gateway/partner-product-config     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${code}            Get Value From Json       ${json_data}     data
    ${get_appCode}     Get From List     ${code}     0
    ${app_code}=       Fetch From Right    ${get_appCode}    appCode:${SPACE}

    Log To Console     App Code: ${app_code}
    
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2     ${db.name}     ${db.Username}     ${db.Password}     ${db.Host}     ${db.Port}    None
    ${access_token}     Query     SELECT api_key, client_id FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code}'; 

    ${key&Id}      Get From List     ${access_token}    0
    ${api_key}     Get From List     ${key&Id}          0
    ${client_Id}   Get From List     ${key&Id}          1
    Log  clientId: ${client_Id}     
    Set Suite Variable    ${api_key}
    Set Suite Variable    ${client_Id}
    Disconnect From Database

    RETURN     ${client_Id}     ${api_key}    ${app_code}

03_Channel_Mapping_Reg
    [Arguments]        ${channel_id's count}    ${app_code}     ${channel_id's}
    [Documentation]    channel-mapping rate limit check
    Create Session      create_channelMap         ${URL}    verify=true

    ${channelMap_ids}     Create List       #Creating empty list to store channel mapping ids

        FOR    ${i}    IN RANGE    ${channel_id's count}
            ${channel_id}    Get From List      ${channel_id's}    ${i}

            ${body}    Create Dictionary
            ...        api_channel_id=${channel_id}
            ...        app_code=${app_code}
            ...        decryption_enabled=${decryp}
            ...        rate_limit=${rateLimit}
            ...        period_seconds=${periodSec}
            ${headers}         Create Dictionary    Content-Type=application/json
            ${response}        POST On Session      create_channelMap     /api/v1/gateway/channel-mapping     json=${body}     headers=${headers}
            ${status_code}=    Convert To String    ${response.status_code}
            Should Be Equal    ${status_code}       ${expected_code}

            ${json_data}          Convert String To Json    ${response.content}     
            ${id}                 Get Value From Json     ${json_data}     data.api_channel_mapping_id
            ${channelMap_id}      Get From List     ${id}     0
            
            ${limit}              Get Value From Json     ${json_data}     data.rate_limit
            ${rateLimit}          Get From List     ${limit}     0

            Append To List    ${channelMap_ids}    ${channelMap_id}
        END

        Log    Channel Mapping IDs: ${channelMap_ids}
        Log To Console     03_Channel_Mapping_Reg: Channel mapping created successfully for all channels with rate limit ${rateLimit}.

04_Application Registry
    [Documentation]   Create application code using AuthService-app and get application id
    [Arguments]       ${app_code}
    ${Auth_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    application_registry     ${Auth_url}:${Auth_port}
    # ${app_name}     FakerLibrary.Generate Random Bank Name

    ${body}    Create Dictionary
    ...        status=${True}
    ...        app_name=${app_name}
    ...        app_code=${app_code}
    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      application_registry     /api/v1/auth/application     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${id}              Get Value From Json       ${json_data}     data.application_id
    ${app_Id}          Get From List     ${id}     0
    Log To Console     04_Application Registry, Application ID: ${app_Id}

    RETURN     ${app_Id}

05_Create User
    [Documentation]    Create user using application id
    [Arguments]        ${app_Id}
    ${Auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     create_user     ${Auth_url}:${Auth_port}
    ${application_id}=    Create List    ${app_Id}

    ${body}    Create Dictionary
    ...        username=${userName}
    ...        password=${password}
    ...        status=${True}
    ...        email=${email}
    ...        application_id=${application_id}
    ...        employee_name=${userName}_01
    # ...        branch_code=

    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      create_user     /api/v1/auth/user     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${id}              Get Value From Json       ${json_data}     data.user_id
    ${user_Id}         Get From List     ${id}     0
    Log To Console     05_Create User: UserId ${user_Id} created successfully. 

    RETURN     ${user_Id}

06_Create Role
    [Documentation]    Create role using User id
    [Arguments]        ${app_Id}
    ${Auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     create_role     ${Auth_url}:${Auth_port}
    ${app_id_list}=    Create List    ${user_Id}

    ${body}    Create Dictionary
    ...        status=${True}
    ...        application_id=${app_Id}
    ...        role_name=${roleName}

    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      create_role     /api/v1/auth/role     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${id}              Get Value From Json       ${json_data}     data.role_id
    ${role_Id}         Get From List     ${id}     0
    ${name}            Get Value From Json       ${json_data}     data.role_name
    ${roleName}=       Get From List     ${name}     0
    Log To Console     06_Create Role: Role created successfully with role id ${role_Id} and role name ${roleName}.

    RETURN     ${role_Id}

07_Create Permission
    [Arguments]            ${app_Id}
    [Documentation]        Read data from excel and create channels dynamically
    ${Auth_url}=           Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session         create_permission     ${Auth_url}:${Auth_port}
    ${headers}             Create Dictionary    Content-Type=application/json

    #Database Connection and get details for Json payload
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2     ${db.name}     ${db.Username}     ${db.Password}     ${db.Host}     ${db.Port}    None    
    ${channel_table}       Query     SELECT count(*) FROM ${schemeName}.api_channels;
    ${id}                  Evaluate    [item[0] for item in ${channel_table}]
    ${id_count}            Get From List    ${id}    0
    Log To Console         Total Channel_Id to Permission: ${id_count}

    ${name}      Query     SELECT api_channel_name FROM ${schemeName}.api_channels;
    ${chan_name}=    Evaluate    [item[0] for item in ${name}]

    ${path}    Query     SELECT api_channel_path FROM ${schemeName}.api_channels;
    ${chan_path}=    Evaluate    [item[0] for item in ${path}]

    ${method}    Query     SELECT api_channel_method FROM ${schemeName}.api_channels;
    ${chan_method}=    Evaluate    [item[0] for item in ${method}]
    Disconnect From Database

    ${permission_id's}=    Create List

        FOR    ${i}    IN RANGE    ${id_count}

            ${api_name}      Get From List    ${chan_name}    ${i}     #Channel Names By index from DB
            # Log To Console   Channel Name ${i}: ${api_name}

            ${api_path}      Get From List    ${chan_path}    ${i}     #Api Path By index from DB
            # Log To Console   Channel Name ${i}: ${api_path}

            ${api_method}    Get From List    ${chan_method}    ${i}   #Api Method By index from DB
            # Log To Console   Channel Name ${i}: ${api_method}

            ${body}    Create Dictionary
            ...        application_id=${app_Id}
            ...        permission_name=${api_name}
            ...        resource_path=${api_path}
            ...        http_method=${api_method}

            # Log To Console     Payload: ${body}
            ${response}        POST On Session      create_permission     /api/v1/auth/permission     json=${body}     headers=${headers}
            ${status_code}=    Convert To String    ${response.status_code}
            Should Be Equal    ${status_code}       ${expected_code}
            ${json_data}       Convert String To Json    ${response.content}  
            ${Id}              Get Value From Json       ${json_data}     data.permissionId
            ${perm_Id}         Get From List     ${Id}     0

            Append To List     ${permission_id's}    ${perm_Id}
        END
        Log    Permission IDs: ${permission_id's}
        Log To Console    07_Create Permission: Permissions created successfully
        RETURN    ${permission_id's}

08_userRole_Mapping
    [Documentation]    Map role and user using their ids
    [Arguments]        ${role_Id}    ${user_Id}
    ${Auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_user_mapping     ${Auth_url}:${Auth_port}

    Convert To Integer     ${role_Id}
    Convert To Integer     ${user_Id}

    ${body}    Create Dictionary
    ...        role_id=${${role_Id}}
    ...        user_id=${${user_Id}}

    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      role_user_mapping     /api/v1/auth/mapping/user-role     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${message}         Get Value From Json       ${json_data}     status.message
    ${msg}             Get From List             ${message}       0
    Log to console     08_UserRole_Mapping: ${msg} for userId ${user_Id} and roleId ${role_Id}

09_permissionRole_Mapping
    [Arguments]        ${role_Id}    ${permission_id's}
    [Documentation]    Map permission and role using their ids
    ${Auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     permission_role_mapping     ${Auth_url}:${Auth_port}
    ${headers}         Create Dictionary    Content-Type=application/json
        ${permissionId_count}     Get Length    ${permission_id's}

        FOR    ${i}    IN RANGE    ${permissionId_count}
            
            ${permission_Id}    Get From List      ${permission_id's}    ${i}

            ${body}    Create Dictionary

            ...        role_id=${${role_Id}}
            ...        permission_id=${${permission_Id}}

            ${response}        POST On Session      permission_role_mapping     /api/v1/auth/mapping/role-permission     json=${body}     headers=${headers}
            ${status_code}=    Convert To String    ${response.status_code}
            Should Be Equal    ${status_code}       ${expected_code}
            ${json_data}       Convert String To Json    ${response.content}     
            ${message}         Get Value From Json       ${json_data}     status.message
            ${msg}             Get From List             ${message}    0
        END
        Log To Console    09_permissionRole_Mapping: ${msg} for all permissions

10_Login as Admin
     [Arguments]        ${app_code}     ${client_Id}     ${api_key}    
    [Documentation]    Auth login test to verify the created user
    ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     auth_login     url= ${login_url}:${login_port}
    ${headers}         Create Dictionary    Content-Type=application/json     
    ...    app-code=${app_code}
    ...    xxx-CLIENT-ID=${client_Id}     
    ...    xxx-API-KEY=${api_key}   

    ${body}    Create Dictionary
    ...        username=${userName}
    ...        userpassword=${password}
    ...        login_type=${loginType}

    ${response}        POST On Session      auth_login     /api/v1/auth/login     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${message}         Get Value From Json       ${json_data}     status.code
    ${msg}             Get From List    ${message}    0    
    Log To Console     ${userName}: ${msg}

    ${cookies}=          Set Variable    ${response.cookies.get_dict()}
    ${access_token}=     Get From Dictionary    ${cookies}    xxx-access-token
    ${refresh_token}=    Get From Dictionary    ${cookies}    xxx-refresh-token

    Log    ${access_token}
    Log    ${refresh_token}

    ${cookies}    Set Variable    xxx-access-token=${access_token}; xxx-refresh-token=${refresh_token}; user_id=${userId}; user_roles=${role_Id} 

    Set Test Message     message=${userName} user login successful and all permissions are mapped successfully🙂.

    RETURN     ${cookies}     ${client_Id}     ${api_key}     ${app_code}

11_Logout Admin
    [Arguments]          ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    [Documentation]       User_logout
    ${gateway_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session        logout     url= ${gateway_url}:${gateway_port}
    ${headers}            Create Dictionary    Content-Type=application/json
        ...    Cookie=${cookies}
        ...    xxx-client-id=${client_Id}     
        ...    xxx-api-key=${api_key}     
        ...    app-code=${app_code}
    ${response}        GET On Session        logout     /api/v1/auth/logout     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}
    ${status_msg}      Get Value From Json    ${json_data}    status.message
    ${msg}     Get From List    ${status_msg}    0 
    Log To Console    ${userName}: ${msg}  
     
*** Test Cases ***
AdminAccess_AuthService_Regression
    ${payload}    ${channel_id's}    ${channel_id's count}    01_Read Data and Create Channels
    ${client_Id}     ${api_key}    ${app_code}    02_Partner_product_config_Reg
    03_Channel_Mapping_Reg       ${channel_id's count}    ${app_code}     ${channel_id's}
    Refresh
    Refresh_route
    ${app_Id}     04_Application Registry    ${app_code}
    ${user_Id}    05_Create User    ${app_Id}
    ${role_Id}    06_Create Role    ${app_Id}
    ${permission_id's}    07_Create Permission    ${app_Id}
    08_userRole_Mapping    ${role_Id}    ${user_Id}
    09_permissionRole_Mapping    ${role_Id}    ${permission_id's}
    Refresh
    Refresh_route
    ${cookies}     ${client_Id}     ${api_key}     ${app_code}    10_Login as Admin    ${app_code}     ${client_Id}     ${api_key}
    11_Logout Admin      ${cookies}    ${client_Id}     ${api_key}     ${app_code}
