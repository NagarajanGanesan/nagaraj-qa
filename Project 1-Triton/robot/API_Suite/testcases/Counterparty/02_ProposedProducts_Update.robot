*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    Business_Authentication
Test Setup     TC_CPPP_03_ProsedProducts_Return_PutId

*** Keywords ***
Business_Authentication
    ${username}    Set Variable       business_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***    
${appId}=      ${cp_app_id}
${custId}=     ${Anchor_cust_id}        
${product}=    Dealer Purchase Order Finance
${proposed}=   70000
${type}=        new         

*** Test Cases ***
ProposedProduct_Update
    TC_CPPP_04_Proposed_Product_PUT_Method      ${appId}     ${custId}     ${proposed_putId}     ${product}     ${proposed}     ${type}    

*** Keywords ***
TC_CPPP_03_ProsedProducts_Return_PutId
    [Tags]    SMOKE
    [Documentation]        Getting Counter Party Prosed Products By id
    create session         ProposedProductsById        ${CP_base_url}
    ${header}=             create dictionary       Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=           GET On Session              ProposedProductsById    /proposedProductsById/${cp_app_id}      headers=${header}
    ${json-data}=          Convert String To Json  ${response.content}
    ${id_value}=           Get Value From Json    ${json-data}    $[0].id
    ${proposed_putId}=     Get From List    ${id_value}           0
    Set Global Variable    ${proposed_putId}

TC_CPPP_04_Proposed_Product_PUT_Method
    [Arguments]         ${appId}     ${custId}     ${proposed_putId}     ${product}     ${proposed}     ${type}    
    [Documentation]     counter party ProposedProduct PUT 
    Create Session      ProposedProduct    ${CP_base_url} 
    ${entry}=           Create Dictionary       appId=${cp_app_id}      custId=${anchor_cust_Id}    id=${proposed_putId}    product=${product}   proposed=${proposed}    type=${type}
    ${cpDebtProfileDataList}=     Create List      ${entry}  
    ${data}=           Create Dictionary        proposedProductsDataList=${cpDebtProfileDataList}    
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request            ProposedProduct       /proposedProductDetails/${cp_app_id}       data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}