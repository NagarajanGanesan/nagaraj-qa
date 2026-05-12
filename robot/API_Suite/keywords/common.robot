*** Settings ***
Resource    ../resources/imports.robot
Resource    ../keywords/variables.robot
Suite Setup    Obtain_Auth_Token

*** Keywords ***
I Open My Triton URL "${url}" With Browser "${browser}"
    [Documentation]    Open Triton URL with specified browser
    Open Browsers    ${url}  ${browser}

Open Browsers
    [Arguments]    ${url}    ${browser}
    Open Browser    ${url}   browser=${browser}
    Maximize Browser Window

TC_BD_Beneficiary_DataFile_Negative_Validation
    [Arguments]     ${appId}   ${bankAcctNumber}    ${bankBranchCode}     ${bankBranchName}    ${bankCode}    ${bankIfscCode}    ${bankName}    ${benName}    ${benType}
    [Documentation]    Anchor  Beneficiary Post Request Negative validation using Data File
    create session     anchor_beneficiary      ${base_url}
    ${body}=           create dictionary    appId=${appId}    bankAcctNumber=${bankAcctNumber}      bankBranchCode=${bankBranchCode}     bankBranchName=${bankBranchName}    bankCode=${bankCode}    bankIfscCode=${bankIfscCode}      bankName=${bankName}      benName=${benName}    benType=${benType}  
    ${header}=         create dictionary      Authorization=${SAMPLE_TOKEN}       content-type=application/json
    ${response}=       Post Request           anchor_beneficiary        /anchorBeneficiary      json=${body}       headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    Should Be Equal    ${status_code}       ${incorrect_expected_code}
    
TC_CN_CreditNorms detail positive testing
    [Arguments]          ${appId}      ${value}     ${cnMasterId}     
    [Documentation]     CreditNorms Creation
    create session      creditNorms_detail      ${base_url}
    ${entry}=           Create Dictionary      appId=${appId}     value=${value}    cnMasterId=${cnMasterId} 
    ${credit_list}=      Create List    ${entry}
    &{data}=            Create Dictionary         creditNormsDetailsDataList=${credit_list}    updatedBy=QA     createdBy=QA
    ${header}=          Create Dictionary      Authorization=${SAMPLE_TOKEN}       content-type=application/json
    ${response}=        Post Request    creditNorms_detail     /creditNormsDetails     data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}

TC_CN_CreditNorms_DataFile_Negative_Validation
    [Arguments]                ${appId}     ${value}     ${cnMasterId}     
    [Documentation]            Anchor creditNorm creation
    create session             anchor_creditNorms    ${base_url}
    ${entry}=                  Create Dictionary      appId=${appId}     value=${value}     cnMasterId=${cnMasterId}
    ${credit_list}=   Create List    ${entry}
    ${header}=                 Create Dictionary       Authorization=${SAMPLE_TOKEN}        content-type=application/json
    &{data}=                   Create Dictionary        creditNormsDetailsDataList=${credit_list}      createdBy=QA     updatedBy=QA 
    ${response}=               Post Request           anchor_creditNorms     /creditNormsDetails    data=${data}    headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal    ${status_code}          ${incorrect_expected_code}

