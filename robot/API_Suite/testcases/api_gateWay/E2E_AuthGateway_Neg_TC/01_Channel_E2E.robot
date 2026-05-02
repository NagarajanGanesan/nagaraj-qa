*** Settings ***
Resource     ../../../keywords/common.robot

*** Variables ***
# Valid test data
${valid_service_id}         1
${valid_channel_id}         1
${invalid_service_id}       999999
${invalid_http_method}      INVALID_METHOD
${nonexistent_channel_id}   999999
${conflict_code}            409

*** Test Cases ***
# NEGATIVE TEST CASES
# ============================================================
TC_05_NEG_Create_Channel_Missing_Service_ID
    [Documentation]    Verify that creating a channel without service_id returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_05     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - No Service ID
    ...    api_channel_name=neg_missing_service_channel
    ...    api_channel_path=/api/v1/e2e/neg-no-svc
    ...    api_channel_method=GET
    ${response}=       POST On Session    ch_neg_05    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_05 PASS: Got 400 for missing service_id

TC_06_NEG_Create_Channel_Missing_Channel_Name
    [Documentation]    Verify that creating a channel without api_channel_name returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_06     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - No Channel Name
    ...    service_id=${valid_service_id}
    ...    api_channel_path=/api/v1/e2e/neg-no-name
    ...    api_channel_method=POST
    ${response}=       POST On Session    ch_neg_06    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_06 PASS: Got 400 for missing api_channel_name

TC_07_NEG_Create_Channel_Missing_Channel_Path
    [Documentation]    Verify that creating a channel without api_channel_path returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_07     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - No Channel Path
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_missing_path_channel
    ...    api_channel_method=GET
    ${response}=       POST On Session    ch_neg_07    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_07 PASS: Got 400 for missing api_channel_path

TC_08_NEG_Create_Channel_With_Invalid_HTTP_Method
    [Documentation]    Verify that creating a channel with an invalid HTTP method returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_08     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - Invalid HTTP Method
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_invalid_method_channel
    ...    api_channel_path=/api/v1/e2e/neg-inv-method
    ...    api_channel_method=${invalid_http_method}
    ${response}=       POST On Session    ch_neg_08    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_08 PASS: Got 400 for invalid HTTP method=${invalid_http_method}

TC_09_NEG_Create_Channel_With_NonExistent_Service_ID
    [Documentation]    Verify that creating a channel with a non-existent service_id returns 400/404
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_09     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - Non-existent Service ID
    ...    service_id=${invalid_service_id}
    ...    api_channel_name=neg_nonexistent_svc_channel
    ...    api_channel_path=/api/v1/e2e/neg-inv-svc
    ...    api_channel_method=GET
    ${response}=       POST On Session    ch_neg_09    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_09 PASS: Got error ${status_code} for non-existent service_id=${invalid_service_id}

TC_10_NEG_Create_Duplicate_Channel_Name
    [Documentation]    Verify that creating a channel with an already existing name returns error (400/409)
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_10     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${dup_name}=       Set Variable    e2e_duplicate_channel_test
    ${payload}=        Create Dictionary
    ...    description=Duplicate Channel Test
    ...    service_id=${valid_service_id}
    ...    api_channel_name=${dup_name}
    ...    api_channel_path=/api/v1/e2e/dup
    ...    api_channel_method=GET
    # First creation
    POST On Session    ch_neg_10    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    # Second creation with same name (duplicate)
    ${response}=       POST On Session    ch_neg_10    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_10 PASS: Got error ${status_code} for duplicate channel name

