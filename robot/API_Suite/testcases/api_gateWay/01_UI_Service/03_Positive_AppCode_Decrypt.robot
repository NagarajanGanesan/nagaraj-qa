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
${userId}                 1
${userRole}               1

${app_code}               your-app-code-uuid
${api_key}                your-api-key-hex-64chars
${client_id}              your-client-id

${Validate_OTP}           12345678
${PAN_Number}             ABCDE1234F
${mobile_No}              9999999999
${email_id}               testuser@example.com
${AES_KEY_B64}            your-base64-encoded-aes-256-key-here    # base64-encoded AES-256 key from gateway config-server (gateway.aes-key)

*** Test Cases ***
App Code Decryption True
    [Documentation]    Verify encrypted request/response flow
    ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${branchCode}      01_Login as user
    02_Lender_getAll_Positive TC    ${cookies}     ${client_Id}     ${api_key}     ${app_code}    
    03_Distributor_getAll_Positive TC    ${cookies}     ${client_Id}     ${api_key}     ${app_code}       
    ${lender_id}    04_Lender_Onboarding_Positive     ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    05_DeleteLender     ${lender_id}     ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    ${Validate_OTP}       06_Dedupe    ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${PAN_Number}
    ${platform_custId}    07_validate_OTP     ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${Validate_OTP}     ${PAN_Number}
    08_getCustomer_details   ${cookies}       ${client_Id}     ${api_key}     ${app_code}     ${platform_custId}
    ${OD_productCode}     09_getProduct       ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    ${loanApp_No}      ${loanApp_Id}          ${cust_id}     10_loanApplication_Init     ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${OD_productCode}     ${branchCode}     ${PAN_Number}     ${mobile_No}     ${email_id}
    ${email_OTP}       11_emailInitiate       ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${loanApp_No}
    12_emailValidate                  ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${loanApp_No}     ${email_OTP}     ${email_Id}
    13_updateLoanApplication          ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${loanApp_No}
    Logout          ${cookies}     ${client_Id}     ${api_key}     ${app_code}

*** Keywords ***
# ─── AES-256-GCM Helper Keywords ────────────────────────────────────────────
# Gateway uses AES-256-GCM: 12-byte random nonce, 16-byte auth tag.

Get Credentials From DB
    [Documentation]    Reads api_key and client_id from partner_product_config for the configured ${app_code}.
    ${db}=          Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=        Query    SELECT api_key, client_id FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code}';
    ${row}=         Get From List    ${rows}    0
    ${api_key}=     Get From List    ${row}     0
    ${client_Id}=   Get From List    ${row}     1
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
    # Log To Console    Assert Response Is AES Encrypted: PASS (${length} bytes, AES-GCM)

Assert Response Decrypts To Valid JSON
    [Arguments]    ${response}
    [Documentation]    Decrypts the AES-CBC encrypted response body and returns a parsed JSON dict.
    ${enc_body}=    Convert To String    ${response.text}
    ${plaintext}=   AES Decrypt Response    ${enc_body}
    ${json_data}=   Convert String To Json    ${plaintext}
    Log To Console    Decrypted response: ${plaintext}
    RETURN    ${json_data}

# ─── Test Keywords ────────────────────────────────────────────────────────────
01_Login as user
    [Documentation]    Encrypts the login payload before POST
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     user_login     url= ${gateway_url}:${gateway_port}

    ${api_key}    ${client_Id}    Get Credentials From DB
    Set Suite Variable    ${api_key}
    Set Suite Variable    ${client_Id}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=       Set Variable    {"username":"${userName}","userpassword":"${password}","login_type":"AD"}
    ${enc_body}=      AES Encrypt Payload    ${payload}
    ${verify_plain}=  Decrypt Payload    ${AES_KEY_B64}    ${enc_body}
    Should Be Equal As Strings    ${verify_plain}    ${payload}
    Log    Request payload verified: ${verify_plain}

    ${response}        POST On Session    user_login    /api/v1/auth/adlogin    data=${enc_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}

    Log To Console     ${response.text}

    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${message}         Get Value From Json    ${json_data}    status.code
    ${msg}             Get From List          ${message}      0
    ${branch}          Get Value From Json    ${json_data}    data.branch_code
    ${branchCode}      Get From List          ${branch}       0
    ${name}            Get Value From Json    ${json_data}    data.user_name
    ${user_name}       Get From List          ${name}         0

    ${cookie_dict}=      Set Variable    ${response.cookies.get_dict()}
    ${access_token}=     Get From Dictionary    ${cookie_dict}    xxx-access-token
    ${refresh_token}=    Get From Dictionary    ${cookie_dict}    xxx-refresh-token

    Log    ${access_token}
    Log    ${refresh_token}

    ${cookies}    Set Variable    xxx-access-token=${access_token}; xxx-refresh-token=${refresh_token}; user_id=${userId}; user_roles=${userRole}

    Set Suite Variable    ${cookies}
    Set Suite Variable    ${app_code}
    Set Suite Variable    ${branchCode}

    Log To Console     ${user_name}: 01_${msg}

    RETURN     ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${branchCode}

