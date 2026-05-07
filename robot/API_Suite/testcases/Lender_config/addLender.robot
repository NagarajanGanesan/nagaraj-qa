*** Settings ***
Resource    ../../keywords/common.robot

*** Keywords ***
TC01_Lender Onboarding_Positive
    [Documentation]    Creates a new lender with random data and returns lender_id and lenderName.
    [Arguments]        ${cookies}    ${client_Id}    ${api_key}    ${app_code}
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     lender_onboarding    ${comServ_url}:${comServ_port}

    ${lenderName}=     Generate Random String    6    [UPPER]
    ${email_Id}=       FakerLibrary.Safe Email
    ${contact}=        Generate Random Mobile Number
    ${reg_Address}=    FakerLibrary.Address
    ${PAN}=            Generate Random PAN
    ${gstIn}=          Generate Random GSTIN
    ${logo}=           Create List    12    23    12

    ${data}=    Create Dictionary
    ...    lenderName=${lenderName}
    ...    email=${email_Id}
    ...    contactNo=${contact}
    ...    registeredAddress=${reg_Address}
    ...    pan=${PAN}
    ...    status=true
    ...    gstIn=${gstIn}
    ...    logo=${logo}

    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=${cookies}
    ...    CAPTIX-CLIENT-ID=${client_Id}
    ...    CAPTIX-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${response}=       Post On Session      lender_onboarding    /api/v1/lender    json=${data}    headers=${headers}
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}       ${expected_code}

    ${json_data}=     Convert String To Json    ${response.content}
    ${id}=            Get Value From Json    ${json_data}    data.id
    ${lender_id}=     Get From List    ${id}    0
    ${pan_val}=       Get Value From Json    ${json_data}    data.pan
    ${PAN_No}=        Get From List    ${pan_val}    0
    ${gst_val}=       Get Value From Json    ${json_data}    data.gstIn
    ${GST_No}=        Get From List    ${gst_val}    0

    Set Suite Variable    ${lender_id}
    Set Suite Variable    ${lenderName}
    Set Suite Variable    ${PAN_No}
    Set Suite Variable    ${GST_No}

    Log To Console    Lender ID: ${lender_id}
    RETURN    ${lender_id}    ${lenderName}
