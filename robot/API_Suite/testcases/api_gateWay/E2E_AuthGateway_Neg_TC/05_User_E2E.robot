*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# Valid data - adjust application_id to a known valid one in your system
${valid_application_id}        1
${nonexistent_application_id}  999999
${invalid_email}               not-a-valid-email
${nonexistent_user_id}         999999
${employee_name}               Test.Employee
${invalid_employee_name}       @!@#$%^&*()
# User ID expected to have active role mappings — adjust to a known mapped user in the test environment
${user_id_with_role_mapping}   1
${duplicate_mobile_number}     9876543210

*** Test Cases ***
# NEGATIVE TEST CASES
# ============================================================

TC_08_NEG_Create_User_Missing_Username
    [Documentation]    Verify that creating a user without username returns 400 Bad Request
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_08     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    password=Test@1234
    ...    status=${True}
    ...    email=neg.missing.user@test.com
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_08    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_08 PASS: Got 400 for missing username

TC_09_NEG_Create_User_Missing_Password
    [Documentation]    Verify that creating a user without password returns 400 Bad Request
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_09     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=neg_no_password_user
    ...    status=${True}
    ...    email=neg.nopwd@test.com
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_09    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_09 PASS: Got 400 for missing password

TC_10_NEG_Create_User_With_Invalid_Email_Format
    [Documentation]    Verify that creating a user with an invalid email format returns 400 Bad Request
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_10     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=neg_invalid_email_user
    ...    password=Test@1234
    ...    status=${True}
    ...    email=${invalid_email}
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_10    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for invalid email format=${invalid_email}

