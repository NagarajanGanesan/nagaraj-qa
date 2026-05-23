*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    credit_underwriter_Authentication
Test Setup    TC_CPLE_02_LimitEligibility_ReturnPutId


*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Variables ***
${custId}                       ${Anchor_cust_id}      
${product}                      Anchor Purchase bill discounting
${anchorName}                   JK Tyres
${creditPeriod}                 10         
${loginLimitAmount}             10
${id}                           ${LE_putId}
${appId}                        ${cp_app_id}
${currentLimit}                 10           
${proposedLimit}                10
${eligibleLimit}                10
${adhocLimit}                   10
${doortoDoor}                   10
${invoiceAgeing}                10
${margin}                       10
${expectedGrowth}               10
${monthlyAverage}               10
${calculatedLimitWoSetOff}      10
${approtionedLimits}            10              
${existingScfLimits}            10
${modelLimit}                   10
${anchorRecommendedAmount}      10
${receivables}                  10
${inventory}                    10
${creditor}                     10
${expectedMonthlyTurnOverWithAnchor}      10
${modelAdhocLimit}              10

*** Test Cases ***
TC_CPLE_01_LimitEligibility_create
    [Documentation]    CounterParty Limit Eligibility Create
    create session     LimitEligibility       ${CP_base_url}
    ${entry}=          Create Dictionary      &{CP_LimitEligible} 
    ${LimitEligible}=  Create List    ${entry}
    ${header}=         Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    &{data}=           Create Dictionary      createdBy=Test     updatedBy=Test    limitEligibilityDetailsData=${LimitEligible}
    ${response}=       Post Request           LimitEligibility     /limitEligibility/${cp_app_id}     data=${data}    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal    ${status_code}         ${expected_code}

LimitEligibility_Update
    TC_CPLE_03_LimitEligibility_Update     ${custId}       ${product}      ${anchorName}      ${creditPeriod}       ${loginLimitAmount}       ${LE_putId}        ${appId}      ${currentLimit}      ${proposedLimit}     ${eligibleLimit}     ${adhocLimit}     ${doortoDoor}     ${invoiceAgeing}     ${margin}     ${expectedGrowth}     ${monthlyAverage}     ${calculatedLimitWoSetOff}     ${approtionedLimits}     ${existingScfLimits}      ${modelLimit}    ${anchorRecommendedAmount}    ${receivables}    ${inventory}     ${creditor}    ${expectedMonthlyTurnOverWithAnchor}     ${modelAdhocLimit}
    

*** Keywords ***
TC_CPLE_02_LimitEligibility_Return_PutId
    [Documentation]        Counterparty   Limit Eligibility Read
    create session         LimitEligibility                               ${CP_base_url}
    ${header}=             Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=           GET On Session                            LimitEligibility             /limitEligibilityById/${cp_app_id}     headers=${header}
    ${json-data}=          Convert String To Json  ${response.content}
    ${id_value}=           Get Value From Json    ${json-data}    $[0].id
    ${LE_putId}=           Get From List    ${id_value}           0
    log  ${LE_putId}
    Set Global Variable   ${LE_putId}

TC_CPLE_03_LimitEligibility_Update
    [Arguments]         ${custId}       ${product}      ${anchorName}      ${creditPeriod}       ${loginLimitAmount}       ${id}        ${appId}      ${currentLimit}      ${proposedLimit}     ${eligibleLimit}     ${adhocLimit}     ${doortoDoor}     ${invoiceAgeing}     ${margin}     ${expectedGrowth}     ${monthlyAverage}     ${calculatedLimitWoSetOff}     ${approtionedLimits}     ${existingScfLimits}      ${modelLimit}    ${anchorRecommendedAmount}    ${receivables}    ${inventory}     ${creditor}    ${expectedMonthlyTurnOverWithAnchor}     ${modelAdhocLimit}
    [Documentation]    CounterParty Limit Eligibility Update
    create session     LimitEligibility_PUT       ${CP_base_url}
    ${entry}=          Create Dictionary      custId=${custId}      product=${product}      anchorName=${anchorName}      creditPeriod=${creditPeriod}      loginLimitAmount=${loginLimitAmount}       id=${id}        appId=${appId}      currentLimit=${currentLimit}      proposedLimit=${proposedLimit}     eligibleLimit=${eligibleLimit}     adhocLimit=${adhocLimit}     doortoDoor=${doortoDoor}     invoiceAgeing=${invoiceAgeing}     margin=${margin}     expectedGrowth=${expectedGrowth}     monthlyAverage=${monthlyAverage}     calculatedLimitWoSetOff=${calculatedLimitWoSetOff}     approtionedLimits=${approtionedLimits}     existingScfLimits=${existingScfLimits}      modelLimit=${modelLimit}     anchorRecommendedAmount=${anchorRecommendedAmount}     receivables=${receivables}     inventory=${inventory}     creditor=${creditor}     expectedMonthlyTurnOverWithAnchor=${expectedMonthlyTurnOverWithAnchor}      modelAdhocLimit=${modelAdhocLimit}
    ${LimitEligible}=  Create List    ${entry}
    &{data}=           Create Dictionary      createdBy=Test         limitEligibilityDetailsData=${LimitEligible}      updatedBy=Test    
    ${header}=         Create Dictionary       Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       Put Request           LimitEligibility_PUT      /limitEligibility     data=${data}    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal    ${status_code}         ${expected_code}  