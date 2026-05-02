*** Settings ***
Resource     ../../../keywords/common.robot
Library      ../../../resources/MongoManager.py    env=qa
Library      ../../../resources/CryptoUtil.py

*** Variables ***
${app_code_creation}      True
${decryption_enabled}     True
${rateLimit}              20
${periodSec}              1

${userName}               your-username
${password}               your-password
${userId}                 2
${userRole}               2

${app_code}               your-app-code-uuid
${Validate_OTP}           12345678
${PAN_Number}             ABCDE1234F
${mobile_No}              9999999999
${email_id}               testuser@example.com
${AES_KEY_B64}            your-base64-encoded-aes-256-key-here    # base64-encoded AES-256 key from gateway config-server (gateway.aes-key)

*** Keywords ***
# ─── AES-256-GCM Helper Keywords ────────────────────────────────────────────
# Gateway uses AES-256-GCM: 12-byte random nonce, 16-byte auth tag.
# Wire format: base64(nonce[12] + ciphertext + tag[16]).
# Matches xxxEncryption(AesMode.GCM) in SessionTokenAuthGatewayFilter and ApiChannelLocatorImpl.
# Used by NEG_04 to encrypt with a wrong key and verify the gateway rejects it.

Get Credentials From DB
    [Documentation]    Reads api_key and client_id from partner_product_config for the configured ${app_code}.
    ${db}=          Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=        Query    SELECT api_key, client_id FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code}';
    ${row}=         Get From List    ${rows}    0
    ${api_key}=     Get From List    ${row}    0
    ${client_Id}=   Get From List    ${row}    1
    Disconnect From Database
    RETURN    ${api_key}    ${client_Id}

AES Encrypt Payload
    [Arguments]    ${plaintext}
    [Documentation]    AES-256-CBC encrypt a JSON string using ${AES_KEY_B64}.
    ...    IV = first 16 bytes of the key (matches gateway CryptoUtil). Output: base64(ciphertext).
    Should Not Be Empty    ${AES_KEY_B64}    msg=Set ${AES_KEY_B64} to the gateway.aes-key value from config-server
    ${enc_body}=    Encrypt Payload    ${AES_KEY_B64}    ${plaintext}
    RETURN    ${enc_body}

AES Decrypt Response
    [Arguments]    ${encrypted_b64}
    [Documentation]    AES-256-CBC decrypt the gateway's encrypted response body.
    ...    IV = first 16 bytes of the key (matches gateway CryptoUtil). Input: base64(ciphertext).
    Should Not Be Empty    ${AES_KEY_B64}    msg=Set ${AES_KEY_B64} to the gateway.aes-key value from config-server
    ${plaintext}=    Decrypt Payload    ${AES_KEY_B64}    ${encrypted_b64}
    RETURN    ${plaintext}

Assert Response Is AES Encrypted
    [Arguments]    ${response}
    [Documentation]    Asserts the response body is AES-256-GCM encrypted:
    ...    - body is non-empty
    ...    - body is NOT parseable as plain JSON (it is base64 ciphertext)
    ...    - base64-decoded length is >= 28 (12-byte nonce + 16-byte auth tag minimum)
    ${body}=      Convert To String    ${response.text}
    Should Not Be Empty    ${body}    msg=Response body is empty — expected AES-GCM ciphertext
    ${is_json}=   Run Keyword And Return Status    Convert String To Json    ${body}
    Should Not Be True    ${is_json}
    ...    msg=Response is plain JSON — gateway did NOT encrypt the response (decryption_enabled=True check failed)
    ${decoded}=       Evaluate    __import__('base64').b64decode($body.strip())
    ${length}=        Evaluate    len($decoded)
    Should Be True    ${length} >= 28
    ...    msg=Decoded response (${length} bytes) is not valid AES-GCM — must be >= 28 (12-byte nonce + 16-byte auth tag)
    Log To Console    Assert Response Is AES Encrypted: PASS (${length} bytes, AES-GCM)

Assert Response Decrypts To Valid JSON
    [Arguments]    ${response}
    [Documentation]    Decrypts the AES-CBC encrypted response body and returns a parsed JSON dict.
    ${enc_body}=    Convert To String    ${response.text}
    ${plaintext}=   AES Decrypt Response    ${enc_body}
    ${json_data}=   Convert String To Json    ${plaintext}
    Log To Console    Decrypted response: ${plaintext}
    RETURN    ${json_data}

*** Test Cases ***
# ─── Negative Scenarios — AES Encryption Validation ──────────────────────────
# All negative tests target a channel where decryption_enabled=True.
# The gateway must reject any request that is not a valid AES-256-CBC ciphertext
# or that was encrypted with the wrong key.

