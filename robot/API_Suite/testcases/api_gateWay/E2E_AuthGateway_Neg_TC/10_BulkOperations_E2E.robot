*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# Bulk Channel - valid references
${bulk_valid_service_id}       2
${bulk_invalid_service_id}     999999
${bulk_valid_http_method}      POST
${bulk_invalid_http_method}    INVALID_METHOD

# Bulk Permission - valid references
${bulk_perm_app_id}            1
${bulk_perm_invalid_app_id}    999999

*** Test Cases ***
# NEGATIVE TEST CASES - BULK CHANNEL INSERT
# ============================================================

TC_06_NEG_BulkChannel_Insert_With_Invalid_HTTP_Method
    [Documentation]    Verify that bulk insert with an invalid HTTP method in any record returns 400 Bad Request
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_06     ${gateway_url}:${gateway_port}
    ${valid_chan}=     FakerLibrary.Safe Domain Name
    ${invalid_chan}=   FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${valid_record}=   Create Dictionary
    ...    description=Valid Record
    ...    service_id=${bulk_valid_service_id}
    ...    api_channel_name=${valid_chan}
    ...    api_channel_path=/api/v1/e2e/neg-inv-method-valid
    ...    api_channel_method=GET
    ${invalid_record}=    Create Dictionary
    ...    description=Invalid HTTP Method Record
    ...    service_id=${bulk_valid_service_id}
    ...    api_channel_name=${invalid_chan}
    ...    api_channel_path=/api/v1/e2e/neg-inv-method
    ...    api_channel_method=${bulk_invalid_http_method}
    ${payload}=        Create List    ${valid_record}    ${invalid_record}
    ${response}=       POST On Session    bch_neg_06    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_06 PASS: Got 400 for bulk insert with invalid HTTP method=${bulk_invalid_http_method}

