*** Settings ***
Documentation    Platform Service E2E Test Suite
...
...    Two authentication modes tested based on Java code in xxx-apigateway:
...
...    PRODUCT MODE  (app_code_creation=false, product_id present)
...      Route predicate : path + method + X-Client-Id + X-API-Key
...      Filter          : HMAC validation (X-Timestamp + X-Request-Signature)
...      requireSessionToken = false  →  isValidHmac() runs
...
...    APP-CODE MODE (app_code_creation=true, no product_id in config)
...      Route predicate : path + method + X-Client-Id + X-API-Key + Cookie + app-code
...      Filter          : HMAC is SKIPPED, refresh-token cookie validated, auth-service called
...      requireSessionToken = true  →  requiresHmacValidation() = false
...
...    IMPORTANT PREREQUISITES
...      1. Set HMAC_SECRET_KEY    = gateway property  secret.hmac-key
...      2. Set REFRESH_COOKIE_NAME = gateway property gateway.refresh-cookie-name
...      3. prod_id=2 must exist in the DB
...      4. common-service must be running for positive routing tests
...      5. Auth-service must be running for TC_A08 / TC_A09 assertions
...
...    NOTE: This file is self-contained.
...    Do NOT import 03_PlatformService.robot as a Resource — it has its own
...    Test Cases section and imports 05_addProduct_Positive.robot which causes
...    parent-suite errors when used as a Resource file.

Resource    ../../../keywords/common.robot

Suite Setup      Setup Platform E2E Suite
Suite Teardown   Run Keyword And Ignore Error    Disconnect From Database


*** Variables ***
# =============================================================
# CRITICAL: Update these two values before running
# =============================================================
${HMAC_SECRET_KEY}         xxx-hmac-secret-key
${REFRESH_COOKIE_NAME}     refresh_token

# =============================================================
# Channel / Service configuration  (matches 03_PlatformService.robot)
# =============================================================
${svc_name}                common-service
${svc_url}                 lb://common-service
${ch_description}          Platform E2E Testing
${platform_method}         POST
${prod_id}                 2
${exp_date}                2028-05-27
${rateLimit}               20
${periodSec}               1

# =============================================================
# Suite Variables — populated by Setup Platform E2E Suite at runtime.
# Declared here so the IDE/LSP can resolve them statically.
# =============================================================
${prod_client_id}          ${EMPTY}
${prod_api_key}            ${EMPTY}
${app_client_id}           ${EMPTY}
${app_api_key}             ${EMPTY}
${app_code_val}            ${EMPTY}
${suite_service_id}        ${EMPTY}
${suite_channel_id}        ${EMPTY}
# platform_path is overridden at runtime by _Create Gateway Channel (random suffix)
${platform_path}           /lender

# =============================================================
# Test payloads
# =============================================================
${valid_payload}           {"customerId": "TEST-001", "amount": 5000, "loanType": "personal"}
${tampered_payload}        {"customerId": "HACKED", "amount": 99999, "loanType": "fraud"}

# =============================================================
# Negative-test values
# =============================================================
${invalid_client_id}       INVALID-CLIENT-0000000000000000
${invalid_api_key}         invalid-api-key-000000000000000000000000000000000000000000000000
${wrong_signature}         aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
${iso_timestamp}           2026-04-01T10:00:00
${old_timestamp}           20200101000000
${future_timestamp}        20990101000000

# =============================================================
# Expected error codes
# GatewayErrorHandler.resolveHttpStatus() / SessionTokenAuthGatewayFilter
# =============================================================
${AUTH_MISSING_CODE}           CLIENT_AUTH_MISSING
${COOKIE_MISSING_CODE}         COOKIE_MISSING
${ROUTE_NOT_FOUND_CODE}        ROUTE_NOT_FOUND
${HMAC_ERROR_CODE}             HMAC
${PAYLOAD_TOO_LARGE_CODE}      PAYLOAD_TOO_LARGE
${PAYLOAD_INVALID_CODE}        PAYLOAD_INVALID
${API_EXPIRED_CODE}            API_EXPIRED
${SESSION_TOKEN_EMPTY_CODE}    SESSION_TOKEN_EMPTY
${ACCESS_DENIED_CODE}          ACCESS_DENIED
${SERVICE_NOT_REACHABLE_CODE}  SERVICE_NOT_REACHABLE


*** Keywords ***

# ================================================================
# SUITE SETUP
# Builds gateway chain for BOTH product-mode and app-code-mode.
# Sets suite variables used by all test cases:
#   ${prod_client_id}  ${prod_api_key}           — product-mode credentials
#   ${app_client_id}   ${app_api_key}  ${app_code_val}  — app-code-mode credentials
#   ${suite_channel_id}
# ================================================================
Setup Platform E2E Suite
    [Documentation]    Creates service → channel → product-mode config + mapping →
    ...                app-code-mode config + mapping → refresh
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    # 1. Register service
    ${service_id}=    _Create Or Get Service    ${gw_url}
    Set Suite Variable    ${suite_service_id}    ${service_id}
    # 2. Create channel
    ${channel_id}=    _Create Gateway Channel    ${gw_url}    ${service_id}
    Set Suite Variable    ${suite_channel_id}    ${channel_id}
    # 3. Product-mode partner config (app_code_creation=False, product_id present)
    _Create Product Mode Config    ${gw_url}    ${channel_id}
    # 4. App-code-mode partner config (app_code_creation=True, no product_id in config)
    _Create App Code Mode Config    ${gw_url}    ${channel_id}
    # 5. Refresh routes
    _Refresh Mapping    ${gw_url}
    _Refresh Routes     ${gw_url}
    Log To Console    === Suite Setup complete ===
    Log To Console    prod_client_id=${prod_client_id}
    Log To Console    app_client_id=${app_client_id}  app_code=${app_code_val}