TC_11_NEG_Get_Channel_By_Nonexistent_ID
    [Documentation]    Verify that fetching a channel with non-existent ID returns 404 Not Found
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_11     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    ch_neg_11    /api/v1/gateway/channel/${nonexistent_channel_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_11 PASS: Got 404 for non-existent channel ID=${nonexistent_channel_id}

TC_12_NEG_Create_Channel_With_Empty_Request_Body
    [Documentation]    Verify that creating a channel with empty request body returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_12     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ${response}=       POST On Session    ch_neg_12    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_12 PASS: Got 400 for empty request body

TC_13_NEG_Create_Channel_Missing_HTTP_Method_Field
    [Documentation]    Verify that creating a channel with api_channel_method field entirely absent returns 400.
    ...                This is distinct from TC_08 which sends an INVALID method value — here the field is omitted.
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_13     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - api_channel_method field absent
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_absent_method_field_channel
    ...    api_channel_path=/api/v1/e2e/neg-absent-method-field
    ${response}=       POST On Session    ch_neg_13    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_13 PASS: Got 400 for absent api_channel_method field (field not sent at all)

TC_14_NEG_Create_Channel_With_Empty_Channel_Name
    [Documentation]    Verify that creating a channel with an empty api_channel_name string returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_14     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - Empty Channel Name
    ...    service_id=${valid_service_id}
    ...    api_channel_name=${EMPTY}
    ...    api_channel_path=/api/v1/e2e/neg-empty-channel-name
    ...    api_channel_method=GET
    ${response}=       POST On Session    ch_neg_14    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_14 PASS: Got 400 for empty api_channel_name

TC_15_NEG_Create_Channel_With_Empty_Channel_Path
    [Documentation]    Verify that creating a channel with an empty api_channel_path string returns 400 Bad Request
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_15     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - Empty Channel Path
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_empty_path_channel
    ...    api_channel_path=${EMPTY}
    ...    api_channel_method=POST
    ${response}=       POST On Session    ch_neg_15    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    Log To Console    TC_15 PASS: Got 400 for empty api_channel_path

TC_16_NEG_Update_Channel_Missing_Channel_ID_In_Body
    [Documentation]    Verify that updating a channel without providing api_channel_id in the body returns 400.
    ...                ApiChannelServiceImpl.update() throws IllegalStateException("Please Provide Valid ChannelId")
    ...                when channelId is null in the request body.
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_16     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    description=Negative Test - Update without channel ID
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_update_no_channel_id
    ...    api_channel_path=/api/v1/e2e/neg-update-no-id
    ...    api_channel_method=GET
    ${response}=       PUT On Session    ch_neg_16    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_16 PASS: Got error ${status_code} for PUT channel without api_channel_id

TC_17_NEG_Delete_Channel_With_NonExistent_ID
    [Documentation]    Verify that deleting a channel with a non-existent channel ID returns error.
    ...                ApiChannelServiceImpl.deleteChannel() throws NoSuchElementException("Channel not Found With Id")
    ...                when the channel does not exist in the DB.
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_17     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    ch_neg_17    /api/v1/gateway/channel/${nonexistent_channel_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_17 PASS: Got error ${status_code} for DELETE non-existent channel_id=${nonexistent_channel_id}

TC_18_NEG_Delete_Channel_With_Active_Mapping
    [Documentation]    Verify that deleting a channel that is currently mapped to a channel-mapping config returns error.
    ...                ApiChannelServiceImpl.deleteChannel() calls deleteIfNoMappings() and throws
    ...                NoSuchElementException("Channel mapped with Config") when mappings exist.
    ...                Uses channel_id=1 which is assumed to have active mappings in the test environment.
    [Tags]    negative    channel    validation    referential-integrity
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_18     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       DELETE On Session    ch_neg_18    /api/v1/gateway/channel/${valid_channel_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_18 PASS: Got error ${status_code} for DELETE channel with active channel mappings (channel_id=${valid_channel_id})

TC_19_NEG_Get_Channels_For_NonExistent_Service_ID
    [Documentation]    Verify that fetching channels for a non-existent service_id returns error.
    ...                ApiChannelServiceImpl.getChannelForService() throws IllegalStateException("Provide Valid ServiceId")
    ...                when serviceRegistryRepository.existsById() returns false.
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_19     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       GET On Session    ch_neg_19    /api/v1/gateway/channel/service/${invalid_service_id}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_19 PASS: Got error ${status_code} for GET channels with non-existent service_id=${invalid_service_id}

TC_20_NEG_Update_Channel_With_NonExistent_Channel_ID
    [Documentation]    Verify that updating a channel using a non-existent api_channel_id returns error.
    ...                ApiChannelServiceImpl.update() throws EntityNotFoundException("Please Provide Valid ChannelId")
    ...                when apiChannelsRepository.findById() returns empty for the given channelId.
    [Tags]    negative    channel    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_20     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${payload}=        Create Dictionary
    ...    api_channel_id=${nonexistent_channel_id}
    ...    description=Negative Test - Update non-existent channel
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_update_nonexistent_id
    ...    api_channel_path=/api/v1/e2e/neg-update-nonexistent-id
    ...    api_channel_method=PUT
    ${response}=       PUT On Session    ch_neg_20    /api/v1/gateway/channel    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_20 PASS: Got error ${status_code} for PUT with non-existent channel_id=${nonexistent_channel_id}

TC_21_NEG_Bulk_Create_Channels_With_Duplicate_Names_In_Payload
    [Documentation]    Verify that bulk creating channels with duplicate names within the same payload returns error.
    ...                ApiChannelServiceImpl.createListOfChannels() checks existingNames.size() != channelDtoList.size()
    ...                and returns BULK_CHANNEL_FAILED when duplicate channel names are detected in the batch.
    [Tags]    negative    channel    bulk    validation
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     ch_neg_21     ${gateway_url}:${gateway_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${channel_1}=      Create Dictionary
    ...    description=Bulk Dup Test 1
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_bulk_dup_channel
    ...    api_channel_path=/api/v1/e2e/bulk-dup-1
    ...    api_channel_method=GET
    ${channel_2}=      Create Dictionary
    ...    description=Bulk Dup Test 2 - same name as above
    ...    service_id=${valid_service_id}
    ...    api_channel_name=neg_bulk_dup_channel
    ...    api_channel_path=/api/v1/e2e/bulk-dup-2
    ...    api_channel_method=POST
    ${payload}=        Create List    ${channel_1}    ${channel_2}
    ${response}=       POST On Session    ch_neg_21    /api/v1/gateway/channel/bulk-insert    json=${payload}    headers=${headers}    expected_status=anything
    ${status_code}=    Convert To String    ${response.status_code}
    Should Not Be Equal    ${status_code}    ${expected_code}
    Log To Console    TC_21 PASS: Got error ${status_code} for bulk insert with duplicate channel names in payload
