*** Settings ***
# Resource     ../../keywords/common.robot
Resource     ../00_CommonKeyword.robot

*** Variables ***
#Partner-product configuration
${exp_date}          2026-07-15

#Application Registry
${app_code}        your-app-code-uuid
${api_key}         your-api-key-hex-64chars
${client_Id}       your-client-id

#Create_User
${userName}           your-username
${password}           your-password
${loginType}          AD
${email}              testuser@example.com
${user_Id}            ${15}
${application_Id}     9

#Create_Role
${roleName}           Test_Role
${role_Id}            ${5}

#Channel_Mapping
${decryp}           false
${rateLimit}        20
${periodSec}        10

#Create_Permission
${EXCEL_PATH}      ${CURDIR}\\dataDriven\\Auth_Permission.xlsx
${SHEET_NAME}      Sheet1  

*** Keywords ***
01_Partner_product_config_Reg
    [Documentation]    create partner product config using app_code
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     product_config     ${gateway_url}:${gateway_port}
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

    Log To Console     01_Partner_product_config_Reg: App code created successfully and API key, Client Id is fetched from database.
    RETURN     ${client_Id}     ${api_key}     ${app_code}  

02_Application Registry
    [Documentation]   Create application code using AuthService-app and get application id
    [Arguments]       ${app_code}
    ${Auth_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    application_registry   ${Auth_url}:${Auth_port}

    ${app_name}        FakerLibrary.Random Letter

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
    ${application_Id}   Convert To String    ${app_Id}
    # Log To Console      Application ID: ${application_Id}
    Log To Console      02_Application Registry, Application ID: ${application_Id}

    RETURN     ${application_Id}  

03_Create User
    [Documentation]     Create user using application id
    [Arguments]         ${application_Id}
    ${Auth_url}=        Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session      create_user     ${Auth_url}:${Auth_port}
    ${application_id}=    Create List    ${application_Id}

    ${body}    Create Dictionary
    ...        username=${userName}
    ...        password=${password}
    ...        status=${True}
    ...        email=${email}
    ...        application_id=${application_id}

    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      create_user     /api/v1/auth/user     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${id}              Get Value From Json       ${json_data}     data.user_id
    ${user_Id}         Get From List     ${id}     0
    # Log To Console     User ID: ${user_Id}
    Log To Console     03_Create User: UserId ${user_Id} created successfully.    

    RETURN     ${user_Id}

04_Create Role
    [Documentation]    Create role using User id
    [Arguments]        ${application_Id}
    ${Auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     create_role     ${Auth_url}:${Auth_port}

    ${body}    Create Dictionary
    ...        status=${True}
    ...        application_id=${application_Id}
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
    # Log To Console     Role ID: ${role_Id}
    # Log To Console     Role Name: ${roleName}
    Log To Console     04_Create Role: Role created successfully with role id ${role_Id} and role name ${roleName}.

    RETURN     ${role_Id}

05_Create Permission
    [Arguments]            ${application_Id}
    [Documentation]        Read data from excel and create channels dynamically
    ${Auth_url}=           Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session         create_permission      ${Auth_url}:${Auth_port}
    ${headers}             Create Dictionary      Content-Type=application/json

    Open Excel Document    ${EXCEL_PATH}    sheetname=${SHEET_NAME}
    ${api_names}=     Read Excel Column    1    sheet_name=${SHEET_NAME}       #permission_name is in column 0
    ${api_paths}=     Read Excel Column    2    sheet_name=${SHEET_NAME}       #resource_path is in column 1
    ${api_methods}=   Read Excel Column    3    sheet_name=${SHEET_NAME}       #http_method is in column 2

    ${name_count}      Get Length    ${api_names}
    ${path_count}      Get Length    ${api_paths}
    ${method_count}    Get Length    ${api_methods}
    Log To Console     permission_create count: ${path_count}

    ${permission_id's}=    Create List    #Creating a empty channel id list to store channel ids

        FOR    ${i}    IN RANGE    ${path_count}
            ${api_name}=      Get From List    ${api_names}      ${i}
            ${api_path}=      Get From List    ${api_paths}      ${i}
            ${api_method}=    Get From List    ${api_methods}    ${i}

            ${body}    Create Dictionary
            ...        application_id=${application_Id}
            ...        permission_name=${api_name}
            ...        resource_path=${api_path}
            ...        http_method=${api_method}

            # Log To Console     Payload: ${body}
            ${response}        POST On Session      create_permission     /api/v1/auth/permission     json=${body}     headers=${headers}
            ${status_code}=    Convert To String    ${response.status_code}
            Should Be Equal    ${status_code}       ${expected_code}
            ${json_data}       Convert String To Json    ${response.content}  
            ${Id}              Get Value From Json       ${json_data}     data.permissionId
            ${perm_Id}         Get From List         ${Id}          0

            Append To List     ${permission_id's}    ${perm_Id}
        END
        Log    Permission IDs: ${permission_id's}

        Log To Console    05_Create Permission: Permissions created successfully
        RETURN    ${permission_id's}

06_userRole_Mapping
    [Documentation]    Map role and user using their ids
    [Arguments]        ${role_Id}    ${user_Id}
    ${Auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_user_mapping     ${Auth_url}:${Auth_port}

    ${body}    Create Dictionary
    ...        role_id=${${role_Id}}
    ...        user_id=${${user_Id}}

    ${headers}         Create Dictionary    Content-Type=application/json
    ${response}        POST On Session      role_user_mapping     /api/v1/auth/mapping/user-role     json=${body}     headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}     
    ${message}         Get Value From Json       ${json_data}     status.message
    ${msg}             Get From List    ${message}    0
    Log to console     06_UserRole_Mapping: ${msg} for userId ${user_Id} and roleId ${role_Id}

07_permissionRole_Mapping
    [Arguments]        ${role_Id}     ${permission_id's}
    [Documentation]    Map permission and role using their ids
    ${Auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     permission_role_mapping     ${Auth_url}:${Auth_port}
    ${headers}         Create Dictionary    Content-Type=application/json
        
    # ${permission_id's}    Create List    300    301    302    303    304    305    306    307    308    309
    # ...                   310    311    312    313    314    315    316    317    318    319
    # ...                   320    321    322    323    324    325    326    327    328    329
    # ...                   330    331    332    333    334    335    336    337    338    339
    # ...                   340    341    342    343    344    345    346    347    348    349
    # ...                   350    351    352    353    354    355   #List of permission ids to be mapped with role

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
            ${msg}             Get From List             ${message}        0
        END
        Log To Console    07_permissionRole_Mapping: ${msg} for all permissions

08__Channel_Mapping_Reg
    [Arguments]        ${app_code}
    [Documentation]    channel-mapping rate limit check
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     product_config         ${gateway_url}:${gateway_port}

    ${channel_ids}    Create List
    # ...    1    2    3    4    5    7    8    9    10    13
    # ...    14    15    16    18    19    21    22    24    25    27
    # ...    28    29    30    31    32    33    34    35    36    37
    # ...    38    39    40    41    42    43    44    45    46    47
    # ...    48    49    50    51    52    53    54    55    56    57
    # ...    58    26    17    12    23    11    20    59    60    61
    # ...    62    63    64    65    66    67    68    69    70    71
    # ...    72    73    74    75    76    77    78    79    80    81
    # ...    82    83    84    85    87    88    89    90    91    92
    # ...    93    94    95    96    99    100    6    108    102    103
    # ...    104   105    106    101    117    86    114    112    113    116
    # ...    98    115    118    119    107    120    121    122    123    124
    # ...    97    125    126    129    138    127    128    171    157    165
    # ...    166   167    168    170    176    177

    FOR    ${channel_id}    IN    @{channel_ids}
        ${body}    Create Dictionary
        ...        api_channel_id=${channel_id}
        ...        app_code=${app_code}
        ...        decryption_enabled=${decryp}
        ...        rate_limit=${rateLimit}
        ...        period_seconds=${periodSec}

        ${headers}         Create Dictionary    Content-Type=application/json
        ${response}        POST On Session      product_config     /api/v1/gateway/channel-mapping     json=${body}     headers=${headers}
        ${status_code}=    Convert To String    ${response.status_code}
        Should Be Equal    ${status_code}       ${expected_code}

        ${json_data}          Convert String To Json    ${response.content}     
        ${id}                 Get Value From Json     ${json_data}     data.api_channel_mapping_id
        ${channelMap_id}      Get From List     ${id}     0
    
        ${limit}              Get Value From Json     ${json_data}     data.rate_limit
        ${rateLimit}          Get From List     ${limit}     0
    END
    Log To Console     08_Channel_Mapping_Reg: Channel mapping created successfully for all channels with rate limit ${rateLimit}.

09_Login as user
    [Arguments]        ${app_code}     ${client_Id}     ${api_key}    
    [Documentation]    Auth login test to verify the created user
    # ${login_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    # Create Session     auth_login     url= ${login_url}:${login_port}
    
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

    Set Test Message     message=${userName} login successful and requested permissions are mapped successfully👍.

    RETURN     ${cookies}     ${client_Id}     ${api_key}     ${app_code}

10_Logout user
    [Arguments]     ${cookies}     ${client_Id}     ${api_key}     ${app_code}
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
    ${msg}             Get From List          ${status_msg}    0 
    Log To Console    ${userName}: ${msg}  
    
*** Test Cases ***
NewUser_Role_Permission_Mapping
    [Documentation]    Test case to verify AuthService user, role and permission mapping using ap
    ${client_id}     ${api_key}    ${app_code}    01_Partner_product_config_Reg
    ${application_Id}     02_Application Registry    ${app_code}
    ${user_Id}    03_Create User    ${application_Id}
    ${role_Id}    04_Create Role    ${application_Id}
    ${permission_id's}     05_Create Permission    ${application_Id}
    06_userRole_Mapping    ${role_Id}    ${user_Id}
    07_permissionRole_Mapping     ${role_Id}    ${permission_id's}
    08__Channel_Mapping_Reg    ${app_code}
    Refresh
    Refresh_route  
    Sleep    10s  
    ${cookies}     ${client_Id}     ${api_key}     ${app_code}    09_Login as user    ${app_code}     ${client_Id}     ${api_key}
    10_Logout user      ${cookies}    ${client_Id}     ${api_key}     ${app_code}
   

    