*** Settings ***
Resource         ../../keywords/variables.robot
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***
${cpMasterId_1}    1
${cpMasterId_2}    2
${cpMasterId_3}    3
${cpMasterId_4}    4
${cpMasterId_5}    5
${cpMasterId_6}    6
${cpMasterId_7}    7
${cpMasterId_8}    8    
${cpMasterId_9}    9
${cpMasterId_10}   10
${cpMasterId_11}   11
${cpMasterId_12}   12
${cpMasterId_13}   13
${cpMasterId_14}   14
${cpMasterId_15}   15
${cpMasterId_16}   16
${cpMasterId_17}   17
${cpMasterId_18}   18
${cpMasterId_19}   19
${cpMasterId_20}   20
${cpMasterId_21}   21
${cpMasterId_22}   22
${cpMasterId_23}   23
${cpMasterId_24}   24
${cpMasterId_25}   25
${cpMasterId_26}   26
${cpMasterId_27}   27

${cpMasterId_value1}    90
${cpMasterId_value2}    89
${cpMasterId_value3}    65
${cpMasterId_value4}    56    
${cpMasterId_value5}    23
${cpMasterId_value6}    12    
${cpMasterId_value7}    76
${cpMasterId_value8}    9
${cpMasterId_value9}    45
${cpMasterId_value10}   12
${cpMasterId_value11}   11
${cpMasterId_value12}   19
${cpMasterId_value13}   09
${cpMasterId_value14}   32
${cpMasterId_value15}   92
${cpMasterId_value16}   23
${cpMasterId_value17}   2
${cpMasterId_value18}   2
${cpMasterId_value19}   23
${cpMasterId_value20}   21
${cpMasterId_value21}   11
${cpMasterId_value22}   33
${cpMasterId_value23}   89
${cpMasterId_value24}   66
${cpMasterId_value25}   33
${cpMasterId_value26}   12 
${cpMasterId_value27}   88


*** Test Cases ***
TC_CP01_Get_CreditPolicy_Master
    [Documentation]    Credit policy Master readall  
    Create Session     creditPolicy_Master  ${CP_base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}     Content-Type=application/json     
    ${response}=       Get Request          creditPolicy_Master        /creditPolicyMaster               headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

TC_CP02_Get_CreditPolicyDetails
    [Documentation]    Credit policy Details readall  
    Create Session     creditPolicy_Details  ${CP_base_url}
    ${header}          Create Dictionary    Authorization=${SAMPLE_TOKEN}     Content-Type=application/json     
    ${response}=       Get Request          creditPolicy_Details      /creditPolicyDetails/${cp_app_id}      headers=${header}
     

    ${json_data}=     Convert String To Json    ${response.content}
    Log To Console    ${json_data}

    FOR    ${index}    IN RANGE    0    27
    ${id_value}=    Get Value From Json    ${json_data}    creditPolicyArray[${index}].id
    ${cred_putId}=            Get From List    ${id_value}           0
    Set Suite Variable    ${cred_putId_${index}}    ${cred_putId}
    Log To Console     ${index}: ${cred_putId}
    END

    Set Global Variable    ${cred_putId_${0}}
    Set Global Variable    ${cred_putId_${1}}
    Set Global Variable    ${cred_putId_${2}}
    Set Global Variable    ${cred_putId_${3}}
    Set Global Variable    ${cred_putId_${4}}
    Set Global Variable    ${cred_putId_${5}}
    Set Global Variable    ${cred_putId_${6}}
    Set Global Variable    ${cred_putId_${7}}
    Set Global Variable    ${cred_putId_${8}}
    Set Global Variable    ${cred_putId_${9}}
    Set Global Variable    ${cred_putId_${10}}
    Set Global Variable    ${cred_putId_${11}}
    Set Global Variable    ${cred_putId_${12}}
    Set Global Variable    ${cred_putId_${13}}
    Set Global Variable    ${cred_putId_${14}}
    Set Global Variable    ${cred_putId_${15}}
    Set Global Variable    ${cred_putId_${16}}
    Set Global Variable    ${cred_putId_${17}}
    Set Global Variable    ${cred_putId_${18}}
    Set Global Variable    ${cred_putId_${19}}
    Set Global Variable    ${cred_putId_${20}}
    Set Global Variable    ${cred_putId_${21}}
    Set Global Variable    ${cred_putId_${22}}
    Set Global Variable    ${cred_putId_${23}}
    Set Global Variable    ${cred_putId_${24}}
    Set Global Variable    ${cred_putId_${25}}
    Set Global Variable    ${cred_putId_${26}}
    Log To Console    First ID: ${cred_putId_${0}}
    Log To Console    Second ID: ${cred_putId_${1}}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}

   

