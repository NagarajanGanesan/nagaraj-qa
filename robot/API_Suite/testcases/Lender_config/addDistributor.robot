*** Settings ***
Resource    ../../keywords/common.robot

*** Keywords ***
TC02_Distributor Onboarding_Positive
    [Documentation]    Creates a new distributor with random data and returns Distributor_id and DistributorName.
    ${comServ_url}=      Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session       Distributor_onboarding    ${comServ_url}:${comServ_port}

    ${DistributorName}=    FakerLibrary.Company
    ${email_Id}=           FakerLibrary.Safe Email
    ${contact}=            Generate Random Mobile Number
    ${reg_Address}=        FakerLibrary.Address
    ${PAN}=                Generate Random PAN
    ${gstIn}=              Generate Random GSTIN
    ${logo}=               Create List    12    23    12
    ${bankAccountName}=    Generate Bank Name
    ${bankAccountNo}=      Generate Account Number    ${bankAccountName}
    ${ifsc_code}=          Generate Ifsc    ${bankAccountName}
    ${accountType}=        Create Dictionary    codesId=2    name=DEBT

    ${data}=    Create Dictionary
    ...    distributorName=${DistributorName}
    ...    email=${email_Id}
    ...    contactNo=${contact}
    ...    registeredAddress=${reg_Address}
    ...    pan=${PAN}
    ...    status=true
    ...    gstIn=${gstIn}
    ...    logo=${logo}
    ...    bankAccountName=${bankAccountName}
    ...    bankAccountNo=${bankAccountNo}
    ...    ifscCode=${ifsc_code}
    ...    accountType=${accountType}

    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       Post On Session      Distributor_onboarding    /api/v1/distributors    json=${data}    headers=${headers}    expected_status=${expected_code}
    ${status_code}=    Convert To String    ${response.status_code}

    ${json_data}=        Convert String To Json    ${response.content}
    ${id}=               Get Value From Json    ${json_data}    data.id
    ${Distributor_id}=   Get From List    ${id}    0
    ${pan_val}=          Get Value From Json    ${json_data}    data.pan
    ${PAN_No}=           Get From List    ${pan_val}    0
    ${gst_val}=          Get Value From Json    ${json_data}    data.gstIn
    ${GST_No}=           Get From List    ${gst_val}    0

    Set Suite Variable    ${Distributor_id}
    Set Suite Variable    ${DistributorName}
    Set Suite Variable    ${PAN_No}
    Set Suite Variable    ${GST_No}

    Log To Console    Distributor ID: ${Distributor_id}
    RETURN    ${Distributor_id}    ${DistributorName}