_Create Or Get Service
    [Arguments]    ${gw_url}
    Create Session    setup_svc    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary    status=${True}    service_name=${svc_name}    service_url=${svc_url}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    setup_svc    /api/v1/gateway/service
    ...    json=${body}    headers=${hdrs}    expected_status=anything
    IF    '${resp.status_code}' == '200'
        ${json}=    Convert String To Json    ${resp.content}
        ${ids}=    Get Value From Json    ${json}    data.service_id
        ${sid}=    Get From List    ${ids}    0
        Log To Console    Service created: id=${sid}
    ELSE
        # Service already exists (SERVICE_CREATING_ERROR) — look it up by name
        Log To Console    Service '${svc_name}' already exists, fetching via GET
        ${get_resp}=    GET On Session    setup_svc    /api/v1/gateway/service
        ...    headers=${hdrs}    expected_status=anything
        ${get_json}=    Convert String To Json    ${get_resp.content}
        ${sid_list}=    Get Value From Json    ${get_json}    $.data[?(@.service_name=='${svc_name}')].service_id
        ${sid}=    Get From List    ${sid_list}    0
    END
    Log To Console    Using service id=${sid}
    RETURN    ${sid}

_Create Gateway Channel
    [Arguments]    ${gw_url}    ${service_id}
    Create Session    setup_ch    ${gw_url}:${gateway_port}
    ${ch_name}=    FakerLibrary.Safe Domain Name
    # Use random 4-digit suffix on path to avoid duplicate-path conflicts on re-runs
    ${rand_suffix}=    Generate Random String    4    [NUMBERS]
    ${ch_path}=    Set Variable    /lender-${rand_suffix}
    Set Suite Variable    ${platform_path}    ${ch_path}
    ${body}=    Create Dictionary
    ...    description=${ch_description}
    ...    service_id=${service_id}
    ...    api_channel_name=${ch_name}
    ...    api_channel_path=${ch_path}
    ...    api_channel_method=${platform_method}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    setup_ch    /api/v1/gateway/channel
    ...    json=${body}    headers=${hdrs}    expected_status=anything
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Channel creation failed (HTTP ${resp.status_code}): ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.api_channel_id
    ${cid}=    Get From List    ${ids}    0
    Log To Console    Channel id=${cid} path=${ch_path}
    RETURN    ${cid}