TC_11_NEG_Create_User_With_NonExistent_Application_ID
    [Documentation]    Verify that creating a user with a non-existent application_id returns error
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_11     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${nonexistent_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=neg_nonexistent_appid_user
    ...    password=Test@1234
    ...    status=${True}
    ...    email=neg.nonexistapp@test.com
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_11    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_11 PASS: Got error ${status_code} for non-existent application_id=${nonexistent_application_id}

TC_12_NEG_Create_Duplicate_Username
    [Documentation]    Verify that creating two users with the same username returns error (400/409)
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_12     ${auth_url}:${Auth_port}
    ${dup_username}=   Set Variable    e2e_duplicate_user_test
    ${application_id}=     Create List    ${valid_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=${dup_username}
    ...    password=Test@1234
    ...    status=${True}
    ...    email=dup.user@test.com
    ...    application_id=${application_id}
    # First creation
    POST On Session    usr_neg_12    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate creation
    ${response}=       POST On Session    usr_neg_12    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_12 PASS: Got error ${status_code} for duplicate username=${dup_username}

TC_13_NEG_Create_User_Missing_Application_ID
    [Documentation]    Verify that creating a user without application_id returns 400 Bad Request
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_13     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=neg_no_appid_user
    ...    password=Test@1234
    ...    status=${True}
    ...    email=neg.noapp@test.com
    ${response}=       POST On Session    usr_neg_13    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_13 PASS: Got 400 for missing application_id

TC_14_NEG_Update_User_With_NonExistent_User_ID
    [Documentation]    Verify that updating a user with a non-existent user_id returns error
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_14     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=neg_nonexistent_update
    ...    user_id=${nonexistent_user_id}
    ...    employee_name=${employee_name}
    ...    password=Test@1234
    ...    status=${True}
    ...    application_id=${application_id}
    ${response}=       PUT On Session    usr_neg_14    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_14 PASS: Got error ${status_code} for update with non-existent user_id=${nonexistent_user_id}

TC_15_NEG_Create_User_With_Invalid_Employee_Name_Format
    [Documentation]    Verify that creating a user with a numeric/invalid employee_name returns 400 Bad Request
    [Tags]    negative    user    employee_name    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_15     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${rand_username}=  FakerLibrary.User Name
    ${rand_email}=     FakerLibrary.Email
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=${rand_username}
    ...    password=Test@1234
    ...    status=${True}
    ...    email=${rand_email}
    ...    employee_name=${invalid_employee_name}
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_15    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_15 PASS: Got 400 for invalid employee_name=${invalid_employee_name}

TC_16_NEG_Create_User_With_Empty_Employee_Name
    [Documentation]    Verify that creating a user with an empty employee_name string returns 400 Bad Request
    [Tags]    negative    user    employee_name    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_16     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${rand_username}=  FakerLibrary.User Name
    ${rand_email}=     FakerLibrary.Email
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    username=${rand_username}
    ...    password=Test@1234
    ...    status=${True}
    ...    email=${rand_email}
    ...    employee_name=${EMPTY}
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_16    /api/v1/auth/user    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_16 PASS: Got 400 for empty employee_name

TC_17_NEG_Update_User_With_Invalid_Employee_Name
    [Documentation]    Verify that updating a user with an invalid employee_name format returns 400 Bad Request
    [Tags]    negative    user    employee_name    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_17     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${rand_username}=  FakerLibrary.User Name
    ${rand_email}=     FakerLibrary.Email
    ${headers}=        Create Dictionary    Content-Type=application/json
    # Create user to get a valid user_id for update
    ${create_body}=    Create Dictionary
    ...    username=${rand_username}
    ...    password=Test@1234
    ...    status=${True}
    ...    email=${rand_email}
    ...    employee_name=${invalid_employee_name}
    ...    application_id=${application_id}
    ${create_resp}=    POST On Session    usr_neg_17    /api/v1/auth/user    json=${create_body}    headers=${headers}    expected_status=anything
    ${create_json}=    Convert String To Json    ${create_resp.content}
    ${uid_list}=       Get Value From Json    ${create_json}    data.user_id
    ${new_uid}=        Get From List    ${uid_list}    0
    # Update with invalid employee_name
    ${update_body}=    Create Dictionary
    ...    username=${rand_username}
    ...    user_id=${new_uid}
    ...    password=Test@1234
    ...    status=${True}
    ...    employee_name=${invalid_employee_name}
    ...    application_id=${application_id}
    ${response}=       PUT On Session    usr_neg_17    /api/v1/auth/user    json=${update_body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_17 PASS: Got 400 for invalid employee_name on update

TC_18_NEG_Update_User_With_Empty_Employee_Name
    [Documentation]    Verify that updating a user with an empty employee_name returns 400 Bad Request
    [Tags]    negative    user    employee_name    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_18     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${rand_username}=  FakerLibrary.User Name
    ${rand_email}=     FakerLibrary.Email
    ${headers}=        Create Dictionary    Content-Type=application/json
    # Create user to get a valid user_id for update
    ${create_body}=    Create Dictionary
    ...    username=${rand_username}
    ...    password=Test@1234
    ...    status=${True}
    ...    email=${rand_email}
    ...    employee_name=${employee_name}
    ...    application_id=${application_id}
    ${create_resp}=    POST On Session    usr_neg_18    /api/v1/auth/user    json=${create_body}    headers=${headers}    expected_status=anything
    ${create_json}=    Convert String To Json    ${create_resp.content}
    ${uid_list}=       Get Value From Json    ${create_json}    data.user_id
    ${new_uid}=        Get From List    ${uid_list}    0
    # Update with empty employee_name
    ${update_body}=    Create Dictionary
    ...    username=${rand_username}
    ...    user_id=${new_uid}
    ...    password=Test@1234
    ...    status=${True}
    ...    employee_name=${EMPTY}
    ...    application_id=${application_id}
    ${response}=       PUT On Session    usr_neg_18    /api/v1/auth/user    json=${update_body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_18 PASS: Got 400 for empty employee_name on update

TC_19_NEG_Create_User_With_Duplicate_Email
    [Documentation]    Verify that creating a user with an email that already belongs to an active user returns 400.
    ...                UserServiceImpl.userCreation() checks usersRepository.existsByEmailAndStatus(email, true)
    ...                and throws IllegalStateException("Given EmailId Already Exists") when duplicate found.
    ...                Creates a user with a known email first, then attempts to create another with the same email.
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_19     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${dup_email}=      Set Variable    e2e.dup.email.neg@test.com
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${first_body}=     Create Dictionary
    ...    username=neg_email_dup_user_first
    ...    password=Test@1234
    ...    status=${True}
    ...    email=${dup_email}
    ...    application_id=${application_id}
    # First creation — establish the duplicate email in the system
    POST On Session    usr_neg_19    /api/v1/auth/user    json=${first_body}    headers=${headers}    expected_status=anything
    # Second creation — same email, different username → must be rejected
    ${second_body}=    Create Dictionary
    ...    username=neg_email_dup_user_second
    ...    password=Test@5678
    ...    status=${True}
    ...    email=${dup_email}
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_19    /api/v1/auth/user    json=${second_body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_19 PASS: Got error ${status_code} for duplicate email=${dup_email}

TC_20_NEG_Create_User_With_Duplicate_Mobile_Number
    [Documentation]    Verify that creating a user with a mobile number that already exists returns 400.
    ...                UserServiceImpl.userCreation() checks usersRepository.existsByMobileNumber(mobileNumber)
    ...                and throws IllegalStateException("Given MobileNumber Already exists") when found.
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_20     ${auth_url}:${Auth_port}
    ${application_id}=     Create List    ${valid_application_id}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${first_body}=     Create Dictionary
    ...    username=neg_mobile_dup_user_first
    ...    password=Test@1234
    ...    status=${True}
    ...    mobile_number=${duplicate_mobile_number}
    ...    application_id=${application_id}
    # First creation — establish the mobile number in the system
    POST On Session    usr_neg_20    /api/v1/auth/user    json=${first_body}    headers=${headers}    expected_status=anything
    # Second creation — same mobile_number, different username → must be rejected
    ${second_body}=    Create Dictionary
    ...    username=neg_mobile_dup_user_second
    ...    password=Test@5678
    ...    status=${True}
    ...    mobile_number=${duplicate_mobile_number}
    ...    application_id=${application_id}
    ${response}=       POST On Session    usr_neg_20    /api/v1/auth/user    json=${second_body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_20 PASS: Got error ${status_code} for duplicate mobile_number=${duplicate_mobile_number}

TC_21_NEG_Delete_User_With_NonExistent_User_ID
    [Documentation]    Verify that deleting a user with a non-existent user_id returns error.
    ...                UserServiceImpl.deleteUser() calls usersRepository.findById(userId).orElseThrow()
    ...                which throws NoSuchElementException("User not Found") when user does not exist.
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_21     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    usr_neg_21    /api/v1/auth/user/${nonexistent_user_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_21 PASS: Got error ${status_code} for DELETE user with non-existent user_id=${nonexistent_user_id}

TC_22_NEG_Delete_User_With_Active_Role_Mapping
    [Documentation]    Verify that deleting a user who has active role mappings returns error.
    ...                UserServiceImpl.deleteUser() calls usersRepository.deleteIfNoRoleMapping(userId).
    ...                When deleted == 0 it throws IllegalStateException("User Mapped With Role").
    ...                Uses user_id=${user_id_with_role_mapping} which is assumed to have role mappings.
    [Tags]    negative    user    validation    referential-integrity
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_22     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    usr_neg_22    /api/v1/auth/user/${user_id_with_role_mapping}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_22 PASS: Got error ${status_code} for DELETE user with active role mappings (user_id=${user_id_with_role_mapping})

TC_23_NEG_Get_User_By_NonExistent_User_ID
    [Documentation]    Verify that fetching a user by a non-existent user_id returns error.
    ...                UserServiceImpl.getUser() calls usersRepository.findById(id).orElseThrow()
    ...                which throws IllegalStateException("Please Provide the Valid UserId").
    [Tags]    negative    user    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     usr_neg_23     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    usr_neg_23    /api/v1/auth/user/${nonexistent_user_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_23 PASS: Got error ${status_code} for GET user with non-existent user_id=${nonexistent_user_id}
