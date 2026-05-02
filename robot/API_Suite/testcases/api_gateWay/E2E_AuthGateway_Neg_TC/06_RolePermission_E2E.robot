*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# Valid data - adjust to a known valid application_id in your system
${valid_application_id}           1
${nonexistent_application_id}     999999
${nonexistent_role_id}            999999
${invalid_http_method}            FETCH
${valid_http_methods}             GET    POST    PUT    DELETE    PATCH
${created_role_id}                1
# Role ID expected to be assigned to a user — adjust to a known mapped role in the test environment
${role_id_with_user_mapping}      1

*** Test Cases ***
# NEGATIVE TEST CASES - ROLE
# ============================================================

TC_09_NEG_Create_Role_Missing_Role_Name
    [Documentation]    Verify that creating a role without role_name returns 400 Bad Request
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_09     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    application_id=${valid_application_id}
    ${response}=       POST On Session    role_neg_09    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_09 PASS: Got 400 for missing role_name

TC_10_NEG_Create_Role_With_NonExistent_Application_ID
    [Documentation]    Verify that creating a role with non-existent application_id returns error
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_10     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    application_id=${nonexistent_application_id}
    ...    role_name=neg_nonexistent_app_role
    ${response}=       POST On Session    role_neg_10    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_10 PASS: Got error ${status_code} for non-existent application_id

TC_11_NEG_Create_Duplicate_Role_Name
    [Documentation]    Verify that creating two roles with the same name returns error (400/409)
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_11     ${auth_url}:${Auth_port}
    ${dup_role_name}=  Set Variable    e2e_duplicate_role_test
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    application_id=${valid_application_id}
    ...    role_name=${dup_role_name}
    # First creation
    POST On Session    role_neg_11    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate creation
    ${response}=       POST On Session    role_neg_11    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_11 PASS: Got error ${status_code} for duplicate role_name=${dup_role_name}

TC_12_NEG_Create_Role_Missing_Application_ID
    [Documentation]    Verify that creating a role without application_id returns 400 Bad Request
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_12     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    role_name=neg_no_appid_role
    ${response}=       POST On Session    role_neg_12    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_12 PASS: Got 400 for missing application_id

TC_13_NEG_Create_Permission_Missing_Permission_Name
    [Documentation]    Verify that creating a permission without permission_name returns 400
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_13     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${valid_application_id}
    ...    resource_path=/api/v1/neg/no-name
    ...    http_method=GET
    ${response}=       POST On Session    perm_neg_13    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_13 PASS: Got 400 for missing permission_name

TC_14_NEG_Create_Permission_Missing_Resource_Path
    [Documentation]    Verify that creating a permission without resource_path returns 400
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_14     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${valid_application_id}
    ...    permission_name=neg_no_path_permission
    ...    http_method=GET
    ${response}=       POST On Session    perm_neg_14    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_14 PASS: Got 400 for missing resource_path

TC_15_NEG_Create_Permission_With_Invalid_HTTP_Method
    [Documentation]    Verify that creating a permission with an unsupported HTTP method returns 400
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_15     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${valid_application_id}
    ...    permission_name=neg_invalid_method_perm
    ...    resource_path=/api/v1/neg/invalid-method
    ...    http_method=${invalid_http_method}
    ${response}=       POST On Session    perm_neg_15    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_15 PASS: Got 400 for invalid http_method=${invalid_http_method}

TC_16_NEG_Create_Permission_Missing_HTTP_Method
    [Documentation]    Verify that creating a permission without http_method returns 400
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_16     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${valid_application_id}
    ...    permission_name=neg_no_method_perm
    ...    resource_path=/api/v1/neg/no-method
    ${response}=       POST On Session    perm_neg_16    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_16 PASS: Got 400 for missing http_method

TC_17_NEG_UserRole_Mapping_With_NonExistent_Role_ID
    [Documentation]    Verify that mapping user to a non-existent role_id returns error
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     urm_neg_17     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${nonexistent_role_id}
    ...    user_id=${1}
    ${response}=       POST On Session    urm_neg_17    /api/v1/auth/mapping/user-role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_17 PASS: Got error ${status_code} for non-existent role_id=${nonexistent_role_id}

TC_18_NEG_RolePermission_Mapping_Missing_Permission_ID
    [Documentation]    Verify that role-permission mapping without permission_id returns 400
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     rpm_neg_18     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${${created_role_id}}
    ${response}=       POST On Session    rpm_neg_18    /api/v1/auth/mapping/role-permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_18 PASS: Got 400 for missing permission_id in role-permission mapping

TC_19_NEG_UserRole_Mapping_With_NonExistent_User_ID
    [Documentation]    Verify that mapping a non-existent user_id to a valid role returns error
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     urm_neg_19     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${${created_role_id}}
    ...    user_id=${nonexistent_role_id}
    ${response}=       POST On Session    urm_neg_19    /api/v1/auth/mapping/user-role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_19 PASS: Got error ${status_code} for user-role mapping with non-existent user_id=${nonexistent_role_id}

