*** Settings ***
Resource               ../../keywords/variables.robot
Test Template          TC_DD01_DueDiligence detail positive testing
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***                                            value         ddId           appID
TC_DD03_Date Of Visit                                         12/09/2022    2253        ${cp_app_id} 
TC_DD04_Name of the Person                                    def           2260        ${cp_app_id} 
TC_DD05_VCPL Attendees                                        jkl           2261        ${cp_app_id} 
TC_DD06_Address Of Premises Visited                           lmn           2262        ${cp_app_id} 
TC_DD07_Observation On Facility                               poi           2263        ${cp_app_id} 
TC_DD08_Business Model                                        rst           2264        ${cp_app_id} 
TC_DD09_Stock Observation                                     xyz           2265        ${cp_app_id} 
TC_DD10_Business Plans                                        ghi           2266        ${cp_app_id} 
TC_DD11_Market Feedbacks                                      uio           2267        ${cp_app_id} 
TC_DD12_Market Information                                    jeh           2268        ${cp_app_id} 