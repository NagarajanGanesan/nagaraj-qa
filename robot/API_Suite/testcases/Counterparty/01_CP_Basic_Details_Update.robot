*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    Business_Authentication
Test Setup     TC_CP_Basic_Details__Return_PutId
*** Keywords ***
Business_Authentication
    ${username}    Set Variable       business_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***
${activity}              Traders      
${anchorRelationShip}    Vendor
${appId}                 ${cp_app_id}
${assessmentType}        Financial 
${cinNumber}             L17110MH1973PLC019745  
${city}                  Chennai
${companyName}           HK Tyres
${constitution}          Private Company
${createdBy}             Tester
${cusContName}           Ganesh
${cusContactEmail}       sample.user@gmail.com
${cusContactNumber}      9823785687
${custId}                ${Anchor_cust_id}
${gstNumber}             24APACC1446D2ZK
${panNumber}             IHJGH1234G
${rmName}                Abhishek Sharma 
${source}                Direct
${state}                 Tamil Nadu
${subSource}             Website
${totalInwardCheques}    12
${updatedBy}             Tester

*** Test Cases ***
TC_CP_Basic_GET_Method
    [Documentation]    Verify CP Basic details    
    create session     cpbasic      ${CP_base_url}
    ${header}=         create dictionary       Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=       GET On Session    cpbasic    /cpBasic/${custId}    headers=${header}
    ${status_code}=    convert to string    ${response.status_code}
    should be equal    ${status_code}       ${expected_code}


Cp_BasicDetails_Update
    TC_Basic_Details_PUT_Method     ${activity}     ${anchorRelationShip}     ${appId}     ${assessmentType}     ${cinNumber}     ${city}     ${companyName}     ${constitution}     ${createdBy}     ${cusContName}     ${cusContactNumber}     ${custId}     ${gstNumber}     ${Basic_putId}     ${panNumber}     ${rmName}      ${source}     ${state}     ${subSource}     ${totalInwardCheques}     ${updatedBy}

*** Keywords ***
TC_CP_Basic_Details__Return_PutId
    [Documentation]    Verify CP Basic details    
    create session     cpbasicdetails       ${CP_base_url}
    ${header}=         create dictionary       Authorization=${SAMPLE_TOKEN}      content-type=application/json
    ${response}=     Get Request     cpbasicdetails     /cpBasicDetails/${cp_app_id}    headers=${header}
    ${json-data}=          Convert String To Json  ${response.content}
    ${id_value}=           Get Value From Json    ${json-data}    $[0].id
    ${Basic_putId}=           Get From List    ${id_value}           0
    log  ${Basic_putId}
    Set Global Variable   ${Basic_putId}

TC_Basic_Details_PUT_Method
    [Arguments]        ${activity}     ${anchorRelationShip}     ${appId}     ${assessmentType}     ${cinNumber}     ${city}     ${companyName}     ${constitution}     ${createdBy}     ${cusContName}     ${cusContactNumber}     ${custId}     ${gstNumber}     ${id}     ${panNumber}     ${rmName}      ${source}     ${state}     ${subSource}     ${totalInwardCheques}     ${updatedBy}
    [Documentation]    counter party BasicDetails PUT 
    Create Session     BasicDetails    ${CP_base_url} 
    ${data}=           Create Dictionary       activity=${activity}  anchorRelationShip=${anchorRelationShip}  appId=${appId}  assessmentType=${assessmentType}   cinNumber=${cinNumber}    city=${city}    companyName=${companyName}  constitution=${constitution}    createdBy=${createdBy}    cusContName=${cusContName}    cusContactEmail=${cusContactEmail}    cusContactNumber=${cusContactNumber}    custId=${custId}    gstNumber=${gstNumber}    id=${Basic_putId}    panNumber=${panNumber}    rmName=${rmName}    source=${source}   state=${state}    subSource=${subSource}    totalInwardCheques=${totalInwardCheques}    updatedBy=${updatedBy}     
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request            BasicDetails        /cpBasicDetails   data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}