TC_20_NEG_UserRole_Mapping_Missing_User_ID_Field
    [Documentation]    Verify that user-role mapping without user_id field returns 400 Bad Request
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     urm_neg_20     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${${created_role_id}}
    ${response}=       POST On Session    urm_neg_20    /api/v1/auth/mapping/user-role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_20 PASS: Got 400 for user-role mapping without user_id field

TC_21_NEG_RolePermission_Mapping_Missing_Role_ID_Field
    [Documentation]    Verify that role-permission mapping without role_id field returns 400 Bad Request
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     rpm_neg_21     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    permission_id=${1}
    ${response}=       POST On Session    rpm_neg_21    /api/v1/auth/mapping/role-permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_21 PASS: Got 400 for role-permission mapping without role_id field

TC_22_NEG_RolePermission_Mapping_NonExistent_Permission_ID
    [Documentation]    Verify that mapping a valid role to a non-existent permission_id returns error
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     rpm_neg_22     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${${created_role_id}}
    ...    permission_id=${nonexistent_role_id}
    ${response}=       POST On Session    rpm_neg_22    /api/v1/auth/mapping/role-permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_22 PASS: Got error ${status_code} for role-permission mapping with non-existent permission_id=${nonexistent_role_id}

TC_23_NEG_Create_Duplicate_Permission_Name
    [Documentation]    Verify that creating two permissions with the same name in the same application returns error (400/409)
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_23     ${auth_url}:${Auth_port}
    ${dup_perm_name}=  Set Variable    e2e_duplicate_permission_neg_test
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${valid_application_id}
    ...    permission_name=${dup_perm_name}
    ...    resource_path=/api/v1/neg/dup-perm-test
    ...    http_method=GET
    # First creation
    POST On Session    perm_neg_23    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate creation — same name, same application
    ${response}=       POST On Session    perm_neg_23    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_23 PASS: Got error ${status_code} for duplicate permission_name=${dup_perm_name}

TC_24_NEG_UserRole_Mapping_Duplicate
    [Documentation]    Verify that mapping the same user to the same role a second time returns an error (duplicate mapping)
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     urm_neg_24     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${${created_role_id}}
    ...    user_id=${1}
    # First mapping
    POST On Session    urm_neg_24    /api/v1/auth/mapping/user-role    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate mapping — exact same user_id + role_id
    ${response}=       POST On Session    urm_neg_24    /api/v1/auth/mapping/user-role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_24 PASS: Got error ${status_code} for duplicate user-role mapping (user_id=1, role_id=${created_role_id})

TC_25_NEG_RolePermission_Mapping_Duplicate
    [Documentation]    Verify that mapping the same permission to the same role a second time returns an error (duplicate mapping)
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     rpm_neg_25     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    role_id=${${created_role_id}}
    ...    permission_id=${1}
    # First mapping
    POST On Session    rpm_neg_25    /api/v1/auth/mapping/role-permission    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate mapping — exact same role_id + permission_id
    ${response}=       POST On Session    rpm_neg_25    /api/v1/auth/mapping/role-permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_25 PASS: Got error ${status_code} for duplicate role-permission mapping (role_id=${created_role_id}, permission_id=1)

TC_26_NEG_Create_Role_With_Empty_Role_Name
    [Documentation]    Verify that creating a role with an empty role_name string returns 400 Bad Request
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_26     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    application_id=${valid_application_id}
    ...    role_name=${EMPTY}
    ${response}=       POST On Session    role_neg_26    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_26 PASS: Got 400 for empty role_name

TC_27_NEG_Create_Permission_With_NonExistent_Application_ID
    [Documentation]    Verify that creating a permission with a non-existent application_id returns error
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_27     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${nonexistent_application_id}
    ...    permission_name=neg_nonexistent_app_permission
    ...    resource_path=/api/v1/neg/nonexistent-app-perm
    ...    http_method=GET
    ${response}=       POST On Session    perm_neg_27    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_27 PASS: Got error ${status_code} for permission with non-existent application_id=${nonexistent_application_id}

TC_28_NEG_Update_Role_With_NonExistent_Role_ID
    [Documentation]    Verify that updating a role using a non-existent role_id returns error (404)
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_28     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    role_id=${nonexistent_role_id}
    ...    application_id=${valid_application_id}
    ...    role_name=neg_nonexistent_role_update
    ${response}=       PUT On Session    role_neg_28    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_28 PASS: Got error ${status_code} for update with non-existent role_id=${nonexistent_role_id}

