*** Settings ***
Resource         ../../keywords/variables.robot
Test Template    TC_CPFR_Details_Positive_Testcase
Suite Setup    CPA_Authentication
*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***                                          app_id                      value           cpFrmId         
TC_FR_01_Why funds are required?                            ${cp_app_id}                 Test             1386
TC_FR_02_If this justify enhancement?                       ${cp_app_id}                 Test             1388
TC_FR_03_What growth is expected?                           ${cp_app_id}                 Rest             1389
TC_FR_04_What is the anchor recommendation?                 ${cp_app_id}                 Test             1390
TC_FR_05_Total consolidated limit proposed?                 ${cp_app_id}                 Test             1391

    