TC_CPEL_LimitEligibility_Negative_Validation
    [Arguments]        ${custId}     ${appId}     ${product}     ${currentLimit}     ${proposedLimit}     ${eligibleLimit}     ${adhocLimit}     ${creditPeriod}     ${doortoDoor}     ${invoiceAgeing}     ${margin}     ${expectedGrowth}     ${monthlyAverage}     ${calculatedLimitWoSetOff}     ${approtionedLimits}     ${existingScfLimits}     ${modelLimit}     ${customerRequestedAmount}     ${anchorRecommendedAmount}
    [Documentation]    CounterParty Limit Eligibility
    create session     LimitEligibility       ${CP_base_url}
    ${entry}=          Create Dictionary      custId=${custId}     appId=${appId}     product=${product}     currentLimit=${currentLimit}     proposedLimit=${proposedLimit}     eligibleLimit=${eligibleLimit}     adhocLimit=${adhocLimit}     creditPeriod=${creditPeriod}     doortoDoor=${doortoDoor}     invoiceAgeing=${invoiceAgeing}     margin=${margin}     expectedGrowth=${expectedGrowth}     monthlyAverage=${monthlyAverage}     calculatedLimitWoSetOff=${calculatedLimitWoSetOff}     approtionedLimits=${approtionedLimits}     existingScfLimits=${existingScfLimits}     modelLimit=${modelLimit}     customerRequestedAmount=${customerRequestedAmount}     anchorRecommendedAmount=${anchorRecommendedAmount}
    ${LimitEligible}=  Create List    ${entry}
    ${header}=         Create Dictionary    content-type=application/json
    &{data}=           Create Dictionary      createdBy=QA     updatedBy=QA    limitEligibilityDetailsData=${LimitEligible}
    ${response}=       Post Request           LimitEligibility     /limitEligibility/${app_id}    data=${data}    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal    ${status_code}          ${incorrect_expected_code}

TC_CPTS_TermSheet_Negative_Validation
    [Arguments]        ${adhocLimit}     ${creditPeriod}     ${custId}     ${doorToDoor}     ${interestRate}     ${interestRateType}     ${invoiceAgeing}     ${margin}     ${pf}     ${product}     ${regularLimit}     ${renewal}     ${renewalPeriod}
    create session     TermSheet        ${CP_base_url}
    ${entry}=          Create Dictionary    adhocLimit=${adhocLimit}     creditPeriod=${creditPeriod}     custId=${custId}     doorToDoor=${doorToDoor}     interestRate=${interestRate}     interestRateType=${interestRateType}     invoiceAgeing=${invoiceAgeing}     margin=${margin}     pf=${pf}     product=${product}     regularLimit=${regularLimit}     renewal=${renewal}     renewalPeriod=${renewalPeriod}
    ${TermSheet}=      Create List    ${entry}
    ${header}=         Create Dictionary     content-type=application/json
    &{data}=           Create Dictionary     createdBy=QA     updatedBy=QA    termSheetDataList=${TermSheet}
    ${response}=       Post Request          TermSheet     /termSheet/${cp_app_id}    data=${data}    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal    ${status_code}         ${incorrect_expected_code} 

TC_CPPP_01_CounterParty_ProsedProducts_DataFile_Negative_Validation
    [Arguments]     ${createdBy}    ${cp_app_id}    ${Anchor_cust_id}    ${product}    ${proposed}    ${type}    ${updatedBy}
    [Documentation]    Post Request CounterParty Prosed Products Negative Validation using Data File
    create session     ProposedProducts      ${CP_base_url}
    ${entry}=    Create Dictionary    appId=${cp_app_id}  custId=${Anchor_cust_id}    product=${product}     proposed=${proposed}    type=${type}
    ${PPDatalist}=    Create List     ${entry}
    &{data}=    Create Dictionary    createdBy=${createdBy}    updatedBy=${updatedBy}    proposedProductsDataList=${PPDatalist}
    ${header}=         create dictionary       content-type=application/json
    ${response}=       Post Request         ProposedProducts       /proposedProductDetails/${cp_app_id}    data=${data}       headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}         ${incorrect_expected_code}

