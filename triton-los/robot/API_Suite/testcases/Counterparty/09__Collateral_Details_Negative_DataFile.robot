*** Settings ***
Resource               ../../keywords/variables.robot
Test Template          TC_CD02_Collateral detail negative testing
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***                                             value                            cmID       appID
TC_CD09_missing primary Security                               ${EMPTY}                         2293       ${cp_app_id} 
TC_CD10_missing secondarySecurity                              ${EMPTY}                         2294       ${cp_app_id} 
TC_CD11_missing guarantees                                     ${EMPTY}                         2295       ${cp_app_id} 
TC_CD12_missing pre-disbursementcreditconditions               ${EMPTY}                         2296       ${cp_app_id} 
TC_CD13_missing financialcovenants                             ${EMPTY}                         2297       ${cp_app_id} 
TC_CD14_missing timeforcompliance                              ${EMPTY}                         2298       ${cp_app_id} 
TC_CD15_missing postdisbursmentcreditconditions                ${EMPTY}                         2299       ${cp_app_id} 
TC_CD16_incorrect primary Security                             @!#                              2293       ${cp_app_id} 
TC_CD17_incorrect secondarySecurity                            @!#                              2294       ${cp_app_id} 
TC_CD18_incorrect guarantees                                   @!#                              2295       ${cp_app_id} 
TC_CD19_incorrect pre-disbursementcreditconditions             @!#                              2296       ${cp_app_id} 
TC_CD20_incorrect financialcovenants                           @!#                              2297       ${cp_app_id} 
TC_CD21_incorrect timeforcompliance                            asaaa                            2298       ${cp_app_id} 
TC_CD22_incorrect postdisbursmentcreditconditions              @!#                              2299       ${cp_app_id} 