TC_CP03_Validate_CreditPolicy
        [Documentation]     validating creditpolicy detail
        create session      validateCreditPolicy      ${CP_base_url}

        ${Business Vintage}=                                                    Create Dictionary      cpMasterId=${cpMasterId_1}                   appId=${cp_app_id}       value=${cpMasterId_value1}     
        ${Turnover}=                                                            Create Dictionary      cpMasterId=${cpMasterId_2}                   appId=${cp_app_id}       value=${cpMasterId_value2}     
        ${Total Debt/GST Turnover(%)}=                                          Create Dictionary      cpMasterId=${cpMasterId_3}                   appId=${cp_app_id}       value=${cpMasterId_value3}     
        ${Sales Growth(%)}=                                                     Create Dictionary      cpMasterId=${cpMasterId_4}                   appId=${cp_app_id}       value=${cpMasterId_value4}     
        ${ATNW}=                                                                Create Dictionary      cpMasterId=${cpMasterId_5}                   appId=${cp_app_id}       value=${cpMasterId_value5}     
        ${PAT}=                                                                 Create Dictionary      cpMasterId=${cpMasterId_6}                   appId=${cp_app_id}       value=${cpMasterId_value6}     
        ${Current Ratio}=                                                       Create Dictionary      cpMasterId=${cpMasterId_7}                   appId=${cp_app_id}       value=${cpMasterId_value7}     
        ${TOL/ATNW}=                                                            Create Dictionary      cpMasterId=${cpMasterId_8}                   appId=${cp_app_id}       value=${cpMasterId_value8}     
        ${Working Capital Cycle}=                                               Create Dictionary      cpMasterId=${cpMasterId_9}                   appId=${cp_app_id}       value=${cpMasterId_value9}     
        ${Inward Cheque Bounces}=                                               Create Dictionary      cpMasterId=${cpMasterId_10}                  appId=${cp_app_id}       value=${cpMasterId_value10}    
        ${Bank Churn(%)}=                                                       Create Dictionary      cpMasterId=${cpMasterId_11}                  appId=${cp_app_id}       value=${cpMasterId_value11}    
        ${Comm_Current Overdues_Credit Card}=                                   Create Dictionary      cpMasterId=${cpMasterId_12}                  appId=${cp_app_id}       value=${cpMasterId_value12}    
        ${Comm_Current Overdues_Non Credit Card}=                               Create Dictionary      cpMasterId=${cpMasterId_13}                  appId=${cp_app_id}       value=${cpMasterId_value13}    
        ${Comm_SMA-1/31-60 DPD in the last 12 months}=                          Create Dictionary      cpMasterId=${cpMasterId_14}                  appId=${cp_app_id}       value=${cpMasterId_value14}    
        ${Comm_SMA-2/61-90 DPD in the last 6 months}=                           Create Dictionary      cpMasterId=${cpMasterId_15}                  appId=${cp_app_id}       value=${cpMasterId_value15}    
        ${Comm_SMA-2/61-90 DPD in 6-12 months}=                                 Create Dictionary      cpMasterId=${cpMasterId_16}                  appId=${cp_app_id}       value=${cpMasterId_value16}    
        ${Comm_Substd, doubtful, loss, restructured/write off_24 months}=       Create Dictionary      cpMasterId=${cpMasterId_17}                  appId=${cp_app_id}       value=${cpMasterId_value17}    
        ${Comm_Wilful or suitfile_48 months}=                                   Create Dictionary      cpMasterId=${cpMasterId_18}                  appId=${cp_app_id}       value=${cpMasterId_value18}    
        ${Con_Bureau Score}=                                                    Create Dictionary      cpMasterId=${cpMasterId_19}                  appId=${cp_app_id}       value=${cpMasterId_value19}    
        ${Con_Current Overdues_Credit Card}=                                    Create Dictionary      cpMasterId=${cpMasterId_20}                  appId=${cp_app_id}       value=${cpMasterId_value20}    
        ${Con_Current Overdues_Non Credit Card}=                                Create Dictionary      cpMasterId=${cpMasterId_21}                  appId=${cp_app_id}       value=${cpMasterId_value21}    
        ${Con_Substd, doubtful, loss, restructured/write off_24 months}=        Create Dictionary      cpMasterId=${cpMasterId_22}                  appId=${cp_app_id}       value=${cpMasterId_value22}    
        ${Con_Wilful or suit filed_in the last 36 months}=                      Create Dictionary      cpMasterId=${cpMasterId_23}                  appId=${cp_app_id}       value=${cpMasterId_value23}    
        ${Latest GST Payment}=                                                  Create Dictionary      cpMasterId=${cpMasterId_24}                  appId=${cp_app_id}       value=${cpMasterId_value24}    
        ${Latest EPFO Payment}=                                                 Create Dictionary      cpMasterId=${cpMasterId_25}                  appId=${cp_app_id}       value=${cpMasterId_value25}    
        ${Vintage with Anchor}=                                                 Create Dictionary      cpMasterId=${cpMasterId_26}                  appId=${cp_app_id}       value=${cpMasterId_value26}    
        ${Min Monthly Purchase from Anchor}=                                    Create Dictionary      cpMasterId=${cpMasterId_27}                  appId=${cp_app_id}       value=${cpMasterId_value27}    

        ${list}=            Create List          ${Business Vintage}  ${Turnover}  ${Total Debt/GST Turnover(%)}  ${Sales Growth(%)}  ${ATNW}  ${PAT}  ${Current Ratio}    ${TOL/ATNW}   ${Working Capital Cycle}   ${Inward Cheque Bounces}  ${Bank Churn(%)}  ${Comm_Current Overdues_Credit Card}  ${Comm_Current Overdues_Non Credit Card}   ${Comm_SMA-1/31-60 DPD in the last 12 months}  ${Comm_SMA-2/61-90 DPD in the last 6 months}  ${Comm_SMA-2/61-90 DPD in 6-12 months}  ${Comm_Substd, doubtful, loss, restructured/write off_24 months}   ${Comm_Wilful or suitfile_48 months}  ${Con_Bureau Score}  ${Con_Current Overdues_Credit Card}  ${Con_Current Overdues_Non Credit Card}  ${Con_Substd, doubtful, loss, restructured/write off_24 months}   ${Con_Wilful or suit filed_in the last 36 months}   ${Latest GST Payment}   ${Latest EPFO Payment}   ${Vintage with Anchor}  ${Min Monthly Purchase from Anchor}       
        &{data}=            Create Dictionary    creditPolicyDetailsData=${list}
        ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
        ${response}=        Post Request         validateCreditPolicy               /validateCreditPolicy     data=&{data}    headers=${header}
        ${status_code}=     convert to string    ${response.status_code}
        Should Be Equal     ${status_code}    ${expected_code}

