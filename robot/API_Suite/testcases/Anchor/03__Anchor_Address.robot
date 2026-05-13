*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication
Test Setup     Anchor_Address_ReturnId_for_PUT

*** Variables ***
${addressLine1}=       T.Nagar
${addressLine2}=       2nd Street
${appId}=              ${Anchor_App_id}
${city}=               Chennai  
${country}=            India
${pinCode}=            639193
${state}=              Tamil Nadu

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Test Cases ***
TC_AD_pincode_read
    Create Session    pincode    ${base_url}
    ${header}=    Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=    Get Request    pincode         /getPincodeDetails?pinCode=607303        headers=${header}
    ${status_code}=  Convert To String    ${response.status_code}
    should be equal    ${status_code}     ${expected_code}
    
AnchorAddressDetail_Update
    TC_AD_05_AnchorAddressDetail_Update     ${addressLine1}     ${addressLine2}    ${appId}     ${city}    ${country}     ${Address_putId}     ${pinCode}     ${state} 

*** Keywords ***
TC_AD_05_AnchorAddressDetail_Update
    [Arguments]        ${addressLine1}     ${addressLine2}    ${appId}     ${city}    ${country}     ${id}     ${pinCode}     ${state}
    [Documentation]    Anchor Address Detail Update
    create session     anchor_Address      ${base_url}
    ${body}=           Create Dictionary       addressLine1=${addressLine1}     addressLine2=${addressLine2}     appId=${appId}     city=${city}     country=${country}     id=${Address_putId}     pinCode=${pinCode}     state=${state}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Address       /anchorAddress      data=${body}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}

Anchor_Address_ReturnId_for_PUT
    [Documentation]    Getting the details of Anchor
    Create Session    anchor_address  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      GET On Session    anchor_address  /anchorAddressFile/${Anchor_App_id}    headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${Address_putId}=           Get From List     ${id_value}           0
    log  ${Address_putId}
    Set Global Variable   ${Address_putId}














