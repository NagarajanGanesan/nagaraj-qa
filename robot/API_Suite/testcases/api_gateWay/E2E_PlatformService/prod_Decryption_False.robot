*** Settings ***
Resource     ../../../keywords/common.robot
Resource     ../../Lender_Config/05_addProduct_Positive.robot

*** Variables ***
# ─────────────────────────────────────────────────────────────
# RUNTIME variables
# ─────────────────────────────────────────────────────────────
${ch_description}          Platform E2E Testing
${api_method}              POST
${HMAC_SECRET_KEY}         xxx-hmac-secret-key
${REFRESH_COOKIE_NAME}     refresh_token
${rateLimit}               20
${periodSec}               1

# Test payloads
${valid_payload}           {"customerId": "TEST-001", "amount": 5000}
${tampered_payload}        {"customerId": "HACKED", "amount": 99999}

# Negative-test credential values
${invalid_client_id}       INVALID-CLIENT-0000000000000000
${invalid_api_key}         invalid-api-key-000000000000000000000000000000000000000000000000
${wrong_signature}         aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
${iso_timestamp}           2026-04-01T10:00:00
${old_timestamp}           20200101000000
${future_timestamp}        20990101000000

# Credential placeholders — filled by TC01_OneTime_Setup (read from gw_tc04_*)
${prod_client_id}          ${EMPTY}
${prod_api_key}            ${EMPTY}
${prod_channel_path}       ${EMPTY}

# Error codes returned by GatewayErrorHandler
${AUTH_MISSING_CODE}       CLIENT_AUTH_MISSING
${ROUTE_NOT_FOUND_CODE}    ROUTE_NOT_FOUND
${HMAC_ERROR_CODE}         HMAC
${API_EXPIRED_CODE}        API_EXPIRED

# ─────────────────────────────────────────────────────────────
# E2E Business API payloads (from Postman collections)
# KVB: adlogin, dedupe-check, loan-application, fetch, pledge
# Lender Portal: login, lender CRUD, product CRUD, invoke, revoke
# ─────────────────────────────────────────────────────────────
${login_payload}           {"username": "your-username", "userpassword": "your-password", "login_type": "NORMAL"}
${adlogin_payload}         {"username": "your-username", "userpassword": "your-password", "login_type": "AD"}
${dedupe_payload}          {"pan": "ABCDE1234F", "mobile": "9876543210", "dob": "1990-01-15", "name": "Test Customer"}
${loan_apply_payload}      {"customer_id": "CUST-TEST-001", "loan_type": "PERSONAL", "amount": 50000, "tenure": 12}
${pledge_payload}          {"customer_id": "CUST-TEST-001", "security_type": "MF", "isin": "INF111M01034"}
${PAYLOAD_INVALID_CODE}    PAYLOAD_INVALID

# ─────────────────────────────────────────────────────────────
# NOTE: One-time config IDs come from keywords/variables.robot (gw_tc04_*).
# ─────────────────────────────────────────────────────────────


*** Keywords ***

# ================================================================
# UTILITY
# ================================================================

_Compute Expiry Date
    [Documentation]    Returns a date randomly 2–6 months from today (YYYY-MM-DD).
    ${expiry}=    Evaluate
    ...    (__import__('datetime').datetime.now() + __import__('datetime').timedelta(days=__import__('random').randint(60, 180))).strftime('%Y-%m-%d')
    Log To Console    Expiry date = ${expiry}
    RETURN    ${expiry}

Generate Current Timestamp
    [Documentation]    Returns current datetime in 14-digit yyyyMMddHHmmss format.
    ${ts}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y%m%d%H%M%S')
    RETURN    ${ts}

Generate HMAC For Payload
    [Arguments]    ${payload}    ${timestamp}    ${secret_key}=${HMAC_SECRET_KEY}
    [Documentation]    HMAC-SHA256(payload::timestamp) for POST requests with body.
    ${message}=    Set Variable    ${payload}::${timestamp}
    ${sig}=    Evaluate
    ...    hmac.new($secret_key.encode('utf-8'), $message.encode('utf-8'), hashlib.sha256).hexdigest()
    ...    modules=hmac,hashlib
    RETURN    ${sig}

