*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    Business_Authentication

*** Keywords ***
Business_Authentication
    ${username}    Set Variable       business_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***
${product}=    Dealer Purchase Order Finance
${proposed}=   70000
${type}=        new

*** Test Cases ***
TC_CPPP_01_Test_CounterParty_ProsedProducts_Details
    [Tags]  SMOKE
    [Documentation]    Create CounterParty Prosed Products Details
    create session     ProposedProducts      ${CP_base_url}
    ${entry}=    Create Dictionary    appId=${cp_app_id}    custId=${Anchor_cust_id}    product=${product}     proposed=${proposed}    type=${type}
    ${PPDatalist}=    Create List     ${entry}   
    &{data}=    Create Dictionary    createdBy=karz    updatedBy=vj    proposedProductsDataList=${PPDatalist}
    ${header}=         create dictionary    Authorization=${SAMPLE_TOKEN}    content-type=application/json
    ${response}=       POST On Session         ProposedProducts       /proposedProductDetails/${cp_app_id}      json=${data}       headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}          ${expected_code}

TC_CPPP_02_Test_Read_CreditNorms_By_Id
    [Tags]    SMOKE
    [Documentation]    Getting CreditNorms By id
    create session     GetCreditNorm        ${CP_base_url}
    ${header}=         create dictionary       Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=       GET On Session              GetCreditNorm    /getCreditNormsIds/${cp_app_id}     headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

