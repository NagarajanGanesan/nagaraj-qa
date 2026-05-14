*** Settings ***
Resource    ../../keywords/variables.robot
Suite Setup    CPA_Authentication
Test Setup     Anchor_Gst_ReturnId_for_PUT

*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Variables ***           
${addressLine1}=    T.Nagar
${addressLine2}     2nd Street    
${appId}            ${Anchor_App_id}
${city}             Chennai
${country}          India
${gstAccntHolderName}      Vijay    
${gstNumber}        24ABACC1406D1ZD  
${pinCode}          635372
${state}            Tamil Nadu
*** Test Cases ***
TC_AG_01_anchor_gst_read all
    [Tags]    SMOKE
    [Documentation]    Anchor gst details read all
    create session     Gst      ${base_url}
    ${header}=    Create Dictionary    Authorization=${SAMPLE_TOKEN}   Content-Type=application/json
    ${response}=       GET On Session      Gst                        anchorGstFile/${Anchor_App_id}    headers=${header}
    ${status_code}=    convert to string                          ${response.status_code}
    should be equal    ${status_code}                             ${expected_code}


TC_AG_02_anchor_gst_read by id(Optional)
    [Tags]    SANITY
    [Documentation]    Anchor gst details read by id
    create session     Gst                                        ${base_url}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session                             Gst                        /anchorGstFile/${Anchor_App_id}    headers=${header}
    ${status_code}=    convert to string                          ${response.status_code}
    should be equal    ${status_code}                             ${expected_code}

TC_AG_03_anchor_gst_read by id(Collection)
    [Tags]    SANITY
    [Documentation]    Anchor gst details read by id
    create session     Gst                                        ${base_url}
    ${header}=          Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=       GET On Session                             Gst                        /anchorGstFile/${Anchor_App_id}         headers=${header}
    ${status_code}=    convert to string                          ${response.status_code}
    should be equal    ${status_code}                             ${expected_code}

Anchor_GST_Update
    TC_AG_07_AnchorGst_Update     ${addressLine1}     ${addressLine2}     ${appId}     ${city}     ${country}     ${gstAccntHolderName}     ${gstNumber}     ${Gst_putId}     ${pinCode}    ${state} 

*** Keywords ***
TC_AG_07_AnchorGst_Update
    [Arguments]        ${addressLine1}     ${addressLine2}     ${appId}     ${city}     ${country}     ${gstAccntHolderName}     ${gstNumber}     ${id}     ${pinCode}    ${state} 
    [Documentation]    Anchor Authorized Detail Update
    create session     anchor_Gst      ${base_url}
    ${entry}=            Create Dictionary     addressLine1=${addressLine1}     addressLine2=${addressLine2}    appId=${appId}     city=${city}     country=${country}     gstAccntHolderName=${gstAccntHolderName}     gstNumber=${gstNumber}     id=${Gst_putId}     pinCode=${pinCode}     state=${state}
    ${anchorGstDetailsDataList}=      Create List    ${entry}
    &{data}=            Create Dictionary     anchorGstDetailsDataList=${anchorGstDetailsDataList}    updatedBy=QA     createdBy=QA
    ${header}          Create Dictionary       Authorization=${SAMPLE_TOKEN}      Content-Type=application/json
    ${response}=       Put Request             anchor_Gst       /anchorGst      data=${data}      headers=${header}
    ${status_code}=    convert to string       ${response.status_code}
    should be equal    ${status_code}     ${expected_code}

Anchor_Gst_ReturnId_for_PUT
    [Documentation]  Getting the anchor authorized details
    create session  anchor_Gst  ${base_url}
    ${header}=        Create Dictionary    Authorization=${SAMPLE_TOKEN}    Content-Type=application/json
    ${response}=      GET On Session   anchor_Gst   /anchorGstFile/${Anchor_App_id}     headers=${header}
    ${json-data}=     Convert String To Json  ${response.content}
    ${id_value}=      Get Value From Json    ${json-data}    $[0].id
    ${Gst_putId}=            Get From List    ${id_value}           0
    log  ${Gst_putId}
    Set Global Variable   ${Gst_putId}