TC_29_NEG_UserRole_Mapping_Both_IDs_Missing
    [Documentation]    Verify that submitting a user-role mapping with both role_id and user_id absent returns 400
    [Tags]    negative    mapping    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     urm_neg_29     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ${response}=       POST On Session    urm_neg_29    /api/v1/auth/mapping/user-role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_29 PASS: Got 400 for user-role mapping with empty body (both IDs missing)

TC_30_NEG_Create_Permission_With_Empty_Resource_Path
    [Documentation]    Verify that creating a permission with an empty string resource_path returns 400 Bad Request.
    ...                The resource_path field is required for AntPathMatcher permission validation in
    ...                xxxLoginImpl.permissionValidation(); an empty path is meaningless and must be rejected.
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_30     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    application_id=${valid_application_id}
    ...    permission_name=neg_empty_path_permission
    ...    resource_path=${EMPTY}
    ...    http_method=GET
    ${response}=       POST On Session    perm_neg_30    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_30 PASS: Got 400 for empty resource_path in permission

TC_31_NEG_Create_Permission_Missing_Application_ID
    [Documentation]    Verify that creating a permission without application_id returns 400 Bad Request.
    ...                PermissionServiceImpl validates the application association; missing applicationId
    ...                causes IllegalStateException("Please Provide Valid ApplicationId").
    [Tags]    negative    permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     perm_neg_31     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    permission_name=neg_no_appid_permission
    ...    resource_path=/api/v1/neg/no-appid
    ...    http_method=GET
    ${response}=       POST On Session    perm_neg_31    /api/v1/auth/permission    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_31 PASS: Got 400 for missing application_id in permission creation

TC_32_NEG_Delete_Role_With_NonExistent_Role_ID
    [Documentation]    Verify that deleting a role with a non-existent role_id returns error.
    ...                RoleServiceImpl.deleterole() throws IllegalStateException("role Id not present")
    ...                when rolesRepository.existsById(roleId) returns false.
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_32     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    role_neg_32    /api/v1/auth/role/${nonexistent_role_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_32 PASS: Got error ${status_code} for DELETE role with non-existent role_id=${nonexistent_role_id}

TC_33_NEG_Delete_Role_Assigned_To_User
    [Documentation]    Verify that deleting a role that is assigned to at least one user returns error.
    ...                RoleServiceImpl.deleterole() checks userRoleMappingRepository.existsByRoles_id(roleId)
    ...                and throws NoSuchElementException("Roles assigned to user") → ResponseStatus.ERROR.
    ...                Uses role_id=${role_id_with_user_mapping} assumed to be mapped to users.
    [Tags]    negative    role    validation    referential-integrity
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_33     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    role_neg_33    /api/v1/auth/role/${role_id_with_user_mapping}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_33 PASS: Got error ${status_code} for DELETE role with active user mapping (role_id=${role_id_with_user_mapping})

TC_34_NEG_Get_Role_By_NonExistent_Role_ID
    [Documentation]    Verify that fetching a role by a non-existent role_id returns error.
    ...                RoleServiceImpl.getrole() calls rolesRepository.findById(id).orElseThrow()
    ...                which throws IllegalStateException("Please Provide Valid RoleId").
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_34     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    role_neg_34    /api/v1/auth/role/${nonexistent_role_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_34 PASS: Got error ${status_code} for GET role with non-existent role_id=${nonexistent_role_id}

TC_35_NEG_Get_Application_Roles_For_NonExistent_Application_ID
    [Documentation]    Verify that fetching roles for a non-existent application_id returns error.
    ...                RoleServiceImpl.getApplicationRole() calls
    ...                rolesRepository.findByApplicationRegistry_Id(applicationId).orElseThrow()
    ...                which throws NoSuchElementException → ResponseStatus.NO_RESOURCE_FOUND.
    [Tags]    negative    role    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_35     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    role_neg_35    /api/v1/auth/role/application/${nonexistent_application_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_35 PASS: Got error ${status_code} for GET application roles with non-existent application_id=${nonexistent_application_id}

TC_36_NEG_Update_Role_Assigned_To_User_With_Different_Application
    [Documentation]    Verify that updating a role's application_id when the role is already assigned to users returns error.
    ...                RoleServiceImpl.updaterole() checks userRoleMappingRepository.existsByRoles_id(roleId)
    ...                and throws NoSuchElementException("Role Assigned With Particular User and Application")
    ...                when applicationId is provided and the role already has user mappings.
    [Tags]    negative    role    validation    referential-integrity
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     role_neg_36     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    role_id=${role_id_with_user_mapping}
    ...    application_id=${valid_application_id}
    ...    role_name=neg_reassign_mapped_role
    ${response}=       PUT On Session    role_neg_36    /api/v1/auth/role    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_36 PASS: Got error ${status_code} for UPDATE role that has active user mapping (role_id=${role_id_with_user_mapping})