Generate HMAC For Timestamp Only
    [Arguments]    ${timestamp}    ${secret_key}=${HMAC_SECRET_KEY}
    [Documentation]    HMAC-SHA256(timestamp) for GET requests without body.
    ${sig}=    Evaluate
    ...    hmac.new($secret_key.encode('utf-8'), $timestamp.encode('utf-8'), hashlib.sha256).hexdigest()
    ...    modules=hmac,hashlib
    RETURN    ${sig}

Build POST Headers
    [Arguments]    ${payload}    ${cid}=${prod_client_id}    ${akey}=${prod_api_key}
    [Documentation]    Builds full HMAC POST headers: client-id, api-key, X-Timestamp, X-Request-Signature.
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${cid}
    ...    api-key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    RETURN    ${hdrs}

Build GET Headers
    [Arguments]    ${cid}=${prod_client_id}    ${akey}=${prod_api_key}
    [Documentation]    Builds HMAC GET headers: timestamp-only signature.
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    client-id=${cid}
    ...    api-key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    RETURN    ${hdrs}

Assert Gateway Error
    [Arguments]    ${response}    ${expected_http_status}    ${expected_error_code}
    ${status}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status}    ${expected_http_status}
    ${json}=    Convert String To Json    ${response.content}
    ${code_list}=    Get Value From Json    ${json}    $.code
    ${code}=    Get From List    ${code_list}    0
    Should Be Equal    ${code}    ${expected_error_code}

# ================================================================
# ONE-TIME SETUP KEYWORDS
# ================================================================

_Get Or Create Service
    ${rand_suffix}=    Generate Random String    6    [LETTERS]
    ${svc_name}=    Set Variable    Platform-${rand_suffix}
    ${svc_url}=     Set Variable    lb://platform-${rand_suffix}
    Set Suite Variable    ${svc_name}
    Set Suite Variable    ${svc_url}
    Log To Console    service_name=${svc_name}  service_url=${svc_url}
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    svc_sess    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary    status=${True}    service_name=${svc_name}    service_url=${svc_url}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    svc_sess    /api/v1/gateway/service
    ...    json=${body}    headers=${hdrs}    expected_status=anything
    IF    '${resp.status_code}' == '200'
        ${json}=    Convert String To Json    ${resp.content}
        ${ids}=    Get Value From Json    ${json}    data.service_id
        ${sid}=    Get From List    ${ids}    0
        Log To Console    Service created: id=${sid}
    ELSE
        ${get_resp}=    GET On Session    svc_sess    /api/v1/gateway/service
        ...    headers=${hdrs}    expected_status=anything
        ${get_json}=    Convert String To Json    ${get_resp.content}
        ${sid_list}=    Get Value From Json    ${get_json}
        ...    $.data[?(@.service_name=='${svc_name}')].service_id
        ${sid}=    Get From List    ${sid_list}    0
        Log To Console    Found existing service: id=${sid}
    END
    Set Suite Variable    ${sid}
    RETURN    ${sid}

_Create Channel
    [Arguments]    ${service_id}
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ch_sess    ${gw_url}:${gateway_port}
    ${ch_name}=    FakerLibrary.Safe Domain Name
    ${rand_suffix}=    Generate Random String    4    [NUMBERS]
    ${ch_path}=    Set Variable    /prod-dec-f-${rand_suffix}
    ${body}=    Create Dictionary
    ...    description=${ch_description}
    ...    service_id=${service_id}
    ...    api_channel_name=${ch_name}
    ...    api_channel_path=${ch_path}
    ...    api_channel_method=${api_method}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    ch_sess    /api/v1/gateway/channel
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Channel creation failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.api_channel_id
    ${cid}=    Get From List    ${ids}    0
    Set Suite Variable    ${ch_name}
    Set Suite Variable    ${ch_path}
    Set Suite Variable    ${cid}
    Log To Console    Channel id=${cid}  path=${ch_path}
    RETURN    ${cid}    ${ch_path}

