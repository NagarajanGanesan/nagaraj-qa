*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication
*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Variables ***                      
${bankFI}           Bank          
${emi}              1000        
${facilityType}     Yes                
${interestRate}       10             
${outstandingOnDate}  10                    
${remarks}            e             
${sanctionDate}      10-              
${sanctionLimit}      1000              
${security}           yes                    
${specificLimit}      yes                
${tenure}              12          

*** Test Cases ***

TC_CP_debt_profile_datafile_GET_Method
    [Documentation]    Verify CP Debt Profile details    
    create session     cpdebtprofile       ${CP_base_url}
    ${header}=         create dictionary       Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=     Get Request     cpdebtprofile     /cpDebtProfile/${cp_app_id}    headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    ${json-data}=          Convert String To Json  ${response.content}
    ${id_value}=           Get Value From Json    ${json-data}    $[0].id
    ${debt_putId}=     Get From List    ${id_value}           0
    Set Global Variable    ${debt_putId}
    should be equal    ${status_code}       ${expected_code}

TC_DebtProfile_PUT_Method
    [Documentation]     counter party debt profile create 
    Create Session      cp_debt_profile_put    ${CP_base_url} 
    ${entry}=           Create Dictionary       appId=${cp_app_id}      bankFI=${bankFI}      emi=${emi}    facilityType=${facilityType}   id=${debt_putId}   interestRate=${interestRate}    outstandingOnDate=${outstandingOnDate}    remarks=${remarks}    sanctionDate=${sanctionDate}    sanctionLimit=${sanctionLimit}    security=${security}    specificLimit=${specificLimit}    tenure=${tenure}       
    ${cpDebtProfileDataList}=     Create List      ${entry}  
    ${data}=           Create Dictionary        cpDebtProfileDataList=${cpDebtProfileDataList}    
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             cp_debt_profile_put       /cpDebtProfile/${cp_app_id}    data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}