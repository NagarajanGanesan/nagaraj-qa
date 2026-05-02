*** Settings ***
Resource    ../resources/imports.robot
Resource    ../keywords/variables.robot

*** Keywords ***
Generate Random PAN
    ${letters}=    Set Variable    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    ${first5}=     Evaluate    ''.join(random.choices('${letters}', k=5))    random
    ${digits}=     Evaluate    ''.join(random.choices('0123456789', k=4))    random
    ${last}=       Evaluate    random.choice('${letters}')    random
    ${panNo}=      Set Variable    ${first5}${digits}${last}
    RETURN         ${panNo}

Generate Random GSTIN
    ${state_code}=    Evaluate    random.randint(1, 35)    random
    ${state_code}=    Evaluate    f"{${state_code}:02d}"
    ${pan}=           Generate Random PAN
    ${entity_code}=   Evaluate    random.choice('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')    random
    ${checksum}=      Evaluate    random.choice('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')    random
    ${gstin}=         Set Variable    ${state_code}${pan}${entity_code}Z${checksum}
    RETURN            ${gstin}

Generate Random Mobile Number
    ${start_digit}=    Evaluate    random.choice('6789')    random
    ${remaining}=      Evaluate    ''.join(random.choices('0123456789', k=9))    random
    ${mobile}=         Set Variable    ${start_digit}${remaining}
    RETURN             ${mobile}

Generate Random Aadhaar
    ${random_aadhar}=    FakerLibrary.Random Number    digits=12    fix_len=True
    RETURN    ${random_aadhar}

Generate Random Address
    ${raw_address}=      FakerLibrary.Address
    ${no_newlines}=      Replace String    ${raw_address}    \n    ${SPACE}
    ${clean_address}=    Replace String Using Regexp    ${no_newlines}    [^a-zA-Z0-9 ]    ${EMPTY}
    ${clean_address}=    Replace String Using Regexp    ${clean_address}    \\s+    ${SPACE}
    RETURN    ${clean_address}

Generate Bank Name
    ${banks}=    Create List    SBI    HDFC    ICICI    AXIS    PNB    KOTAK    YES    BOB    CANARA    UNION
    ${bank}=     Evaluate    random.choice(${banks})    random
    RETURN       ${bank}

Generate Account Number
    [Arguments]    ${bank_name}
    ${acc_no}=    Generate Random String    12    [NUMBERS]
    RETURN        ${acc_no}

Generate Ifsc
    [Arguments]    ${bank_name}
    ${code}=       Convert To Upper Case    ${bank_name}
    ${code}=       Get Substring    ${code}    0    4
    ${branch}=     Generate Random String    6    [UPPER][NUMBERS]
    ${ifsc}=       Set Variable    ${code}0${branch}
    RETURN         ${ifsc}

# ──────────────────────────────────────────────────────────────
# AUTH HEADER HELPERS  — use these instead of inline Create Dictionary blocks
# ──────────────────────────────────────────────────────────────

Fetch DB Credentials
    [Documentation]    Queries PostgreSQL for the api_key and client_id matching app_code.
    [Arguments]    ${app_code}
    ${db}=          Get From Dictionary    ${DB_CONFIGS}    ${ENV}
    Connect To Database    psycopg2    ${db.name}    ${db.Username}    ${db.Password}    ${db.Host}    ${db.Port}    None
    ${rows}=        Query    SELECT api_key, client_id FROM ${schemeName}.partner_product_config WHERE app_code = '${app_code}';
    Disconnect From Database
    ${row}=         Get From List    ${rows}    0
    ${api_key}=     Get From List    ${row}     0
    ${client_id}=   Get From List    ${row}     1
    RETURN    ${api_key}    ${client_id}

Build Auth Headers
    [Documentation]    Returns auth headers without a session cookie (used for login / unauthenticated calls).
    [Arguments]    ${client_id}    ${api_key}    ${app_code}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    xxx-CLIENT-ID=${client_id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    RETURN    ${headers}

Build Session Headers
    [Documentation]    Returns auth headers that include the active session cookie.
    [Arguments]    ${cookies}    ${client_id}    ${api_key}    ${app_code}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=${cookies}
    ...    xxx-CLIENT-ID=${client_id}
    ...    xxx-API-KEY=${api_key}
    ...    app-code=${app_code}
    RETURN    ${headers}