TC_CP_debt_profile_datafile_positive_id
    [Arguments]        ${appId}     ${bankFI}    ${cmpdInt}    ${emi}        ${facilityType}        ${interestRate}        ${outstandingOnDate}        ${remarks}        ${sanctionDate}        ${sanctionLimit}        ${security}        ${seq}        ${specificLimit}        ${tenure}
    [Documentation]     counter party debt profile create
    Create Session      cp_debt_profile_post        ${CP_base_url}
    ${entry}=           Create Dictionary    appId= ${appId}    bankFI=${bankFI}     cmpId=${cmpdInt}    emi=${emi}    facilityType=${facilityType}    interestRate=${interestRate}    outstandingOnDate=${outstandingOnDate}    remarks=${remarks}    sanctionDate=${sanctionDate}    sanctionLimit=${sanctionLimit}    security=${security}    seq=${seq}    specificLimit=${specificLimit}    tenure=${tenure}
    ${debtList}=        Create List        ${entry}
    ${header}=          Create Dictionary       Authorization=${SAMPLE_TOKEN}        content-type=application/json
    ${data}=            Create Dictionary        createdBy=laravel        updatedBy=karthi        cpDebtProfileDataList=${debtList}
    ${response}=        Post Request        cp_debt_profile_post        /cpDebtProfile/${cp_app_id}      data=${data}       headers=${header}
    ${status_code}=     convert to string       ${response.status_code}
    should be equal     ${status_code}         ${expected_code}

TC_CP_debt_profile_datafile_negative_id
    [Arguments]          ${appId}     ${bankFI}    ${emi}    ${facilityType}        ${id}        ${interestRate}        ${outstandingOnDate}        ${remarks}        ${sanctionDate}        ${sanctionLimit}        ${security}        ${specificLimit}        ${tenure}
    [Documentation]     counter party debt profile create
    Create Session      cp_debt_profile_post        ${CP_base_url}
    ${entry}=           Create Dictionary      appId= ${appId}    bankFI=${bankFI}     emi=${emi}    facilityType=${facilityType}    id=${id}    interestRate=${interestRate}    outstandingOnDate=${outstandingOnDate}    remarks=${remarks}    sanctionDate=${sanctionDate}    sanctionLimit=${sanctionLimit}    security=${security}    specificLimit=${specificLimit}    tenure=${tenure}    
    ${debtList}=        Create List        ${entry}
    ${header}=          Create Dictionary   Authorization=${SAMPLE_TOKEN}     content-type=application/json
    ${data}=            Create Dictionary        createdBy=Tester        updatedBy=karthi        cpDebtProfileDataList=${debtList}
    ${response}=        Post Request        cp_debt_profile_post        /cpDebtProfile/${cp_app_id}       data=${data}       headers=${header}
    ${status_code}=     convert to string       ${response.status_code}
    should be equal     ${status_code}         ${incorrect_expected_code}

TC_CP_basic_details_positive
    [Arguments]        ${panNumber}    ${companyName}    ${gstNumber}    ${cinNumber}    ${constitution}    ${city}    ${state}    ${source}    ${subSource}    ${rmName}    ${cusContName}    ${cusContactNumber}    ${cusContactEmail}
    [Documentation]    basic details create testcases
    Create Session     basicdetailsnegative         ${CP_base_url}
    ${body}=            Create Dictionary     panNumber=${panNumber}     companyName=${companyName}     gstNumber=${gstNumber}     cinNumber=${cinNumber}     constitution=${constitution}     city=${city}     state=${state}     source=${source}     subSource=${subSource}     rmName=${rmName}     cusContName=${cusContName}     cusContactNumber=${cusContactNumber}     cusContactEmail=${cusContactEmail}
    ${header}=         Create Dictionary      Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=        Post Request     basicdetailsnegative     /cpBasicDetails     json=${body}     headers=${header}
    Should Be Equal As Strings       ${response.status_code}        ${server_err_code}
    # response code changed to 500 (Purpose of change :Have to change company name and pan,cin number for every run)

TC_CP_basic_details_datafile
    [Arguments]         ${panNumber}     ${companyName}     ${gstNumber}     ${cinNumber}     ${constitution}     ${city}     ${state}     ${source}     ${subSource}     ${rmName}     ${cusContName}     ${cusContactNumber}     ${cusContactEmail}
    [Documentation]    basic details create testcases
    Create Session     basicdetailsnegative         ${CP_base_url}
    ${body}=            Create Dictionary     panNumber=${panNumber}     companyName=${companyName}     gstNumber=${gstNumber}     cinNumber=${cinNumber}     constitution=${constitution}     city=${city}     state=${state}     source=${source}     subSource=${subSource}     rmName=${rmName}     cusContName=${cusContName}     cusContactNumber=${cusContactNumber}     cusContactEmail=${cusContactEmail}
    ${header}=         Create Dictionary       content-type=application/json
    ${response}=        Post Request     basicdetailsnegative     /cpBasicDetails     json=${body}     headers=${header}
    ${statuscode}=    Convert To String         ${response.status_code}
    Should Be Equal        ${statuscode}       ${incorrect_expected_code}

