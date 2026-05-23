*** Settings ***
Resource        ../../keywords/variables.robot
Test Template   TC_CI_anchor_customer_info_detail
Suite Setup    CPA_Authentication

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Test Cases ***                                      customerName                      product            pan              cin                        status
TC_CI_03_Empty product                                    RamCo                           ${EMPTY}          JKOOI0980P       L09374KA2010PTC096091       Active
TC_CI_04_Empty cusotmerName                               ${EMPTY}                        SCF               CFLOX5034O       L21267LA6759OPG021111       Active
TC_CI_05_Empty pan                                        KIM                             SCF               ${EMPTY}         L21267MS6759OPG021111       NA
TC_CI_06_Empty status                                     RMK                             SCF               ASFHG1090L       U21267MP6759OPG910292       ${EMPTY}
TC_CI_07_Incorrect pan                                    HDB                             SCF               ABCDE1234        L21267LA6759OPG398420       Active