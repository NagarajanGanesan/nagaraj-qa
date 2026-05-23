*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***
TC_CPCM_01_CounterParty_Collateral
    [Documentation]    Getting collateral master data
    Create Session     CP_collateral    ${CP_base_url}     
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session    CP_collateral   /collateralMaster    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}


TC_CPCM_09_CounterParty_Collateral
    [Documentation]    Getting collateralDetails data
    Create Session     CP_collateral    ${CP_base_url}     
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session    CP_collateral   /collateral/${cp_app_id}    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}