TC_CP04_Update_CreditPolicy
        [Documentation]     updating creditpolicy detail
        create session      updateCreditPolicy      ${CP_base_url}

        ${Business Vintage}=                                                    Create Dictionary      cpMasterId=${cpMasterId_1}                   appId=${cp_app_id}       value=${cpMasterId_value1}     id=${cred_putId_${0}}  
        ${Turnover}=                                                            Create Dictionary      cpMasterId=${cpMasterId_2}                   appId=${cp_app_id}       value=${cpMasterId_value2}     id=${cred_putId_${1}}
        ${Total Debt/GST Turnover(%)}=                                          Create Dictionary      cpMasterId=${cpMasterId_3}                   appId=${cp_app_id}       value=${cpMasterId_value3}     id=${cred_putId_${2}}
        ${Sales Growth(%)}=                                                     Create Dictionary      cpMasterId=${cpMasterId_4}                   appId=${cp_app_id}       value=${cpMasterId_value4}     id=${cred_putId_${3}}
        ${ATNW}=                                                                Create Dictionary      cpMasterId=${cpMasterId_5}                   appId=${cp_app_id}       value=${cpMasterId_value5}     id=${cred_putId_${4}}
        ${PAT}=                                                                 Create Dictionary      cpMasterId=${cpMasterId_6}                   appId=${cp_app_id}       value=${cpMasterId_value6}     id=${cred_putId_${5}}
        ${Current Ratio}=                                                       Create Dictionary      cpMasterId=${cpMasterId_7}                   appId=${cp_app_id}       value=${cpMasterId_value7}     id=${cred_putId_${6}}
        ${TOL/ATNW}=                                                            Create Dictionary      cpMasterId=${cpMasterId_8}                   appId=${cp_app_id}       value=${cpMasterId_value8}     id=${cred_putId_${7}}
        ${Working Capital Cycle}=                                               Create Dictionary      cpMasterId=${cpMasterId_9}                   appId=${cp_app_id}       value=${cpMasterId_value9}     id=${cred_putId_${8}}
        ${Inward Cheque Bounces}=                                               Create Dictionary      cpMasterId=${cpMasterId_10}                  appId=${cp_app_id}       value=${cpMasterId_value10}    id=${cred_putId_${9}}
        ${Bank Churn(%)}=                                                       Create Dictionary      cpMasterId=${cpMasterId_11}                  appId=${cp_app_id}       value=${cpMasterId_value11}    id=${cred_putId_${10}}
        ${Comm_Current Overdues_Credit Card}=                                   Create Dictionary      cpMasterId=${cpMasterId_12}                  appId=${cp_app_id}       value=${cpMasterId_value12}    id=${cred_putId_${11}}
        ${Comm_Current Overdues_Non Credit Card}=                               Create Dictionary      cpMasterId=${cpMasterId_13}                  appId=${cp_app_id}       value=${cpMasterId_value13}    id=${cred_putId_${12}}
        ${Comm_SMA-1/31-60 DPD in the last 12 months}=                          Create Dictionary      cpMasterId=${cpMasterId_14}                  appId=${cp_app_id}       value=${cpMasterId_value14}    id=${cred_putId_${13}}
        ${Comm_SMA-2/61-90 DPD in the last 6 months}=                           Create Dictionary      cpMasterId=${cpMasterId_15}                  appId=${cp_app_id}       value=${cpMasterId_value15}    id=${cred_putId_${14}}
        ${Comm_SMA-2/61-90 DPD in 6-12 months}=                                 Create Dictionary      cpMasterId=${cpMasterId_16}                  appId=${cp_app_id}       value=${cpMasterId_value16}    id=${cred_putId_${15}}
        ${Comm_Substd, doubtful, loss, restructured/write off_24 months}=       Create Dictionary      cpMasterId=${cpMasterId_17}                  appId=${cp_app_id}       value=${cpMasterId_value17}    id=${cred_putId_${16}}
        ${Comm_Wilful or suitfile_48 months}=                                   Create Dictionary      cpMasterId=${cpMasterId_18}                  appId=${cp_app_id}       value=${cpMasterId_value18}    id=${cred_putId_${17}}
        ${Con_Bureau Score}=                                                    Create Dictionary      cpMasterId=${cpMasterId_19}                  appId=${cp_app_id}       value=${cpMasterId_value19}    id=${cred_putId_${18}}
        ${Con_Current Overdues_Credit Card}=                                    Create Dictionary      cpMasterId=${cpMasterId_20}                  appId=${cp_app_id}       value=${cpMasterId_value20}    id=${cred_putId_${19}}
        ${Con_Current Overdues_Non Credit Card}=                                Create Dictionary      cpMasterId=${cpMasterId_21}                  appId=${cp_app_id}       value=${cpMasterId_value21}    id=${cred_putId_${20}}
        ${Con_Substd, doubtful, loss, restructured/write off_24 months}=        Create Dictionary      cpMasterId=${cpMasterId_22}                  appId=${cp_app_id}       value=${cpMasterId_value22}    id=${cred_putId_${21}}
        ${Con_Wilful or suit filed_in the last 36 months}=                      Create Dictionary      cpMasterId=${cpMasterId_23}                  appId=${cp_app_id}       value=${cpMasterId_value23}    id=${cred_putId_${22}}
        ${Latest GST Payment}=                                                  Create Dictionary      cpMasterId=${cpMasterId_24}                  appId=${cp_app_id}       value=${cpMasterId_value24}    id=${cred_putId_${23}}
        ${Latest EPFO Payment}=                                                 Create Dictionary      cpMasterId=${cpMasterId_25}                  appId=${cp_app_id}       value=${cpMasterId_value25}    id=${cred_putId_${24}}
        ${Vintage with Anchor}=                                                 Create Dictionary      cpMasterId=${cpMasterId_26}                  appId=${cp_app_id}       value=${cpMasterId_value26}    id=${cred_putId_${25}}
        ${Min Monthly Purchase from Anchor}=                                    Create Dictionary      cpMasterId=${cpMasterId_27}                  appId=${cp_app_id}       value=${cpMasterId_value27}    id=${cred_putId_${26}}
  
        ${list}=            Create List          ${Business Vintage}  ${Turnover}  ${Total Debt/GST Turnover(%)}  ${Sales Growth(%)}  ${ATNW}  ${PAT}  ${Current Ratio}    ${TOL/ATNW}   ${Working Capital Cycle}   ${Inward Cheque Bounces}  ${Bank Churn(%)}  ${Comm_Current Overdues_Credit Card}  ${Comm_Current Overdues_Non Credit Card}   ${Comm_SMA-1/31-60 DPD in the last 12 months}  ${Comm_SMA-2/61-90 DPD in the last 6 months}  ${Comm_SMA-2/61-90 DPD in 6-12 months}  ${Comm_Substd, doubtful, loss, restructured/write off_24 months}   ${Comm_Wilful or suitfile_48 months}  ${Con_Bureau Score}  ${Con_Current Overdues_Credit Card}  ${Con_Current Overdues_Non Credit Card}  ${Con_Substd, doubtful, loss, restructured/write off_24 months}   ${Con_Wilful or suit filed_in the last 36 months}   ${Latest GST Payment}   ${Latest EPFO Payment}   ${Vintage with Anchor}  ${Min Monthly Purchase from Anchor}       
        &{data}=            Create Dictionary    creditPolicyDetailsData=${list}
        ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
        ${response}=        Put Request         updateCreditPolicy               /creditPolicyDetails     data=&{data}    headers=${header}
        ${status_code}=     convert to string    ${response.status_code}
        Should Be Equal     ${status_code}    ${expected_code}
   

