*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
${valid_app_code}          xxxxx-axxxx-xxxx-xxxx-416e1f00909
${invalid_app_code}        totally-invalid-app-code
${nonexistent_app_code}    00000000-0000-0000-0000-000000000000
${nonexistent_app_id}      999999

*** Test Cases ***
# NEGATIVE TEST CASES
# ============================================================

TC_05_NEG_Create_Application_Missing_App_Name
    [Documentation]    Verify that creating an application without app_name returns 400 Bad Request
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_05     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    app_code=${valid_app_code}
    ${response}=       POST On Session    app_neg_05    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_05 PASS: Got 400 for missing app_name

TC_06_NEG_Create_Application_Missing_AppCode
    [Documentation]    Verify that creating an application without app_code returns 400 Bad Request
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_06     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    app_name=neg_missing_appcode_app
    ${response}=       POST On Session    app_neg_06    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_06 PASS: Got 400 for missing app_code

TC_07_NEG_Create_Application_With_Invalid_AppCode
    [Documentation]    Verify that creating an application with an invalid/unregistered app_code returns error
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_07     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    app_name=neg_invalid_appcode_app
    ...    app_code=${invalid_app_code}
    ${response}=       POST On Session    app_neg_07    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_07 PASS: Got error ${status_code} for invalid app_code

TC_08_NEG_Create_Duplicate_Application_Name
    [Documentation]    Verify that creating two applications with the same name returns error (400/409)
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_08     ${auth_url}:${Auth_port}
    ${dup_name}=       Set Variable    e2e_duplicate_app_test
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    app_name=${dup_name}
    ...    app_code=${valid_app_code}
    # First creation
    POST On Session    app_neg_08    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate creation
    ${response}=       POST On Session    app_neg_08    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_08 PASS: Got error ${status_code} for duplicate application name

TC_09_NEG_Update_Application_With_NonExistent_ID
    [Documentation]    Verify that updating an application with a non-existent ID returns error (404)
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_09     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    application_id=${nonexistent_app_id}
    ...    app_name=neg_nonexistent_update
    ...    app_code=${valid_app_code}
    ${response}=       PUT On Session    app_neg_09    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_09 PASS: Got error ${status_code} for update with non-existent ID=${nonexistent_app_id}

TC_10_NEG_Create_Application_With_Empty_App_Name
    [Documentation]    Verify that creating an application with an empty string app_name returns 400
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_10     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    app_name=${EMPTY}
    ...    app_code=${valid_app_code}
    ${response}=       POST On Session    app_neg_10    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for empty app_name

TC_11_NEG_Get_Application_By_NonExistent_ID
    [Documentation]    Verify that fetching an application by a non-existent application_id returns error (404)
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_11     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    app_neg_11    /api/v1/auth/application/${nonexistent_app_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_11 PASS: Got error ${status_code} for GET with non-existent application_id=${nonexistent_app_id}

TC_12_NEG_Create_Application_With_Nonexistent_AppCode
    [Documentation]    Verify that creating an application with a non-existent UUID app_code returns error
    [Tags]    negative    application    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     app_neg_12     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=${True}
    ...    app_name=neg_nonexistent_uuid_app
    ...    app_code=${nonexistent_app_code}
    ${response}=       POST On Session    app_neg_12    /api/v1/auth/application    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_12 PASS: Got error ${status_code} for non-existent UUID app_code=${nonexistent_app_code}

