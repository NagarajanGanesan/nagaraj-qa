*** Settings ***
Resource     ../../keywords/common.robot
Resource     ../Lender_Config/addProductAsset_Positive.robot

*** Variables ***
${intAutoPay}         5
${totalDsaLim}        1000000.0
${availDsaLim}        20000

# Interest / Tenure
${minLoanAmount}      1000
${maxLoanAmount}      10000000
${minIntRate}         10.5
${defaultInttRate}    12
${maxInttRate}        30.89
${minimumTenure}      12
${defaultTenure}      15
${maximumTenure}      30

# Product Interest Share
${lenderShare}                             34.5
${finsireDistributorInterestShareType}     1
${finsireShare}                            55
${distributorShare}                        45

# Fees
${feeName}          Processing Fee
${feeType}          1
${feeCalculation}   1
${feeValue}         500
${minFeeAmount}     100
${maxFeeAmount}     1000
${feeBasis}         UPFRONT
${feeCondition}     ON_DISBURSEMENT
${lenderPreFixed}   12
${gstType}          1

*** Keywords ***
Build Product Configuration Payload
    [Documentation]    Builds the complete product JSON, conditionally including DSA limits.
    [Arguments]    ${dsa_limit_applicable_flag}    ${lender_id}    ${lender_name}    ${Distributor_id}    ${DistributorName}    ${DEDUCT_AT_DISBURSEMENT_STATUS}    ${GST_APPLICABLE_STATUS}

    ${productName}=    FakerLibrary.Cryptocurrency Name
    ${dsa_flag}=       Convert To Boolean    ${dsa_limit_applicable_flag}

    &{LENDER_OBJ}=    Create Dictionary    id=${lender_id}    lenderName=${lender_name}

    &{PAYLOAD}=    Create Dictionary
    ...    productName=${productName}
    ...    productType=${productType}
    ...    assetType=${assetType}
    ...    lender=${LENDER_OBJ}
    ...    interestAutopayDay=${intAutoPay}
    ...    status=True
    ...    dsaLimitApplicable=${dsa_limit_applicable_flag}

    IF    ${dsa_flag} == ${True}
        Set To Dictionary    ${PAYLOAD}    totalDsaLimit=${totalDsaLim}
        Set To Dictionary    ${PAYLOAD}    availableDsaLimit=${availDsaLim}
    ELSE
        Remove From Dictionary    ${PAYLOAD}    totalDsaLimit
        Remove From Dictionary    ${PAYLOAD}    availableDsaLimit
    END

    &{INT_TENURE_CONFIG_ITEM}=    Create Dictionary
    ...    minimumLoanAmount=${minLoanAmount}
    ...    maximumLoanAmount=${maxLoanAmount}
    ...    minimumInterestRate=${minIntRate}
    ...    defaultInterestRate=${defaultInttRate}
    ...    maximumInterestRate=${maxInttRate}
    ...    minimumTenure=${minimumTenure}
    ...    defaultTenure=${defaultTenure}
    ...    maximumTenure=${maximumTenure}

    ${INTEREST_TENURE_CONFIG_LIST}=    Create List    ${INT_TENURE_CONFIG_ITEM}
    Set To Dictionary    ${PAYLOAD}    productInterestTenureConfig=${INTEREST_TENURE_CONFIG_LIST}

    &{INTEREST_SHARE}=    Create Dictionary
    ...    lenderShare=${lenderShare}
    ...    finsireDistributorInterestShareType=${finsireDistributorInterestShareType}
    ...    finsireShare=${finsireShare}
    ...    distributorShare=${distributorShare}
    Set To Dictionary    ${PAYLOAD}    productInterestShare=${INTEREST_SHARE}

    &{FEE_DETAILS}=    Create Dictionary
    ...    feeName=${feeName}
    ...    feeType=${feeType}
    ...    feeCalculationTypeEnum=${feeCalculation}
    ...    feeValue=${feeValue}
    ...    minFeeAmount=${minFeeAmount}
    ...    maxFeeAmount=${maxFeeAmount}
    ...    feeBasis=${feeBasis}
    ...    feeCondition=${feeCondition}
    ...    deductAtDisbursement=${DEDUCT_AT_DISBURSEMENT_STATUS}
    ...    gstApplicable=${GST_APPLICABLE_STATUS}
    ...    lenderPreFixedValue=${lenderPreFixed}
    ...    lenderShare=${lenderShare}
    ...    finsireDistributorFeeShareType=${finsireDistributorInterestShareType}
    ...    finsireShare=${finsireShare}
    ...    distributorShare=${distributorShare}
    ...    status=${TRUE}

    IF    '${DEDUCT_AT_DISBURSEMENT_STATUS}' == '${FALSE}'
        Remove From Dictionary    ${FEE_DETAILS}    deductAtDisbursement
    END

    IF    '${GST_APPLICABLE_STATUS}' == '${True}'
        Set To Dictionary    ${FEE_DETAILS}    gstType=1    gstValue=18
    ELSE
        Remove From Dictionary    ${FEE_DETAILS}    gstType
        Remove From Dictionary    ${FEE_DETAILS}    gstValue
    END

    ${FEES_LIST}=    Create List    ${FEE_DETAILS}
    Set To Dictionary    ${PAYLOAD}    fees=${FEES_LIST}
    RETURN    ${PAYLOAD}

TC05_Product_Positive
    [Documentation]    Creates a product and returns Product_id and Product_Code.
    [Arguments]    ${cookies}    ${client_Id}    ${api_key}    ${app_code}    ${dsa_limit_applicable_flag}    ${lender_id}    ${lender_name}    ${Distributor_id}    ${DistributorName}    ${deductAt_Disbursement}    ${gst_Applicable}

    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     product_session    ${comServ_url}:${comServ_port}

    ${REQUEST_BODY}=    Build Product Configuration Payload
    ...    ${dsa_limit_applicable_flag}    ${lender_id}    ${lender_name}
    ...    ${Distributor_id}    ${DistributorName}    ${deductAt_Disbursement}    ${gst_Applicable}

    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Cookie=${cookies}
    ...    CAPTIX-CLIENT-ID=${client_Id}
    ...    CAPTIX-API-KEY=${api_key}
    ...    app-code=${app_code}

    ${RESPONSE}=       POST On Session    product_session    /api/v1/product    json=${REQUEST_BODY}    headers=${headers}    expected_status=${expected_code}
    ${json_data}=      Convert String To Json    ${RESPONSE.content}

    ${id_list}=        Get Value From Json    ${json_data}    data.id
    ${Product_id}=     Get From List    ${id_list}    0

    ${code_list}=      Get Value From Json    ${json_data}    data.productCode
    ${Product_Code}=   Get From List    ${code_list}    0

    Set Suite Variable    ${Product_id}
    Set Suite Variable    ${Product_Code}

    Log To Console    Product ID: ${Product_id}  Code: ${Product_Code}
    RETURN    ${Product_id}    ${Product_Code}