TC_CP05_RunCreditPolicy_master  
        [Documentation]     Running creditpolicy detail
        create session      runCreditPolicy      ${CP_base_url}

        ${Business Vintage}=                                                    Create Dictionary      cpMasterId=${cpMasterId_1}                   appId=${cp_app_id}       value=${cpMasterId_value1}
        ${Turnover}=                                                            Create Dictionary      cpMasterId=${cpMasterId_2}                   appId=${cp_app_id}       value=${cpMasterId_value2}
        ${Total Debt/GST Turnover(%)}=                                          Create Dictionary      cpMasterId=${cpMasterId_3}                   appId=${cp_app_id}       value=${cpMasterId_value3}  
        ${Sales Growth(%)}=                                                     Create Dictionary      cpMasterId=${cpMasterId_4}                   appId=${cp_app_id}       value=${cpMasterId_value4}
        ${ATNW}=                                                                Create Dictionary      cpMasterId=${cpMasterId_5}                   appId=${cp_app_id}       value=${cpMasterId_value5}
        ${PAT}=                                                                 Create Dictionary      cpMasterId=${cpMasterId_6}                   appId=${cp_app_id}       value=${cpMasterId_value6}
        ${Current Ratio}=                                                       Create Dictionary      cpMasterId=${cpMasterId_7}                   appId=${cp_app_id}       value=${cpMasterId_value7}
        ${TOL/ATNW}=                                                            Create Dictionary      cpMasterId=${cpMasterId_8}                   appId=${cp_app_id}       value=${cpMasterId_value8}
        ${Working Capital Cycle}=                                               Create Dictionary      cpMasterId=${cpMasterId_9}                   appId=${cp_app_id}       value=${cpMasterId_value9}
        ${Inward Cheque Bounces}=                                               Create Dictionary      cpMasterId=${cpMasterId_10}                  appId=${cp_app_id}       value=${cpMasterId_value10}
        ${Bank Churn(%)}=                                                       Create Dictionary      cpMasterId=${cpMasterId_11}                  appId=${cp_app_id}       value=${cpMasterId_value11}
        ${Comm_Current Overdues_Credit Card}=                                   Create Dictionary      cpMasterId=${cpMasterId_12}                  appId=${cp_app_id}       value=${cpMasterId_value12}
        ${Comm_Current Overdues_Non Credit Card}=                               Create Dictionary      cpMasterId=${cpMasterId_13}                  appId=${cp_app_id}       value=${cpMasterId_value13}
        ${Comm_SMA-1/31-60 DPD in the last 12 months}=                          Create Dictionary      cpMasterId=${cpMasterId_14}                  appId=${cp_app_id}       value=${cpMasterId_value14}
        ${Comm_SMA-2/61-90 DPD in the last 6 months}=                           Create Dictionary      cpMasterId=${cpMasterId_15}                  appId=${cp_app_id}       value=${cpMasterId_value15}
        ${Comm_SMA-2/61-90 DPD in 6-12 months}=                                 Create Dictionary      cpMasterId=${cpMasterId_16}                  appId=${cp_app_id}       value=${cpMasterId_value16}
        ${Comm_Substd, doubtful, loss, restructured/write off_24 months}=       Create Dictionary      cpMasterId=${cpMasterId_17}                  appId=${cp_app_id}       value=${cpMasterId_value17}
        ${Comm_Wilful or suitfile_48 months}=                                   Create Dictionary      cpMasterId=${cpMasterId_18}                  appId=${cp_app_id}       value=${cpMasterId_value18}
        ${Con_Bureau Score}=                                                    Create Dictionary      cpMasterId=${cpMasterId_19}                  appId=${cp_app_id}       value=${cpMasterId_value19}
        ${Con_Current Overdues_Credit Card}=                                    Create Dictionary      cpMasterId=${cpMasterId_20}                  appId=${cp_app_id}       value=${cpMasterId_value20}
        ${Con_Current Overdues_Non Credit Card}=                                Create Dictionary      cpMasterId=${cpMasterId_21}                  appId=${cp_app_id}       value=${cpMasterId_value21}
        ${Con_Substd, doubtful, loss, restructured/write off_24 months}=        Create Dictionary      cpMasterId=${cpMasterId_22}                  appId=${cp_app_id}       value=${cpMasterId_value22}
        ${Con_Wilful or suit filed_in the last 36 months}=                      Create Dictionary      cpMasterId=${cpMasterId_23}                  appId=${cp_app_id}       value=${cpMasterId_value23}
        ${Latest GST Payment}=                                                  Create Dictionary      cpMasterId=${cpMasterId_24}                  appId=${cp_app_id}       value=${cpMasterId_value24}
        ${Latest EPFO Payment}=                                                 Create Dictionary      cpMasterId=${cpMasterId_25}                  appId=${cp_app_id}       value=${cpMasterId_value25}
        ${Vintage with Anchor}=                                                 Create Dictionary      cpMasterId=${cpMasterId_26}                  appId=${cp_app_id}       value=${cpMasterId_value26}
        ${Min Monthly Purchase from Anchor}=                                    Create Dictionary      cpMasterId=${cpMasterId_27}                  appId=${cp_app_id}       value=${cpMasterId_value27}


        ${list}=            Create List          ${Business Vintage}  ${Turnover}  ${Total Debt/GST Turnover(%)}  ${Sales Growth(%)}  ${ATNW}  ${PAT}  ${Current Ratio}    ${TOL/ATNW}   ${Working Capital Cycle}   ${Inward Cheque Bounces}  ${Bank Churn(%)}  ${Comm_Current Overdues_Credit Card}  ${Comm_Current Overdues_Non Credit Card}   ${Comm_SMA-1/31-60 DPD in the last 12 months}  ${Comm_SMA-2/61-90 DPD in the last 6 months}  ${Comm_SMA-2/61-90 DPD in 6-12 months}  ${Comm_Substd, doubtful, loss, restructured/write off_24 months}   ${Comm_Wilful or suitfile_48 months}  ${Con_Bureau Score}  ${Con_Current Overdues_Credit Card}  ${Con_Current Overdues_Non Credit Card}  ${Con_Substd, doubtful, loss, restructured/write off_24 months}   ${Con_Wilful or suit filed_in the last 36 months}   ${Latest GST Payment}   ${Latest EPFO Payment}   ${Vintage with Anchor}  ${Min Monthly Purchase from Anchor}       
        &{data}=            Create Dictionary    creditPolicyDetailsData=${list}
        ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
        ${response}=        Post Request         runCreditPolicy               /creditPolicyMaster?cpType=Dealer&ProductName=Dealer%20Purchase%20Order%20Finance&custId=6&apppId=15097     data=&{data}    headers=${header}
        ${status_code}=     convert to string    ${response.status_code}
        Should Be Equal     ${status_code}    ${expected_code}

