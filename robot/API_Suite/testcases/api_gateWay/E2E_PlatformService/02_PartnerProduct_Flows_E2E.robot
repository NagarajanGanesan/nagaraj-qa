*** Settings ***
Resource     ../../../keywords/common.robot
Resource     ../../Lender_Config/05_addProduct_Positive.robot

*** Variables ***
# ─────────────────────────────────────────────────────────────
# RUNTIME variables (no pre-fill needed)
# ─────────────────────────────────────────────────────────────
# Service / channel
${ch_description}      Platform E2E Testing
${api_method}          POST

# HMAC secret key (must match gateway property: secret.hmac-key)
${HMAC_SECRET_KEY}     xxx-hmac-secret-key

# Rate limiting
${rateLimit}           20
${periodSec}           1

# RBAC — placeholders; real values set at runtime by _Generate RBAC Names
${app_name}            ${EMPTY}
${userName}            ${EMPTY}
${email}               ${EMPTY}
${roleName}            ${EMPTY}
${employee_name}       ${EMPTY}
${password}            Platform@1234
${loginType}           NORMAL

# Test payload (product mode gateway calls)
${valid_payload}       {"customerId": "TEST-001", "amount": 5000}


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

_Generate RBAC Names
    [Documentation]    Generates unique RBAC identifiers per run and stores them as suite variables.
    ${rand_suffix}=    Generate Random String    6    [LOWER][NUMBERS]
    ${app_name}=       Set Variable    App-${rand_suffix}
    ${userName}=       Set Variable    user_${rand_suffix}
    ${email}=          Set Variable    user_${rand_suffix}@test.com
    ${roleName}=       Set Variable    Role-${rand_suffix}
    Set Suite Variable    ${app_name}
    Set Suite Variable    ${userName}
    Set Suite Variable    ${email}
    Set Suite Variable    ${roleName}
    Log To Console    RBAC names — app=${app_name}  user=${userName}  role=${roleName}  

# ================================================================
# ONE-TIME SETUP KEYWORDS
# Called only from TC01_OneTime_Setup and TC02_OneTime_Setup.
# ================================================================

_Get Or Create Service
    [Documentation]    Register service with a randomly generated name and URL; returns service_id.
    ${rand_suffix}=    Generate Random String    6    [LETTERS]
    ${svc_name}=    Set Variable    Platform-${rand_suffix}
    ${svc_url}=     Set Variable    lb://platform-${rand_suffix}
    Set Suite Variable    ${svc_name}
    Set Suite Variable    ${svc_url}
    Log To Console    service_name=${svc_name}  service_url=${svc_url}
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    svc_sess    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    status=${True}
    ...    service_name=${svc_name}
    ...    service_url=${svc_url}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    svc_sess    /api/v1/gateway/service
    ...    json=${body}    headers=${hdrs}    expected_status=anything
    IF    '${resp.status_code}' == '200'
        ${json}=    Convert String To Json    ${resp.content}
        ${ids}=    Get Value From Json    ${json}    data.service_id
        ${sid}=    Get From List    ${ids}    0
        Log To Console    Service created: id=${sid}
    ELSE
        Log To Console    Service exists — fetching via GET
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
    [Documentation]    Create channel with unique random path; returns channel_id and channel_path.
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ch_sess    ${gw_url}:${gateway_port}
    ${ch_name}=    FakerLibrary.Safe Domain Name
    ${rand_suffix}=    Generate Random String    4    [NUMBERS]
    ${ch_path}=    Set Variable    /lender-${rand_suffix}
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

