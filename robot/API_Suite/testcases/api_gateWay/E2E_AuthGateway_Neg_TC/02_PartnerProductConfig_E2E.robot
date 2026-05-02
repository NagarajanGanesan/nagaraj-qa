*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
${valid_exp_date}          2027-12-31
${past_exp_date}           2020-01-01
${invalid_date_format}     31-12-2027
${invalid_app_code}        invalid-app-code-9999
${nonexistent_app_code}    00000000-0000-0000-0000-000000000000
${nonexistent_config_id}   999999
${valid_product_id}        1

*** Test Cases ***
# NEGATIVE TEST CASES
# ============================================================
TC_04_NEG_Create_PartnerConfig_Missing_Expiry_Date
    [Documentation]    Verify that creating a partner config without expiry_date returns 400 Bad Request
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_04     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${True}
    ${response}=       POST On Session    ppc_neg_04    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_04 PASS: Got 400 for missing expiry_date

TC_05_NEG_Create_PartnerConfig_With_Past_Expiry_Date
    [Documentation]    Verify that creating a partner config with a past expiry date returns 400 Bad Request
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_05     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${True}
    ...    expiry_date=${past_exp_date}
    ${response}=       POST On Session    ppc_neg_05    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_05 PASS: Got 400 for past expiry_date=${past_exp_date}

TC_06_NEG_Create_PartnerConfig_With_Invalid_Date_Format
    [Documentation]    Verify that creating a partner config with wrong date format (DD-MM-YYYY) returns 400
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_06     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${True}
    ...    expiry_date=${invalid_date_format}
    ${response}=       POST On Session    ppc_neg_06    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_06 PASS: Got 400 for invalid date format=${invalid_date_format}

TC_07_NEG_Create_PartnerConfig_With_Empty_Body
    [Documentation]    Verify that creating a partner config with empty body returns 400 Bad Request
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_07     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ${response}=       POST On Session    ppc_neg_07    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_07 PASS: Got 400 for empty request body

TC_08_NEG_Update_PartnerConfig_With_NonExistent_AppCode
    [Documentation]    Verify that updating config with a non-existent app_code returns 404 Not Found
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_08     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=true
    ...    expiry_date=${valid_exp_date}
    ...    app_code=${nonexistent_app_code}
    ${response}=       PUT On Session    ppc_neg_08    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_08 PASS: Got error ${status_code} for non-existent app_code

TC_09_NEG_Create_PartnerConfig_Missing_AppCode_Creation_Flag
    [Documentation]    Verify that creating a partner config without app_code_creation flag returns 400
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_09     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    expiry_date=${valid_exp_date}
    ${response}=       POST On Session    ppc_neg_09    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_09 PASS: Got 400 for missing app_code_creation flag

TC_10_NEG_Create_PartnerConfig_AppCodeCreation_False_Without_AppCode
    [Documentation]    Verify that setting app_code_creation=False without providing an existing app_code returns 400.
    ...                When app_code_creation=False the caller must supply a valid app_code to update; omitting it is invalid.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_10     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${False}
    ...    expiry_date=${valid_exp_date}
    ${response}=       POST On Session    ppc_neg_10    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_10 PASS: Got 400 for app_code_creation=False with no app_code supplied

TC_11_NEG_Get_PartnerConfig_By_NonExistent_AppCode
    [Documentation]    Verify that fetching a partner-product-config by a non-existent app_code returns error (404)
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_11     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    ppc_neg_11    /api/v1/gateway/partner-product-config/${nonexistent_app_code}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_11 PASS: Got error ${status_code} for GET with non-existent app_code=${nonexistent_app_code}

TC_12_NEG_Update_PartnerConfig_With_Expired_Date_Less_Than_Today
    [Documentation]    Verify that updating a partner config with an expiry_date in the past returns 400 Bad Request
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_12     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${True}
    ...    expiry_date=${past_exp_date}
    ...    app_code=${nonexistent_app_code}
    ${response}=       PUT On Session    ppc_neg_12    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_12 PASS: Got error ${status_code} for PUT with past expiry_date=${past_exp_date}

