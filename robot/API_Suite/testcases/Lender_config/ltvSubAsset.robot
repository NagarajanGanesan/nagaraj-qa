*** Settings ***
Resource     ../../keywords/common.robot
Resource     ../Lender_Config/03_addProductAsset_Positive.robot

*** Variables ***
${codeValueId}=         3
${holdingName}=         Equity
${assetSubType}=        1
${ltv}=                 75.50
${totalAssetSubLim}=    5000000.00

*** Keywords ***
Build_LtvSubType_Payload
    [Documentation]    Builds the LTV asset-subtype payload with conditional limit field.
    [Arguments]    ${asset_SubTypeLimit_applicable}    ${lenderId}    ${lenderName}

    ${lender_detail}=       Create Dictionary    id=${lenderId}    lenderName=${lenderName}
    ${holding_Format}=      Create Dictionary    codeValueId=${codeValueId}    name=${holdingName}
    ${AssetSubType_APPLICABLE}=    Convert To Boolean    ${asset_SubTypeLimit_applicable}

    &{PAYLOAD}=    Create Dictionary
    ...    lender=${lender_detail}
    ...    assetType=${assetType}
    ...    assetSubType=${assetSubType}
    ...    holdingFormat=${holding_Format}
    ...    ltv=${ltv}
    ...    totalAssetSubTypeLimit=${totalAssetSubLim}
    ...    status=True
    ...    assetSubTypeLimitApplicable=${AssetSubType_APPLICABLE}

    IF    ${AssetSubType_APPLICABLE} == ${True}
        Set To Dictionary    ${PAYLOAD}    totalAssetSubTypeLimit=${totalAssetSubLim}
    ELSE
        Remove From Dictionary    ${PAYLOAD}    totalAssetSubTypeLimit
    END

    RETURN    ${PAYLOAD}

TC04_LtvAssetSubType_Positive
    [Documentation]    Creates an LTV asset-subtype config entry.
    [Arguments]        ${asset_SubTypeLimit_applicable}    ${lenderId}    ${lenderName}
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     add_ltvSubType    ${comServ_url}:${comServ_port}

    ${REQUEST_BODY}=    Build_LtvSubType_Payload    ${asset_SubTypeLimit_applicable}    ${lenderId}    ${lenderName}
    ${headers}=         Create Dictionary    Content-Type=application/json

    IF    '${asset_SubTypeLimit_applicable}' == 'True'
        Dictionary Should Contain Key    ${REQUEST_BODY}    totalAssetSubTypeLimit
    ELSE
        Dictionary Should Not Contain Key    ${REQUEST_BODY}    totalAssetSubTypeLimit
    END

    ${RESPONSE}=    POST On Session    add_ltvSubType    /api/v1/ltv-asset    json=${REQUEST_BODY}    headers=${headers}    expected_status=${expected_code}

    ${json_data}=       Convert String To Json    ${RESPONSE.content}
    ${msg_list}=        Get Value From Json    ${json_data}    status.message
    ${msg}=             Get From List    ${msg_list}    0
    Log To Console      LTV SubType response: ${msg}
