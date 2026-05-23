*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    credit_underwriter_Authentication
Test Setup    TC_CPTS_02_TermSheet_Return_PutId

*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***
${custId}             ${Anchor_cust_id}    
${anchorName}         JK Tyres
${product}            Anchor Purchase Bill Discounting                     
${regularLimit}       10
${adhocLimit}         10
${creditPeriod}       10           
${doorToDoor}         10
${invoiceAgeing}      10
${applyOfInterest}    In-Arrears
${interestBorneBy}    Counterparty
${penaltyBorneBy}     Counterparty
${renewalPeriod}      10
${interestRate}       10
${pf}                 10
${renewal}            10
${invoiceFunding}     10
${graceDays}          10
${margin}             10
${interestRateType}   Fixed
${id}                 10
${appId}              ${cp_app_id} 

*** Test Cases ***
TC_CPTS_01_TermSheet_create
   [Documentation]     CounterParty TermSheet Create
    create session     TermSheet        ${CP_base_url}
    ${entry}=          Create Dictionary    &{CP_TermSheet}
    ${TermSheet}=      Create List    ${entry}
    ${header}=         Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    &{data}=           Create Dictionary     createdBy=QA     updatedBy=QA    termSheetDataList=${TermSheet}
    ${response}=       Post Request          TermSheet     /termSheet/${cp_app_id}         data=${data}     headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal    ${status_code}         ${expected_code}

TermSheet_Update
    TC_CPTS_03_TermSheet_Update         ${custId}    ${anchorName}    ${product}    ${regularLimit}      ${adhocLimit}      ${creditPeriod}     ${doorToDoor}     ${invoiceAgeing}     ${applyOfInterest}     ${interestBorneBy}     ${penaltyBorneBy}     ${renewalPeriod}       ${interestRate}     ${pf}       ${renewal}     ${invoiceFunding}    ${graceDays}    ${margin}    ${interestRateType}      ${TS_putId}    ${appId}           

*** Keywords ***
TC_CPTS_02_TermSheet_Return_PutId
    [Documentation]        Counterparty   Termsheet  read
    create session         Cp_Termsheet                               ${CP_base_url}
    ${header}=             Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=           GET On Session                                Cp_Termsheet             /termSheetGet/${cp_app_id}         headers=${header}
    ${json-data}=          Convert String To Json  ${response.content}
    ${id_value}=           Get Value From Json    ${json-data}    $[0].id
    ${TS_putId}=           Get From List    ${id_value}           0
    log  ${TS_putId}
    Set Global Variable   ${TS_putId}

TC_CPTS_03_TermSheet_Update
    [Documentation]     CounterParty TermSheet Update
    [Arguments]         ${custId}    ${anchorName}    ${product}    ${regularLimit}      ${adhocLimit}      ${creditPeriod}     ${doorToDoor}     ${invoiceAgeing}     ${applyOfInterest}     ${interestBorneBy}     ${penaltyBorneBy}     ${renewalPeriod}       ${interestRate}     ${pf}       ${renewal}     ${invoiceFunding}    ${graceDays}    ${margin}    ${interestRateType}      ${id}    ${appId}           
    create session     TermSheet_PUT       ${CP_base_url}
    ${entry}=          Create Dictionary     custId=${Anchor_cust_id}    anchorName=MK Pvt Ltd    product=Dealer Sales Bill    regularLimit=1      adhocLimit=1      creditPeriod=1     doorToDoor=1     invoiceAgeing=1     applyOfInterest=1     interestBorneBy=1     penaltyBorneBy=1     renewalPeriod=1       interestRate=1     pf=1       renewal=1     invoiceFunding=1    graceDays=1    margin=1    interestRateType=fixed      id=${TS_putId}   appId=${cp_app_id}           
    ${TermSheet1}=     Create List    ${entry}
    ${header}=         Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    &{data}=           Create Dictionary      createdBy=QA     updatedBy=QA    termSheetDataList=${TermSheet1}
    ${response}=       Put Request          TermSheet_PUT       /updateTermSheet         data=${data}     headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal    ${status_code}         ${expected_code}



