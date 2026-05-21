*** Settings ***
Resource    ../../keywords/variables.robot
Test Setup     Anchor_Beneficiary_ReturnId_for_PUT
Suite Setup    operation_maker_Authentication

*** Keywords ***
operation_maker_Authentication
    ${username}    Set Variable       operation_maker_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Variables ***          
${appId}               ${Anchor_App_id}
${bankAcctNumber}      2038309487380
${bankBranchCode}      000281 
${bankBranchName}      Vadalur
${bankCode}            449
${bankIfscCode}        IOBA0000281
${bankName}            INDIAN OVERSEAS BANK
${benName}             HARI
${benType}             Dealer

*** Test Cases ***
TC_BD01_Beneficiary_create
    [Documentation]    Anchor  Beneficiary1   creation
    create session     anchor_beneficiary1     ${base_url}
    ${bankAcctNumber}=        Generate Random String    10     [NUMBERS]
    ${body}=           Create Dictionary        appId=${appId}     bankAcctNumber=${bankAcctNumber}      bankBranchCode=000281         bankBranchName=Vadalur      bankCode=449      bankIfscCode=IOBA0000281     bankName=INDIAN OVERSEAS BANK     benName=HARI     id=0      benType=DEALER    
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       Post Request            anchor_beneficiary1      /anchorBeneficiary      data=${body}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}          ${expected_code}

AnchorBeneficiary_Update   
    TC_AD_04_AnchorBeneficiary_Update            ${appId}    ${bankAcctNumber}      ${bankBranchCode}         ${bankBranchName}      ${bankCode}      ${bankIfscCode}     ${bankName}      ${benName}     ${Ben_putID}       ${benType} 
    
*** Keywords ***
TC_AD_04_AnchorBeneficiary_Update
    [Arguments]        ${appId}    ${bankAcctNumber}      ${bankBranchCode}         ${bankBranchName}      ${bankCode}      ${bankIfscCode}     ${bankName}      ${benName}     ${Ben_putID}       ${benType} 
    [Documentation]    Anchor Basic Beneficiary Update
    create session     anchor_Beneficiary      ${base_url}
    ${bankAcctNumber}=     Generate Random String        10    [NUMBERS]    
    ${body}=           Create Dictionary       appId=${appId}     bankAcctNumber=${bankAcctNumber}      bankBranchCode=${bankBranchCode}        bankBranchName=${bankBranchName}      bankCode=${bankCode}      bankIfscCode=${bankIfscCode}       bankName=${bankName}      benName=${benName}     id=${Ben_putID}       benType=${benType} 
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Beneficiary       /anchorBeneficiary      data=${body}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}
    
Anchor_Beneficiary_ReturnId_for_PUT
    [Documentation]   Getting the anchor key details
    create session    anchor_Beneficiary  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      GET On Session      anchor_Beneficiary         /anchorBeneficiaryFile/${Anchor_App_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    Log To Console    ${json-data}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${Ben_putID}=            Get From List    ${id_value}           0
    Log To Console  ${Ben_putID}
    Set Global Variable   ${Ben_putID}  