TC_CP_commercial_cc_positive_id
    [Arguments]        ${custId}          ${productRemarks}         ${anchorNameRemarks}     ${regularLimitRemarks}     ${adhocLimitRemarks}       ${creditPeriodRemarks}    ${doorRemarks}       ${invoiceAgeingRemarks}     ${marginRemarks}      ${interestRateRemarks}     ${pfRemarks}     ${renewalRemarks}       ${interestTypeRemarks}         ${renewalPeriodRemarks}     
    [Documentation]        counter party commercial cc positive validation
    Create Session        cp_commercial_cc_details     ${CP_base_url}    
    ${CommercialCC}=           Create Dictionary       custId=${custId}          productRemarks=${productRemarks}         anchorNameRemarks=${anchorNameRemarks}     regularLimitRemarks=${regularLimitRemarks}     adhocLimitRemarks=${adhocLimitRemarks}       creditPeriodRemarks=${creditPeriodRemarks}       doorRemarks=${doorRemarks}       invoiceAgeingRemarks=${invoiceAgeingRemarks}     marginRemarks=${marginRemarks}      interestRateRemarks=${interestRateRemarks}     pfRemarks=${pfRemarks}     renewalRemarks=${renewalRemarks}       interestTypeRemarks=${interestTypeRemarks}         renewalPeriodRemarks=${renewalPeriodRemarks}     
    ${entry}=           Create List     ${CommercialCC}
    ${body}=            Create Dictionary        commercialDataList=${entry}
    ${header}=      Create Dictionary    Authorization=${SAMPLE_TOKEN}    content-type=application/json
    ${response}=    Post Request     cp_commercial_cc_details     /commercialCc/${cp_app_id}    json=${body}    headers=${header}
    ${statuscode}=    Convert To String    ${response.status_code}
    Should Be Equal    ${statuscode}    ${expected_code}

TC_CP_commercial_cc_datafile_id
    [Arguments]        ${custId}          ${productRemarks}         ${anchorNameRemarks}     ${regularLimitRemarks}     ${adhocLimitRemarks}       ${creditPeriodRemarks}    ${doorRemarks}       ${invoiceAgeingRemarks}     ${marginRemarks}      ${interestRateRemarks}     ${pfRemarks}     ${renewalRemarks}       ${interestTypeRemarks}         ${renewalPeriodRemarks}     
    [Documentation]        counter party commercial cc positive validation
    Create Session        cp_commercial_cc_details     ${CP_base_url}    
    ${CommercialCC}=           Create Dictionary       custId=${custId}          productRemarks=${productRemarks}         anchorNameRemarks=${anchorNameRemarks}     regularLimitRemarks=${regularLimitRemarks}     adhocLimitRemarks=${adhocLimitRemarks}       creditPeriodRemarks=${creditPeriodRemarks}       doorRemarks=${doorRemarks}       invoiceAgeingRemarks=${invoiceAgeingRemarks}     marginRemarks=${marginRemarks}      interestRateRemarks=${interestRateRemarks}     pfRemarks=${pfRemarks}     renewalRemarks=${renewalRemarks}       interestTypeRemarks=${interestTypeRemarks}         renewalPeriodRemarks=${renewalPeriodRemarks}     
    ${entry}=           Create List     ${CommercialCC}
    ${body}=            Create Dictionary        commercialDataList=${entry}
    ${header}=      Create Dictionary    Authorization=${SAMPLE_TOKEN}    content-type=application/json
    ${response}=    Post Request     cp_commercial_cc_details     /commercialCc/${cp_app_id}    json=${body}    headers=${header}
    ${statuscode}=    Convert To String    ${response.status_code}
    Should Be Equal    ${statuscode}    ${expected_code}

