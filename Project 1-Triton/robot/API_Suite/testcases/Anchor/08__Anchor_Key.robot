*** Settings ***
Resource    ../../keywords/variables.robot
Test Setup     Anchor_Key_ReturnId_for_PUT
Suite Setup    CPA_Authentication

*** Variables ***
${appId}=               ${Anchor_App_id}
${emailId}              sample.user@gmail.com  
${mobile}               9876543456
${name}                 Test
${type}                 New

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
    
*** Test Cases ***
Anchor_Key_Update 
    TC_AK_13_AnchorKey_Update        ${appId}     ${emailId}     ${anchorKey_putId}     ${mobile}     ${name}     ${type}

TC_KE_08_Ky_Anchor_Key_File_By_Id_read
    [Documentation]  Get Anchor Key person File by ID
    create session          Anchor_Key_File_id       ${base_url}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=        GET On Session          Anchor_Key_File_id        /anchorKeyFile/${Anchor_App_id}      headers=${header}
    ${status_code}=     convert to string   ${response.status_code}
    should be equal     ${status_code}  ${expected_code}

*** Keywords ***
TC_AK_13_AnchorKey_Update
    [Arguments]        ${appId}     ${emailId}     ${id}     ${mobile}     ${name}     ${type}     
    [Documentation]    Anchor Key Detail Update
    create session     anchor_Key      ${base_url}
    ${entry}=            Create Dictionary       appId=${appId}     emailId=${emailId}     id=${anchorKey_putId}      mobile=${mobile}     name=${name}     type=${type}         
    ${anchorKeyDataList}=      Create List    ${entry}
    &{data}=            Create Dictionary     anchorKeyDataList=${anchorKeyDataList}    updatedBy=QA     createdBy=QA
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Key       /anchorKey      data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}

Anchor_Key_ReturnId_for_PUT
    [Documentation]  Getting the anchor key details
    create session  anchor_Key  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      GET On Session   anchor_Key   /anchorKeyFile/${Anchor_App_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${anchorKey_putId}=            Get From List    ${id_value}           0
    log  ${anchorKey_putId}
    Set Global Variable   ${anchorKey_putId}