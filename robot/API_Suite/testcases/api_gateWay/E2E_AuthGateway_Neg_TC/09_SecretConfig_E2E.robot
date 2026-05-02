*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
${valid_secret_service_id}      2
${nonexistent_service_id}       999999
${nonexistent_secret_id}        999999
${secret_username}              configUser
${secret_password}              xxx1234
${secret_base_path}             /api/v1/secrets
${created_secret_id}            1

*** Test Cases ***
# NEGATIVE TEST CASES - SECRET CONFIG
# ============================================================

TC_08_NEG_Create_Secret_Missing_Key
    [Documentation]    Verify that creating a secret without the key field returns 400 Bad Request
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_08     ${base_url}:${secrets_port}    auth=${auth}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    value=neg-missing-key-value
    ...    service_id=${valid_secret_service_id}
    ${response}=       POST On Session    sec_neg_08    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_08 PASS: Got 400 for missing key field

TC_09_NEG_Create_Secret_Missing_Value
    [Documentation]    Verify that creating a secret without the value field returns 400 Bad Request
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_09     ${base_url}:${secrets_port}    auth=${auth}
    ${rand_key}=       FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    key=${rand_key}.neg-no-value
    ...    service_id=${valid_secret_service_id}
    ${response}=       POST On Session    sec_neg_09    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_09 PASS: Got 400 for missing value field

TC_10_NEG_Create_Secret_Missing_ServiceID
    [Documentation]    Verify that creating a secret without service_id returns 400 Bad Request
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_10     ${base_url}:${secrets_port}    auth=${auth}
    ${rand_key}=       FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    key=${rand_key}.neg-no-svcid
    ...    value=neg-no-service-id-value
    ${response}=       POST On Session    sec_neg_10    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for missing service_id

TC_11_NEG_Create_Secret_With_Empty_Value
    [Documentation]    Verify that creating a secret with an empty value string returns 400 (value must be at least 1 character)
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_11     ${base_url}:${secrets_port}    auth=${auth}
    ${rand_key}=       FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    key=${rand_key}.neg-empty-value
    ...    value=${EMPTY}
    ...    service_id=${valid_secret_service_id}
    ${response}=       POST On Session    sec_neg_11    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_11 PASS: Got 400 for empty value (must be at least 1 character)

TC_12_NEG_Create_Secret_With_Nonexistent_ServiceID
    [Documentation]    Verify that creating a secret with a non-existent service_id returns error
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_12     ${base_url}:${secrets_port}    auth=${auth}
    ${rand_key}=       FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    key=${rand_key}.neg-invalid-svc
    ...    value=neg-invalid-service-id
    ...    service_id=${nonexistent_service_id}
    ${response}=       POST On Session    sec_neg_12    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_12 PASS: Got error ${status_code} for non-existent service_id=${nonexistent_service_id}

TC_13_NEG_Create_Duplicate_Key_For_Same_Service
    [Documentation]    Verify that inserting a duplicate key for the same service returns error
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_13     ${base_url}:${secrets_port}    auth=${auth}
    ${dup_key}=        FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    key=${dup_key}.dup-test
    ...    value=duplicate-key-value
    ...    service_id=${valid_secret_service_id}
    # First creation
    POST On Session    sec_neg_13    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate creation
    ${response}=       POST On Session    sec_neg_13    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_13 PASS: Got error ${status_code} for duplicate key for same service

TC_14_NEG_Get_Secrets_By_Nonexistent_ServiceID
    [Documentation]    Verify that fetching secrets with a non-existent service_id returns 404
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_14     ${base_url}:${secrets_port}    auth=${auth}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    sec_neg_14    ${secret_base_path}/${nonexistent_service_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_14 PASS: Got 404 for non-existent service_id=${nonexistent_service_id}

TC_15_NEG_Update_Secret_With_Nonexistent_Secret_ID
    [Documentation]    Verify that updating a secret with a non-existent secret_id returns error
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_15     ${base_url}:${secrets_port}    auth=${auth}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    secret_id=${nonexistent_secret_id}
    ...    value=neg-update-nonexistent
    ...    status=${True}
    ${response}=       PUT On Session    sec_neg_15    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_15 PASS: Got error ${status_code} for update with non-existent secret_id=${nonexistent_secret_id}

TC_16_NEG_Delete_Secret_With_Nonexistent_ID
    [Documentation]    Verify that deleting a secret with a non-existent ID returns 404
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_16     ${base_url}:${secrets_port}    auth=${auth}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    sec_neg_16    ${secret_base_path}/${nonexistent_secret_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_16 PASS: Got 404 for delete with non-existent secret_id=${nonexistent_secret_id}

TC_17_NEG_Bulk_Insert_Secrets_Empty_Value_In_Record
    [Documentation]    Verify that bulk insert with an empty value in any record returns 400 Bad Request
    [Tags]    negative    secret    bulk    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_17     ${base_url}:${secrets_port}    auth=${auth}
    ${rand_key_1}=     FakerLibrary.Safe Domain Name
    ${rand_key_2}=     FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${valid_record}=   Create Dictionary
    ...    key=${rand_key_1}.neg-empty
    ...    value=valid-value
    ...    service_id=${valid_secret_service_id}
    ${empty_value_record}=    Create Dictionary
    ...    key=${rand_key_2}.neg-empty
    ...    value=${EMPTY}
    ...    service_id=${valid_secret_service_id}
    ${payload}=        Create List    ${valid_record}    ${empty_value_record}
    ${response}=       POST On Session    sec_neg_17    ${secret_base_path}/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_17 PASS: Got 400 for bulk insert with empty value in one record

TC_18_NEG_Bulk_Update_Secrets_With_Invalid_ServiceID
    [Documentation]    Verify that bulk update with invalid service_id for a record returns 200 PARTIAL_UPDATE
    [Tags]    negative    secret    bulk    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_18     ${base_url}:${secrets_port}    auth=${auth}
    ${rand_key}=       FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${invalid_record}=    Create Dictionary
    ...    key=${rand_key}.invalid-svc-upd
    ...    value=invalid-service-update
    ...    service_id=${nonexistent_service_id}
    ${payload}=        Create List    ${invalid_record}
    ${response}=       PUT On Session    sec_neg_18    ${secret_base_path}/bulk-update    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    ${json_data}=      Convert String To Json    ${response.content}
    ${code}=           Get Value From Json    ${json_data}    status.code
    ${code_val}=       Get From List    ${code}    0
    Log To Console    TC_18 PASS: Got 400 PARTIAL_UPDATE for bulk update with invalid service_id

TC_19_NEG_Create_Secret_With_Empty_Body
    [Documentation]    Verify that creating a secret with an empty body returns 400 Bad Request
    [Tags]    negative    secret    validation
    ${base_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${auth}=           Create List    ${secret_username}    ${secret_password}
    Create Session     sec_neg_19     ${base_url}:${secrets_port}    auth=${auth}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ${response}=       POST On Session    sec_neg_19    ${secret_base_path}    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_19 PASS: Got 400 for empty request body
