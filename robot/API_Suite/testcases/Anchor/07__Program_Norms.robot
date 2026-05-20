*** Settings ***
Resource    ../../keywords/variables.robot
Test Setup     Anchor_ProgramNorms_ReturnId_for_PUT
Suite Setup    CPA_Authentication

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
    
*** Variables ***
${adhocProgLimit}              ${50000}
${anchorOnboardingDate}        2021-08-12
${appId}                       ${Anchor_App_id}
${cmpOvdInt}                   No
${cmpdInt}                     Yes
${counterPartyGracePeriod}     ${5}
${cpMaxLimit}                  ${950000}   
${cpMinLimit}                  ${750000}
${createdBy}                   QA
${doorToDoor}                  ${30}
${dueDateCalculation}          22-10-2023
${fundingPercent}              ${90}
${fundingType}                 Tier 2
${interestAppTye}              Upfront       
${interestCalculation}         Absolute Penalty Rate
${interestOwnerShip}           Anchor
${interestPaymentFrequency}    Monthly
${interestRate}                ${26}
${interimReviewFrequency}      ${12}
${invoiceAgeing}               ${30}
${maxDrawdown}                 ${100}
${nextInterimReviewOn}         2021-04-24
${overallProgLimit}            ${700000}
${penalInterest}               ${3}
${penalInterestOwnerShip}      Anchor
${pricingRoiMax}               ${15}
${pricingRoiMin}               ${13}
${processingFeesMax}           ${1}
${processingFeesMin}           ${1}
${programType}                 Dealer
${regularProgLimit}            ${60000}
${repaymentType}               Bullet
${securityCovgPrimary}         Counterparty
${securityCovgSecondry}        FLDG
${stopSupplyTriggerDays}       ${60}
${tenure}                      ${45}
${subProduct}                  POS
${transactionType}             Recourse
${updatedBy}                   QA

*** Test Cases ***
AnchorProgramNorms_Update
    TC_AP_27_AnchorProgramNorms_Update       ${adhocProgLimit}       ${anchorOnboardingDate}      ${appId}     ${cmpOvdInt}     ${cmpdInt}      ${counterPartyGracePeriod}     ${cpMaxLimit}     ${cpMinLimit}     ${createdBy}     ${doorToDoor}     ${dueDateCalculation}     ${fundingPercent}      ${fundingType}     ${programNorms_putId}      ${interestAppTye}     ${interestCalculation}     ${interestOwnerShip}     ${interestPaymentFrequency}     ${interestRate}     ${interimReviewFrequency}     ${invoiceAgeing}     ${maxDrawdown}     ${nextInterimReviewOn}     ${overallProgLimit}     ${penalInterest}     ${penalInterestOwnerShip}     ${pricingRoiMax}     ${pricingRoiMin}     ${processingFeesMax}     ${processingFeesMin}      ${programType}      ${regularProgLimit}         ${repaymentType}     ${securityCovgPrimary}     ${securityCovgSecondry}      ${stopSupplyTriggerDays}     ${tenure}      ${subProduct}          ${transactionType}     ${updatedBy}

TC_PN_01_Test_anchorPrograms_By_App_Id_read
    [Tags]    SANITY
    [Documentation]    Getting Anchor Program details by C_id
    create session     anchorPrograms_By_Cust_Id                          ${base_url}
    ${header}=    Create Dictionary    Authorization=${SAMPLE_TOKEN}   Content-Type=application/json
    ${response}=       GET On Session           anchorPrograms_By_Cust_Id        /programsDetailsByCustId/${Anchor_cust_id}   headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

TC_PN_03_Test_anchorPrograms_By_Id_read
    [Tags]    SANITY
    [Documentation]    Getting Anchor Program details by Product
    create session     anchorPrograms_By_Product                          ${base_url}
     ${header}=    Create Dictionary    Authorization=${SAMPLE_TOKEN}   Content-Type=application/json
    ${response}=       Get Request                              anchorPrograms_By_Product        /anchorPrograms/${Anchor_App_id}?productName=Dealer Invoice Finance     headers=${header} 
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