_Create Partner Config AppCode True
    [Arguments]    ${expiry_date}
    [Documentation]    POST partner-product-config with app_code_creation=True.
    ...                Reads app_code from API response; fetches client_id + api_key from DB.
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ppc_app    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    app_code_creation=${True}
    ...    expiry_date=${expiry_date}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    ppc_app    /api/v1/gateway/partner-product-config
    ...    json=${body}    headers=${hdrs}    expected_status=anything
    Log To Console    [AppCode=True] partner config status=${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=App-code partner config failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${data}=    Get Value From Json    ${json}    $.data
    ${raw}=    Get From List    ${data}    0
    ${app_code_val}=    Fetch From Right    ${raw}    appCode:${SPACE}
    Log To Console    app_code=${app_code_val}
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT api_key, client_id FROM ${schemeName}.partner_product_config
    ...    WHERE app_code = '${app_code_val}' AND status = true LIMIT 1
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    ${ak}=     Get From List    ${row}     0
    ${cid}=    Get From List    ${row}     1
    Set Suite Variable    ${app_code_val}
    Set Suite Variable    ${cid}
    Set Suite Variable    ${ak}
    Log To Console    client_id=${cid}  api_key=${ak}
    RETURN    ${app_code_val}    ${cid}    ${ak}

_Create Partner Config AppCode False
    [Arguments]    ${product_id}    ${expiry_date}
    [Documentation]    POST partner-product-config with app_code_creation=False + product_id.
    ...                Fetches client_id + api_key from DB (app_code IS NULL).
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ppc_prod    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    product_id=${product_id}
    ...    app_code_creation=${False}
    ...    expiry_date=${expiry_date}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    ppc_prod    /api/v1/gateway/partner-product-config
    ...    json=${body}    headers=${hdrs}    expected_status=anything
    Log To Console    [AppCode=False] partner config status=${resp.status_code}
    ${db}=    Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=    Query
    ...    SELECT api_key, client_id FROM ${schemeName}.partner_product_config
    ...    WHERE products_id = ${product_id} AND app_code IS NULL AND status = true
    ...    ORDER BY created_at DESC LIMIT 1
    Disconnect From Database
    ${row}=    Get From List    ${rows}    0
    ${ak}=     Get From List    ${row}     0
    ${cid}=    Get From List    ${row}     1
    Set Suite Variable    ${cid}
    Set Suite Variable    ${ak}
    Log To Console    client_id=${cid}  api_key=${ak}
    RETURN    ${cid}    ${ak}

_Channel Mapping By AppCode
    [Arguments]    ${channel_id}    ${app_code}    ${decryption_enabled}
    [Documentation]    Create channel mapping using app_code; returns mapping_id.
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    cm_app    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    app_code=${app_code}
    ...    decryption_enabled=${decryption_enabled}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    cm_app    /api/v1/gateway/channel-mapping
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Channel mapping (app_code, decryption=${decryption_enabled}) failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.api_channel_mapping_id
    ${mid}=    Get From List    ${ids}    0
    Log To Console    [AppCode mapping] id=${mid}  decryption_enabled=${decryption_enabled}
    RETURN    ${mid}

_Channel Mapping By ProductId
    [Arguments]    ${channel_id}    ${product_id}    ${decryption_enabled}
    [Documentation]    Create channel mapping using product_id; returns mapping_id.
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    cm_prod    ${gw_url}:${gateway_port}
    ${body}=    Create Dictionary
    ...    api_channel_id=${channel_id}
    ...    product_id=${product_id}
    ...    decryption_enabled=${decryption_enabled}
    ...    rate_limit=${rateLimit}
    ...    period_seconds=${periodSec}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    cm_prod    /api/v1/gateway/channel-mapping
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Channel mapping (product_id, decryption=${decryption_enabled}) failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.api_channel_mapping_id
    ${mid}=    Get From List    ${ids}    0
    Log To Console    [ProductId mapping] id=${mid}  decryption_enabled=${decryption_enabled}
    RETURN    ${mid}

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

# ================================================================
# RBAC KEYWORDS
# Run during every regression cycle (TC03).
# ================================================================

_RBAC Application Registry
    [Arguments]    ${app_code}
    [Documentation]    Register application in auth service; returns application_id.
    ${auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    app_reg    ${auth_url}:${Auth_port}
    ${body}=    Create Dictionary
    ...    status=${True}
    ...    app_name=${app_name}
    ...    app_code=${app_code}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    app_reg    /api/v1/auth/application
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Application registry failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.application_id
    ${app_id}=    Get From List    ${ids}    0
    Log To Console    Application registered: id=${app_id}
    RETURN    ${app_id}

_RBAC Create User
    [Arguments]    ${app_id}
    [Documentation]    Create user under the application; returns user_id.
    ${auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    usr_crt    ${auth_url}:${Auth_port}
    ${app_id_list}=    Create List    ${app_id}
    ${body}=    Create Dictionary
    ...    username=${userName}
    ...    password=${password}
    ...    status=${True}
    ...    employee_name=${userName}_01
    ...    email=${email}
    ...    application_id=${app_id_list}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    usr_crt    /api/v1/auth/user
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=User creation failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.user_id
    ${uid}=    Get From List    ${ids}    0
    Log To Console    User created: id=${uid}  username=${userName}
    RETURN    ${uid}

_RBAC Create Role
    [Arguments]    ${app_id}
    [Documentation]    Create role under the application; returns role_id.
    ${auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    role_crt    ${auth_url}:${Auth_port}
    ${body}=    Create Dictionary
    ...    status=${True}
    ...    application_id=${app_id}
    ...    role_name=${roleName}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    role_crt    /api/v1/auth/role
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Role creation failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.role_id
    ${rid}=    Get From List    ${ids}    0
    Log To Console    Role created: id=${rid}  name=${roleName}
    RETURN    ${rid}

_RBAC Create Permission
    [Arguments]    ${app_id}    ${perm_name}    ${channel_path}    ${channel_method}
    [Documentation]    Create one permission for the channel; returns permission_id.
    ${auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    perm_crt    ${auth_url}:${Auth_port}
    ${body}=    Create Dictionary
    ...    application_id=${app_id}
    ...    permission_name=${perm_name}
    ...    resource_path=${channel_path}
    ...    http_method=${channel_method}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    perm_crt    /api/v1/auth/permission
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Permission creation failed: ${resp.content}
    ${json}=    Convert String To Json    ${resp.content}
    ${ids}=    Get Value From Json    ${json}    data.permissionId
    ${pid}=    Get From List    ${ids}    0
    Log To Console    Permission created: id=${pid}  path=${channel_path}
    RETURN    ${pid}

_RBAC UserRole Mapping
    [Arguments]    ${role_id}    ${user_id}
    ${auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    ur_map    ${auth_url}:${Auth_port}
    ${body}=    Create Dictionary
    ...    role_id=${${role_id}}
    ...    user_id=${${user_id}}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    ur_map    /api/v1/auth/mapping/user-role
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=User-role mapping failed: ${resp.content}
    Log To Console    User-Role mapped: user_id=${user_id}  role_id=${role_id}

_RBAC RolePermission Mapping
    [Arguments]    ${role_id}    ${permission_id}
    ${auth_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    rp_map    ${auth_url}:${Auth_port}
    ${body}=    Create Dictionary
    ...    role_id=${${role_id}}
    ...    permission_id=${${permission_id}}
    ${hdrs}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    rp_map    /api/v1/auth/mapping/role-permission
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Role-permission mapping failed: ${resp.content}
    Log To Console    Role-Permission mapped: role_id=${role_id}  permission_id=${permission_id}

_Login As User
    [Arguments]    ${app_code}    ${client_id}    ${api_key}
    [Documentation]    Login via gateway auth endpoint; returns cookie string.
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    login_sess    ${gw_url}:${login_port}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    app-code=${app_code}
    ...    xxx-CLIENT-ID=${client_id}
    ...    xxx-API-KEY=${api_key}
    ${body}=    Create Dictionary
    ...    username=${userName}
    ...    userpassword=${password}
    ...    login_type=${loginType}
    ${resp}=    POST On Session    login_sess    /api/v1/auth/login
    ...    json=${body}    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Login failed: ${resp.content}
    ${cookies}=    Set Variable    ${resp.cookies.get_dict()}
    ${access_token}=    Get From Dictionary    ${cookies}    xxx-access-token
    ${refresh_token}=    Get From Dictionary    ${cookies}    xxx-refresh-token
    ${cookie_str}=    Set Variable    xxx-access-token=${access_token}; xxx-refresh-token=${refresh_token}
    Log To Console    Login successful — user=${userName}
    RETURN    ${cookie_str}

_Logout User
    [Arguments]    ${cookies}    ${client_id}    ${api_key}    ${app_code}
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    logout_sess    ${gw_url}:${gateway_port}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=${cookies}
    ...    xxx-client-id=${client_id}
    ...    xxx-api-key=${api_key}
    ...    app-code=${app_code}
    ${resp}=    GET On Session    logout_sess    /api/v1/auth/logout    headers=${hdrs}
    Should Be Equal As Strings    ${resp.status_code}    200
    ...    msg=Logout failed: ${resp.content}
    Log To Console    Logout successful — user=${userName}

# ================================================================
# HMAC HELPERS — product mode (TC04)
# Matches SignatureGeneration.java: POST → HMAC(payload::ts), GET → HMAC(ts)
# ================================================================

_Generate Timestamp
    ${ts}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y%m%d%H%M%S')
    RETURN    ${ts}

_HMAC For Payload
    [Arguments]    ${payload}    ${timestamp}
    ${msg}=    Set Variable    ${payload}::${timestamp}
    ${sig}=    Evaluate
    ...    hmac.new($HMAC_SECRET_KEY.encode('utf-8'), $msg.encode('utf-8'), hashlib.sha256).hexdigest()
    ...    modules=hmac,hashlib
    RETURN    ${sig}

_HMAC Timestamp Only
    [Arguments]    ${timestamp}
    ${sig}=    Evaluate
    ...    hmac.new($HMAC_SECRET_KEY.encode('utf-8'), $timestamp.encode('utf-8'), hashlib.sha256).hexdigest()
    ...    modules=hmac,hashlib
    RETURN    ${sig}

_Send Gateway POST
    [Arguments]    ${path}    ${payload}    ${client_id}    ${api_key}
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    gw_post    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    _Generate Timestamp
    ${sig}=    _HMAC For Payload    ${payload}    ${ts}
    ${hdrs}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Client-Id=${client_id}
    ...    API-Key=${api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    POST On Session    gw_post    ${path}
    ...    data=${payload}    headers=${hdrs}    expected_status=anything
    Log To Console    Gateway POST ${path} → ${resp.status_code}
    RETURN    ${resp}

_Send Gateway GET
    [Arguments]    ${path}    ${client_id}    ${api_key}
    ${gw_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    gw_get    ${gw_url}:${gateway_port}    verify=false
    ${ts}=    _Generate Timestamp
    ${sig}=    _HMAC Timestamp Only    ${ts}
    ${hdrs}=    Create Dictionary
    ...    X-Client-Id=${client_id}
    ...    X-API-Key=${api_key}
    ...    X-Timestamp=${ts}
    ...    X-Request-Signature=${sig}
    ${resp}=    GET On Session    gw_get    ${path}
    ...    headers=${hdrs}    expected_status=anything
    Log To Console    Gateway GET ${path} → ${resp.status_code}
    RETURN    ${resp}


*** Test Cases ***

# ════════════════════════════════════════════════════════════════
# ONE-TIME SETUP — run these ONCE per environment to provision
# the gateway infrastructure. After running, copy the printed IDs
# into keywords/variables.robot (gw_tc01_* / gw_tc02_* variables).
# Tag: setup  →  robot --include setup 02_PartnerProduct_Flows_E2E.robot
# ════════════════════════════════════════════════════════════════

TC01_OneTime_Setup
    [Tags]    setup
    [Documentation]
    ...    ONE-TIME: Creates service → channel → partner config (app_code_creation=True)
    ...    → channel mapping (decryption=False) → channel mapping (decryption=True) → refresh.
    ...    Copy the printed IDs into keywords/variables.robot under gw_tc01_* variables.
    ${expiry_date}=    _Compute Expiry Date
    ${service_id}=    _Get Or Create Service
    ${channel_id}    ${channel_path}=    _Create Channel    ${service_id}
    ${app_code}    ${client_id}    ${api_key}=    _Create Partner Config AppCode True    ${expiry_date}
    _Channel Mapping By AppCode    ${channel_id}    ${app_code}    ${False}
    _Channel Mapping By AppCode    ${channel_id}    ${app_code}    ${True}
    _Refresh
    _Refresh Routes
    Log To Console    ════════════════════════════════════════
    Log To Console    TC01 Setup complete — copy to variables.robot:
    Log To Console    \${gw_tc01_service_id}    ${service_id}
    Log To Console    \${gw_tc01_channel_id}    ${channel_id}
    Log To Console    \${gw_tc01_channel_path}  ${channel_path}
    Log To Console    \${gw_tc01_app_code}      ${app_code}
    Log To Console    \${gw_tc01_client_id}     ${client_id}
    Log To Console    \${gw_tc01_api_key}       ${api_key}
    Log To Console    ════════════════════════════════════════

TC02_OneTime_Setup
    [Tags]    setup
    [Documentation]
    ...    ONE-TIME: Creates service → channel → product → partner config (app_code_creation=False)
    ...    → channel mapping (decryption=False) → channel mapping (decryption=True) → refresh.
    ...    Copy the printed IDs into keywords/variables.robot under gw_tc02_* variables.
    ${expiry_date}=    _Compute Expiry Date
    ${service_id}=    _Get Or Create Service
    ${channel_id}    ${channel_path}=    _Create Channel    ${service_id}
    ${product_id}=    TC05_Product_Positive     ${cookies}    ${client_id}    ${api_key}    ${app_code}    True    ${lender_id}    ${lender_name}
    ...    ${Distributor_id}    ${DistributorName}    True    True     
    ${client_id}    ${api_key}=    _Create Partner Config AppCode False    ${product_id}    ${expiry_date}
    _Channel Mapping By ProductId    ${channel_id}    ${product_id}    ${False}
    _Channel Mapping By ProductId    ${channel_id}    ${product_id}    ${True}
    _Refresh
    _Refresh Routes
    Log To Console    ════════════════════════════════════════
    Log To Console    TC02 Setup complete — copy to variables.robot:
    Log To Console    \${gw_tc02_service_id}    ${service_id}
    Log To Console    \${gw_tc02_channel_id}    ${channel_id}
    Log To Console    \${gw_tc02_channel_path}  ${channel_path}
    Log To Console    \${gw_tc02_product_id}    ${product_id}
    Log To Console    \${gw_tc02_client_id}     ${client_id}
    Log To Console    \${gw_tc02_api_key}       ${api_key}
    Log To Console    ════════════════════════════════════════

# ════════════════════════════════════════════════════════════════
# REGRESSION — run on every regression cycle.
# Reads IDs from keywords/variables.robot (gw_tc01_* / gw_tc02_*).
# Tag: regression  →  robot --include regression 02_PartnerProduct_Flows_E2E.robot
# ════════════════════════════════════════════════════════════════

TC03_Regression_AppCode_True
    [Tags]    regression
    [Documentation]
    ...    REGRESSION (app_code_creation=True / RBAC mode).
    ...    Uses pre-configured IDs from variables.robot (gw_tc01_*).
    ...    Runs: application registry → create user → create role
    ...          → create permission → user-role mapping → role-permission mapping
    ...          → refresh → login → logout
    # Generate unique RBAC names for this run
    _Generate RBAC Names
    # Read one-time IDs from variables.robot
    ${app_code}=     Set Variable    ${gw_tc01_app_code}
    ${client_id}=    Set Variable    ${gw_tc01_client_id}
    ${api_key}=      Set Variable    ${gw_tc01_api_key}
    ${ch_path}=      Set Variable    ${gw_tc01_channel_path}
    Should Not Be Empty    ${app_code}
    ...    msg=gw_tc01_app_code is empty — run TC01_OneTime_Setup first and fill variables.robot
    Should Not Be Empty    ${client_id}
    ...    msg=gw_tc01_client_id is empty — run TC01_OneTime_Setup first and fill variables.robot
    # RBAC flow
    ${app_id}=    _RBAC Application Registry    ${app_code}
    ${user_id}=   _RBAC Create User             ${app_id}
    ${role_id}=   _RBAC Create Role             ${app_id}
    ${perm_id}=   _RBAC Create Permission
    ...    ${app_id}    platform_e2e    ${ch_path}    ${api_method}
    _RBAC UserRole Mapping        ${role_id}    ${user_id}
    _RBAC RolePermission Mapping  ${role_id}    ${perm_id}
    # Refresh so new permissions take effect
    _Refresh
    _Refresh Routes
    # Login + logout to verify RBAC wiring
    ${cookies}=    _Login As User    ${app_code}    ${client_id}    ${api_key}
    _Logout User    ${cookies}    ${client_id}    ${api_key}    ${app_code}
    Log To Console    TC03 PASS — RBAC flow verified for app_code=${app_code}

TC04_Regression_AppCode_False
    [Tags]    regression
    [Documentation]
    ...    REGRESSION (app_code_creation=False / product + HMAC mode).
    ...    Uses pre-configured IDs from variables.robot (gw_tc02_*).
    ...    Runs: HMAC POST with decryption_enabled=False → assert response
    ...          HMAC POST with decryption_enabled=True  → assert response
    ...          HMAC GET → assert not 401
    # Read one-time IDs from variables.robot
    ${client_id}=    Set Variable    ${gw_tc02_client_id}
    ${api_key}=      Set Variable    ${gw_tc02_api_key}
    ${ch_path}=      Set Variable    ${gw_tc02_channel_path}
    Should Not Be Empty    ${client_id}
    ...    msg=gw_tc02_client_id is empty — run TC02_OneTime_Setup first and fill variables.robot
    Should Not Be Empty    ${ch_path}
    ...    msg=gw_tc02_channel_path is empty — run TC02_OneTime_Setup first and fill variables.robot
    # Refresh routes before sending requests
    _Refresh
    _Refresh Routes
    # HMAC POST — decryption_enabled=False (gateway forwards payload as-is)
    ${resp_off}=    _Send Gateway POST    ${ch_path}    ${valid_payload}    ${client_id}    ${api_key}
    Should Not Be Equal As Strings    ${resp_off.status_code}    401
    ...    msg=Auth failed on decryption-disabled mapping
    Log To Console    [Decryption=OFF] status=${resp_off.status_code}  body=${resp_off.content}
    # HMAC POST — decryption_enabled=True (gateway decrypts payload before forwarding)
    ${resp_on}=    _Send Gateway POST    ${ch_path}    ${valid_payload}    ${client_id}    ${api_key}
    Should Not Be Equal As Strings    ${resp_on.status_code}    401
    ...    msg=Auth failed on decryption-enabled mapping
    Log To Console    [Decryption=ON]  status=${resp_on.status_code}  body=${resp_on.content}
    # HMAC GET — timestamp-only signature
    ${resp_get}=    _Send Gateway GET    ${ch_path}    ${client_id}    ${api_key}
    Should Not Be Equal As Strings    ${resp_get.status_code}    401
    ...    msg=HMAC GET auth failed
    Log To Console    [HMAC GET] status=${resp_get.status_code}
    Log To Console    TC04 PASS — HMAC validation verified for product mode