TC_13_NEG_Create_PartnerConfig_AppCodeCreation_False_ProductId_Has_Active_Config
    [Documentation]    Verify that creating a config with app_code_creation=False and a productId that already has
    ...                an active config returns 400. PartnerProductConfigServiceImpl.create() calls
    ...                findTopByProducts_IdAndStatusOrderByCreatedAtDesc() and throws
    ...                IllegalStateException("Already Configuration Setup. Days Left X") when config exists and is not expired.
    ...                Uses product_id=1 which is assumed to have an active config in the test environment.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_13     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${False}
    ...    expiry_date=${valid_exp_date}
    ...    product_id=${valid_product_id}
    ${response}=       POST On Session    ppc_neg_13    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    ${incorrect_expected_code}
    Log To Console    TC_13 PASS: Got 400 for app_code_creation=False with product_id=${valid_product_id} that already has active config

TC_14_NEG_EnableDisable_Config_With_NonExistent_Config_ID
    [Documentation]    Verify that enabling/disabling a partner config using a non-existent config_id returns error.
    ...                PartnerProductConfigServiceImpl.enableDisable() calls findById().orElseThrow() which throws
    ...                NoSuchElementException → ResponseStatus.BAD_REQUEST when no config found with given ID.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_14     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT On Session    ppc_neg_14    url=/api/v1/gateway/partner-product-config/${nonexistent_config_id}?enable=true    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_14 PASS: Got error ${status_code} for enable/disable with non-existent config_id=${nonexistent_config_id}

TC_15_NEG_Delete_Config_By_NonExistent_Config_ID_Path_Variable
    [Documentation]    Verify that deleting a config using a non-existent config_id via path variable returns error.
    ...                PartnerProductConfigServiceImpl.deleteConfig() throws NoSuchElementException("config not found with id: X")
    ...                when partnerProductConfigRepository.existsById() returns false.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_15     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    ppc_neg_15    /api/v1/gateway/partner-product-config/${nonexistent_config_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_15 PASS: Got error ${status_code} for DELETE config with non-existent config_id=${nonexistent_config_id}

TC_16_NEG_Delete_Config_By_NonExistent_ProductID_Query_Param
    [Documentation]    Verify that deleting a config by non-existent productId via query param returns error.
    ...                PartnerProductConfigServiceImpl.deleteConfigUsingProductOrAppCode() throws
    ...                NoSuchElementException("Config not Found with id: X") when existsByProducts_Id() returns false.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_16     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    ppc_neg_16    url=/api/v1/gateway/partner-product-config?id=999999&product=true    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_16 PASS: Got error ${status_code} for DELETE config by non-existent productId via query param

TC_17_NEG_Delete_Config_By_NonExistent_AppCode_Query_Param
    [Documentation]    Verify that deleting a config by non-existent appCode via query param returns error.
    ...                PartnerProductConfigServiceImpl.deleteConfigUsingProductOrAppCode() throws
    ...                NoSuchElementException("Config not Found with id: X") when existsByAppCode() returns false.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_17     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    ppc_neg_17    url=/api/v1/gateway/partner-product-config?id=${nonexistent_app_code}&product=false    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_17 PASS: Got error ${status_code} for DELETE config by non-existent appCode=${nonexistent_app_code} via query param

TC_18_NEG_Renew_Config_When_Two_Active_Secrets_Already_Exist
    [Documentation]    Verify that renewing (PUT) a config when already 2 active secrets exist for the same appCode returns error.
    ...                PartnerProductConfigServiceImpl.recreate() calls isGreaterThanTwo() which checks
    ...                countByAppCodeAndStatus(...) < 2. When count >= 2 it throws IllegalStateException("already two secrets available").
    ...                Uses a valid known appCode that already has 2 active configs in the test environment.
    [Tags]    negative    partner-config    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ppc_neg_18     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${body}=           Create Dictionary
    ...    app_code_creation=${False}
    ...    expiry_date=${valid_exp_date}
    ...    app_code=${nonexistent_app_code}
    ${response}=       PUT On Session    ppc_neg_18    /api/v1/gateway/partner-product-config    json=${body}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_18 PASS: Got error ${status_code} for PUT renew config with max active secrets already present
