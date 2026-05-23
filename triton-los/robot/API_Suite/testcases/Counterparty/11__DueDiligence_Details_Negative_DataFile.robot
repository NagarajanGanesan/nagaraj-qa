*** Settings ***
Resource               ../../keywords/variables.robot
Test Template          TC_DD02_DueDiligence detail negative testing
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
    
*** Test Cases ***                                             value                           ddID       appID
TC_DD13_missing Date Of Visit                                 ${EMPTY}                         2253        ${cp_app_id} 
TC_DD14_missing Name of the Person                            ${EMPTY}                         2260        ${cp_app_id} 
TC_DD15_missing VCPL Attendees                                ${EMPTY}                         2261        ${cp_app_id} 
TC_DD16_missing Address Of Premises Visited                   ${EMPTY}                         2262        ${cp_app_id} 
TC_DD17_missing Observation On Facility                       ${EMPTY}                         2263        ${cp_app_id} 
TC_DD18_missing Business Model                                ${EMPTY}                         2264        ${cp_app_id} 
TC_DD19_missing Stock Observation                             ${EMPTY}                         2265        ${cp_app_id} 
TC_DD20_missing Business Plans                                ${EMPTY}                         2266        ${cp_app_id} 
TC_DD21_missing Market Feedbacks                              ${EMPTY}                         2267        ${cp_app_id} 
TC_DD21_missing Market Information                            ${EMPTY}                         2268        ${cp_app_id} 
TC_DD22_incorrect Date Of Visit                               @!#$!                            2253        ${cp_app_id} 
TC_DD23_incorrect Name of the Person                          @!#$!                            2260        ${cp_app_id} 
TC_DD24_incorrect VCPL Attendees                              @!#$!                            2261        ${cp_app_id} 
TC_DD25_incorrect Address Of Premises Visited                 @!#$!                            2262        ${cp_app_id} 
TC_DD26_incorrect Observation On Facility                     @!#$!                            2263        ${cp_app_id} 
TC_DD27_incorrect Business Model                              @!#$!                            2264        ${cp_app_id} 
TC_DD28_incorrect Stock Observation                           @!#$!                            2265        ${cp_app_id} 
TC_DD29_incorrect Business Plans                              @!#$!                            2266        ${cp_app_id} 
TC_DD30_incorrect Market Feedbacks                            @!#$!                            2267        ${cp_app_id} 
TC_DD31_incorrect Market Information                          @!#$!                            2268        ${cp_app_id} 