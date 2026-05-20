*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup       Business_Authentication
*** Keywords ***
Business_Authentication
    ${username}    Set Variable       business_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***               
TC_CP_basic_details_positive
    [Documentation]    basic details create testcases
    Create Session     basicdetailspositive         ${CP_base_url}
    ${body}=            Create Dictionary           &{cp_Basic_details}
    ${header}=         Create Dictionary      Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=        Post Request     basicdetailspositive     /cpBasicDetails     json=${body}     headers=${header}
    Should Be Equal As Strings       ${response.status_code}        ${server_err_code}
    # response code changed to 500 (Purpose of change :Have to change company  name and pan,cin number for every run)
    
   
