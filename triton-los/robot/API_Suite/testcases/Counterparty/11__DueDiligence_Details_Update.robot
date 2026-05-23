*** Settings ***
Resource          ../../keywords/variables.robot
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***
TC_CPDM_02_CounterParty_dueDiligence_readby
    [Documentation]    Getting DueDiligenceDetails data
    Create Session     Due_Diligence    ${CP_base_url}    
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session     Due_Diligence       /dueDiligenceDetails/${cp_app_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
     Log To Console        ${json-data}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    Log To Console       ${id_value}
    ${Due_putId}=            Get From List    ${id_value}           0
    Log To Console       ${Due_putId}
    log  ${Due_putId}
    Set Global Variable         ${Due_putId}
    Log To Console       ${Due_putId}

    ${id_value1}=      Get Value From Json    ${json-data}    $[1].id
    Log To Console       ${id_value1}
    ${Due_putId1}=            Get From List    ${id_value1}         0
    Log To Console       ${Due_putId1}
    log  ${Due_putId1}  
    Set Global Variable  ${Due_putId1}
    Log To Console        ${Due_putId1}

    ${id_value2}=      Get Value From Json    ${json-data}    $[2].id
    Log To Console       ${id_value2}
    ${Due_putId2}=            Get From List    ${id_value2}         0
    Log To Console       ${Due_putId2}
    log  ${Due_putId2}  
    Set Global Variable  ${Due_putId2}
    Log To Console        ${Due_putId2}
   
    ${id_value3}=      Get Value From Json    ${json-data}    $[3].id
    Log To Console       ${id_value3}
    ${Due_putId3}=            Get From List    ${id_value3}         0
    Log To Console       ${Due_putId3}
    log  ${Due_putId3}  
    Set Global Variable  ${Due_putId3}
    Log To Console        ${Due_putId3}

    ${id_value4}=      Get Value From Json    ${json-data}    $[4].id
    Log To Console       ${id_value4}
    ${Due_putId4}=            Get From List    ${id_value4}         0
    Log To Console       ${Due_putId4}
    log  ${Due_putId4}  
    Set Global Variable  ${Due_putId4}
    Log To Console        ${Due_putId4}

    ${id_value5}=      Get Value From Json    ${json-data}    $[5].id
    Log To Console       ${id_value5}
    ${Due_putId5}=            Get From List    ${id_value5}         0
    Log To Console       ${Due_putId5}
    log  ${Due_putId5}  
    Set Global Variable  ${Due_putId5}
    Log To Console        ${Due_putId5}

    ${id_value6}=      Get Value From Json    ${json-data}    $[6].id
    Log To Console       ${id_value6}
    ${Due_putId6}=            Get From List    ${id_value6}         0
    Log To Console       ${Due_putId6}
    log  ${Due_putId6}  
    Set Global Variable  ${Due_putId6}
    Log To Console        ${Due_putId6}

    ${id_value7}=      Get Value From Json    ${json-data}    $[7].id
    Log To Console       ${id_value7}
    ${Due_putId7}=            Get From List    ${id_value7}         0
    Log To Console       ${Due_putId7}
    log  ${Due_putId7}  
    Set Global Variable  ${Due_putId7}
    Log To Console        ${Due_putId7}

    ${id_value8}=      Get Value From Json    ${json-data}    $[8].id
    Log To Console       ${id_value8}
    ${Due_putId8}=            Get From List    ${id_value8}         0
    Log To Console       ${Due_putId8}
    log  ${Due_putId8}  
    Set Global Variable  ${Due_putId8}
    Log To Console        ${Due_putId8}

    ${id_value9}=      Get Value From Json    ${json-data}    $[9].id
    Log To Console       ${id_value9}
    ${Due_putId9}=            Get From List    ${id_value9}         0
    Log To Console       ${Due_putId9}
    log  ${Due_putId9}  
    Set Global Variable  ${Due_putId9}
    Log To Console        ${Due_putId9}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}

TC_dD01_CP_dueDiligence_details_create
    [Documentation]     anchor_dueDiligence detail
    create session      anchor_dueDiligence      ${CP_base_url}
    ${Date Of Visit}=                       Create Dictionary         appId=${cp_app_id}       ddId=2253      id=${Due_putId}        value=13/09/2022  
    ${Name of the Person}=                  Create Dictionary         appId=${cp_app_id}       ddId=2260      id=${Due_putId1}       value= def
    ${VCPL Attendees}=                      Create Dictionary         appId=${cp_app_id}       ddId=2261      id=${Due_putId2}       value=jkl
    ${Add Of Prem_Visited}=                 Create Dictionary         appId=${cp_app_id}       ddId=2262      id=${Due_putId3}       value=lmn
    ${Obser On Facility}=                   Create Dictionary         appId=${cp_app_id}       ddId=2263      id=${Due_putId4}       value=poi
    ${Business Model}=                      Create Dictionary         appId=${cp_app_id}       ddId=2264      id=${Due_putId5}       value=rst
    ${Stock Observation}=                   Create Dictionary         appId=${cp_app_id}       ddId=2265      id=${Due_putId6}       value= xyz
    ${Business Plans}=                      Create Dictionary         appId=${cp_app_id}       ddId=2266      id=${Due_putId7}       value=ghi
    ${Market Feedbacks}=                    Create Dictionary         appId=${cp_app_id}       ddId=2267      id=${Due_putId8}       value=iou  
    ${Market Information}=                  Create Dictionary         appId=${cp_app_id}       ddId=2268      id=${Due_putId9}       value=jeh
    ${dueDiligenceDetailsDataList}=         Create List               ${Date Of Visit}       ${Name of the Person}       ${VCPL Attendees}       ${Add Of Prem_Visited}        ${Obser On Facility}        ${Business Model}        ${Stock Observation}         ${Business Plans}        ${Market Feedbacks}         ${Market Information}  
    ${data}=                                Create Dictionary         createdBy=QA     dueDiligenceDetailsDataList=${dueDiligenceDetailsDataList}      updatedBy=QA                    
    ${header}                               Create Dictionary         Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=                            Put Request               anchor_dueDiligence      /dueDiligenceDetails      data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}