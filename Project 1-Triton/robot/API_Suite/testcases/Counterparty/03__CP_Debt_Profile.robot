*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication
*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***                             
TC_CP_debt_profile_datafile_positive_id           
    [Documentation]     counter party debt profile create
    Create Session      cp_debt_profile_post        ${CP_base_url}
    ${entry}=           Create Dictionary           &{Cp_Debt_Profile}
    ${cpDebtProfileDataList}=    Create List    ${entry}
    ${data}=            Create Dictionary       cpDebtProfileDataList=${cpDebtProfileDataList}           
    ${header}=          Create Dictionary       Authorization=${SAMPLE_TOKEN}        content-type=application/json
    ${response}=        Post Request    cp_debt_profile_post    /cpDebtProfile/${cp_app_id}     data=${data}       headers=${header}
    ${status_code}=     convert to string       ${response.status_code}
    should be equal     ${status_code}         ${expected_code}