NEG_01 Plain JSON To Decrypt Channel Returns PAYLOAD_INVALID
    [Documentation]    Sending unencrypted plain JSON to a decryption_enabled=True channel must
    ...    be rejected with HTTP 400 and error code PAYLOAD_INVALID.
    ...    The gateway throws EncryptionException during decryptIfEnabled() before HMAC check.
    ${api_key}    ${client_Id}    Get Credentials From DB
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     neg01    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${body}=    Create Dictionary
    ...    username=${userName}
    ...    userpassword=${password}
    ...    login_type=AD
    ${response}=    POST On Session    neg01    /api/v1/auth/adlogin    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    400
    ...    msg=Expected 400 for plain JSON to decrypt=True channel — got ${response.status_code}: ${response.text}
    ${json_data}=    Convert String To Json    ${response.content}
    ${code}=         Get Value From Json    ${json_data}    status.code
    ${err_code}=     Get From List    ${code}    0
    Should Be Equal    ${err_code}    PAYLOAD_INVALID
    ...    msg=Expected error code PAYLOAD_INVALID — got ${err_code}
    Log To Console    NEG_01 PASS: Plain JSON correctly rejected — ${err_code}

NEG_02 Corrupted Base64 Ciphertext Returns PAYLOAD_INVALID
    [Documentation]    Random bytes encoded as base64 are not a valid AES-GCM ciphertext.
    ...    Gateway must return HTTP 400 PAYLOAD_INVALID (GCM auth-tag decryption failure).
    ${api_key}    ${client_Id}    Get Credentials From DB
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     neg02    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${corrupt}=    Evaluate    __import__('base64').b64encode(__import__('os').urandom(64)).decode()
    ${response}=    POST On Session    neg02    /api/v1/auth/adlogin
    ...    data=${corrupt}    headers=${headers}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    400
    ...    msg=Expected 400 for corrupted ciphertext — got ${response.status_code}: ${response.text}
    ${json_data}=    Convert String To Json    ${response.content}
    ${code}=         Get Value From Json    ${json_data}    status.code
    ${err_code}=     Get From List    ${code}    0
    Should Be Equal    ${err_code}    PAYLOAD_INVALID
    ...    msg=Expected PAYLOAD_INVALID — got ${err_code}
    Log To Console    NEG_02 PASS: Corrupted ciphertext correctly rejected — ${err_code}

NEG_03 Truncated Ciphertext Returns PAYLOAD_INVALID
    [Documentation]    A ciphertext shorter than 28 bytes (12-byte nonce + 16-byte tag minimum)
    ...    is structurally invalid for AES-GCM — must return HTTP 400 PAYLOAD_INVALID.
    ${api_key}    ${client_Id}    Get Credentials From DB
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     neg03    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${truncated}=    Evaluate    __import__('base64').b64encode(__import__('os').urandom(10)).decode()
    ${response}=     POST On Session    neg03    /api/v1/auth/adlogin
    ...    data=${truncated}    headers=${headers}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    400
    ...    msg=Expected 400 for truncated ciphertext (10 bytes) — got ${response.status_code}: ${response.text}
    ${json_data}=    Convert String To Json    ${response.content}
    ${code}=         Get Value From Json    ${json_data}    status.code
    ${err_code}=     Get From List    ${code}    0
    Should Be Equal    ${err_code}    PAYLOAD_INVALID
    ...    msg=Expected PAYLOAD_INVALID — got ${err_code}
    Log To Console    NEG_03 PASS: Truncated ciphertext correctly rejected — ${err_code}

NEG_04 Wrong AES Key Returns PAYLOAD_INVALID
    [Documentation]    Payload encrypted with a random wrong 256-bit key using AES-256-CBC.
    ...    Gateway decrypts with its actual key → produces garbage plaintext → JSON parse fails → HTTP 400 PAYLOAD_INVALID.
    ...    This test generates its own random wrong key — does not require ${AES_KEY_B64}.
    ${api_key}    ${client_Id}    Get Credentials From DB
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     neg04    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary
    ...    Content-Type=text/plain
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${wrong_key}=    Evaluate    __import__('base64').b64encode(__import__('os').urandom(32)).decode()
    ${payload_str}=  Set Variable    {"username":"${userName}","userpassword":"${password}","login_type":"AD"}
    ${enc_body}=     Encrypt Payload    ${wrong_key}    ${payload_str}
    ${response}=     POST On Session    neg04    /api/v1/auth/adlogin
    ...    data=${enc_body}    headers=${headers}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    400
    ...    msg=Expected 400 for wrong-key AES-CBC encryption — got ${response.status_code}: ${response.text}
    ${json_data}=    Convert String To Json    ${response.content}
    ${code}=         Get Value From Json    ${json_data}    status.code
    ${err_code}=     Get From List    ${code}    0
    Should Be Equal    ${err_code}    PAYLOAD_INVALID
    ...    msg=Expected PAYLOAD_INVALID — got ${err_code}
    Log To Console    NEG_04 PASS: Wrong-key AES-CBC encryption correctly rejected — ${err_code}

NEG_05 Empty Body To POST Endpoint Returns Error
    [Documentation]    Sending an empty body to a POST endpoint on a decrypt=True channel must
    ...    return an error (400 PAYLOAD_INVALID or 400 BAD_REQUEST).
    ...    Empty string cannot be AES-GCM decrypted.
    ${api_key}    ${client_Id}    Get Credentials From DB
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     neg05    ${gateway_url}:${gateway_port}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${response}=    POST On Session    neg05    /api/v1/auth/adlogin
    ...    data=${EMPTY}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} >= 400
    ...    msg=Expected 4xx for empty body — got ${response.status_code}: ${response.text}
    Log To Console    NEG_05 PASS: Empty body rejected with HTTP ${response.status_code}