TC_CI_anchor_customer_info_detail
    [Arguments]        ${customerName}    ${product}  ${pan}  ${cin}    ${status}
    [Documentation]    Anchor  CustomerInfo Detail Negative validation using Data File
    create session     customerinfo_detail      ${base_url}
    ${body}=           create dictionary       customerName=${customerName}   product=${product}  pan=${pan}  cin=${cin}    status=${status}
    ${header}=         create dictionary       Authorization=${SAMPLE_TOKEN}  content-type=application/json
    ${response}=       Post Request          customerinfo_detail        /customerInfoDetail      json=${body}       headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}       ${incorrect_expected_code}

TC_CD01_Collateral detail positive testing
    [Arguments]        ${value}     ${cmId}     ${appId}     
    [Documentation]     Posting correct data of Collateral detail
    create session      collateral_detail      ${CP_base_url}
    ${entry}=           Create Dictionary      value=${value}   cmId=${cmId}    appId=${appId}
    ${collateral_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     collateralDetailsDataList=${collateral_list}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}   content-type=application/json
    ${response}=        Post Request    collateral_detail    /collateralDetails     data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}

TC_CD02_Collateral detail negative testing
    [Arguments]        ${value}     ${cmId}     ${appId}     
    [Documentation]     Posting incorrect Collateral detail
    create session      collateral_detail      ${CP_base_url}
    ${entry}=           Create Dictionary      value=${value}   cmId=${cmId}    appId=${appId}
    ${collateral_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     collateralDetailsDataList=${collateral_list}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}  content-type=application/json
    ${response}=        Post Request    collateral_detail    /collateralDetails     data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${incorrect_expected_code}
 
TC_DD01_DueDiligence detail positive testing
    [Arguments]        ${value}     ${ddId}     ${appId}     
    [Documentation]     Posting correct data of duediligence detail
    create session      duediligence_detail      ${CP_base_url}
    ${entry}=           Create Dictionary      value=${value}   ddId=${ddId}    appId=${appId}
    ${duediligence_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     dueDiligenceDetailsDataList=${duediligence_list}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=        Post Request    duediligence_detail    /dueDiligenceDetails     data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}

