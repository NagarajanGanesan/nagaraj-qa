*** Settings ***
Resource      ../../keywords/variables.robot
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Variables ***
${primarySec}=    123
${secondSec}=     j
${gurantees}=     t
${preDis}=        p
${finCon}=        e
${timeForCom}=    22
${postDisCon}=    h
${cmID1}=         2293
${cmID2}          2294
${cmID3}          2295
${cmID4}          2296
${cmID5}          2297
${cmID6}          2298
${cmID7}          2299

*** Test Cases ***                                           
TC_CPCM_09_CounterParty_Collateral
    [Documentation]    Getting collateralDetails data
    Create Session     CP_collateral    ${CP_base_url}    
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session    CP_collateral   /collateral/${cp_app_id}    headers=${header}
    ${status_code}=    convert to string      ${response.status_code}
    should be equal     ${status_code}          ${expected_code}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    Log To Console       ${id_value}
    ${id1}=            Get From List    ${id_value}           0
    Log To Console       ${id1}
    log  ${id1}
    Set Global Variable        ${id1}
    Log To Console       ${id1}

    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[1].id
    Log To Console       ${id_value}
    ${id2}=            Get From List    ${id_value}           0
    Log To Console       ${id2}
    log  ${id2}
    Set Global Variable        ${id2}
    Log To Console       ${id2}

    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[2].id
    Log To Console       ${id_value}
    ${id3}=            Get From List    ${id_value}           0
    Log To Console       ${id3}
    log  ${id3}
    Set Global Variable        ${id3}
    Log To Console       ${id3}

    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[3].id
    Log To Console       ${id_value}
    ${id4}=            Get From List    ${id_value}           0
    Log To Console       ${id4}
    log  ${id4}
    Set Global Variable        ${id4}
    Log To Console       ${id4}

    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[4].id
    Log To Console       ${id_value}
    ${id5}=            Get From List    ${id_value}           0
    Log To Console       ${id5}
    log  ${id5}
    Set Global Variable        ${id5}
    Log To Console       ${id5}

    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[5].id
    Log To Console       ${id_value}
    ${id6}=            Get From List    ${id_value}           0
    Log To Console       ${id6}
    log  ${id6}
    Set Global Variable        ${id6}
    Log To Console       ${id6}

    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[6].id
    Log To Console       ${id_value}
    ${id7}=           Get From List    ${id_value}           0
    Log To Console       ${id7}
    log  ${id7}
    Set Global Variable        ${id7}
    Log To Console       ${id7}

TC_CD_10_Collateral_Update
    [Documentation]    CP Collateral Detail Update
    create session     CP_collateral_PUT     ${CP_base_url}
    ${prim_Sec}=           Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id1}      value=${primarySec}
    ${seco_Sec}=           Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id2}      value=${secondSec}
    ${guran_tees}=         Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id3}      value=${gurantees}
    ${pre_Dis}=            Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id4}      value=${preDis}  
    ${fin_Con}=            Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id5}      value=${finCon}  
    ${time_For_Com}=       Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id6}      value=${timeForCom}
    ${post_Dis_Con}=       Create Dictionary         appId=${cp_app_id}     cmId=${cmID1}      id=${id7}      value=${postDisCon}




    ${collateralDetailsDataList}=      Create List   ${prim_Sec}   ${seco_Sec}    ${guran_tees}    ${pre_Dis}    ${fin_Con}    ${time_For_Com}     ${post_Dis_Con}

    ${data}=           Create Dictionary        collateralDetailsDataList=${collateralDetailsDataList}    createdBy=QA    updatedBy=QA                    

    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json

    ${response}=       Put Request             CP_collateral_PUT       /collateralDetails      data=${data}      headers=${header}

    ${status_code}=    convert to string       ${response.status_code}

    should be equal    ${status_code}     ${expected_code}