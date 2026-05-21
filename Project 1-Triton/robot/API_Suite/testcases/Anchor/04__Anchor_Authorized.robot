*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication
Test Setup     Anchor_Authorized_ReturnId_for_PUT
*** Variables ***
${appId}=            ${Anchor_App_id}
${createdBy}=        Test
${emailId}=          sample.user@gmail.com            
${indemnityDoc}=     test
${mobile}=           6789876535
${name}=             Mohan
${type}=             new
${updatedBy}=        QA

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***
Anchor_Authorized_Update
    TC_AA_05_AnchorAuthorized_Update     ${appId}     ${createdBy}    ${emailId}     ${Authorized_putId}    ${indemnityDoc}     ${mobile}     ${name}    ${type}    ${updatedBy}

*** Keywords ***
TC_AA_05_AnchorAuthorized_Update
    [Arguments]        ${appId}     ${createdBy}    ${emailId}     ${id}    ${indemnityDoc}     ${mobile}      ${name}    ${type}    ${updatedBy}
    [Documentation]    Anchor Authorized Detail Update
    create session     anchor_Authorized      ${base_url}
    ${entry}=          Create Dictionary       appId=${appId}     createdBy=${createdBy}     emailId=${emailId}     id=${Authorized_putId}    indemnityDoc=${indemnityDoc}     mobile=${mobile}     name=${name}      type=${type}     updatedBy=${updatedBy}
    ${Authorized_list}=      Create List    ${entry}
    &{data}=           Create Dictionary     anchorAuthDataList=${Authorized_list}    updatedBy=QA     createdBy=QA
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Authorized       /anchorAuthorized      data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}

Anchor_Authorized_ReturnId_for_PUT
    [Documentation]  Getting the anchor authorized details
    create session  anchor_authorized  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      GET On Session   anchor_authorized   /anchorAuthorizedFile/${Anchor_App_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${Authorized_putId}=            Get From List    ${id_value}           0
    log  ${Authorized_putId}
    Set Global Variable   ${Authorized_putId}