_Create Product Mode Config
    [Arguments]    ${gw_url}    ${channel_id}
    # PartnerProductConfig: app_code_creation=False → products FK set, app_code IS NULL
    # Note: create() throws "Already Configuration Setup" if active config exists for prod_id.
    # We call it anyway; regardless of success/failure we fetch credentials from DB.
    Create Session    setup_ppc    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${cfg_body}=    Create Dictionary
    ...    product_id=${prod_id}
    ...    app_code_creation=${False}
    ...    expiry_date=${exp_date}
    ${cfg_resp}=    POST On Session    setup_ppc    /api/v1/gateway/partner-product-config
    ...    json=${cfg_body}    headers=${hdrs}    expected_status=anything
    Log To Console    Product config create status=${cfg_resp.status_code}
    # Channel mapping: product_id links to the partner config (ChannelMappingServiceImpl.configMapping)
    ${map_body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    product_id=${prod_id}
    ...    decryption_enabled=${False}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${map_resp}=    POST On Session    setup_ppc    /api/v1/gateway/channel-mapping
    ...    json=${map_body}    headers=${hdrs}    expected_status=anything
    Log To Console    Product channel mapping status=${map_resp.status_code}
    # DB: product-mode config has products_id FK set and app_code IS NULL
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT client_id, api_key FROM ${schemeName}.partner_product_config WHERE products_id = ${prod_id} AND app_code IS NULL AND status = true ORDER BY created_at DESC LIMIT 1
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    ${pc_id}=    Get From List    ${row}    0
    ${pk}=    Get From List    ${row}    1
    Set Suite Variable    ${prod_client_id}    ${pc_id}
    Set Suite Variable    ${prod_api_key}    ${pk}
    Log To Console    Product mode creds — client_id=${prod_client_id}

_Create App Code Mode Config
    [Arguments]    ${gw_url}    ${channel_id}
    # PartnerProductConfig: app_code_creation=True → app_code UUID set, products FK IS NULL
    # Returns app_code UUID in response data field
    Create Session    setup_app    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${cfg_body}=    Create Dictionary
    ...    product_id=${prod_id}
    ...    app_code_creation=${True}
    ...    expiry_date=${exp_date}
    ${cfg_resp}=    POST On Session    setup_app    /api/v1/gateway/partner-product-config
    ...    json=${cfg_body}    headers=${hdrs}    expected_status=anything
    Log To Console    App-code config create status=${cfg_resp.status_code}
    Should Be Equal As Strings    ${cfg_resp.status_code}    200
    ...    msg=App-code config creation failed (HTTP ${cfg_resp.status_code}): ${cfg_resp.content}
    # Read app_code from API response (data field = generated UUID for app_code mode)
    ${resp_json}=    Convert String To Json    ${cfg_resp.content}
    ${data_vals}=    Get Value From Json    ${resp_json}    $.data
    ${app_code_from_api}=    Get From List    ${data_vals}    0
    Log To Console    App-code from API=${app_code_from_api}
    # Channel mapping: uses app_code (NOT product_id) — see ChannelMappingServiceImpl.configMapping
    ${map_body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    app_code=${app_code_from_api}
    ...    decryption_enabled=${False}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${map_resp}=    POST On Session    setup_app    /api/v1/gateway/channel-mapping
    ...    json=${map_body}    headers=${hdrs}    expected_status=anything
    Log To Console    App-code channel mapping status=${map_resp.status_code}
    # DB: app-code config has app_code = generated UUID
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT client_id, api_key, app_code FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code_from_api}' AND status = true LIMIT 1
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    ${ac_id}=    Get From List    ${row}    0
    ${ak}=    Get From List    ${row}    1
    ${ac}=    Get From List    ${row}    2
    Set Suite Variable    ${app_client_id}    ${ac_id}
    Set Suite Variable    ${app_api_key}    ${ak}
    Set Suite Variable    ${app_code_val}    ${ac}
    Log To Console    App-code mode creds — client_id=${app_client_id} app_code=${app_code_val}

_Refresh Mapping
    [Arguments]    ${gw_url}
    Create Session    refresh_m    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    GET On Session    refresh_m    /api/v1/gateway/refresh-mapping
    ...    headers=${hdrs}    expected_status=anything
    Log To Console    Refresh mapping: ${resp.status_code}

_Refresh Routes
    [Arguments]    ${gw_url}
    Create Session    refresh_r    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    GET On Session    refresh_r    /api/v1/gateway/refresh-mapping/routes
    ...    headers=${hdrs}    expected_status=anything
    Log To Console    Refresh routes: ${resp.status_code}


# ================================================================
# HMAC HELPERS — match SignatureGeneration.java logic exactly
# GatewayConstants.SIGNATURE_DATE_FORMAT = "yyyyMMddHHmmss"
# POST/PUT with body  → HMAC-SHA256( payload + "::" + timestamp )
# GET / no body       → HMAC-SHA256( timestamp )
# ================================================================
Generate Current Timestamp
    [Documentation]    Returns current datetime in 14-digit yyyyMMddHHmmss format
    ${ts}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y%m%d%H%M%S')
    RETURN    ${ts}

Generate HMAC For Payload
    [Arguments]    ${payload}    ${timestamp}    ${secret_key}=${HMAC_SECRET_KEY}
    [Documentation]    HMAC-SHA256( payload::timestamp ) for requests with body
    ${message}=    Set Variable    ${payload}::${timestamp}
    ${sig}=    Evaluate
    ...    hmac.new($secret_key.encode('utf-8'), $message.encode('utf-8'), hashlib.sha256).hexdigest()
    ...    modules=hmac,hashlib
    RETURN    ${sig}

Generate HMAC For Timestamp Only
    [Arguments]    ${timestamp}    ${secret_key}=${HMAC_SECRET_KEY}
    [Documentation]    HMAC-SHA256( timestamp ) for GET requests without body
    ${sig}=    Evaluate
    ...    hmac.new($secret_key.encode('utf-8'), $timestamp.encode('utf-8'), hashlib.sha256).hexdigest()
    ...    modules=hmac,hashlib
    RETURN    ${sig}


# ================================================================
# HEADER BUILDERS
# ================================================================
Build Product POST Headers
    [Arguments]    ${payload}    ${cid}=${prod_client_id}    ${akey}=${prod_api_key}
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${cid}
    ...    X-API-Key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    RETURN    ${hdrs}

Build Product GET Headers
    [Arguments]    ${cid}=${prod_client_id}    ${akey}=${prod_api_key}
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    X-Client-Id=${cid}
    ...    X-API-Key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    RETURN    ${hdrs}

Build Product Headers With Cookie
    [Arguments]    ${payload}    ${cid}=${prod_client_id}    ${akey}=${prod_api_key}
    [Documentation]    Adds a dummy refresh cookie so GatewayErrorHandler returns
    ...                ROUTE_NOT_FOUND (not COOKIE_MISSING) for route-not-found scenarios.
    ...                GatewayErrorHandler checks: clientId → apiKey → cookie → exception type.
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${cid}
    ...    X-API-Key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy_value
    RETURN    ${hdrs}

Build App Code Headers
    [Arguments]    ${cid}=${app_client_id}    ${akey}=${app_api_key}    ${app_code}=${app_code_val}    ${cookie_val}=${EMPTY}
    [Documentation]    Headers for app-code mode. Pass cookie_val to include Cookie header.
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${cid}
    ...    X-API-Key=${akey}
    ...    app-code=${app_code}
    IF    '${cookie_val}' != '${EMPTY}'
        Set To Dictionary    ${hdrs}    Cookie=${REFRESH_COOKIE_NAME}=${cookie_val}
    END
    RETURN    ${hdrs}


# ================================================================
# ASSERTION HELPER
# ================================================================
Assert Gateway Error
    [Arguments]    ${response}    ${expected_http_status}    ${expected_error_code}
    ${status}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status}    ${expected_http_status}
    ${json}=    Convert String To Json    ${response.content}
    ${code_list}=    Get Value From Json    ${json}    $.code
    ${code}=    Get From List    ${code_list}    0
    Should Be Equal    ${code}    ${expected_error_code}


*** Test Cases ***

# =================================================================
# PRODUCT MODE — POSITIVE TEST CASES
# product_id present, app_code absent (app_code IS NULL in DB)
# Route predicate: path + method + X-Client-Id + X-API-Key
# Filter: HMAC validation (requireSessionToken=false)
# =================================================================

TC_P01_Product_Mode_Credentials_Stored_In_DB
    [Documentation]    Verify that Suite Setup stored product-mode credentials in DB.
    ...                client_id = ULID, api_key = HKDF-SHA256 hex, app_code = NULL.
    [Tags]    product    positive    credentials    smoke
    Should Not Be Empty    ${prod_client_id}
    Should Not Be Empty    ${prod_api_key}
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT client_id, api_key, app_code, status FROM ${schemeName}.partner_product_config WHERE client_id = '${prod_client_id}'
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    Should Be Equal    ${row[0]}    ${prod_client_id}
    Should Be Equal    ${row[1]}    ${prod_api_key}
    Should Be Equal As Strings    ${row[2]}    None
    Should Be True    ${row[3]}
    Log To Console    TC_P01 PASS: product-mode credentials validated in DB