*** Keywords ***
TC_AP_27_AnchorProgramNorms_Update
    [Arguments]           ${adhocProgLimit}       ${anchorOnboardingDate}      ${appId}     ${cmpOvdInt}     ${cmpdInt}      ${counterPartyGracePeriod}     ${cpMaxLimit}     ${cpMinLimit}     ${createdBy}     ${doorToDoor}     ${dueDateCalculation}     ${fundingPercent}      ${fundingType}     ${id}      ${interestAppTye}     ${interestCalculation}     ${interestOwnerShip}     ${interestPaymentFrequency}     ${interestRate}     ${interimReviewFrequency}      ${invoiceAgeing}       ${maxDrawdown}     ${nextInterimReviewOn}     ${overallProgLimit}     ${penalInterest}     ${penalInterestOwnerShip}     ${pricingRoiMax}     ${pricingRoiMin}     ${processingFeesMax}     ${processingFeesMin}     ${programType}        ${regularProgLimit}        ${repaymentType}     ${securityCovgPrimary}     ${securityCovgSecondry}      ${stopSupplyTriggerDays}         ${tenure}       ${subProduct}         ${transactionType}     ${updatedBy}          
    [Documentation]      Anchor ProgramNorms Detail Update
    create session       anchor_ProgramNorms      ${base_url}
    ${entry}=            Create Dictionary      adhocProgLimit=${adhocProgLimit}       anchorOnboardingDate=${anchorOnboardingDate}      appId=${appId}     cmpOvdInt=${cmpOvdInt}     cmpdInt=${cmpdInt}      counterPartyGracePeriod=${counterPartyGracePeriod}     cpMaxLimit=${cpMaxLimit}     cpMinLimit=${cpMinLimit}     createdBy=${createdBy}     doorToDoor=${doorToDoor}     dueDateCalculation=${dueDateCalculation}     fundingPercent=${fundingPercent}      fundingType=${fundingType}     id=${programNorms_putId}      interestAppTye=${interestAppTye}     interestCalculation=${interestCalculation}      interestOwnerShip=${interestOwnerShip}      interestPaymentFrequency=${interestPaymentFrequency}     interestRate=${interestRate}     interimReviewFrequency=${interimReviewFrequency}     invoiceAgeing=${invoiceAgeing}     maxDrawdown=${maxDrawdown}     nextInterimReviewOn=${nextInterimReviewOn}     overallProgLimit=${overallProgLimit}     penalInterest=${penalInterest}     penalInterestOwnerShip=${penalInterestOwnerShip}     pricingRoiMax=${pricingRoiMax}     pricingRoiMin=${pricingRoiMin}     processingFeesMax=${processingFeesMax}     processingFeesMin=${processingFeesMin}     programType=${programType}       regularProgLimit=${regularProgLimit}       repaymentType=${repaymentType}     securityCovgPrimary=${securityCovgPrimary}     securityCovgSecondry=${securityCovgSecondry}      stopSupplyTriggerDays=${stopSupplyTriggerDays}       tenure=${tenure}       subProduct=${subProduct}        transactionType=${transactionType}     updatedBy=${updatedBy}
    ${anchorProgarmNormsList}=      Create List    ${entry}
    &{data}=            Create Dictionary      anchorProgarmNormsList=${anchorProgarmNormsList}      createdBy=QA    updatedBy=QA   
    ${header}           Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=        Put Request             anchor_ProgramNorms       /anchorPrograms      data=${data}      headers=${header}
    ${status_code}=     convert to string       ${response.status_code}
    should be equal     ${status_code}     ${expected_code}

Anchor_ProgramNorms_ReturnId_for_PUT
    [Documentation]  Getting the anchor authorized details
    create session   anchor_ProgramNorms  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      Get Request   anchor_ProgramNorms      /anchorProgramsFile/${Anchor_App_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${programNorms_putId}=           Get From List    ${id_value}           0
    log  ${programNorms_putId}
    Set Global Variable   ${programNorms_putId}
