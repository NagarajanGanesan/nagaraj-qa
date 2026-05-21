*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Test Cases ***
Anchor_BasicDetails_Read
  [Documentation]    Getting the anchor basic details
  create session     anchor_basic  ${base_url}
  ${header}=         Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
  ${response}=       Get Request   anchor_basic   /anchorBasicFile/${Anchor_App_id}     headers=${header}
  ${status_code}=    Convert To String     ${response.status_code}
  Should Be Equal    ${status_code}     ${expected_code}