02_Lender_getAll_Positive TC
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    [Documentation]    Retrieves all lender details — decrypts AES-GCM encrypted gateway response.
    ${comServ_url}=   Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    lender_getAll    url=${comServ_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${response}=      Get On Session    lender_getAll        /api/v1/lender        headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}
    ${msg_list}=     Get Value From Json    ${json_data}    status.message
    ${msg}=          Get From List    ${msg_list}    0
    Log To Console   02_Lender_getAll: ${msg}

03_Distributor_getAll_Positive TC
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    [Documentation]    Retrieves all distributor details — decrypts AES-GCM encrypted gateway response.
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    Distributor_getAll    ${comServ_url}:${gateway_port}
    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${response}=      Get On Session    Distributor_getAll    /api/v1/distributors    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}
    ${msg_list}=     Get Value From Json    ${json_data}    status.message
    ${msg}=          Get From List    ${msg_list}    0
    Log To Console   03_Distributor_getAll: ${msg}

04_Lender_Onboarding_Positive
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    [Documentation]    Sets up the environment for lender onboarding — plain JSON (direct comServ call, not through gateway).
    ${comServ_url}=   Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    lender_onboarding    ${comServ_url}:${comServ_port}

    ${lenderName}=    Generate Random String    3    [UPPER]
    ${email_Id}=      FakerLibrary.Safe Email
    ${contact}=       Generate Random Mobile Number
    ${reg_Address}=   FakerLibrary.Address
    ${PAN}=           Generate Random PAN
    ${gstIn}=         Generate Random GSTIN
    ${logo}=          Create List    12    23    12

    Set Suite Variable   ${lenderName}
    Set Test Variable    ${email_Id}
    Set Test Variable    ${contact}
    Set Test Variable    ${reg_Address}
    Set Test Variable    ${PAN}
    Set Test Variable    ${gstIn}
    Set Test Variable    ${logo}

    ${data}=    Create Dictionary
    ...    lenderName=${lenderName}
    ...    email=${email_Id}
    ...    contactNo=${contact}
    ...    registeredAddress=${reg_Address}
    ...    pan=${PAN}
    ...    status=true
    ...    gstIn=${gstIn}
    ...    logo=${logo}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${response}=       Post On Session      lender_onboarding    /api/v1/lender    json=${data}    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}
    ${json_data}       Convert String To Json    ${response.content}
    ${id}              Get Value From Json    ${json_data}    data.id
    ${lender_id}       Get From List          ${id}           0

    ${Post_pan}=       Get Value From Json    ${json_data}    data.pan
    ${PAN_No}          Get From List          ${Post_pan}     0

    ${Post_gst}=       Get Value From Json    ${json_data}    data.gstIn
    ${GST_No}          Get From List          ${Post_gst}     0

    Log to console     Lender ID is: ${lender_id}
    Set Suite Variable    ${lender_id}

    RETURN    ${lender_id}   ${lenderName}

05_DeleteLender
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}    ${lender_id}
    [Documentation]    Deletes the created lender — plain JSON (direct comServ call, not through gateway).
    ${comServ_url}=   Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    lender_delete    ${comServ_url}:${comServ_port}
    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    ${response}=      Delete On Session    lender_delete    /api/v1/lender/${lender_id}    headers=${headers}
    ${status_code}=   Convert To String    ${response.status_code}
    Should Be Equal   ${status_code}       ${expected_code}

