*** Settings ***
Resource               ../../keywords/variables.robot
Test Template          TC_CD01_Collateral detail positive testing
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Test Cases ***                                            value        cmID       appID
TC_CD03_primary Security                                       abc          2293       ${cp_app_id} 
TC_CD04_secondarySecurity                                      jkl          2294       ${cp_app_id} 
TC_CD04_guarantees                                             xyz          2295       ${cp_app_id} 
TC_CD05_pre-disbursementcreditconditions                       poi          2296       ${cp_app_id} 
TC_CD06_financialcovenants                                     rst          2297       ${cp_app_id} 
TC_CD07_timeforcompliance                                      122          2298       ${cp_app_id} 
TC_CD08_postdisbursmentcreditconditions                        csv          2299       ${cp_app_id} 



   