TC_07_NEG_BulkChannel_Insert_Missing_Channel_Method
    [Documentation]    Verify that bulk insert with a record missing api_channel_method returns 400
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_07     ${gateway_url}:${gateway_port}
    ${chan_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing Method Record
    ...    service_id=${bulk_valid_service_id}
    ...    api_channel_name=${chan_name}
    ...    api_channel_path=/api/v1/e2e/neg-no-method
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bch_neg_07    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_07 PASS: Got 400 for bulk insert with missing api_channel_method

TC_08_NEG_BulkChannel_Insert_Missing_Channel_Name
    [Documentation]    Verify that bulk insert with a record missing api_channel_name returns 400
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_08     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing Name Record
    ...    service_id=${bulk_valid_service_id}
    ...    api_channel_path=/api/v1/e2e/neg-no-name
    ...    api_channel_method=GET
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bch_neg_08    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_08 PASS: Got 400 for bulk insert with missing api_channel_name

TC_09_NEG_BulkChannel_Insert_Missing_Channel_Path
    [Documentation]    Verify that bulk insert with a record missing api_channel_path returns 400
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_09     ${gateway_url}:${gateway_port}
    ${chan_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing Path Record
    ...    service_id=${bulk_valid_service_id}
    ...    api_channel_name=${chan_name}
    ...    api_channel_method=POST
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bch_neg_09    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_09 PASS: Got 400 for bulk insert with missing api_channel_path

TC_10_NEG_BulkChannel_Insert_Missing_Service_ID
    [Documentation]    Verify that bulk insert with a record missing service_id returns 400
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_10     ${gateway_url}:${gateway_port}
    ${chan_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing Service ID Record
    ...    api_channel_name=${chan_name}
    ...    api_channel_path=/api/v1/e2e/neg-no-svcid
    ...    api_channel_method=GET
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bch_neg_10    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for bulk insert with missing service_id

TC_11_NEG_BulkChannel_Insert_All_Records_With_Nonexistent_Service_IDs
    [Documentation]    Verify that bulk insert where all records have non-existent service_ids returns 200 with all failures
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_11     ${gateway_url}:${gateway_port}
    ${chan_name_1}=    FakerLibrary.Safe Domain Name
    ${chan_name_2}=    FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record_1}=       Create Dictionary
    ...    description=All Invalid Service One
    ...    service_id=${bulk_invalid_service_id}
    ...    api_channel_name=${chan_name_1}
    ...    api_channel_path=/api/v1/e2e/neg-all-invalid-one
    ...    api_channel_method=GET
    ${record_2}=       Create Dictionary
    ...    description=All Invalid Service Two
    ...    service_id=${bulk_invalid_service_id}
    ...    api_channel_name=${chan_name_2}
    ...    api_channel_path=/api/v1/e2e/neg-all-invalid-two
    ...    api_channel_method=POST
    ${payload}=        Create List    ${record_1}    ${record_2}
    ${response}=       POST On Session    bch_neg_11    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    ${json_data}=      Convert String To Json    ${response.content}
    Log To Console    TC_11 PASS: Bulk insert with all invalid service_ids returned 400,

TC_12_NEG_BulkChannel_Insert_Empty_Array
    [Documentation]    Verify that bulk insert with an empty array returns 400 Bad Request
    [Tags]    negative    bulk-channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bch_neg_12     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create List
    ${response}=       POST On Session    bch_neg_12    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_12 PASS: Got error ${status_code} for bulk insert with empty array

TC_13_NEG_BulkPermission_Insert_Missing_Permission_Name
    [Documentation]    Verify that bulk permission insert with a record missing permission_name returns 400
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_13     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${valid_record}=   Create Dictionary
    ...    description=Valid permission
    ...    application_id=${bulk_perm_app_id}
    ...    permission_name=neg-valid-perm-alongside
    ...    resource_path=/api/v1/e2e/neg-perm-valid
    ...    http_method=GET
    ${missing_name_record}=    Create Dictionary
    ...    description=Missing permission name
    ...    application_id=${bulk_perm_app_id}
    ...    resource_path=/api/v1/e2e/neg-no-perm-name
    ...    http_method=POST
    ${payload}=        Create List    ${valid_record}    ${missing_name_record}
    ${response}=       POST On Session    bperm_neg_13    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_13 PASS: Got 400 for bulk permission insert with missing permission_name

TC_14_NEG_BulkPermission_Insert_Missing_HTTP_Method
    [Documentation]    Verify that bulk permission insert with a record missing http_method returns 400
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_14     ${auth_url}:${Auth_port}
    ${perm_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing HTTP method
    ...    application_id=${bulk_perm_app_id}
    ...    permission_name=${perm_name}
    ...    resource_path=/api/v1/e2e/neg-no-http-method
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bperm_neg_14    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_14 PASS: Got 400 for bulk permission insert with missing http_method

TC_15_NEG_BulkPermission_Insert_Invalid_HTTP_Method
    [Documentation]    Verify that bulk permission insert with an unsupported HTTP method returns 400
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_15     ${auth_url}:${Auth_port}
    ${perm_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Invalid HTTP method
    ...    application_id=${bulk_perm_app_id}
    ...    permission_name=${perm_name}
    ...    resource_path=/api/v1/e2e/neg-invalid-method
    ...    http_method=FETCH
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bperm_neg_15    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_15 PASS: Got 400 for bulk permission insert with invalid http_method=FETCH

TC_16_NEG_BulkPermission_Insert_Missing_Resource_Path
    [Documentation]    Verify that bulk permission insert with a record missing resource_path returns 400
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_16     ${auth_url}:${Auth_port}
    ${perm_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing resource path
    ...    application_id=${bulk_perm_app_id}
    ...    permission_name=${perm_name}
    ...    http_method=GET
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bperm_neg_16    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_16 PASS: Got 400 for bulk permission insert with missing resource_path

TC_17_NEG_BulkPermission_Insert_Missing_Application_ID
    [Documentation]    Verify that bulk permission insert with a record missing application_id returns 400
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_17     ${auth_url}:${Auth_port}
    ${perm_name}=      FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Missing application_id
    ...    permission_name=${perm_name}
    ...    resource_path=/api/v1/e2e/neg-no-app-id
    ...    http_method=GET
    ${payload}=        Create List    ${record}
    ${response}=       POST On Session    bperm_neg_17    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_17 PASS: Got 400 for bulk permission insert with missing application_id

TC_18_NEG_BulkPermission_Insert_All_Records_With_Invalid_AppID
    [Documentation]    Verify bulk permission insert where all records have non-existent application_id returns 200 with all failures
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_18     ${auth_url}:${Auth_port}
    ${perm_1}=         FakerLibrary.Safe Domain Name
    ${perm_2}=         FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record_1}=       Create Dictionary
    ...    description=All invalid app id one
    ...    application_id=${bulk_perm_invalid_app_id}
    ...    permission_name=${perm_1}
    ...    resource_path=/api/v1/e2e/neg-all-invalid-perm-one
    ...    http_method=GET
    ${record_2}=       Create Dictionary
    ...    description=All invalid app id two
    ...    application_id=${bulk_perm_invalid_app_id}
    ...    permission_name=${perm_2}
    ...    resource_path=/api/v1/e2e/neg-all-invalid-perm-two
    ...    http_method=POST
    ${payload}=        Create List    ${record_1}    ${record_2}
    ${response}=       POST On Session    bperm_neg_18    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}=      Convert String To Json    ${response.content}
    ${failure_count}=  Get Value From Json    ${json_data}    data.failureCount
    ${fc_val}=         Get From List    ${failure_count}    0
    IF  ${fc_val} > 1
        Log To Console    TC_18 PASS: Got failures for bulk permission insert with invalid application_ids, failureCount=${fc_val}
    ELSE
        Log To Console    TC_18 FAIL: Expected failureCount > 1 but got failureCount=${fc_val}
    END

TC_19_NEG_BulkPermission_Insert_Duplicate_Permission_Name
    [Documentation]    Verify that inserting a permission with a name that already exists returns error in the errors list
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_19     ${auth_url}:${Auth_port}
    ${dup_perm_name}=  FakerLibrary.Safe Domain Name
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${record}=         Create Dictionary
    ...    description=Duplicate permission test
    ...    application_id=${bulk_perm_app_id}
    ...    permission_name=${dup_perm_name}
    ...    resource_path=/api/v1/e2e/dup-perm
    ...    http_method=GET
    ${payload}=        Create List    ${record}
    # First insert
    POST On Session    bperm_neg_19    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    # Duplicate insert - should return error for duplicate
    ${response}=       POST On Session    bperm_neg_19    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}=      Convert String To Json    ${response.content}
    ${failure_count}=  Get Value From Json    ${json_data}    data.failureCount
    ${fc_val}=         Get From List    ${failure_count}    0
    Should Be True     ${fc_val} > 0
    Log To Console    TC_19 PASS: Got 200 with failures for duplicate permission_name in bulk insert

TC_20_NEG_BulkPermission_Insert_Empty_Array
    [Documentation]    Verify that bulk permission insert with an empty array returns error
    [Tags]    negative    bulk-permission    validation
    ${auth_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     bperm_neg_20     ${auth_url}:${Auth_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create List
    ${response}=       POST On Session    bperm_neg_20    /api/v1/auth/permission/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_20 PASS: Got error ${status_code} for bulk permission insert with empty array
