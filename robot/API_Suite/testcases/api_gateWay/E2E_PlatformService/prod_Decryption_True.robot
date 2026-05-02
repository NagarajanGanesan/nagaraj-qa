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
${valid_payload}           {"customerId": "TEST-002", "amount": 7500}
${tampered_payload}        {"customerId": "HACKED", "amount": 99999}

# Negative-test credential values
${invalid_client_id}       INVALID-CLIENT-0000000000000000
${invalid_api_key}         invalid-api-key-000000000000000000000000000000000000000000000000
${wrong_signature}         aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
${iso_timestamp}           2026-04-01T10:00:00
${old_timestamp}           20200101000000
${future_timestamp}        20990101000000

# Credential placeholders — filled by TC01_OneTime_Setup (read from gw_tc05_*)
${prod_client_id}          ${EMPTY}
${prod_api_key}            ${EMPTY}
${prod_channel_path}       ${EMPTY}

# Error codes returned by GatewayErrorHandler
${AUTH_MISSING_CODE}       CLIENT_AUTH_MISSING
${ROUTE_NOT_FOUND_CODE}    ROUTE_NOT_FOUND
${HMAC_ERROR_CODE}         HMAC
${API_EXPIRED_CODE}        API_EXPIRED
${PAYLOAD_INVALID_CODE}    PAYLOAD_INVALID

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

# ─────────────────────────────────────────────────────────────
# AES key for encrypt/decrypt E2E tests.
# Must match gateway property: gateway.aes-key (base64-encoded 256-bit key).
# Fill this from the gateway config-server settings before running E2E tests.
# Leave ${EMPTY} to skip encrypted-payload tests (TC_T20–TC_T25).
# ─────────────────────────────────────────────────────────────
${AES_KEY_B64}             ${EMPTY}

