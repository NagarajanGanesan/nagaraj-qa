*** Settings ***
Resource     ../../keywords/common.robot
Resource     ../KVB_PositiveFlow/00_KVB_variables.robot
Library      ../../resources/MongoManager.py     env=dev

*** Keywords ***
01_Login as user
    [Documentation]    Authenticate and return session cookies + API credentials.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     user_login    url=${gateway_url}:${gateway_port}
    ${api_key}    ${client_Id}=    Fetch DB Credentials    ${app_code}
    ${headers}=    Build Auth Headers    ${client_Id}    ${api_key}    ${app_code}
    ${body}=    Create Dictionary
    ...    username=${userName}
    ...    userpassword=${password}
    ...    login_type=valid_loginType
    ${response}=       POST On Session    user_login    /api/v1/auth/adlogin    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=      Convert String To Json    ${response.content}
    ${message}=        Get Value From Json    ${json_data}    status.code
    ${msg}=            Get From List          ${message}     0
    ${branch}=         Get Value From Json    ${json_data}    data.branch_code
    ${branchCode}=     Get From List          ${branch}      0
    ${name}=           Get Value From Json    ${json_data}    data.user_name
    ${user_name}=      Get From List          ${name}        0
    ${raw_cookies}=    Set Variable           ${response.cookies.get_dict()}
    ${access_token}=   Get From Dictionary    ${raw_cookies}    captix-access-token
    ${refresh_token}=  Get From Dictionary    ${raw_cookies}    captix-refresh-token
    ${cookies}=        Set Variable    captix-access-token=${access_token}; captix-refresh-token=${refresh_token}; user_id=${userId}; user_roles=${userRole}
    Log To Console     ${user_name}: 01_${msg}
    RETURN    ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${branchCode}

02_Dedupe
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    [Documentation]    Check whether the customer already has an active application.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     dedupe_check    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${data}=    Create Dictionary
    ...    lenderCustomerId=${lenderCustId}
    ${response}=       POST On Session    dedupe_check    /api/v1/dedupe-check    json=${data}    headers=${headers}
    ${json_data}=      Convert String To Json    ${response.content}
    ${status_msg}=     Get Value From Json    ${json_data}    status.message
    ${msg}=            Get From List          ${status_msg}   0
    Log To Console     02_Dedupe: ${msg}
    IF    '${msg}' == 'An active loan application already exists for this customer'
        ${custId}=           Get Value From Json    ${json_data}    data.platformCustomerId
        ${platform_custId}=  Get From List          ${custId}       0
        ${mob}=              Get Value From Json    ${json_data}    data.mobileNumber
        ${mobile_No}=        Get From List          ${mob}          0
        ${appNo}=            Get Value From Json    ${json_data}    data.loanApplicationNo
        ${loanApp_No}=       Get From List          ${appNo}        0
        ${type}=             Get Value From Json    ${json_data}    data.productType
        ${prodType}=         Get From List          ${type}         0
        Log To Console     platformCustomerId: ${platform_custId}, loanAppNo: ${loanApp_No}, productType: ${prodType}
        ${params}=           Create Dictionary    loanApplicationNo=${loanApp_No}
        ${response}=         GET On Session    dedupe_check    /api/v1/workflow/workflow-details    headers=${headers}    params=${params}
        ${json_data}=        Convert String To Json    ${response.content}
        ${status_msg}=       Get Value From Json    ${json_data}    status.message
        ${msg}=              Get From List          ${status_msg}   0
        Fail    msg=${msg}
    ELSE
        ${data}=           Get Value From Json    ${json_data}    data
        ${active_details}=    Get From List    ${data}    0
        Log To Console     ${active_details}
    END
    ${Validate_OTP}=    Set Variable    12345
    Log To Console     02_Dedupe OTP: ${Validate_OTP}
    Set Test Variable    ${Validate_OTP}
    RETURN    ${Validate_OTP}

03_validate_OTP
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${Validate_OTP}
    [Documentation]    Submit dedupe OTP and return the resolved platformCustomerId.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     validate_otp    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${body}=    Create Dictionary    otp=${Validate_OTP}    lenderCustomerId=${lenderCustId}
    ${response}=        POST On Session    validate_otp    /api/v1/validate-otp    json=${body}    headers=${headers}
    ${json_data}=       Convert String To Json    ${response.content}
    ${status_msg}=      Get Value From Json    ${json_data}    status.message
    ${msg}=             Get From List          ${status_msg}   0
    ${platform_Id}=     Get Value From Json    ${json_data}    data.platformCustomerId
    ${platform_custId}=    Get From List    ${platform_Id}    0
    IF    '${msg}' == 'Customer already exists'
        Fail    msg=${msg} cannot move forward
    END
    Log To Console     03_Validate_OTP: ${msg}
    Log To Console     platformCustomerId: ${platform_custId}
    RETURN    ${platform_custId}

