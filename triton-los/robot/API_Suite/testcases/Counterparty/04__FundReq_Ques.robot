*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication
*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***
TC_CPFQ_01_readall
    Create Session        CP_fundReq_Question        ${cp_base_url}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=        GET On Session        CP_fundReq_Question        /fundReqMaster        headers=${header}
    ${status_code}=     convert to string   ${response.status_code}
    should be equal     ${status_code}  ${expected_code}