06_Dedupe
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${PAN_Number}
    [Documentation]    AES-256-GCM encrypted dedupe check.
    ...    Encrypts the PAN payload before POST; asserts encrypted response; decrypts to parse result.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     dedupe_check     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=    Set Variable    {"pan":"${PAN_Number}"}
    ${enc_body}=   AES Encrypt Payload    ${payload}

    ${response}        POST On Session      dedupe_check    /api/v1/dedupe-check    data=${enc_body}    headers=${headers}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_code}     Get Value From Json    ${json_data}    status.http_status
    ${http_status}     Get From List          ${status_code}    0
    ${status_msg}      Get Value From Json    ${json_data}    status.message
    ${msg}             Get From List          ${status_msg}    0
    Log To Console     06_Dedupe: ${msg}

    IF    '${msg}' == 'An active loan application already exists for this customer'

        ${custId}              Get Value From Json    ${json_data}     data.platformCustomerId
        ${platform_custId}     Get From List          ${custId}        0
        ${mob}                 Get Value From Json    ${json_data}     data.mobileNumber
        ${mobile_No}           Get From List          ${mob}           0
        ${appNo}               Get Value From Json    ${json_data}     data.loanApplicationNo
        ${loanApp_No}          Get From List          ${appNo}         0
        ${type}                Get Value From Json    ${json_data}     data.productType
        ${prodType}            Get From List          ${type}          0

        Log To Console     platformCustomerId: ${platform_custId}, loanAppNo: ${loanApp_No}, productType: ${prodType}

        ${params}=         Create Dictionary    loanApplicationNo=${loanApp_No}
        ${response}        GET On Session       dedupe_check    /api/v1/workflow/workflow-details    headers=${headers}    params=${params}
        Assert Response Is AES Encrypted    ${response}
        ${json_data}=      Assert Response Decrypts To Valid JSON    ${response}
        ${status_msg}      Get Value From Json    ${json_data}    status.message
        ${msg}             Get From List          ${status_msg}   0

        Fail     msg=${msg}

    ELSE
        ${data}           Get Value From Json    ${json_data}    data
        ${active_details}    Get From List       ${data}    0
        Log To Console     ${active_details}
    END

    Log To Console     06_Dedupe: ${Validate_OTP}

    Set Test Variable    ${Validate_OTP}

    RETURN     ${Validate_OTP}

07_validate_OTP
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${Validate_OTP}     ${PAN_Number}
    [Documentation]    AES-256-GCM encrypted OTP validation.
    ...    Encrypts OTP + PAN payload before POST; asserts encrypted response; decrypts to extract platformCustomerId.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     validate_otp     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=    Set Variable    {"otp":"${Validate_OTP}","pan":"${PAN_Number}"}
    ${enc_body}=   AES Encrypt Payload    ${payload}

    ${response}            POST On Session    validate_otp    /api/v1/validate-otp    data=${enc_body}    headers=${headers}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_code}         Get Value From Json    ${json_data}    status.http_status
    ${http_status}         Get From List          ${status_code}    0
    ${status_msg}          Get Value From Json    ${json_data}    status.message
    ${msg}                 Get From List          ${status_msg}    0
    ${platform_Id}         Get Value From Json    ${json_data}    data.platformCustomerId
    ${platform_custId}     Get From List          ${platform_Id}    0

    IF    '${msg}' == 'Customer already exists'
        Fail     msg=${msg} cannot move forward
    END

    Log To Console     07_Validate_OTP: ${msg}
    Log To Console     platformCustomerId: ${platform_custId}

    RETURN     ${platform_custId}

08_getCustomer_details
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${platform_custId}
    [Documentation]    AES-256-GCM encrypted GET customer details.
    ...    No request body (GET); asserts encrypted response; decrypts to log customer info.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     get_CustomerDetails     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${params}=      Create Dictionary    platformCustomerId=${platform_custId}
    ${response}     GET On Session       get_CustomerDetails    /api/v1/customer    headers=${headers}    params=${params}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=GET customer failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_msg}    Get Value From Json    ${json_data}    status.message
    ${msg}           Get From List          ${status_msg}    0
    ${name}          Get Value From Json    ${json_data}    data[0].firstName
    ${cust_name}     Get From List          ${name}    0
    ${pan}           Get Value From Json    ${json_data}    data[0].pan
    ${cust_pan}      Get From List          ${pan}    0
    Log To Console     08_getCustomerDetails_ById: ${msg}, customerName:${cust_name}, customerPan:${cust_pan}

09_getProduct
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    [Documentation]    AES-256-GCM encrypted GET product list.
    ...    No request body (GET); asserts encrypted response; decrypts to log product info.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     getProduct_details     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${response}        GET On Session    getProduct_details    /api/v1/product    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=GET product failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_code}    Get Value From Json    ${json_data}    status.http_status
    ${http_status}    Get From List          ${status_code}    0
    ${status_msg}     Get Value From Json    ${json_data}    status.message
    ${msg}            Get From List          ${status_msg}    0
    Log To Console     09_GetProduct: ${msg}

