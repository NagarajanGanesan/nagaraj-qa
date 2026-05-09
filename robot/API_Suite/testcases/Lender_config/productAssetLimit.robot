*** Settings ***
Resource     ../../keywords/common.robot
Resource     ../Lender_Config/01_addLender_Positive.robot

*** Variables ***
${productType}=     1
${assetType}=       1
${minLoanAmt}=      100000.00
${maxLoanAmt}=      500000.00
${totalProdLim}=    5000000.00
${totalAssetLim}=   5000000.00
${availAssetLim}=   100000
${availProdLim}=    100000

*** Keywords ***
Build_ProductAsset_Payload
    [Documentation]    Builds the product-asset payload with conditional limit fields.
    [Arguments]    ${product_limit_applicable}    ${asset_limit_applicable}    ${lenderId}    ${lenderName}

    ${lender_detail}=    Create Dictionary    id=${lenderId}    lenderName=${lenderName}
    ${Product_APPLICABLE}=    Convert To Boolean    ${product_limit_applicable}
    ${Asset_APPLICABLE}=      Convert To Boolean    ${asset_limit_applicable}

    &{PAYLOAD}=    Create Dictionary
    ...    lender=${lender_detail}
    ...    productType=${productType}
    ...    assetType=${assetType}
    ...    minimumLoanAmount=${minLoanAmt}
    ...    maximumLoanAmount=${maxLoanAmt}
    ...    totalAssetLimit=${totalAssetLim}
    ...    availableAssetLimit=${availAssetLim}
    ...    availableProductLimit=${availProdLim}
    ...    status=True
    ...    productLimitApplicable=${Product_APPLICABLE}
    ...    assetLimitApplicable=${Asset_APPLICABLE}

    IF    ${Product_APPLICABLE} == ${True}
        Set To Dictionary    ${PAYLOAD}    totalProductLimit=${totalProdLim}
    ELSE
        Remove From Dictionary    ${PAYLOAD}    totalProductLimit
    END

    IF    ${Asset_APPLICABLE} == ${True}
        Set To Dictionary    ${PAYLOAD}    totalAssetLimit=${totalAssetLim}
    ELSE
        Remove From Dictionary    ${PAYLOAD}    totalAssetLimit
    END

    Set Suite Variable    ${productType}
    Set Suite Variable    ${assetType}
    RETURN    ${PAYLOAD}

TC03_Product Asset_Positive
    [Documentation]    Creates a product-asset limit config and returns productType and assetType.
    [Arguments]        ${product_limit_applicable}    ${asset_limit_applicable}    ${lenderId}    ${lenderName}
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     add_productAsset    ${comServ_url}:${comServ_port}

    ${REQUEST_BODY}=    Build_ProductAsset_Payload    ${product_limit_applicable}    ${asset_limit_applicable}    ${lenderId}    ${lenderName}
    ${headers}=         Create Dictionary    Content-Type=application/json

    ${RESPONSE}=    POST On Session    add_productAsset    /api/v1/asset-limit-config    json=${REQUEST_BODY}    headers=${headers}    expected_status=${expected_code}

    IF    '${product_limit_applicable}' == 'True'
        Dictionary Should Contain Key    ${REQUEST_BODY}    totalProductLimit
    ELSE
        Dictionary Should Not Contain Key    ${REQUEST_BODY}    totalProductLimit
    END

    IF    '${asset_limit_applicable}' == 'True'
        Dictionary Should Contain Key    ${REQUEST_BODY}    totalAssetLimit
    ELSE
        Dictionary Should Not Contain Key    ${REQUEST_BODY}    totalAssetLimit
    END

    ${json_data}=         Convert String To Json    ${RESPONSE.content}
    ${id}=                Get Value From Json    ${json_data}    data.id
    ${productAsset_id}=   Get From List    ${id}    0
    Log To Console        Product Asset ID: ${productAsset_id}

    RETURN    ${productType}    ${assetType}