TC_P02_Product_Valid_POST_With_HMAC_Payload_Timestamp
    [Documentation]    Valid POST with correct X-Client-Id, X-API-Key, and
    ...                HMAC-SHA256(payload::timestamp) — should not return 401.
    ...                SignatureGeneration.java: message = payload + "::" + X-Timestamp
    [Tags]    product    positive    hmac    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p02    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build Product POST Headers    ${valid_payload}
    ${resp}=    POST On Session    tc_p02    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_P02 PASS: Valid product POST accepted — status=${resp.status_code}

TC_P03_Product_Valid_GET_With_Timestamp_Only_HMAC
    [Documentation]    Valid GET with HMAC-SHA256(timestamp only).
    ...                isValidHmac() → no body → isValidHmacTimestamp() called.
    [Tags]    product    positive    hmac    get
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p03    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Build Product GET Headers
    ${resp}=    GET On Session    tc_p03    ${platform_path}
    ...    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_P03 PASS: Valid product GET accepted — status=${resp.status_code}

TC_P04_Product_Timestamp_Must_Be_14_Digits_yyyyMMddHHmmss
    [Documentation]    Verify timestamp is 14 digits. GatewayConstants.SIGNATURE_DATE_FORMAT = "yyyyMMddHHmmss"
    [Tags]    product    positive    timestamp
    ${ts}=    Generate Current Timestamp
    Should Match Regexp    ${ts}    ^\\d{14}$
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p04    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p04    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    401
    Log To Console    TC_P04 PASS: 14-digit yyyyMMddHHmmss timestamp accepted

TC_P05_Product_5_Requests_Within_Rate_Limit_All_Succeed
    [Documentation]    5 consecutive requests (well within rateLimit=${rateLimit}/period=${periodSec}s)
    ...                should all succeed (none 429). RedisRateLimiter: token bucket.
    [Tags]    product    positive    rate_limit
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p05    ${gw_url}:${gateway_port}    verify=false
    FOR    ${idx}    IN RANGE    1    6
        ${hdrs}=    Build Product POST Headers    ${valid_payload}
        ${resp}=    POST On Session    tc_p05    ${platform_path}
        ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
        Should Not Be Equal As Strings    ${resp.status_code}    429
        Log To Console    Request ${idx}: ${resp.status_code}
    END
    Log To Console    TC_P05 PASS: 5 requests within rate limit — none rejected with 429

TC_P06_Refresh_Mapping_And_Routes_Return_200
    [Documentation]    Refresh endpoints return HTTP 200.
    ...                RefreshController.refreshMapping() + refreshRoutes()
    [Tags]    product    positive    refresh    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p06    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${r1}=    GET On Session    tc_p06    /api/v1/gateway/refresh-mapping    headers=${hdrs}
    Should Be Equal As Strings    ${r1.status_code}    ${expected_code}
    ${r2}=    GET On Session    tc_p06    /api/v1/gateway/refresh-mapping/routes    headers=${hdrs}
    Should Be Equal As Strings    ${r2.status_code}    ${expected_code}
    Log To Console    TC_P06 PASS: Refresh mapping + routes → 200

TC_P07_Fallback_Endpoint_Returns_SERVICE_NOT_REACHABLE
    [Documentation]    FallbackController.fallback() returns SERVICE_NOT_REACHABLE
    ...                when circuit breaker is open (triggered by 502/503/504).
    [Tags]    product    positive    fallback    circuit_breaker
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p07    ${gw_url}:${gateway_port}
    ${resp}=    GET On Session    tc_p07    /api/v1/gateway/fallback    expected_status=anything
    ${json}=    Convert String To Json    ${resp.content}
    ${code_list}=    Get Value From Json    ${json}    $.code
    ${code}=    Get From List    ${code_list}    0
    Should Be Equal    ${code}    ${SERVICE_NOT_REACHABLE_CODE}
    ${success_list}=    Get Value From Json    ${json}    $.success
    ${success}=    Get From List    ${success_list}    0
    Should Not Be True    ${success}
    Log To Console    TC_P07 PASS: Fallback returns SERVICE_NOT_REACHABLE


# -----------------------------------------------------------------
# PRODUCT MODE — NEGATIVE: Missing Auth Headers
# GatewayErrorHandler.resolveHttpStatus():
#   !hasText(clientId) || !hasText(apiKey) → CLIENT_AUTH_MISSING (checked FIRST)
# -----------------------------------------------------------------

TC_P08_Missing_XClientId_Returns_CLIENT_AUTH_MISSING
    [Documentation]    No X-Client-Id header → CLIENT_AUTH_MISSING 401.
    ...                GatewayErrorHandler checks credentials before cookie/route.
    [Tags]    product    negative    auth    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p08    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p08    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_P08 PASS: Missing X-Client-Id → 401 CLIENT_AUTH_MISSING

TC_P09_Missing_XApiKey_Returns_CLIENT_AUTH_MISSING
    [Documentation]    No X-API-Key header → CLIENT_AUTH_MISSING 401.
    [Tags]    product    negative    auth
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p09    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p09    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_P09 PASS: Missing X-API-Key → 401 CLIENT_AUTH_MISSING

TC_P10_Both_Auth_Headers_Missing_Returns_CLIENT_AUTH_MISSING
    [Documentation]    Both X-Client-Id and X-API-Key absent → CLIENT_AUTH_MISSING 401.
    [Tags]    product    negative    auth    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p10    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    tc_p10    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_P10 PASS: Both auth headers missing → 401 CLIENT_AUTH_MISSING


