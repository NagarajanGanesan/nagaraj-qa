*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup        Operation_maker_Authentication

*** Keywords ***
Operation_maker_Authentication
    ${username}    Set Variable       operation_maker_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***
TC_RM_01_Remarks_create
    Create Session    myremarks     ${base_url}
    ${body}=     create dictionary     createdBy=Tata     custId=97     description=Thiru02     stepperTab=test     updatedBy=Thiru
    ${header}=     create dictionary     Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=     POST On Session    myremarks     /remarks    json=${body}     headers=${header}
    Should Be Equal As Strings     ${response.status_code}     ${expected_code}

TC_RM_02_Remarks_read
    create session    myremarks    ${base_url}
    ${header}=         Create Dictionary         Authorization=${SAMPLE_TOKEN}         Content-Type=application/json
    ${response}=     get request    myremarks    /remarks/${Anchor_App_id}     headers=${header}
    should be equal as strings    ${response.status_code}    ${expected_code}








    


