*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
${valid_service_name}      e2e-automation-service
${valid_service_url}       lb://e2e-automation-service
${nonexistent_service_id}  999999

*** Test Cases ***
# NEGATIVE TEST CASES - GATEWAY SERVICE
# ============================================================

TC_07_NEG_Create_Service_Missing_Service_Name
    [Documentation]    Verify that creating a service without service_name returns 400 Bad Request
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_07     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=true
    ...    service_url=lb://neg-no-name-service
    ${response}=       POST On Session    svc_neg_07    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_07 PASS: Got 400 for missing service_name

TC_08_NEG_Create_Service_Missing_Service_URL
    [Documentation]    Verify that creating a service without service_url returns 400 Bad Request
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_08     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=true
    ...    service_name=neg-no-url-service
    ${response}=       POST On Session    svc_neg_08    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_08 PASS: Got 400 for missing service_url

TC_09_NEG_Create_Duplicate_Service_Name
    [Documentation]    Verify that registering a service with an already existing name returns error (400/409)
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_09     ${gateway_url}:${gateway_port}
    ${dup_svc_name}=   Set Variable    e2e-duplicate-service-test
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=true
    ...    service_name=${dup_svc_name}
    ...    service_url=lb://${dup_svc_name}
    # First registration
    POST On Session    svc_neg_09    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    # Duplicate registration
    ${response}=       POST On Session    svc_neg_09    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_09 PASS: Got error ${status_code} for duplicate service_name=${dup_svc_name}

TC_10_NEG_Create_Service_With_Empty_Service_Name
    [Documentation]    Verify that creating a service with empty string service_name returns 400
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_10     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=true
    ...    service_name=${EMPTY}
    ...    service_url=lb://neg-empty-name-service
    ${response}=       POST On Session    svc_neg_10    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for empty service_name

TC_11_NEG_Create_Service_With_Empty_Body
    [Documentation]    Verify that creating a service with empty request body returns 400
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_11     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ${response}=       POST On Session    svc_neg_11    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_11 PASS: Got 400 for empty request body

TC_12_NEG_Get_Service_By_NonExistent_ID
    [Documentation]    Verify that fetching a service with non-existent ID returns 404 Not Found
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_12     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    svc_neg_12    /api/v1/gateway/service/${nonexistent_service_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_12 PASS: Got 404 for non-existent service_id=${nonexistent_service_id}

TC_13_NEG_Update_Service_With_NonExistent_Service_ID
    [Documentation]    Verify that updating a service using a non-existent service_id returns error (404)
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_13     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    service_id=${nonexistent_service_id}
    ...    status=true
    ...    service_name=neg-nonexistent-update-service
    ...    service_url=lb://neg-nonexistent-update-service
    ${response}=       PUT On Session    svc_neg_13    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_13 PASS: Got error ${status_code} for update with non-existent service_id=${nonexistent_service_id}

TC_14_NEG_Create_Service_With_Invalid_URL_Format
    [Documentation]    Verify that creating a service with a service_url that does not use the lb:// scheme returns 400.
    ...                The gateway expects lb://<service-name> format for service discovery; http:// URLs are invalid.
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_14     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=true
    ...    service_name=neg-invalid-url-format-service
    ...    service_url=http://neg-invalid-url-format-service
    ${response}=       POST On Session    svc_neg_14    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_14 PASS: Got 400 for service_url with invalid scheme (http:// instead of lb://)

TC_15_NEG_Create_Service_With_Empty_Service_URL
    [Documentation]    Verify that creating a service with an empty service_url string returns 400 Bad Request
    [Tags]    negative    service    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     svc_neg_15     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    status=true
    ...    service_name=neg-empty-url-service
    ...    service_url=${EMPTY}
    ${response}=       POST On Session    svc_neg_15    /api/v1/gateway/service    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_15 PASS: Got 400 for empty service_url
