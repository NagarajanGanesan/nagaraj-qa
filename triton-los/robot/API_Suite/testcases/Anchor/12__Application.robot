*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup       Operation_maker_Authentication


*** Keywords ***
Operation_maker_Authentication
    ${username}    Set Variable       operation_maker_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***
TC_AP_01_Test_Anchor_List_Details_Readall
    [Tags]    SANITY
    [Documentation]    Getting All Anchor_List_Details
    create session     AnchorListDetails     ${base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session       AnchorListDetails   /anchorListDetails        headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

TC_AP_02_Test_Application_read
    [Tags]    SANITY
    [Documentation]    Getting Application details by cust_id
    create session     applicationRead     ${base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session       applicationRead       /application/${Anchor_cust_id}       headers=${header} 
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

TC_AP_03_Test_Application_read_all
    [Tags]    SANITY
    [Documentation]    Getting All Application details 
    create session     applicationReadAll     ${base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session       applicationReadAll   /applicationDetails     headers=${header} 
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

TC_AD_04_Application_Details_post
    [Tags]  SANITY
    [Documentation]    Application Details post  creation
    create session     Application Details post     ${base_url}
    ${body}=           Create Dictionary       appId=${Anchor_App_id}     appType=8219     createdBy=Thiru      type=89      updatedBy=Thiru      
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       Post Request            Application Details post      /applicationDetails     data=${body}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}          ${expected_code}

TC_AP_05_Test_Application_Details_with_id
    [Tags]    SANITY
    [Documentation]    Getting All Application details 
    create session     Application_Details_with_id     ${base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session       Application_Details_with_id       /applicationDetails/${Anchor_App_id}     headers=${header} 
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

TC_AP_06_Test_CP_List_Details
    [Tags]    SANITY
    [Documentation]    Getting CP_List_Details
    create session     CPListDetails     ${base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session       CPListDetails   /cpListDetails        headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}