10_loanApplication_Init
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}    ${OD_productCode}     ${branchCode}     ${PAN_Number}     ${mobile_No}     ${email_id}
    [Documentation]    AES-256-GCM encrypted loan application initiation.
    ...    Encrypts the loan payload before POST; asserts encrypted response; decrypts and fetches IDs from MongoDB.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     LoanApp_init     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=    Set Variable    {"pan":"${PAN_Number}","productCode":"${OD_productCode}","phoneNumber":"${mobile_No}","email":"${email_id}"}
    ${enc_body}=   AES Encrypt Payload    ${payload}

    ${response}        POST On Session    LoanApp_init    /api/v1/loan-application/apply    data=${enc_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=Loan init failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_code}    Get Value From Json    ${json_data}    status.http_status
    ${http_status}    Get From List          ${status_code}    0
    ${status_msg}     Get Value From Json    ${json_data}    status.message
    ${msg}            Get From List          ${status_msg}    0

    ${cust_id}=      MongoManager.Get Customer Id By Pan        ${PAN_Number}
    ${loanApp_No}=    MongoManager.Get Loan App No By Customer Id    ${cust_id}
    ${loanApp_Id}=    MongoManager.Get Loan App Id By Loan Number    ${loanApp_No}

    Set Suite Variable     ${loanApp_No}
    Set Suite Variable     ${loanApp_Id}
    Set Suite Variable     ${cust_id}

    Log to console     10_loanApplication_Init: ${msg}
    Log To Console     customer_Id: ${cust_id}, loanApp_No: ${loanApp_No}, loanApp_Id: ${loanApp_Id}

    RETURN     ${loanApp_No}    ${loanApp_Id}     ${cust_id}

11_emailInitiate
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${loanApp_No}
    [Documentation]    AES-256-GCM encrypted email initiation.
    ...    Encrypts loan application number + email before POST; asserts encrypted response; decrypts; prompts for OTP.
    ${gateway_url}=    Get From Dictionary   ${URL_CONFIGS}    ${ENV}
    Create Session     email_initiate     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=    Set Variable    {"loanApplicationNo":"${loanApp_No}","email":"${email_Id}"}
    ${enc_body}=   AES Encrypt Payload    ${payload}

    ${response}        POST On Session    email_initiate    /api/v1/kyc/initiate-email    data=${enc_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=Email initiate failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_msg}    Get Value From Json    ${json_data}     status.message
    ${msg}           Get From List          ${status_msg}    0

    ${email_OTP}=    Get value    Please enter the OTP received on your email_Id:

    Log To Console     11_emailInitiate: ${msg}

    RETURN     ${email_OTP}

12_emailValidate
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${loanApp_No}     ${email_OTP}     ${email_Id}
    [Documentation]    AES-256-GCM encrypted email OTP validation.
    ...    Encrypts loan number + email + OTP before POST; asserts encrypted response; decrypts to verify.
    ${gateway_url}=    Get From Dictionary   ${URL_CONFIGS}    ${ENV}
    Create Session     email_validate     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=    Set Variable    {"loanApplicationNo":"${loanApp_No}","email":"${email_Id}","otp":"${email_OTP}"}
    ${enc_body}=   AES Encrypt Payload    ${payload}

    ${response}        POST On Session    email_validate    /api/v1/kyc/validate-email    data=${enc_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=Email validate failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_msg}    Get Value From Json    ${json_data}    status.message
    ${msg}           Get From List          ${status_msg}    0
    Log To Console     12_emailValidate: ${msg}

13_updateLoanApplication
    [Arguments]        ${cookies}     ${client_Id}     ${api_key}     ${app_code}     ${loanApp_No}
    [Documentation]    AES-256-GCM encrypted loan application update.
    ...    Encrypts the PUT payload before sending; asserts encrypted response; decrypts to verify.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     LoanApp_update     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${payload}=    Set Variable    {"loanApplicationNo":"${loanApp_No}","purposeOfLoan":2}
    ${enc_body}=   AES Encrypt Payload    ${payload}

    ${response}        PUT On Session    LoanApp_update    /api/v1/loan-application/update    data=${enc_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=Update loan failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_msg}    Get Value From Json    ${json_data}    status.message
    ${msg}           Get From List          ${status_msg}    0
    Log To Console     13_UpdateLoanApplication: ${msg}

Logout
    [Arguments]     ${cookies}     ${client_Id}     ${api_key}     ${app_code}
    [Documentation]    AES-256-GCM encrypted logout.
    ...    No request body (GET); asserts encrypted response; decrypts to verify logout message.
    ${gateway_url}=       Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session        logout     url= ${gateway_url}:${gateway_port}

    ${headers}    Create Dictionary
    ...    Content-Type=text/plain
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_Id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${response}     GET On Session    logout    /api/v1/auth/logout    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${expected_code}
    ...    msg=Logout failed — HTTP ${response.status_code}: ${response.text}
    Assert Response Is AES Encrypted    ${response}
    ${json_data}=    Assert Response Decrypts To Valid JSON    ${response}

    ${status_msg}    Get Value From Json    ${json_data}    status.message
    ${msg}           Get From List          ${status_msg}    0
    Log To Console    ${userName}: ${msg}