04_getCustomer_details
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${platform_custId}
    [Documentation]    Retrieve and log customer profile by platformCustomerId.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     get_CustomerDetails    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${params}=     Create Dictionary    platformCustomerId=${platform_custId}
    ${response}=   GET On Session    get_CustomerDetails    /api/v1/customer    headers=${headers}    params=${params}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    ${name}=       Get Value From Json    ${json_data}    data[0].firstName
    ${cust_name}=  Get From List          ${name}         0
    ${pan}=        Get Value From Json    ${json_data}    data[0].pan
    ${cust_pan}=   Get From List          ${pan}          0
    Log To Console     04_getCustomerDetails_ById: ${msg}, customerName:${cust_name}, customerPan:${cust_pan}

05_getProduct
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    [Documentation]    Fetch available products and return the configured product code.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     getProduct_details    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${response}=   GET On Session    getProduct_details    /api/v1/product    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console     05_GetProduct: ${msg}
    RETURN    ${productCode}

06_loanApplication_Init
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${productCode}    ${branchCode}
    [Documentation]    Initiate loan application and resolve IDs from MongoDB.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     LoanApp_init    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${body}=    Create Dictionary
    ...    pan=${PAN_Number}
    ...    productCode=${productCode}
    ...    phoneNumber=${mobile_No}
    ...    email=${email_id}
    ${response}=       POST On Session    LoanApp_init    /api/v1/loan-application/apply    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    ${cust_id}=    MongoManager.Get Customer Id By Pan              ${PAN_Number}
    ${loanApp_No}=    MongoManager.Get Loan App No By Customer Id    ${cust_id}
    ${loanApp_Id}=    MongoManager.Get Loan App Id By Loan Number    ${loanApp_No}
    Set Suite Variable    ${loanApp_No}
    Set Suite Variable    ${loanApp_Id}
    Set Suite Variable    ${cust_id}
    Log to console     06_loanApplication_Init: ${msg}
    Log To Console     customer_Id: ${cust_id}, loanApp_No: ${loanApp_No}, loanApp_Id: ${loanApp_Id}
    RETURN    ${loanApp_No}    ${loanApp_Id}    ${cust_id}

07_emailInitiate
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${loanApp_No}
    [Documentation]    Trigger email OTP for KYC and return the mock OTP value.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     email_initiate    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${body}=    Create Dictionary    loanApplicationNo=${loanApp_No}    email=${email_Id}
    ${response}=       POST On Session    email_initiate    /api/v1/kyc/initiate-email    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    ${email_OTP}=    Set Variable    12345
    Log To Console     07_emailInitiate: ${msg}
    RETURN    ${email_OTP}

08_emailValidate
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${loanApp_No}    ${email_OTP}
    [Documentation]    Validate email OTP to complete KYC.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     email_validate    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${body}=    Create Dictionary    loanApplicationNo=${loanApp_No}    email=${email_Id}    otp=${email_OTP}
    ${response}=       POST On Session    email_validate    /api/v1/kyc/validate-email    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console     08_emailValidate: ${msg}

09_getCodeValue
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    [Documentation]    Retrieve code values used in loan application dropdowns.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     get_CodeValue    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${params}=     Create Dictionary    codeId=${codeValue_Id}
    ${response}=   GET On Session    get_CodeValue    /api/v1/codeValues    headers=${headers}    params=${params}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console     09_CodeValues: ${msg}

10_updateLoanApp
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${loanApp_No}
    [Documentation]    Update loan application with purpose of loan.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     LoanApp_update    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${body}=    Create Dictionary
    ...    loanApplicationNo=${loanApp_No}
    ...    purposeOfLoan=${2}
    ${response}=       PUT On Session    LoanApp_update    /api/v1/loan-application/update    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console     10_UpdateLoanApplication: ${msg}

11_getCust_BankDetail
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${platform_custId}
    [Documentation]    Retrieve saved bank accounts for the customer.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     get_CustBankDetails    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${response}=   GET On Session    get_CustBankDetails    /api/v1/customer/bankAccounts/${platform_custId}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console     11_Get_CustomerBank_Details: ${msg}

12_create_BankInt
    [Arguments]        ${loanApp_No}    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    [Documentation]    Link a bank account to the loan application.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     Bank_Init    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${data}=    Create Dictionary
    ...    loanApplicationNo=${loanApp_No}
    ...    bankAccountNumber=${bankAccountNo}
    ...    ifscCode=${ifsc_code}
    ...    bankName=${bankName}
    ...    bankAccountType=${bankAccountType}
    ...    accountHolderName=${accountHolderName}
    ${response}=       POST On Session    Bank_Init    /api/v1/bank/init    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console     12_Loan Bank Acc Init: ${msg}

Logout
    [Arguments]    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    [Documentation]    Invalidate the active session.
    ${gateway_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     logout    url=${gateway_url}:${gateway_port}
    ${headers}=    Build Session Headers    ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${response}=   GET On Session    logout    /api/v1/auth/logout    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ${json_data}=  Convert String To Json    ${response.content}
    ${status_msg}=    Get Value From Json    ${json_data}    status.message
    ${msg}=        Get From List          ${status_msg}   0
    Log To Console    user: ${msg}