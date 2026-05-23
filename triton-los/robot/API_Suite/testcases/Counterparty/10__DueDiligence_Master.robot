*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***

TC_CPDDM_01_CounterParty_DueDiligence
    [Documentation]    Getting DD master data
    Create Session     DD_master    ${CP_base_url}  
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json    
    ${response}=       GET On Session    DD_master   /dueDiligenceMaster    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}
    

TC_CPDM_02_CounterParty_dueDiligence_readby
    [Documentation]    Getting DueDiligenceDetails data
    Create Session     Due_Diligence    ${CP_base_url}     
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session     Due_Diligence       /dueDiligenceDetails/${cp_app_id}     headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}