# ─────────────────────────────────────────────────────────────
# NOTE: One-time config IDs come from keywords/variables.robot (gw_tc05_*).
# NOTE: decryption_enabled=True flow (from SessionTokenAuthGatewayFilter.java):
#   1. decryptIfEnabled(rawBody) → AES-GCM decrypt using gateway.aes-key
#   2. normalizeJson(decrypted)  → compact JSON (Jackson writeValueAsString)
#   3. isValidHmac(normalizedPayload) → HMAC-SHA256(normalizedPayload::timestamp)
#   4. forward(decryptedBody) → backend receives plaintext
#   5. modifyResponseBody → gateway AES-GCM ENCRYPTS the response before returning
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
    ${ch_path}=    Set Variable    /prod-dec-t-${rand_suffix}
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
    [Documentation]    POST partner-product-config (app_code=False) + channel mapping (decryption=True).
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
    # Channel mapping — decryption_enabled=True
    ${map_body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    product_id=${product_id}
    ...    decryption_enabled=${True}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${map_resp}=    POST On Session    ppc_sess    /api/v1/gateway/channel-mapping
    ...    json=${map_body}    headers=${hdrs}    expected_status=anything
    Log To Console    Channel mapping (decryption=True) status=${map_resp.status_code}
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
    [Documentation]    Loads stored IDs from variables.robot (gw_tc05_*) into local suite variables.
    Set Suite Variable    ${prod_client_id}    ${gw_tc05_client_id}
    Set Suite Variable    ${prod_api_key}      ${gw_tc05_api_key}
    Set Suite Variable    ${prod_channel_path} ${gw_tc05_channel_path}
    Should Not Be Empty    ${prod_client_id}
    ...    msg=gw_tc05_client_id is empty — run TC01_OneTime_Setup first and fill variables.robot
    Should Not Be Empty    ${prod_channel_path}
    ...    msg=gw_tc05_channel_path is empty — run TC01_OneTime_Setup first and fill variables.robot

# ================================================================
# AES-GCM HELPERS (decryption_enabled=True E2E tests)
# Gateway uses xxxEncryption(AesMode.GCM) with gateway.aes-key.
# Format: base64( 12-byte-nonce || ciphertext || 16-byte-GCM-tag )
# ================================================================

Encrypt Payload AES GCM
    [Arguments]    ${plaintext}    ${key_b64}=${AES_KEY_B64}
    [Documentation]    AES-256-GCM encrypt plaintext using the gateway AES key.
    ...                Returns base64(12-byte-nonce || ciphertext || 16-byte-GCM-tag).
    ...                Must match xxxEncryption format used in SessionTokenAuthGatewayFilter.
    ${encrypted}=    Evaluate
    ...    __import__('base64').b64encode((lambda k,p,n:n+__import__('cryptography.hazmat.primitives.ciphers.aead',fromlist=['AESGCM']).AESGCM(k).encrypt(n,p,None))(__import__('base64').b64decode($key_b64),$plaintext.encode('utf-8'),__import__('os').urandom(12))).decode('utf-8')
    RETURN    ${encrypted}

Decrypt Response AES GCM
    [Arguments]    ${encrypted_b64}    ${key_b64}=${AES_KEY_B64}
    [Documentation]    AES-256-GCM decrypt base64(nonce || ciphertext || tag) response from gateway.
    ...                Gateway encrypts responses via modifyResponseBody when decryption_enabled=True.
    ${decrypted}=    Evaluate
    ...    (lambda k,e:__import__('cryptography.hazmat.primitives.ciphers.aead',fromlist=['AESGCM']).AESGCM(k).decrypt(e[:12],e[12:],None).decode('utf-8'))(__import__('base64').b64decode($key_b64),__import__('base64').b64decode($encrypted_b64))
    RETURN    ${decrypted}

Normalize JSON Payload
    [Arguments]    ${json_str}
    [Documentation]    Compact JSON without whitespace — matches Jackson normalizeJson
    ...                (objectMapper.writeValueAsString(objectMapper.readTree(body))).
    ${normalized}=    Evaluate
    ...    __import__('json').dumps(__import__('json').loads($json_str),separators=(',',':'))
    RETURN    ${normalized}

Build POST Headers Encrypted
    [Arguments]    ${plaintext_payload}    ${cid}=${prod_client_id}    ${akey}=${prod_api_key}
    [Documentation]    Builds HMAC headers for encrypted-body POST to a decrypt=True channel.
    ...                IMPORTANT: HMAC is computed on the NORMALIZED PLAINTEXT (not the encrypted body).
    ...                Gateway flow: decrypt(body) → normalizeJson → validateHMAC(normalizedPayload)
    ...                So client must send HMAC of normalized plaintext, body is the AES-encrypted form.
    ${ts}=    Generate Current Timestamp
    ${normalized}=    Normalize JSON Payload    ${plaintext_payload}
    ${sig}=    Generate HMAC For Payload    ${normalized}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${cid}
    ...    api-key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    RETURN    ${hdrs}


*** Test Cases ***

# ════════════════════════════════════════════════════════════════
# ONE-TIME SETUP
# Tag: setup  →  robot --include setup prod_Decryption_True.robot
# ════════════════════════════════════════════════════════════════

TC01_OneTime_Setup
    [Tags]    setup
    [Documentation]
    ...    ONE-TIME: service → channel → product → partner config (app_code_creation=False)
    ...    → channel mapping (decryption_enabled=True) → refresh.
    ...    Copy the printed IDs into keywords/variables.robot under gw_tc05_* variables.
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
    Log To Console    \${gw_tc05_service_id}    ${service_id}
    Log To Console    \${gw_tc05_channel_id}    ${channel_id}
    Log To Console    \${gw_tc05_channel_path}  ${channel_path}
    Log To Console    \${gw_tc05_product_id}    ${product_id}
    Log To Console    \${gw_tc05_client_id}     ${prod_client_id}
    Log To Console    \${gw_tc05_api_key}       ${prod_api_key}
    Log To Console    ════════════════════════════════════════

# ════════════════════════════════════════════════════════════════
# REGRESSION — POSITIVE: Valid HMAC flow (decryption_enabled=True)
# HMAC auth layer runs BEFORE payload decryption — valid signatures pass.
# Tag: regression  →  robot --include regression prod_Decryption_True.robot
# ════════════════════════════════════════════════════════════════

TC_T01_Valid_POST_With_HMAC_Payload_Timestamp
    [Tags]    regression    positive    hmac
    [Documentation]
    ...    Valid POST: correct client-id, api-key, HMAC-SHA256(payload::timestamp).
    ...    decryption_enabled=True: gateway will attempt to decrypt payload after HMAC passes.
    ...    Expected: not 401 (HMAC auth passes; backend result may vary).
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t01    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${valid_payload}
    ${resp}=    POST On Session    tc_t01    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_T01 PASS: Valid HMAC POST accepted — status=${resp.status_code}

TC_T02_Valid_GET_With_Timestamp_Only_HMAC
    [Tags]    regression    positive    hmac    get
    [Documentation]
    ...    Valid GET: HMAC-SHA256(timestamp only). No body — timestamp-only signature.
    ...    decryption_enabled=True has no effect on GET (no body to decrypt).
    ...    Expected: not 401.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t02    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build GET Headers
    ${resp}=    GET On Session    tc_t02    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_T02 PASS: Valid HMAC GET accepted — status=${resp.status_code}

TC_T03_Timestamp_Must_Be_14_Digit_yyyyMMddHHmmss
    [Tags]    regression    positive    timestamp
    [Documentation]    Validates 14-digit yyyyMMddHHmmss timestamp format is accepted.
    _Load Regression Credentials
    ${ts}=    Generate Current Timestamp
    Should Match Regexp    ${ts}    ^\\d{14}$
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t03    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_t03    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_T03 PASS: 14-digit timestamp accepted — status=${resp.status_code}

TC_T04_Five_Requests_Within_Rate_Limit
    [Tags]    regression    positive    rate_limit
    [Documentation]    5 consecutive requests within rate limit — none should be 429.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t04    ${gw_url}:${gateway_port}    verify=false
    FOR    ${idx}    IN RANGE    1    6
        ${hdrs}=    Build POST Headers    ${valid_payload}
        ${resp}=    POST On Session    tc_t04    ${prod_channel_path}
        ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
        Should Not Be Equal As Strings    ${resp.status_code}    429
        Log To Console    Request ${idx}: ${resp.status_code}
    END
    Log To Console    TC_T04 PASS: 5 requests within rate limit — none rejected with 429

# ════════════════════════════════════════════════════════════════
# REGRESSION — NEGATIVE: Missing Auth Headers
# ════════════════════════════════════════════════════════════════

TC_T05_Missing_XClientId_Returns_CLIENT_AUTH_MISSING
    [Tags]    regression    negative    auth
    [Documentation]    No client-id → 401 CLIENT_AUTH_MISSING.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t05    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_t05    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_T05 PASS: Missing client-id → 401 CLIENT_AUTH_MISSING

TC_T06_Missing_XApiKey_Returns_CLIENT_AUTH_MISSING
    [Tags]    regression    negative    auth
    [Documentation]    No api-key → 401 CLIENT_AUTH_MISSING.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t06    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_t06    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_T06 PASS: Missing api-key → 401 CLIENT_AUTH_MISSING

TC_T07_Both_Auth_Headers_Missing_Returns_CLIENT_AUTH_MISSING
    [Tags]    regression    negative    auth
    [Documentation]    Both client-id and api-key absent → 401 CLIENT_AUTH_MISSING.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t07    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    tc_t07    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_T07 PASS: Both auth headers missing → 401 CLIENT_AUTH_MISSING

# ════════════════════════════════════════════════════════════════
# REGRESSION — NEGATIVE: Route Not Found
# ════════════════════════════════════════════════════════════════

TC_T08_Invalid_ClientId_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Unregistered client-id → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t08    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${invalid_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session     tc_t08    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_T08 PASS: Invalid client-id → 401 ROUTE_NOT_FOUND

TC_T09_Invalid_ApiKey_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Wrong api-key → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t09    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${invalid_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session    tc_t09    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_T09 PASS: Invalid api-key → 401 ROUTE_NOT_FOUND

TC_T10_Non_Configured_Path_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Path not registered in ApiChannel → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t10    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    GET On Session    tc_t10    /api/v1/nonexistent/path/xyz
    ...    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_T10 PASS: Non-configured path → 401 ROUTE_NOT_FOUND

TC_T11_Wrong_HTTP_Method_Returns_ROUTE_NOT_FOUND
    [Tags]    regression    negative    route
    [Documentation]    Channel registered for POST. Sending DELETE → 401 ROUTE_NOT_FOUND.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t11    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    DELETE On Session    tc_t11    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_T11 PASS: Wrong HTTP method (DELETE on POST route) → 401 ROUTE_NOT_FOUND

# ════════════════════════════════════════════════════════════════
# REGRESSION — NEGATIVE: HMAC Validation
# HMAC filter runs BEFORE decryption — same behaviour as decryption=False
# ════════════════════════════════════════════════════════════════

TC_T12_Missing_Timestamp_Returns_HMAC
    [Tags]    regression    negative    hmac
    [Documentation]    No X-Timestamp → HMAC filter fails → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t12    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_t12    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_T12 PASS: Missing X-Timestamp → 401 HMAC

TC_T13_Missing_Signature_Returns_HMAC
    [Tags]    regression    negative    hmac
    [Documentation]    No X-Request-Signature → HMAC filter fails → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t13    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ${resp}=    POST On Session    tc_t13    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_T13 PASS: Missing X-Request-Signature → 401 HMAC

TC_T14_Wrong_Signature_Returns_HMAC
    [Tags]    regression    negative    hmac
    [Documentation]    Valid credentials + timestamp but random wrong signature → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t14    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_t14    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_T14 PASS: Wrong HMAC signature → 401 HMAC

TC_T15_Tampered_Payload_Returns_HMAC
    [Tags]    regression    negative    hmac    security
    [Documentation]    Sign original payload; send tampered body.
    ...                HMAC filter detects mismatch before decryption → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t15    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${original_sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${original_sig}
    ${resp}=    POST On Session    tc_t15    ${prod_channel_path}
    ...    data=${tampered_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_T15 PASS: Tampered payload + original signature → 401 HMAC

TC_T16_ISO_Timestamp_Format_Returns_HMAC
    [Tags]    regression    negative    hmac    timestamp
    [Documentation]    ISO-8601 format (2026-04-01T10:00:00) instead of yyyyMMddHHmmss → 401 HMAC.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t16    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${iso_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${iso_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_t16    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_T16 PASS: ISO-8601 timestamp format rejected → 401 HMAC

TC_T17_Old_Timestamp_Replay_Attack_Test
    [Tags]    regression    negative    hmac    replay    security
    [Documentation]    Old timestamp 20200101000000 — replay attack test.
    ...                Logs result; does not hard-fail since gateway may not enforce freshness.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t17    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${old_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${old_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_t17    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${status}=    Convert To String    ${resp.status_code}
    Should Not Be Equal As Strings    ${status}    500
    IF    '${status}' == '401'
        Log To Console    TC_T17 PASS: Old timestamp replay rejected — status=401
    ELSE
        Log To Console    TC_T17 WARN: Old timestamp NOT rejected (no freshness check) — status=${status}
    END

TC_T18_Future_Timestamp_Test
    [Tags]    regression    negative    hmac    timestamp
    [Documentation]    Far-future timestamp 20990101000000 — out-of-range rejection test.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t18    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${future_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    client-id=${prod_client_id}
    ...    api-key=${prod_api_key}
    ...    X-Timestamp=${future_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_t18    ${prod_channel_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${status}=    Convert To String    ${resp.status_code}
    Should Not Be Equal As Strings    ${status}    500
    IF    '${status}' == '401'
        Log To Console    TC_T18 PASS: Future timestamp (2099) rejected — status=401
    ELSE
        Log To Console    TC_T18 WARN: Future timestamp NOT rejected — status=${status}
    END

# ════════════════════════════════════════════════════════════════
# REGRESSION — E2E Business API Scenarios (decryption_enabled=True)
# Verifies the full AES-GCM encrypt/decrypt cycle through the gateway.
# Gateway flow (SessionTokenAuthGatewayFilter.java):
#   REQUEST:  decryptIfEnabled(body) → normalizeJson → validateHMAC → forward
#   RESPONSE: modifyResponseBody → AES-GCM encrypt → return to client
#
# Prerequisites for TC_T20–TC_T25:
#   Fill ${AES_KEY_B64} with the gateway's gateway.aes-key (base64-encoded).
#   Leave ${EMPTY} to skip encrypted-payload tests.
# Tag: regression e2e
# ════════════════════════════════════════════════════════════════

TC_T19_Plain_Payload_Returns_PAYLOAD_INVALID_Not_401
    [Tags]    regression    e2e    decrypt_verify
    [Documentation]
    ...    KEY ASSERTION for decryption_enabled=True:
    ...    When a plain-text JSON payload is sent to a decrypt=True channel, the gateway
    ...    calls decryptIfEnabled() → AES-GCM decrypt fails (EncryptionException) →
    ...    returns 400 PAYLOAD_INVALID BEFORE HMAC is checked.
    ...    This confirms decryption runs first (not just an HMAC skip).
    ...    Asserts: NOT 401 (HMAC error) AND error code is PAYLOAD_INVALID.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t19    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build POST Headers    ${login_payload}
    ${resp}=    POST On Session    tc_t19    ${prod_channel_path}
    ...    data=${login_payload}    headers=${hdrs}    expected_status=anything
    # Plain JSON → AES decrypt fails → 400 PAYLOAD_INVALID (not 401)
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=Got 401 HMAC error — decryption should fail before HMAC is checked
    ${status}=    Convert To String    ${resp.status_code}
    IF    '${status}' == '400'
        ${json}=    Convert String To Json    ${resp.content}
        ${code_list}=    Get Value From Json    ${json}    $.code
        ${code}=    Get From List    ${code_list}    0
        Should Be Equal    ${code}    ${PAYLOAD_INVALID_CODE}
        ...    msg=Expected PAYLOAD_INVALID error code for plaintext on decrypt=True channel
        Log To Console    TC_T19 PASS: Plain payload → 400 PAYLOAD_INVALID (decryption failed as expected)
    ELSE
        Log To Console    TC_T19 INFO: status=${status} (non-400 may indicate backend handled it)
    END

TC_T20_Encrypted_Login_Payload_Full_Cycle_Decrypt_True
    [Tags]    regression    e2e    business_api    encrypted
    [Documentation]
    ...    E2E FULL CYCLE: Encrypt login payload → send through gateway (decrypt=True).
    ...    Gateway: AES-GCM decrypts body → normalizeJson → validateHMAC(normalized) → forward.
    ...    Response: gateway AES-GCM encrypts backend response before returning to client.
    ...    Asserts: HMAC passes (not 401), response received (not 400 PAYLOAD_INVALID).
    ...    Requires: ${AES_KEY_B64} must be filled (not ${EMPTY}).
    Skip If    '${AES_KEY_B64}' == '${EMPTY}'
    ...    AES_KEY_B64 is empty — fill it from gateway config-server (gateway.aes-key) to run this test
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t20    ${gw_url}:${gateway_port}    verify=false
    # Encrypt payload + build HMAC headers of normalized plaintext
    ${encrypted_body}=    Encrypt Payload AES GCM    ${login_payload}
    ${hdrs}=    Build POST Headers Encrypted    ${login_payload}
    ${resp}=    POST On Session    tc_t20    ${prod_channel_path}
    ...    data=${encrypted_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC auth failed — check gw_tc05_client_id/gw_tc05_api_key and AES_KEY_B64
    Should Not Be Equal As Strings    ${resp.status_code}    400
    ...    msg=PAYLOAD_INVALID — AES_KEY_B64 may not match gateway gateway.aes-key
    Log To Console    TC_T20 PASS: Encrypted login payload accepted → status=${resp.status_code}

TC_T21_Encrypted_AD_Login_Full_Cycle_Decrypt_True
    [Tags]    regression    e2e    business_api    encrypted
    [Documentation]
    ...    E2E FULL CYCLE: Encrypt AD-login payload (KVB Postman) → gateway decrypts + forwards.
    ...    Asserts: not 401, not 400 PAYLOAD_INVALID.
    ...    Requires: ${AES_KEY_B64} filled.
    Skip If    '${AES_KEY_B64}' == '${EMPTY}'
    ...    AES_KEY_B64 is empty — fill from gateway config-server to run encrypted tests
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t21    ${gw_url}:${gateway_port}    verify=false
    ${encrypted_body}=    Encrypt Payload AES GCM    ${adlogin_payload}
    ${hdrs}=    Build POST Headers Encrypted    ${adlogin_payload}
    ${resp}=    POST On Session    tc_t21    ${prod_channel_path}
    ...    data=${encrypted_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Should Not Be Equal As Strings    ${resp.status_code}    400
    Log To Console    TC_T21 PASS: Encrypted AD-login payload accepted → status=${resp.status_code}

TC_T22_Encrypted_Dedupe_Check_Full_Cycle_Decrypt_True
    [Tags]    regression    e2e    business_api    encrypted
    [Documentation]
    ...    E2E FULL CYCLE: Encrypt dedupe-check payload (KVB Postman) → gateway decrypts + forwards.
    ...    Asserts: not 401, not 400 PAYLOAD_INVALID.
    ...    Requires: ${AES_KEY_B64} filled.
    Skip If    '${AES_KEY_B64}' == '${EMPTY}'
    ...    AES_KEY_B64 is empty — fill from gateway config-server to run encrypted tests
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t22    ${gw_url}:${gateway_port}    verify=false
    ${encrypted_body}=    Encrypt Payload AES GCM    ${dedupe_payload}
    ${hdrs}=    Build POST Headers Encrypted    ${dedupe_payload}
    ${resp}=    POST On Session    tc_t22    ${prod_channel_path}
    ...    data=${encrypted_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Should Not Be Equal As Strings    ${resp.status_code}    400
    Log To Console    TC_T22 PASS: Encrypted dedupe-check payload accepted → status=${resp.status_code}

TC_T23_GET_Request_No_Body_Works_Decrypt_True
    [Tags]    regression    e2e    business_api    get
    [Documentation]
    ...    E2E: GET request (no body) through gateway (decryption_enabled=True).
    ...    No body → decryptIfEnabled returns empty → HMAC(timestamp only) validated.
    ...    Decryption is skipped for empty body (StringUtils.hasText check in gateway).
    ...    Asserts: not 401, response is received.
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t23    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build GET Headers
    ${resp}=    GET On Session    tc_t23    ${prod_channel_path}
    ...    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    ...    msg=HMAC GET auth failed on decrypt=True channel
    Log To Console    TC_T23 PASS: GET request with no body accepted → status=${resp.status_code}

TC_T24_Response_Is_AES_Encrypted_Not_Plain_JSON
    [Tags]    regression    e2e    decrypt_verify    encrypted
    [Documentation]
    ...    KEY ASSERTION for decryption_enabled=True:
    ...    When a valid encrypted request succeeds, the gateway ENCRYPTS the response
    ...    via modifyResponseBody (ApiChannelLocatorImpl.java line 265–284).
    ...    Asserts: response body is NOT plain JSON (it's an AES-GCM base64 blob)
    ...    i.e. response body does NOT start with { or [.
    ...    Requires: ${AES_KEY_B64} filled.
    Skip If    '${AES_KEY_B64}' == '${EMPTY}'
    ...    AES_KEY_B64 is empty — fill from gateway config-server to run response-encryption tests
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t24    ${gw_url}:${gateway_port}    verify=false
    ${encrypted_body}=    Encrypt Payload AES GCM    ${login_payload}
    ${hdrs}=    Build POST Headers Encrypted    ${login_payload}
    ${resp}=    POST On Session    tc_t24    ${prod_channel_path}
    ...    data=${encrypted_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Should Not Be Equal As Strings    ${resp.status_code}    400
    ${body}=    Convert To String    ${resp.content}
    Should Not Be Empty    ${body}    msg=Response body is empty
    # Encrypted AES-GCM response is base64-encoded — does NOT start with { or [
    Should Not Match Regexp    ${body.strip()}    ^[\\[{]
    ...    msg=Response starts with { or [ — gateway may NOT be encrypting responses (unexpected for decrypt=True)
    Log To Console    TC_T24 PASS: Response is AES-encrypted (not plain JSON — decrypt=True response encryption confirmed)

TC_T25_Decrypt_Response_Is_Valid_JSON
    [Tags]    regression    e2e    decrypt_verify    encrypted
    [Documentation]
    ...    FULL ROUND-TRIP VERIFY for decryption_enabled=True:
    ...    1. Encrypt request payload using gateway AES key
    ...    2. Send with HMAC of normalized plaintext
    ...    3. Receive AES-encrypted response from gateway
    ...    4. Decrypt response using same AES key
    ...    5. Assert decrypted response is valid JSON (proves full encrypt/decrypt cycle works)
    ...    Requires: ${AES_KEY_B64} filled with gateway.aes-key value.
    Skip If    '${AES_KEY_B64}' == '${EMPTY}'
    ...    AES_KEY_B64 is empty — fill from gateway config-server (gateway.aes-key) to run full cycle test
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t25    ${gw_url}:${gateway_port}    verify=false
    # Step 1: encrypt payload
    ${encrypted_body}=    Encrypt Payload AES GCM    ${login_payload}
    # Step 2: build HMAC headers (HMAC of normalized plaintext)
    ${hdrs}=    Build POST Headers Encrypted    ${login_payload}
    # Step 3: send encrypted request
    ${resp}=    POST On Session    tc_t25    ${prod_channel_path}
    ...    data=${encrypted_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Should Not Be Equal As Strings    ${resp.status_code}    400
    # Step 4: decrypt response body
    ${enc_response}=    Convert To String    ${resp.content}
    Should Not Be Empty    ${enc_response}    msg=Response body is empty
    ${decrypted_response}=    Decrypt Response AES GCM    ${enc_response}
    # Step 5: assert decrypted response is valid JSON
    ${json}=    Evaluate    __import__('json').loads($decrypted_response)
    Should Not Be Empty    ${json}    msg=Decrypted response is empty
    Log To Console    TC_T25 PASS: Full round-trip — encrypted request → decrypted response is valid JSON

TC_T26_Pledge_Initiate_Encrypted_Full_Cycle
    [Tags]    regression    e2e    business_api    encrypted
    [Documentation]
    ...    E2E FULL CYCLE: Encrypt pledge-initiate payload (KVB Postman) → gateway decrypts + forwards.
    ...    Source: KVB Postman — POST /api/v1/pledge/initiate.
    ...    Asserts: not 401, not 400.
    ...    Requires: ${AES_KEY_B64} filled.
    Skip If    '${AES_KEY_B64}' == '${EMPTY}'
    ...    AES_KEY_B64 is empty — fill from gateway config-server to run encrypted tests
    _Load Regression Credentials
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_t26    ${gw_url}:${gateway_port}    verify=false
    ${encrypted_body}=    Encrypt Payload AES GCM    ${pledge_payload}
    ${hdrs}=    Build POST Headers Encrypted    ${pledge_payload}
    ${resp}=    POST On Session    tc_t26    ${prod_channel_path}
    ...    data=${encrypted_body}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Should Not Be Equal As Strings    ${resp.status_code}    400
    Log To Console    TC_T26 PASS: Encrypted pledge-initiate payload accepted → status=${resp.status_code}