TC_CP06_RunCreditPolicy_Details
        [Documentation]     Running creditpolicy detail
        create session      runCreditPolicy      ${CP_base_url}

        ${Business Vintage}=                                                    Create Dictionary      cpMasterId=${cpMasterId_1}                   appId=${cp_app_id}       value=${cpMasterId_value1}
        ${Turnover}=                                                            Create Dictionary      cpMasterId=${cpMasterId_2}                   appId=${cp_app_id}       value=${cpMasterId_value2}
        ${Total Debt/GST Turnover(%)}=                                          Create Dictionary      cpMasterId=${cpMasterId_3}                   appId=${cp_app_id}       value=${cpMasterId_value3}  
        ${Sales Growth(%)}=                                                     Create Dictionary      cpMasterId=${cpMasterId_4}                   appId=${cp_app_id}       value=${cpMasterId_value4}
        ${ATNW}=                                                                Create Dictionary      cpMasterId=${cpMasterId_5}                   appId=${cp_app_id}       value=${cpMasterId_value5}
        ${PAT}=                                                                 Create Dictionary      cpMasterId=${cpMasterId_6}                   appId=${cp_app_id}       value=${cpMasterId_value6}
        ${Current Ratio}=                                                       Create Dictionary      cpMasterId=${cpMasterId_7}                   appId=${cp_app_id}       value=${cpMasterId_value7}
        ${TOL/ATNW}=                                                            Create Dictionary      cpMasterId=${cpMasterId_8}                   appId=${cp_app_id}       value=${cpMasterId_value8}
        ${Working Capital Cycle}=                                               Create Dictionary      cpMasterId=${cpMasterId_9}                   appId=${cp_app_id}       value=${cpMasterId_value9}
        ${Inward Cheque Bounces}=                                               Create Dictionary      cpMasterId=${cpMasterId_10}                  appId=${cp_app_id}       value=${cpMasterId_value10}
        ${Bank Churn(%)}=                                                       Create Dictionary      cpMasterId=${cpMasterId_11}                  appId=${cp_app_id}       value=${cpMasterId_value11}
        ${Comm_Current Overdues_Credit Card}=                                   Create Dictionary      cpMasterId=${cpMasterId_12}                  appId=${cp_app_id}       value=${cpMasterId_value12}
        ${Comm_Current Overdues_Non Credit Card}=                               Create Dictionary      cpMasterId=${cpMasterId_13}                  appId=${cp_app_id}       value=${cpMasterId_value13}
        ${Comm_SMA-1/31-60 DPD in the last 12 months}=                          Create Dictionary      cpMasterId=${cpMasterId_14}                  appId=${cp_app_id}       value=${cpMasterId_value14}
        ${Comm_SMA-2/61-90 DPD in the last 6 months}=                           Create Dictionary      cpMasterId=${cpMasterId_15}                  appId=${cp_app_id}       value=${cpMasterId_value15}
        ${Comm_SMA-2/61-90 DPD in 6-12 months}=                                 Create Dictionary      cpMasterId=${cpMasterId_16}                  appId=${cp_app_id}       value=${cpMasterId_value16}
        ${Comm_Substd, doubtful, loss, restructured/write off_24 months}=       Create Dictionary      cpMasterId=${cpMasterId_17}                  appId=${cp_app_id}       value=${cpMasterId_value17}
        ${Comm_Wilful or suitfile_48 months}=                                   Create Dictionary      cpMasterId=${cpMasterId_18}                  appId=${cp_app_id}       value=${cpMasterId_value18}
        ${Con_Bureau Score}=                                                    Create Dictionary      cpMasterId=${cpMasterId_19}                  appId=${cp_app_id}       value=${cpMasterId_value19}
        ${Con_Current Overdues_Credit Card}=                                    Create Dictionary      cpMasterId=${cpMasterId_20}                  appId=${cp_app_id}       value=${cpMasterId_value20}
        ${Con_Current Overdues_Non Credit Card}=                                Create Dictionary      cpMasterId=${cpMasterId_21}                  appId=${cp_app_id}       value=${cpMasterId_value21}
        ${Con_Substd, doubtful, loss, restructured/write off_24 months}=        Create Dictionary      cpMasterId=${cpMasterId_22}                  appId=${cp_app_id}       value=${cpMasterId_value22}
        ${Con_Wilful or suit filed_in the last 36 months}=                      Create Dictionary      cpMasterId=${cpMasterId_23}                  appId=${cp_app_id}       value=${cpMasterId_value23}
        ${Latest GST Payment}=                                                  Create Dictionary      cpMasterId=${cpMasterId_24}                  appId=${cp_app_id}       value=${cpMasterId_value24}
        ${Latest EPFO Payment}=                                                 Create Dictionary      cpMasterId=${cpMasterId_25}                  appId=${cp_app_id}       value=${cpMasterId_value25}
        ${Vintage with Anchor}=                                                 Create Dictionary      cpMasterId=${cpMasterId_26}                  appId=${cp_app_id}       value=${cpMasterId_value26}
        ${Min Monthly Purchase from Anchor}=                                    Create Dictionary      cpMasterId=${cpMasterId_27}                  appId=${cp_app_id}       value=${cpMasterId_value27}


        ${list}=            Create List          ${Business Vintage}  ${Turnover}  ${Total Debt/GST Turnover(%)}  ${Sales Growth(%)}  ${ATNW}  ${PAT}  ${Current Ratio}    ${TOL/ATNW}   ${Working Capital Cycle}   ${Inward Cheque Bounces}  ${Bank Churn(%)}  ${Comm_Current Overdues_Credit Card}  ${Comm_Current Overdues_Non Credit Card}   ${Comm_SMA-1/31-60 DPD in the last 12 months}  ${Comm_SMA-2/61-90 DPD in the last 6 months}  ${Comm_SMA-2/61-90 DPD in 6-12 months}  ${Comm_Substd, doubtful, loss, restructured/write off_24 months}   ${Comm_Wilful or suitfile_48 months}  ${Con_Bureau Score}  ${Con_Current Overdues_Credit Card}  ${Con_Current Overdues_Non Credit Card}  ${Con_Substd, doubtful, loss, restructured/write off_24 months}   ${Con_Wilful or suit filed_in the last 36 months}   ${Latest GST Payment}   ${Latest EPFO Payment}   ${Vintage with Anchor}  ${Min Monthly Purchase from Anchor}       
        &{data}=            Create Dictionary    creditPolicyDetailsData=${list}
        ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}      content-type=application/json
        ${response}=        Post Request         runCreditPolicy             /creditPolicyDetails     data=&{data}    headers=${header}
        ${status_code}=     convert to string    ${response.status_code}
        Should Be Equal     ${status_code}    ${expected_code}