_Create Partner Config And Map
    [Arguments]    ${channel_id}    ${product_id}    ${expiry_date}
    [Documentation]    POST partner-product-config (app_code=False) + channel mapping (decryption=False).
    ...                Fetches client_id + api_key from DB.
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ppc_sess    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    # Partner product config
    ${cfg_body}=    Create Dictionary
    ...    product_id=${product_id}
    ...    app_code_creation=${False}
    ...    expiry_date=${expiry_date}
    ${cfg_resp}=    POST On Session    ppc_sess    /api/v1/gateway/partner-product-config
    ...    json=${cfg_body}    headers=${hdrs}    expected_status=anything
    Log To Console    Partner config status=${cfg_resp.status_code}
    # Channel mapping — decryption_enabled=False
    ${map_body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    product_id=${product_id}
    ...    decryption_enabled=${False}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${map_resp}=    POST On Session    ppc_sess    /api/v1/gateway/channel-mapping
    ...    json=${map_body}    headers=${hdrs}    expected_status=anything
    Log To Console    Channel mapping (decryption=False) status=${map_resp.status_code}
    # Fetch credentials from DB
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT client_id, api_key FROM ${schemeName}.partner_product_config
    ...    WHERE products_id = ${product_id} AND app_code IS NULL AND status = true
    ...    ORDER BY created_at DESC LIMIT 1
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    ${cid}=    Get From List    ${row}    0
    ${ak}=     Get From List    ${row}    1
    Set Suite Variable    ${prod_client_id}    ${cid}
    Set Suite Variable    ${prod_api_key}      ${ak}
    Log To Console    prod_client_id=${cid}  prod_api_key=${ak}

_Refresh
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ref_m    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    GET On Session    ref_m    /api/v1/gateway/refresh-mapping    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    Log To Console    Refresh mapping → 200

_Refresh Routes
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ref_r    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    GET On Session    ref_r    /api/v1/gateway/refresh-mapping/routes    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    Log To Console    Refresh routes → 200

_Load Regression Credentials
    [Documentation]    Loads stored IDs from variables.robot (gw_tc04_*) into local suite variables.
    Set Suite Variable    ${prod_client_id}    ${gw_tc04_client_id}
    Set Suite Variable    ${prod_api_key}      ${gw_tc04_api_key}
    Set Suite Variable    ${prod_channel_path} ${gw_tc04_channel_path}
    Should Not Be Empty    ${prod_client_id}
    ...    msg=gw_tc04_client_id is empty — run TC01_OneTime_Setup first and fill variables.robot
    Should Not Be Empty    ${prod_channel_path}
    ...    msg=gw_tc04_channel_path is empty — run TC01_OneTime_Setup first and fill variables.robot

Assert Response Is Plain JSON
    [Arguments]    ${response}
    [Documentation]    Verifies response body is parseable as JSON AND starts with { or [.
    ...                For decryption_enabled=False this confirms the gateway does NOT encrypt
    ...                the response — plain text is forwarded as-is from the backend.
    ${body}=    Convert To String    ${response.content}
    Should Not Be Empty    ${body}    msg=Response body is empty
    ${json}=    Convert String To Json    ${response.content}
    Should Match Regexp    ${body.strip()}    ^[\\[{]
    ...    msg=Response body does not start with { or [ — gateway may be encrypting responses
    RETURN    ${json}


*** Test Cases ***

# ════════════════════════════════════════════════════════════════
# ONE-TIME SETUP
# Tag: setup  →  robot --include setup prod_Decryption_False.robot
# ════════════════════════════════════════════════════════════════

TC01_OneTime_Setup
    [Tags]    setup
    [Documentation]
    ...    ONE-TIME: service → channel → product → partner config (app_code_creation=False)
    ...    → channel mapping (decryption_enabled=False) → refresh.
    ...    Copy the printed IDs into keywords/variables.robot under gw_tc04_* variables.
    ${expiry_date}=    _Compute Expiry Date
    ${service_id}=    _Get Or Create Service
    ${channel_id}    ${channel_path}=    _Create Channel    ${service_id}
    ${product_id}=    TC05_Product_Positive    True    ${lender_id}    ${lender_name}
    ...    ${Distributor_id}    ${DistributorName}    True    True
    _Create Partner Config And Map    ${channel_id}    ${product_id}    ${expiry_date}
    _Refresh
    _Refresh Routes
    Log To Console    ════════════════════════════════════════
    Log To Console    TC01 Setup complete — copy to variables.robot:
    Log To Console    \${gw_tc04_service_id}    ${service_id}
    Log To Console    \${gw_tc04_channel_id}    ${channel_id}
    Log To Console    \${gw_tc04_channel_path}  ${channel_path}
    Log To Console    \${gw_tc04_product_id}    ${product_id}
    Log To Console    \${gw_tc04_client_id}     ${prod_client_id}
    Log To Console    \${gw_tc04_api_key}       ${prod_api_key}
    Log To Console    ════════════════════════════════════════

# ════════════════════════════════════════════════════════════════
# REGRESSION — POSITIVE: Valid HMAC flow (decryption_enabled=False)
# Tag: regression  →  robot --include regression prod_Decryption_False.robot
# ════════════════════════════════════════════════════════════════

TC_F01_Valid_POST_With_HMAC_Payload_Timestamp
    [Tags]    regression    positive    hmac
    [Documentation]
    ...    Valid POST: correct client-id, api-key, HMAC-SHA256(payload::timestamp).
    ...    Gateway forwards payload as-is (decryption_enabled=False).
    ...    Expected: not 401 (HMAC auth passes).
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f01    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${valid_payload}
    ${resp}=    POST On Session    tc_f01    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_F01 PASS: Valid HMAC POST accepted — status=${resp.status_code}

TC_F02_Valid_GET_With_Timestamp_Only_HMAC
    [Tags]    regression    positive    hmac    get
    [Documentation]
    ...    Valid GET: HMAC-SHA256(timestamp only). No body — timestamp-only signature.
    ...    Expected: not 401.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f02    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build GET Headers
    ${resp}=    GET On Session    tc_f02    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_F02 PASS: Valid HMAC GET accepted — status=${resp.status_code}

TC_F03_Timestamp_Must_Be_14_Digit_yyyyMMddHHmmss
    [Tags]    regression    positive    timestamp
    [Documentation]
    ...    Validates that Generate Current Timestamp produces exactly 14 digits
    ...    matching yyyyMMddHHmmss. Gateway uses GatewayConstants.SIGNATURE_DATE_FORMAT.
    _Load Regression Credentials
    ${ts}=    Generate Current Timestamp
    Should Match Regexp    ${ts}    ^\\d{14}$
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f03    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_f03    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_F03 PASS: 14-digit timestamp accepted — status=${resp.status_code}

TC_F04_Five_Requests_Within_Rate_Limit
    [Tags]    regression    positive    rate_limit
    [Documentation]
    ...    5 consecutive requests within rateLimit=${rateLimit}/period=${periodSec}s.
    ...    RedisRateLimiter token bucket — none should be 429.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f04    ${gw_url}:${gateway_port}    verify=false
    FOR    ${idx}    IN RANGE    1    6
        ${hdrs}=    Build POST Headers    ${valid_payload}
        ${resp}=    POST On Session    tc_f04    ${prod_channel_path}
        ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
        Should Not Be Equal As Strings    ${resp.status_code}    429
        Log To Console    Request ${idx}: ${resp.status_code}
    END
    Log To Console    TC_F04 PASS: 5 requests within rate limit — none rejected with 429

# ════════════════════════════════════════════════════════════════
# REGRESSION — NEGATIVE: Missing Auth Headers
# GatewayErrorHandler: !hasText(clientId) || !hasText(apiKey) → CLIENT_AUTH_MISSING
# ════════════════════════════════════════════════════════════════

TC_F05_Missing_XClientId_Returns_CLIENT_AUTH_MISSING
    [Tags]    regression    negative    auth
    [Documentation]    No client-id → 401 CLIENT_AUTH_MISSING.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f05    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_f05    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_F05 PASS: Missing client-id → 401 CLIENT_AUTH_MISSING

TC_F06_Missing_XApiKey_Returns_CLIENT_AUTH_MISSING
    [Tags]    regression    negative    auth
    [Documentation]    No api-key → 401 CLIENT_AUTH_MISSING.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f06    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_f06    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_F06 PASS: Missing api-key → 401 CLIENT_AUTH_MISSING

TC_F07_Both_Auth_Headers_Missing_Returns_CLIENT_AUTH_MISSING
    [Tags]    regression    negative    auth
    [Documentation]    Both client-id and api-key absent → 401 CLIENT_AUTH_MISSING.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f07    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    tc_f07    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_F07 PASS: Both auth headers missing → 401 CLIENT_AUTH_MISSING

# ════════════════════════════════════════════════════════════════
# REGRESSION — NEGATIVE: Route Not Found
# Dummy cookie included so GatewayErrorHandler reaches ROUTE_NOT_FOUND
# (without cookie → COOKIE_MISSING; with dummy cookie → ROUTE_NOT_FOUND)
# ════════════════════════════════════════════════════════════════

TC_F08_Invalid_ClientId_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Unregistered client-id → route predicate fails → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f08    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${invalid_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session    tc_f08    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_F08 PASS: Invalid client-id → 401 ROUTE_NOT_FOUND

TC_F09_Invalid_ApiKey_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Wrong api-key → route predicate fails → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f09    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${invalid_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session    tc_f09    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_F09 PASS: Invalid api-key → 401 ROUTE_NOT_FOUND

TC_F10_Non_Configured_Path_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Path not registered in ApiChannel → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f10    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    GET On Session    tc_f10    /api/v1/nonexistent/path/xyz
    ...    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_F10 PASS: Non-configured path → 401 ROUTE_NOT_FOUND

TC_F11_Wrong_HTTP_Method_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Channel registered for POST. Sending DELETE fails method predicate → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f11    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    DELETE On Session    tc_f11    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_F11 PASS: Wrong HTTP method (DELETE on POST route) → 401 ROUTE_NOT_FOUND

# ════════════════════════════════════════════════════════════════
# REGRESSION — NEGATIVE: HMAC Validation
# SessionTokenAuthGatewayFilter: requiresHmacValidation()=true for product mode
# ════════════════════════════════════════════════════════════════

TC_F12_Missing_Timestamp_Returns_HMAC
    [Tags]    regression    negative    hmac
    [Documentation]    No X-Timestamp → isValidHmacForBody() fails → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f12    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_f12    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_F12 PASS: Missing X-Timestamp → 401 HMAC

TC_F13_Missing_Signature_Returns_HMAC
    [Tags]    regression    negative    hmac
    [Documentation]    No X-Request-Signature → isValidHmacForBody() fails → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f13    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ${resp}=    POST On Session    tc_f13    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_F13 PASS: Missing X-Request-Signature → 401 HMAC

TC_F14_Wrong_Signature_Returns_HMAC
    [Tags]    regression    negative    hmac
    [Documentation]    Valid credentials + timestamp but random wrong signature → 401 HMAC.
    ...                constantTimeEquals(clientHmac, serverHmac) = false.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f14    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_f14    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_F14 PASS: Wrong HMAC signature → 401 HMAC

TC_F15_Tampered_Payload_Returns_HMAC
    [Tags]    regression    negative    hmac    security
    [Documentation]    Sign original payload; send tampered body.
    ...                Gateway recomputes HMAC(tampered::ts) ≠ original sig → 401 HMAC.
    ...                Validates payload integrity.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f15    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${original_sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${original_sig}
    ${resp}=    POST On Session    tc_f15    ${prod_channel_path}
    ...    data=${tampered_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_F15 PASS: Tampered payload + original signature → 401 HMAC

TC_F16_ISO_Timestamp_Format_Returns_HMAC
    [Tags]    regression    negative    hmac    timestamp
    [Documentation]    ISO-8601 format (2026-04-01T10:00:00) instead of yyyyMMddHHmmss.
    ...                Server uses correct-format ts → HMAC mismatch → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f16    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${iso_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${iso_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_f16    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_F16 PASS: ISO-8601 timestamp format rejected → 401 HMAC

TC_F17_Old_Timestamp_Replay_Attack_Test
    [Tags]    regression    negative    hmac    replay    security
    [Documentation]    Old timestamp 20200101000000 with valid HMAC — replay attack test.
    ...                Logs result; does not hard-fail since gateway may not enforce freshness.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f17    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${old_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${old_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_f17    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${status}=    Convert To String    ${resp.status_code}
    Should Not Be Equal As Strings    ${status}    500
    IF    '${status}' == '401'
        Log To Console    TC_F17 PASS: Old timestamp replay rejected — status=401
    ELSE
        Log To Console    TC_F17 WARN: Old timestamp NOT rejected (no freshness check) — status=${status}
    END

TC_F18_Future_Timestamp_Test
    [Tags]    regression    negative    hmac    timestamp
    [Documentation]    Far-future timestamp 20990101000000 — tests out-of-range rejection.
    ...                Logs result; does not hard-fail since gateway may not enforce freshness.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f18    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${future_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${future_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_f18    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${status}=    Convert To String    ${resp.status_code}
    Should Not Be Equal As Strings    ${status}    500
    IF    '${status}' == '401'
        Log To Console    TC_F18 PASS: Future timestamp (2099) rejected — status=401
    ELSE
        Log To Console    TC_F18 WARN: Future timestamp NOT rejected — status=${status}
    END

# ════════════════════════════════════════════════════════════════
# REGRESSION — E2E Business API Scenarios (decryption_enabled=False)
# Calls real business API payloads from the Postman collections
# (KVB + Lender Portal) through the gateway using HMAC product mode.
# Verifies:
#   1. HMAC auth passes for real-world request bodies
#   2. Response body is plain-text JSON (gateway does NOT encrypt responses)
#   3. The full request → gateway(HMAC) → backend → response flow works
# Tag: regression e2e
# ════════════════════════════════════════════════════════════════

TC_F19_Login_API_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api
    [Documentation]
    ...    E2E: POST login payload through gateway (decryption_enabled=False).
    ...    Source: Lender Portal Postman — POST /api/v1/auth/login.
    ...    Gateway forwards payload as-is (no decryption), backend responds.
    ...    Asserts: HMAC passes (not 401), response body is parseable JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f19    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${login_payload}
    ${resp}=    POST On Session    tc_f19    ${prod_channel_path}
    ...    data=${login_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed — check gw_tc04_client_id/gw_tc04_api_key in variables.robot
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F19 PASS: Login payload HMAC accepted → status=${resp.status_code}

TC_F20_AD_Login_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api
    [Documentation]
    ...    E2E: POST AD-login payload through gateway (decryption_enabled=False).
    ...    Source: KVB Postman — POST /api/v1/auth/adlogin.
    ...    Asserts: HMAC passes, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f20    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${adlogin_payload}
    ${resp}=    POST On Session    tc_f20    ${prod_channel_path}
    ...    data=${adlogin_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed for AD-login payload
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F20 PASS: AD-login payload HMAC accepted → status=${resp.status_code}

TC_F21_Dedupe_Check_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api
    [Documentation]
    ...    E2E: POST dedupe-check payload through gateway (decryption_enabled=False).
    ...    Source: KVB Postman — POST /api/v1/dedupe-check.
    ...    Asserts: HMAC passes, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f21    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${dedupe_payload}
    ${resp}=    POST On Session    tc_f21    ${prod_channel_path}
    ...    data=${dedupe_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed for dedupe-check payload
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F21 PASS: Dedupe-check payload HMAC accepted → status=${resp.status_code}

TC_F22_Lender_Listing_GET_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api    get
    [Documentation]
    ...    E2E: GET lender listing through gateway (decryption_enabled=False).
    ...    Source: Lender Portal Postman — GET /api/v1/lender.
    ...    No body → HMAC(timestamp only). Asserts: not 401, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f22    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build GET Headers
    ${resp}=    GET On Session    tc_f22    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC GET auth failed for lender listing
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F22 PASS: Lender GET HMAC accepted → status=${resp.status_code}

TC_F23_Product_Listing_GET_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api    get
    [Documentation]
    ...    E2E: GET product listing through gateway (decryption_enabled=False).
    ...    Source: KVB + Lender Portal Postman — GET /api/v1/product.
    ...    Asserts: not 401, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f23    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build GET Headers
    ${resp}=    GET On Session    tc_f23    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC GET auth failed for product listing
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F23 PASS: Product GET HMAC accepted → status=${resp.status_code}

TC_F24_Loan_Application_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api
    [Documentation]
    ...    E2E: POST loan-application payload through gateway (decryption_enabled=False).
    ...    Source: KVB Postman — POST /api/v1/loan-application/apply.
    ...    Asserts: HMAC passes, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f24    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${loan_apply_payload}
    ${resp}=    POST On Session    tc_f24    ${prod_channel_path}
    ...    data=${loan_apply_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed for loan-application payload
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F24 PASS: Loan-application payload HMAC accepted → status=${resp.status_code}

TC_F25_Pledge_Initiate_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api
    [Documentation]
    ...    E2E: POST pledge-initiate payload through gateway (decryption_enabled=False).
    ...    Source: KVB Postman — POST /api/v1/pledge/initiate.
    ...    Asserts: HMAC passes, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f25    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${pledge_payload}
    ${resp}=    POST On Session    tc_f25    ${prod_channel_path}
    ...    data=${pledge_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed for pledge-initiate payload
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F25 PASS: Pledge-initiate payload HMAC accepted → status=${resp.status_code}

TC_F26_Response_Is_Plaintext_JSON_Not_AES_Encrypted
    [Tags]    regression    e2e    decrypt_verify
    [Documentation]
    ...    KEY ASSERTION for decryption_enabled=False:
    ...    Explicitly verifies the gateway does NOT encrypt the response body.
    ...    When decryption_enabled=False the modifyResponseBody filter is NOT applied
    ...    (see ApiChannelLocatorImpl.java line 265: if(decryptionEnabled)).
    ...    Method: send valid HMAC POST → assert response body parses as JSON AND
    ...    begins with { or [ (raw JSON, not a base64-AES blob).
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f26    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${login_payload}
    ${resp}=    POST On Session    tc_f26    ${prod_channel_path}
    ...    data=${login_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ${body}=    Convert To String    ${resp.content}
    Should Not Be Empty    ${body}    msg=Response body is empty
    # Must parse as JSON — encrypted AES-GCM blobs are not valid JSON
    ${json}=    Convert String To Json    ${resp.content}
    # Body must begin with { or [ — base64 AES blobs start with alphanumeric chars
    Should Match Regexp    ${body.strip()}    ^[\\[{]
    ...    msg=Response body does not look like JSON — gateway may be encrypting it (unexpected for decrypt=False)
    Log To Console    TC_F26 PASS: Response is plain-text JSON (decrypt=False confirmed — no response encryption)

TC_F27_Lender_Create_Via_Gateway_Decrypt_Off
    [Tags]    regression    e2e    business_api
    [Documentation]
    ...    E2E: POST lender-create payload through gateway (decryption_enabled=False).
    ...    Source: Lender Portal Postman — POST /api/v1/lender.
    ...    Asserts: HMAC passes, response is valid JSON.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_f27    ${gw_url}:${gateway_port}    verify=false
    ${rand_suffix}=    Generate Random String    4    [NUMBERS]
    ${lender_body}=    Set Variable    {"lender_name": "TestLender${rand_suffix}", "status": true, "lender_code": "TL${rand_suffix}"}
    ${hdrs}=    Build POST Headers    ${lender_body}
    ${resp}=    POST On Session    tc_f27    ${prod_channel_path}
    ...    data=${lender_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed for lender-create payload
    Assert Response Is Plain JSON    ${resp}
    Log To Console    TC_F27 PASS: Lender-create payload HMAC accepted → status=${resp.status_code}