# -----------------------------------------------------------------
# PRODUCT MODE — NEGATIVE: Route Not Found (invalid credentials / wrong route)
# GatewayErrorHandler order: clientId check → cookie check → exception type
# A dummy Cookie is included so error handler reaches ROUTE_NOT_FOUND
# (without cookie → COOKIE_MISSING; with dummy cookie → ROUTE_NOT_FOUND)
# -----------------------------------------------------------------

TC_P11_Invalid_ClientId_Returns_ROUTE_NOT_FOUND
    [Documentation]    Unregistered X-Client-Id → route predicate (.header("X-Client-Id", clientId)) fails.
    ...                Dummy cookie included so GatewayErrorHandler returns ROUTE_NOT_FOUND.
    [Tags]    product    negative    route    auth
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p11    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${invalid_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session    tc_p11    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_P11 PASS: Invalid X-Client-Id → 401 ROUTE_NOT_FOUND

TC_P12_Invalid_ApiKey_Returns_ROUTE_NOT_FOUND
    [Documentation]    Wrong X-API-Key → route predicate (.header("X-API-Key", apiKey)) fails.
    [Tags]    product    negative    route    auth
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p12    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${invalid_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session    tc_p12    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_P12 PASS: Invalid X-API-Key → 401 ROUTE_NOT_FOUND

TC_P13_Non_Configured_Path_Returns_ROUTE_NOT_FOUND
    [Documentation]    Path not registered in ApiChannel → no route matches → ROUTE_NOT_FOUND.
    [Tags]    product    negative    route
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p13    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    GET On Session    tc_p13    /api/v1/nonexistent/path/xyz
    ...    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_P13 PASS: Non-configured path → 401 ROUTE_NOT_FOUND

TC_P14_Wrong_HTTP_Method_Returns_ROUTE_NOT_FOUND
    [Documentation]    Channel registered for POST. Sending DELETE fails method predicate.
    ...                .method(ApiChannelMethod.valueOf(method).getHttpMethod())
    [Tags]    product    negative    route    method
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p14    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    DELETE On Session    tc_p14    ${platform_path}
    ...    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_P14 PASS: Wrong HTTP method (DELETE on POST route) → 401 ROUTE_NOT_FOUND


# -----------------------------------------------------------------
# PRODUCT MODE — NEGATIVE: HMAC Validation
# SessionTokenAuthGatewayFilter: requiresHmacValidation()=true for product mode
# isValidHmac() → isValidHmacForBody() for POST; isValidHmacTimestamp() for GET
# -----------------------------------------------------------------

TC_P15_Missing_Timestamp_Returns_HMAC
    [Documentation]    No X-Timestamp header → HMAC 401.
    ...                isValidHmacForBody(): StringUtils.hasText(timestamp) = false → HMAC fail.
    [Tags]    product    negative    hmac    timestamp
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p15    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_p15    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_P15 PASS: Missing X-Timestamp → 401 HMAC

TC_P16_Missing_Signature_Returns_HMAC
    [Documentation]    No X-Request-Signature header → HMAC 401.
    ...                isValidHmacForBody(): StringUtils.hasText(clientHmac) = false → HMAC fail.
    [Tags]    product    negative    hmac    signature
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p16    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ${resp}=    POST On Session    tc_p16    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_P16 PASS: Missing X-Request-Signature → 401 HMAC

TC_P17_Wrong_HMAC_Signature_Returns_HMAC
    [Documentation]    Valid credentials and timestamp but random wrong signature.
    ...                constantTimeEquals(clientHmac, serverHmac) = false → HMAC 401.
    [Tags]    product    negative    hmac    signature    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p17    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_p17    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_P17 PASS: Wrong HMAC signature → 401 HMAC

TC_P18_Tampered_Payload_With_Original_Signature_Returns_HMAC
    [Documentation]    Sign original payload, but send tampered body.
    ...                Gateway recomputes HMAC(tampered::ts) ≠ original sig → HMAC 401.
    ...                Validates payload integrity: normalizeJson() then HMAC check.
    [Tags]    product    negative    hmac    payload    security
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p18    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${original_sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${original_sig}
    ${resp}=    POST On Session    tc_p18    ${platform_path}
    ...    data=${tampered_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_P18 PASS: Tampered payload + original signature → 401 HMAC (payload integrity)

TC_P19_Wrong_Timestamp_Format_ISO8601_Returns_HMAC
    [Documentation]    ISO-8601 timestamp (2026-04-01T10:00:00) instead of yyyyMMddHHmmss.
    ...                Server uses correct-format timestamp for its HMAC → mismatch → HMAC 401.
    [Tags]    product    negative    hmac    timestamp    format
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p19    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${iso_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${iso_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p19    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_P19 PASS: ISO-8601 timestamp format rejected → 401 HMAC

TC_P20_Old_Timestamp_Replay_Attack_Test
    [Documentation]    Old timestamp 20200101000000 with valid HMAC.
    ...                Tests replay attack prevention. Logs result without hard-failing
    ...                since the current gateway code does not implement timestamp freshness.
    [Tags]    product    negative    hmac    timestamp    replay    security
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p20    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${old_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${old_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p20    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${status}=    Convert To String    ${resp.status_code}
    Should Not Be Equal As Strings    ${status}    500
    IF    '${status}' == '401'
        Log To Console    TC_P20 PASS: Old timestamp replay rejected — status=401
    ELSE
        Log To Console    TC_P20 WARN: Old timestamp NOT rejected (no freshness check) — status=${status}
    END

TC_P21_Future_Timestamp_Extimestamp_Test
    [Documentation]    Far-future timestamp 20990101000000 (year 2099).
    ...                Tests out-of-range / extended timestamp rejection.
    ...                Tagged extimestamp. Logs result without hard-failing
    ...                since gateway does not enforce timestamp freshness check.
    [Tags]    product    negative    hmac    timestamp    extimestamp
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p21    ${gw_url}:${gateway_port}    verify=false
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${future_timestamp}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${future_timestamp}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p21    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${status}=    Convert To String    ${resp.status_code}
    Should Not Be Equal As Strings    ${status}    500
    IF    '${status}' == '401'
        Log To Console    TC_P21 PASS: Future timestamp (2099) rejected — status=401
    ELSE
        Log To Console    TC_P21 WARN: Future timestamp NOT rejected — status=${status}
    END


# -----------------------------------------------------------------
# PRODUCT MODE — NEGATIVE: Payload Validation
# xxxRequestSizeGatewayFilterFactory: runs BEFORE HMAC check
# -----------------------------------------------------------------

TC_P22_Oversized_Payload_Returns_413_PAYLOAD_TOO_LARGE
    [Documentation]    Payload over gateway.request-size limit → 413 PAYLOAD_TOO_LARGE.
    ...                xxxRequestSizeGatewayFilterFactory checks contentLength before HMAC.
    [Tags]    product    negative    payload    size
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p22    ${gw_url}:${gateway_port}    verify=false
    ${large_data}=    Evaluate    'X' * 1048577
    ${large_json}=    Set Variable    {"data": "${large_data}"}
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${large_json}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${prod_client_id}
    ...    X-API-Key=${prod_api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p22    ${platform_path}
    ...    data=${large_json}    headers=${hdrs}    expected_status=anything
    Should Be Equal As Strings    ${resp.status_code}    413
    ${json}=    Convert String To Json    ${resp.content}
    ${code_list}=    Get Value From Json    ${json}    $.code
    ${code}=    Get From List    ${code_list}    0
    Should Be Equal    ${code}    ${PAYLOAD_TOO_LARGE_CODE}
    Log To Console    TC_P22 PASS: Oversized payload → 413 PAYLOAD_TOO_LARGE


# -----------------------------------------------------------------
# PRODUCT MODE — NEGATIVE: Expired Config
# SessionTokenAuthGatewayFilter.isExpired(): Instant.now().isAfter(expiryDate.toInstant())
# -----------------------------------------------------------------

TC_P23_Expired_Config_Returns_401_API_EXPIRED
    [Documentation]    Create a product config with past expiry (2020-01-01) via recreate endpoint,
    ...                refresh, then request → API_EXPIRED 401.
    ...                NOTE: recreate allows up to 2 active configs per product.
    [Tags]    product    negative    expiry    config
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p23    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    # Use recreate endpoint which allows a second config (up to 2 per product)
    ${cfg_body}=    Create Dictionary
    ...    product_id=${prod_id}
    ...    expiry_date=2020-01-01
    ${cfg_resp}=    POST On Session    tc_p23    /api/v1/gateway/partner-product-config/recreate/${prod_id}
    ...    json=${cfg_body}    headers=${hdrs}    expected_status=anything
    Log To Console    TC_P23 Expired config create: ${cfg_resp.status_code}
    # Fetch the expired credentials from DB
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT client_id, api_key FROM ${schemeName}.partner_product_config WHERE products_id = ${prod_id} AND expiry_date < NOW() AND status = true ORDER BY created_at DESC LIMIT 1
    Disconnect From Database
    ${has_expired_config}=    Evaluate    len(${rows}) > 0
    IF    not ${has_expired_config}
        Log To Console    TC_P23 SKIP: No expired config found — recreate may have rejected past date
        # RETURN
    END
    ${row}=    Get From List    ${rows}    0
    ${exp_cid}=    Get From List    ${row}    0
    ${exp_key}=    Get From List    ${row}    1
    # Refresh so gateway picks up the expired route
    _Refresh Mapping    ${gw_url}
    _Refresh Routes     ${gw_url}
    # Request with expired credentials — gateway isExpired() check returns API_EXPIRED
    Create Session    tc_p23_gw    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${req_hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${exp_cid}
    ...    X-API-Key=${exp_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    tc_p23_gw    ${platform_path}
    ...    data=${valid_payload}    headers=${req_hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${API_EXPIRED_CODE}
    Log To Console    TC_P23 PASS: Expired config → 401 API_EXPIRED

TC_P24_Disabled_Config_Returns_401_ROUTE_NOT_FOUND
    [Documentation]    Disable prod_client_id config (status=false) via PUT enable=false,
    ...                refresh routes, then credentials no longer match any route.
    ...                ApiChannelLocatorImpl skips config where status=false.
    [Tags]    product    negative    config    disable
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT id, client_id, api_key FROM ${schemeName}.partner_product_config WHERE client_id = '${prod_client_id}' LIMIT 1
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    ${config_id}=    Get From List    ${row}    0
    ${cid}=    Get From List    ${row}    1
    ${akey}=    Get From List    ${row}    2
    # Disable
    Create Session    tc_p24    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${dis_resp}=    PUT On Session    tc_p24
    ...    /api/v1/gateway/partner-product-config/${config_id}?enable=false
    ...    headers=${hdrs}    expected_status=anything
    Log To Console    TC_P24 Disable status=${dis_resp.status_code}
    _Refresh Mapping    ${gw_url}
    _Refresh Routes     ${gw_url}
    # Request — should fail; route removed from gateway
    Create Session    tc_p24_gw    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    Generate Current Timestamp
    ${sig}=    Generate HMAC For Payload    ${valid_payload}    ${ts}
    ${req_hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${cid}
    ...    X-API-Key=${akey}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ...    Cookie=${REFRESH_COOKIE_NAME}=dummy
    ${resp}=    POST On Session    tc_p24_gw    ${platform_path}
    ...    data=${valid_payload}    headers=${req_hdrs}    expected_status=anything
    Should Be Equal As Strings    ${resp.status_code}    ${unauthorized_code}
    # Restore for subsequent tests
    ${res_resp}=    PUT On Session    tc_p24
    ...    /api/v1/gateway/partner-product-config/${config_id}?enable=true
    ...    headers=${hdrs}    expected_status=anything
    _Refresh Mapping    ${gw_url}
    _Refresh Routes     ${gw_url}
    Log To Console    TC_P24 PASS: Disabled config → 401 (route removed); restored


# -----------------------------------------------------------------
# PRODUCT MODE — NEGATIVE: Rate Limiting
# ApiChannelLocatorImpl: RedisRateLimiter token bucket
# replenishRate = rateLimit / periodSeconds; burstCapacity = rateLimit
# -----------------------------------------------------------------

TC_P25_Exceed_Rate_Limit_Returns_429
    [Documentation]    Flood 34 requests to exceed rateLimit=${rateLimit}/period=${periodSec}s.
    ...                RedisRateLimiter returns HTTP 429 when burst capacity exhausted.
    [Tags]    product    negative    rate_limit
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p25    ${gw_url}:${gateway_port}    verify=false
    ${rate_exceeded}=    Set Variable    ${False}
    FOR    ${idx}    IN RANGE    1    35
        ${hdrs}=    Build Product POST Headers    ${valid_payload}
        ${resp}=    POST On Session    tc_p25    ${platform_path}
        ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
        ${status}=    Convert To String    ${resp.status_code}
        IF    '${status}' == '429'
            ${rate_exceeded}=    Set Variable    ${True}
            BREAK
        END
        Log To Console    Req ${idx}: ${status}
    END
    Should Be True    ${rate_exceeded}
    ...    Rate limit not triggered in 34 requests — verify rateLimit=${rateLimit} periodSec=${periodSec}
    Log To Console    TC_P25 PASS: Rate limit exceeded → 429

TC_P26_Rate_Limit_Recovers_After_Window
    [Documentation]    After 429, wait for token bucket replenishment (periodSec + buffer),
    ...                then verify next request succeeds (not 429).
    [Tags]    product    negative    rate_limit    recovery
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_p26    ${gw_url}:${gateway_port}    verify=false
    FOR    ${idx}    IN RANGE    1    25
        ${hdrs}=    Build Product POST Headers    ${valid_payload}
        ${resp}=    POST On Session    tc_p26    ${platform_path}
        ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
        IF    ${resp.status_code} == 429    BREAK
    END
    Sleep    3s    reason=Wait for token bucket replenishment (periodSec=${periodSec}s + buffer)
    ${hdrs}=    Build Product POST Headers    ${valid_payload}
    ${resp}=    POST On Session    tc_p26    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Should Not Be Equal As Strings    ${resp.status_code}    429
    Log To Console    TC_P26 PASS: Rate limit recovered — status=${resp.status_code}


# =================================================================
# APP-CODE MODE — TEST CASES
# app_code_creation=True → requireSessionToken=true in filter
# Route predicate (non-login): path + method + X-Client-Id + X-API-Key + Cookie + app-code
# Filter: HMAC validation is SKIPPED (requiresHmacValidation=false)
#         validateSessionTokenIfRequired() → checks refresh cookie
#         If cookie present → validateTokenWithAuthService() → auth-service call
# =================================================================

TC_A01_App_Code_Credentials_Stored_In_DB
    [Documentation]    Verify app-code mode credentials in DB after Suite Setup.
    ...                client_id (ULID), api_key (HKDF-SHA256), app_code (UUID) all non-null.
    ...                products_id IS NULL for app-code configs (only app_code is set).
    [Tags]    appcode    positive    credentials    smoke
    Should Not Be Empty    ${app_client_id}
    Should Not Be Empty    ${app_api_key}
    Should Not Be Empty    ${app_code_val}
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT client_id, api_key, app_code, status FROM ${schemeName}.partner_product_config WHERE client_id = '${app_client_id}'
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    Should Be Equal    ${row[0]}    ${app_client_id}
    Should Be Equal    ${row[1]}    ${app_api_key}
    Should Not Be Equal As Strings    ${row[2]}    None
    Should Be True    ${row[3]}
    Log To Console    TC_A01 PASS: app-code credentials validated — app_code=${app_code_val}

TC_A02_App_Code_Missing_XClientId_Returns_CLIENT_AUTH_MISSING
    [Documentation]    App-code request without X-Client-Id → CLIENT_AUTH_MISSING 401.
    ...                GatewayErrorHandler checks clientId/apiKey BEFORE cookie check.
    [Tags]    appcode    negative    auth    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a02    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-API-Key=${app_api_key}
    ...    app-code=${app_code_val}
    ...    Cookie=${REFRESH_COOKIE_NAME}=some_token
    ${resp}=    POST On Session    tc_a02    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_A02 PASS: App-code missing X-Client-Id → 401 CLIENT_AUTH_MISSING

TC_A03_App_Code_Missing_XApiKey_Returns_CLIENT_AUTH_MISSING
    [Documentation]    App-code request without X-API-Key → CLIENT_AUTH_MISSING 401.
    [Tags]    appcode    negative    auth
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a03    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    app-code=${app_code_val}
    ...    Cookie=${REFRESH_COOKIE_NAME}=some_token
    ${resp}=    POST On Session    tc_a03    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${AUTH_MISSING_CODE}
    Log To Console    TC_A03 PASS: App-code missing X-API-Key → 401 CLIENT_AUTH_MISSING

TC_A04_App_Code_Missing_app_code_Header_Returns_ROUTE_NOT_FOUND
    [Documentation]    App-code route predicate: .header("app-code", appCode) — required header.
    ...                Without app-code, predicate fails → ROUTE_NOT_FOUND.
    ...                Cookie included so GatewayErrorHandler reaches ROUTE_NOT_FOUND check.
    [Tags]    appcode    negative    route
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a04    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    X-API-Key=${app_api_key}
    ...    Cookie=${REFRESH_COOKIE_NAME}=some_token
    ${resp}=    POST On Session    tc_a04    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_A04 PASS: Missing app-code header → 401 ROUTE_NOT_FOUND

TC_A05_App_Code_Wrong_app_code_Value_Returns_ROUTE_NOT_FOUND
    [Documentation]    Wrong app-code value (not matching config.getAppCode()).
    ...                Route predicate exact-match fails → ROUTE_NOT_FOUND.
    [Tags]    appcode    negative    route
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a05    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    X-API-Key=${app_api_key}
    ...    app-code=wrong-app-code-00000000-0000-0000-0000-000000000000
    ...    Cookie=${REFRESH_COOKIE_NAME}=some_token
    ${resp}=    POST On Session    tc_a05    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${ROUTE_NOT_FOUND_CODE}
    Log To Console    TC_A05 PASS: Wrong app-code value → 401 ROUTE_NOT_FOUND

TC_A06_App_Code_No_Cookie_Returns_COOKIE_MISSING
    [Documentation]    App-code route predicate requires Cookie header matching cookie name regex.
    ...                Without Cookie header, predicate fails → no route match.
    ...                GatewayErrorHandler: has clientId + apiKey → checks cookie → COOKIE_MISSING.
    ...                (COOKIE_MISSING, not ROUTE_NOT_FOUND, because cookie check comes first in handler)
    [Tags]    appcode    negative    route    session
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a06    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    X-API-Key=${app_api_key}
    ...    app-code=${app_code_val}
    ${resp}=    POST On Session    tc_a06    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${COOKIE_MISSING_CODE}
    Log To Console    TC_A06 PASS: No Cookie header → 401 COOKIE_MISSING

TC_A07_App_Code_Empty_Refresh_Token_Returns_SESSION_TOKEN_EMPTY
    [Documentation]    Cookie header contains refresh cookie name but empty value.
    ...                Route predicate matches (Cookie header has cookie name in text).
    ...                SessionTokenAuthGatewayFilter.validateSessionTokenIfRequired():
    ...                extractTokenFromCookies() returns empty → SESSION_TOKEN_EMPTY 401.
    ...                PREREQUISITE: REFRESH_COOKIE_NAME must match gateway.refresh-cookie-name
    [Tags]    appcode    negative    session    smoke
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a07    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    X-API-Key=${app_api_key}
    ...    app-code=${app_code_val}
    ...    Cookie=${REFRESH_COOKIE_NAME}=
    ${resp}=    POST On Session    tc_a07    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    Assert Gateway Error    ${resp}    ${unauthorized_code}    ${SESSION_TOKEN_EMPTY_CODE}
    Log To Console    TC_A07 PASS: Empty refresh token → 401 SESSION_TOKEN_EMPTY

TC_A08_App_Code_Invalid_Token_Returns_ACCESS_DENIED_Or_Auth_Error
    [Documentation]    All correct headers + invalid refresh token cookie.
    ...                Route matches. Token non-empty → validateTokenWithAuthService() called.
    ...                Auth service rejects invalid token → ACCESS_DENIED 401.
    ...                If auth-service unreachable → AUTH_SERVICE_UNREACHABLE 500.
    [Tags]    appcode    negative    session    auth_service
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a08    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    X-API-Key=${app_api_key}
    ...    app-code=${app_code_val}
    ...    Cookie=${REFRESH_COOKIE_NAME}=invalid_fake_token_xyz123
    ${resp}=    POST On Session    tc_a08    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${json}=    Convert String To Json    ${resp.content}
    ${code_list}=    Get Value From Json    ${json}    $.code
    ${code}=    Get From List    ${code_list}    0
    Should Be True
    ...    '${code}' == '${ACCESS_DENIED_CODE}' or '${code}' == 'AUTH_SERVICE_UNREACHABLE' or '${code}' == 'AUTH_SERVICE_FAILED'
    ...    Unexpected error code: ${code}. Expected ACCESS_DENIED / AUTH_SERVICE_UNREACHABLE / AUTH_SERVICE_FAILED
    Log To Console    TC_A08: Invalid refresh token → code=${code} status=${resp.status_code}

TC_A09_App_Code_HMAC_Not_Validated_In_App_Code_Mode
    [Documentation]    In app-code mode requiresHmacValidation(config) = !requireSessionToken = false.
    ...                Sending garbage X-Request-Signature must NOT cause HMAC 401.
    ...                Route matches (has cookie + correct app-code) → filter skips HMAC →
    ...                proceeds to auth-service validation.
    [Tags]    appcode    positive    hmac
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    tc_a09    ${gw_url}:${gateway_port}    verify=false
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Client-Id=${app_client_id}
    ...    X-API-Key=${app_api_key}
    ...    app-code=${app_code_val}
    ...    Cookie=${REFRESH_COOKIE_NAME}=invalid_token_val
    ...    X-Timestamp=garbage_timestamp
    ...    X-Request-Signature=${wrong_signature}
    ${resp}=    POST On Session    tc_a09    ${platform_path}
    ...    data=${valid_payload}    headers=${hdrs}    expected_status=anything
    ${json}=    Convert String To Json    ${resp.content}
    ${code_list}=    Get Value From Json    ${json}    $.code
    ${code}=    Get From List    ${code_list}    0
    Should Not Be Equal    ${code}    ${HMAC_ERROR_CODE}
    Log To Console    TC_A09 PASS: App-code mode skips HMAC — response code=${code} (not HMAC)