TC_DD02_DueDiligence detail negative testing
    [Arguments]        ${value}     ${ddId}     ${appId}     
    [Documentation]     Posting incorrect duediligence detail
    create session      duediligence_detail   ${CP_base_url}
    ${entry}=           Create Dictionary      value=${value}   ddId=${ddId}    appId=${appId}
    ${duediligence_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     dueDiligenceDetailsDataList=${duediligence_list}
    ${header}=          Create Dictionary     Authorization=${SAMPLE_TOKEN}   content-type=application/json
    ${response}=        Post Request    duediligence_detail    /dueDiligenceDetails    data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${incorrect_expected_code}

TC_CPFR_Details_Positive_Testcase
    [Arguments]                ${appId}        ${value}        ${cpFrmId}
    [Documentation]            Counter Party fund request details
    create session             CP-FundDetails    ${CP_base_url}
    ${entry}=                  Create Dictionary      appId=${appId}     value=${value}     cpFrmId=${cpFrmId}
    ${fundAns_List}=           Create List    ${entry}
    ${header}=                 Create Dictionary      Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    &{data}=                   Create Dictionary      createdBy=QA      fundReqDetailsDataList=${fundAns_List}     updatedBy=QA 
    ${response}=               Post Request           CP-FundDetails    /fundReqDetails    data=${data}    headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal            ${status_code}          ${expected_code}  

TC_CP_FundReqMaster_Testcases
    [Arguments]                ${dataType}        ${description}        ${displayName}     ${questions}     ${requirementName}   ${status}
    [Documentation]            FundReqMaster_Testcases
    create session             CP-FundReqMaster    ${CP_base_url}
    ${entry}=                  Create Dictionary     datatype=${dataType}     description=${description}    displayName=${displayName}    questions=${questions}     requirementName=${requirementName}    status=${status}
    ${header}=                 Create Dictionary      Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    &{data}=                   Create Dictionary       ${entry}
    ${response}=               Post Request           CP-FundReqMaster     /fundReqMaster    data=${data}    headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal    ${status_code}          ${expected_code}

TC_CPCP_Details_Positive_Testcase
    [Arguments]                ${appId}     ${value}     ${cpMasterId}     
    [Documentation]            Anchor creditpolicy creation
    create session             CP_creditpolicy    ${CP_base_url}
    ${entry}=                  Create Dictionary      appId=${appId}     value=${value}     cpMasterId=${cpMasterId}
    ${creditpolicy_list}=      Create List    ${entry}
    ${header}=                 Create Dictionary      Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    &{data}=                   Create Dictionary      createdBy=QA     updatedBy=QA    creditPolicyDetailsData=${creditpolicy_list}
    ${response}=               Post Request           CP_creditpolicy     /creditPolicyDetails    data=${data}    headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal    ${status_code}          ${expected_code}
    
TC_SPD22_softPolicy_details_Postive testing
    [Arguments]        ${softPolicyId}     ${appId}     ${value}     
    [Documentation]     Posting correct data of softpolicy detail
    create session      softpolicy_detail      ${CP_base_url}
    ${entry}=           Create Dictionary      softPolicyId=${softPolicyId}   appId=${appId}    value=${value}
    ${softpolicy_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     softPolicyDetailsDataList=${softpolicy_list}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=        Post Request    softpolicy_detail        /softPolicyDetails     data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}

TC_SP131_softPolicy_details_negative testing
    [Arguments]        ${softPolicyId}     ${appId}     ${value}     
    [Documentation]     Posting incorrect softpolicy detail
    create session      softpolicy_detail      ${CP_base_url}
    ${entry}=           Create Dictionary      softpolicy=${softPolicyId}   appId=${appId}    value=${value}
    ${softpolicy_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     softPolicyDetailsDataList=${softpolicy_list}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=        Post Request    softpolicy_detail    /validateSoftPolicy     data=&data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    should be equal     ${status_code}          ${incorrect_expected_code}

TC_CPCP_Details_Negative_Testcase
    [Arguments]                ${appId}     ${value}     ${cpMasterId}     
    [Documentation]            Anchor creditpolicy negative validation
    create session             CP_creditpolicy    ${CP_base_url}
    ${entry}=                  Create Dictionary      appId=${appId}     value=${value}     cpMasterId=${cpMasterId}
    ${creditpolicy_list}=      Create List    ${entry}
    &{data}=                   Create Dictionary      creditPolicyDetailsData=${creditpolicy_list}
    ${header}=                 Create Dictionary      Authorization=${SAMPLE_TOKEN}     Content-Type=application/json
    ${response}=               Post Request           CP_creditpolicy     /validateCreditPolicy    data=${data}    headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal     ${status_code}          ${incorrect_expected_code}

TC_AD_05_AnchorAddressDetail_Update_Negative
    [Arguments]        ${addressLine1}     ${addressLine2}    ${appId}     ${city}    ${country}     ${id}     ${pinCode}     ${state}
    [Documentation]    Anchor Address Detail Update
    create session     anchor_Address      ${base_url}
    ${body}=           Create Dictionary       addressLine1=${addressLine1}     addressLine2=${addressLine2}     appId=${appId}     city=${city}     country=${country}     id=${Address_putId}     pinCode=${pinCode}     state=${state}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Address       /anchorAddress      data=${body}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${incorrect_expected_code}

TC_AA_05_AnchorAuthorized_Update_Negative
    [Arguments]        ${appId}     ${createdBy}    ${emailId}     ${id}    ${indemnityDoc}     ${mobile}      ${name}    ${type}    ${updatedBy}
    [Documentation]    Anchor Authorized Detail Update
    create session     anchor_Authorized      ${base_url}
    ${entry}=            Create Dictionary       appId=${appId}     createdBy=${createdBy}     emailId=${emailId}     id=${Authorized_putId}    indemnityDoc=${indemnityDoc}     mobile=${mobile}     name=${name}      type=${type}     updatedBy=${updatedBy}
    ${Authorized_list}=      Create List    ${entry}
    &{data}=            Create Dictionary     anchorAuthDataList=${Authorized_list}    updatedBy=QA     createdBy=QA
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Authorized       /anchorAuthorized      data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${incorrect_expected_code}

Anchor_credtiNorms_ReturnId_for_PUT
    [Documentation]  Getting the anchor authorized details
    create session   anchor_ProgramNorms  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      GET On Session   anchor_ProgramNorms   /creditNormsDetailsByFId/${Anchor_App_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${creditNorms_putId}=           Get From List    ${id_value}           0
    log  ${creditNorms_putId}
    Set Global Variable   ${creditNorms_putId}

Obtain_Auth_Token
    [Arguments]    ${username}    ${password}
    create session      create_token      ${Auth_url}
    ${data}=            Create Dictionary     client_id=ThinkIAM   client_secret=Cj7d397ypEqNxOmzZUes74JCY8ssVhuq   scope=openid   grant_type=password  username=${username}    password=sample_password
    ${header}=          Create Dictionary      content-type=application/x-www-form-urlencoded
    ${response}=        Post on Session    create_token     /realms/ThinkIAM/protocol/openid-connect/token     data=${data}    headers=${header}
    ${status_code}=     convert to string      ${response.status_code}
    ${Get_token}=       Get From Dictionary     ${response.json()}      access_token
    ${Token}=           Catenate    Bearer ${Get_token}  
    Set Suite Variable            ${Token}
    should be equal     ${status_code}          ${expected_code}

TC_CP07_Validate_CreditPolicy_Negative
    [Arguments]                ${appId}     ${value}     ${cpMasterId}     
    [Documentation]            Anchor creditpolicy negative validation
    create session             CP_creditpolicy    ${CP_base_url}
    ${entry}=                  Create Dictionary      appId=${appId}     value=${value}     cpMasterId=${cpMasterId}
    ${creditpolicy_list}=      Create List    ${entry}
    &{data}=                   Create Dictionary      creditPolicyDetailsData=${creditpolicy_list}
    ${header}=                 Create Dictionary      Authorization=${SAMPLE_TOKEN}     Content-Type=application/json
    ${response}=               Post Request           CP_creditpolicy     /validateCreditPolicy    data=${data}    headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal            ${status_code}          ${incorrect_expected_code}

softpolicy_master_type
      [Documentation]  Getting the softpolicy master type data
      create session         CP_soft_master_type        ${CP_base_url}
      ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
      ${response}=           GET On Session   CP_soft_master_type   /softPolicyMasterType    headers=${header}
      ${json-data}=          Convert String To Json      ${response.content}
      ${display_name1}=       Get Value From Json         ${json-data}    $[0].displayName
      ${display_name2}=       Get Value From Json         ${json-data}    $[1].displayName
      ${display_name3}=       Get Value From Json         ${json-data}    $[2].displayName
      ${display_name4}=       Get Value From Json         ${json-data}    $[3].displayName
      ${display_name5}=       Get Value From Json         ${json-data}    $[4].displayName
      ${displayname1_value}=    Get From List    ${display_name1}    0
      ${displayname2_value}=    Get From List    ${display_name2}    0            
      ${displayname3_value}=    Get From List    ${display_name3}    0
      ${displayname4_value}=    Get From List    ${display_name4}    0
      ${displayname5_value}=    Get From List    ${display_name5}    0
      ${Softpolicy_master_list}=      Create List      ${displayname1_value}  ${displayname2_value}   ${displayname3_value}    ${displayname4_value}    ${displayname5_value}    
      [Return]         ${Softpolicy_master_list}

softpolicy_master_sub_type
      [Documentation]  Getting the softpolicy master sub type data
      create session         CP_soft_master_subtype        ${CP_base_url}
      ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
      ${response}=           GET On Session   CP_soft_master_subtype   /softPolicyMasterSubType    headers=${header}
      ${json-data}=          Convert String To Json      ${response.content}
      ${display_name1}=       Get Value From Json          ${json-data}    $[0].displayName
      ${display_name2}=       Get Value From Json          ${json-data}    $[1].displayName
      ${display_name3}=       Get Value From Json         ${json-data}    $[2].displayName
      ${display_name4}=       Get Value From Json         ${json-data}    $[3].displayName
      ${display_name5}=       Get Value From Json         ${json-data}    $[4].displayName
      ${display_name6}=       Get Value From Json         ${json-data}    $[5].displayName
      ${display_name7}=       Get Value From Json         ${json-data}    $[6].displayName
      ${display_name8}=       Get Value From Json         ${json-data}    $[7].displayName
      ${display_name9}=       Get Value From Json         ${json-data}    $[8].displayName
      ${display_name10}=       Get Value From Json         ${json-data}    $[9].displayName
      ${display_name11}=       Get Value From Json         ${json-data}    $[10].displayName
      ${display_name12}=       Get Value From Json         ${json-data}    $[11].displayName
      ${display_name13}=       Get Value From Json         ${json-data}    $[12].displayName
      ${display_name14}=       Get Value From Json         ${json-data}    $[13].displayName
      ${display_name15}=       Get Value From Json         ${json-data}    $[14].displayName
      ${display_name16}=       Get Value From Json         ${json-data}    $[15].displayName
      ${display_name17}=       Get Value From Json         ${json-data}    $[16].displayName
      ${display_name18}=       Get Value From Json         ${json-data}    $[17].displayName
      ${display_name19}=       Get Value From Json         ${json-data}    $[18].displayName
      ${display_name20}=       Get Value From Json         ${json-data}    $[19].displayName
      ${display_name21}=       Get Value From Json         ${json-data}    $[20].displayName
      ${displayname1_value}=    Get From List    ${display_name1}    0
      ${displayname2_value}=    Get From List    ${display_name2}    0            
      ${displayname3_value}=    Get From List    ${display_name3}    0
      ${displayname4_value}=    Get From List    ${display_name4}    0
      ${displayname5_value}=    Get From List    ${display_name5}    0
      ${displayname6_value}=    Get From List    ${display_name6}    0
      ${displayname7_value}=    Get From List    ${display_name7}    0            
      ${displayname8_value}=    Get From List    ${display_name8}    0
      ${displayname9_value}=    Get From List    ${display_name9}    0
      ${displayname10_value}=    Get From List    ${display_name10}    0
      ${displayname11_value}=    Get From List    ${display_name11}    0
      ${displayname12_value}=    Get From List    ${display_name12}    0            
      ${displayname13_value}=    Get From List    ${display_name13}    0
      ${displayname14_value}=    Get From List    ${display_name14}    0
      ${displayname15_value}=    Get From List    ${display_name15}    0
      ${displayname16_value}=    Get From List    ${display_name16}    0
      ${displayname17_value}=    Get From List    ${display_name17}    0            
      ${displayname18_value}=    Get From List    ${display_name18}    0
      ${Softpolicy_master_subtype_list}=      Create List      ${displayname1_value}  ${displayname2_value}   ${displayname3_value}    ${displayname4_value}    ${displayname5_value}      ${displayname6_value}  ${displayname7_value}   ${displayname8_value}    ${displayname9_value}    ${displayname10_value}      ${displayname11_value}  ${displayname12_value}   ${displayname13_value}    ${displayname14_value}    ${displayname15_value}   ${displayname16_value}  ${displayname17_value}   ${displayname18_value}   # ${displayname19_value}    ${displayname20_value}       ${displayname21_value}  
      [Return]         ${Softpolicy_master_subtype_list}
    