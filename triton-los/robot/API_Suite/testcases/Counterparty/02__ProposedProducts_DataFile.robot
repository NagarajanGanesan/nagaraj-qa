*** Settings ***
Resource    ../../keywords/variables.robot
Test Template     TC_CPPP_01_CounterParty_ProsedProducts_DataFile_Negative_Validation 
Suite Setup        Business_Authentication

*** Keywords ***
Business_Authentication
    ${username}    Set Variable       business_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***                                 createdBy      appId             custId                     product         proposed     type      updatedBy
TC_CPPP_01_Invalid app_id                           Karthi      !@@#              ${Anchor_cust_id}        dealerFinance       100         new          bala    
TC_CPPP_02_Invalid cust_id                          Karthi      ${cp_app_id}           -@                 dealerFinance        2          new      bala         
TC_CPPP_03_Missing proposed                         Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      ${EMPTY}        new      bala         
TC_CPPP_04_Invalid proposed                         Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      ^&*%             new      bala         
TC_CPPP_05_Invalid type                             Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      400             (12!@)   bala         
TC_CPPP_06_Invalid type                             Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      500                @@       bala      
TC_CPPP_07_Missing custId                           Karthi      ${cp_app_id}      ${EMPTY}                dealerFinance        345             ^&     bala         
TC_CPPP_08_Missing proposed and type                Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      ${EMPTY}         ${EMPTY}  bala         
TC_CPPP_09_Invalid proposed amount                  Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance     ----              new      bala         
TC_CPPP_10_Invalid proposed amount                  Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      -577              new      bala         
TC_CPPP_11_Missing type                             Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance      575             ${EMPTY}   bala         
TC_CPPP_12_Missing product and createdBy           ${EMPTY}     ${cp_app_id}      ${Anchor_cust_id}        ${EMPTY}          5677               new      bala         
TC_CPPP_13_Missing cust_id and type                 Karthi      ${cp_app_id}      ${EMPTY}                dealerFinance     7676               ${EMPTY}  bala         
TC_CPPP_14_Invalid cust_id and app_id               Karthi         @#$!                 &*              dealerFinance    677            new         bala         
TC_CPPP_15_Invalid proposed and type                Karthi      ${cp_app_id}     ${Anchor_cust_id}        dealerFinance      @#$$              &*()     bala         
TC_CPPP_16_Invalid proposed amount                  12w@4T      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance     77@6               new      $%^^         
TC_CPPP_17_Invalid proposed amount                  Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance     6 76                new      bala      
TC_CPPP_18_Missing Proposed                         Karthi      ${cp_app_id}      ${Anchor_cust_id}       dealerFinance     ${EMPTY}             @@       bala      
TC_CPPP_19_Invalid Product and type                 Karthi      ${cp_app_id}      ${Anchor_cust_id}       Q!@#Ed$@          676                  !Qw@#    bala
TC_CPPP_20_Invalid Product                          Karthi      ${cp_app_id}       ${Anchor_cust_id}       %%%%wwwe!         67676                Renew    bala