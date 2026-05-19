*** Settings ***
Resource         ../../keywords/variables.robot
Test Template     common.TC_CN_CreditNorms detail positive testing
Suite Setup        CPA_Authentication

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***
${MinVin}           12             #Months
${MinPur}           10000  
${ProPan}           Required 
${ProOvd}           Required
${BusPan}           Required
${GstCert}          Required 
*** Test Cases ***                                                     appId                value                    cnMasterId                       
TC_CN_01_Min Vintage with anchor                               ${Anchor_App_id}            ${MinVin}                    263                 
TC_CN_02_Min Monthly Purchase                                  ${Anchor_App_id}            ${MinPur}                    266    
TC_CN_03_Promoter/Gurantor PAN                                 ${Anchor_App_id}            ${ProPan}                    389    
TC_CN_04_Promoter/Gurantor OVD                                 ${Anchor_App_id}            ${ProOvd}                    390
TC_CN_05_Business PAN                                          ${Anchor_App_id}            ${BusPan}                    391    
TC_CN_06_Gst Certificate                                       ${Anchor_App_id}            ${GstCert}                   392