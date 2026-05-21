*** Settings ***
Resource        ../../keywords/variables.robot
Suite Setup    CPA_Authentication
*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Variables ***
${Ans1}        Thiru
${Ans2}        Priya
${Ans3}        Karthick
${Ans4}        Veera
${Ans5}        karthikeyan

*** Test Cases ***       
TC_CPFA_FundReq_Answer_Return_PutId
    Create Session          FundReq_Answer_Read        ${cp_base_url}
    ${header}=              Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=            GET On Session       FundReq_Answer_Read         /fundReqDetails/${cp_app_id}        headers=${header}
    ${json-data}=           Convert String To Json     ${response.content}
    ${id_value}=            Get Value From Json    ${json-data}    $[0].id
    Log To Console          ${id_value}
    ${FR_PutId}=            Get From List    ${id_value}           0
    Log To Console          ${FR_PutId}
    log                     ${FR_PutId}
    Set Global Variable     ${FR_PutId}
    Log To Console          ${FR_PutId}    

    ${id_value1}=           Get Value From Json    ${json-data}    $[1].id
    Log To Console          ${id_value1}
    ${FR_PutId1}=           Get From List    ${id_value1}         0
    Log To Console          ${FR_PutId1}
    log                     ${FR_PutId1}  
    Set Global Variable     ${FR_PutId1}
    Log To Console          ${FR_PutId1}  

    ${id_value2}=           Get Value From Json    ${json-data}    $[2].id
    Log To Console          ${id_value2}
    ${FR_PutId2}=           Get From List    ${id_value2}         0
    Log To Console          ${FR_PutId2}
    log                     ${FR_PutId2}  
    Set Global Variable     ${FR_PutId2}
    Log To Console          ${FR_PutId2}

    ${id_value3}=           Get Value From Json    ${json-data}    $[3].id
    Log To Console          ${id_value3}
    ${FR_PutId3}=           Get From List    ${id_value3}         0
    Log To Console          ${FR_PutId3}
    log                     ${FR_PutId3}  
    Set Global Variable     ${FR_PutId3}
    Log To Console          ${FR_PutId3}

    ${id_value4}=           Get Value From Json    ${json-data}    $[4].id
    Log To Console          ${id_value4}
    ${FR_PutId4}=           Get From List    ${id_value4}         0
    Log To Console          ${FR_PutId4}
    log                     ${FR_PutId4}  
    Set Global Variable     ${FR_PutId4}
    Log To Console          ${FR_PutId4}


TC_CP_03_FundReq_Answer_Read_for_PUT
    [Documentation]            FundReq_Answer_PUT
    create session             FundReq_Answers_       ${CP_base_url}
    ${whyFunds}=               Create Dictionary      appId=${cp_app_id}     value=${Ans1}     cpFrmId=1386      id=${FR_PutId}
    ${enhancement}=            Create Dictionary      appId=${cp_app_id}     value=${Ans2}     cpFrmId=1388      id=${FR_PutId1}
    ${growthexpec}=            Create Dictionary      appId=${cp_app_id}     value=${Ans3}     cpFrmId=1389      id=${FR_PutId2}
    ${recommendation}=         Create Dictionary      appId=${cp_app_id}     value=${Ans4}     cpFrmId=1390      id=${FR_PutId3}
    ${limitproposed}=          Create Dictionary      appId=${cp_app_id}     value=${Ans5}     cpFrmId=1391      id=${FR_PutId4}
    ${fundAns_List}=           Create List            ${whyFunds}       ${enhancement}     ${growthexpec}    ${recommendation}     ${limitproposed}
    &{data}=                   Create Dictionary      createdBy=QA      fundReqDetailsDataList=${fundAns_List}     updatedBy=QA 
    ${header}=                 Create Dictionary      Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=               Put Request            FundReq_Answers_          /fundReqDetails      data=${data}      headers=${header}
    ${status_code}=            convert to string      ${response.status_code}
    should be equal            ${status_code}         ${expected_code}



