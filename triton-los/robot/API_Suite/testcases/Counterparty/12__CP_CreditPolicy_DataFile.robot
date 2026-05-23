*** Settings ***
Resource         ../../keywords/variables.robot
Test Template    TC_CP07_Validate_CreditPolicy_Negative
Suite Setup            credit_underwriter_Authentication
*** Keywords ***
credit_underwriter_Authentication
    ${username}    Set Variable       credit_underwriter_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}

*** Variables ***                 
${BusVin}               1                 
${Turnover}             2
${TotalDebt}            3
${SalesGrowth}          4
${ATNW}                 5
${PAT}                  6
${CurrentRatio}         7
${TOL_ATNW}             8
${WorkingCapital}       9
${InwardCheque}         10
${BankChurn}            11
${Comm_CurrentOD_CC}    12
${Comm_CurrentOD_NCC}   13
${SMA1}                 14
${SMA2}                 15
${SMA2_6to12}           16
${Comm_Subs}            17
${Comm_Wilful}          18
${bureau_cons}          19
${Con_CurrentOD_CC}     20
${Con_CurrentOD_NCC}    21
${Con_Subs}             22
${Cons_Wilful}          23
${LatestGSTPayment}     24
${LatestEPFOPayment}    25
${VintagewithAnchor}    26
${MinMonthlyPurchase}   27

*** Test Cases ***                                       appId                   value            cpMasterId
TC_CP08_Missing Business vintage                        ${cp_app_id}            ${EMPTY}         ${BusVin}    #months
TC_CP09_Invalid Business vintage                        ${cp_app_id}            2.7              ${BusVin}
TC_CP10_AlphaNumeric value in Business vintage          ${cp_app_id}            12abd            ${BusVin}
TC_CP11_Symbols in Business vintage                     ${cp_app_id}            12$%             ${BusVin}
TC_CP12_Negative value in Business vintage              ${cp_app_id}            -12              ${BusVin}
TC_CP13_Invalid length for Business vintage             ${cp_app_id}            13211            ${BusVin}

TC_CP14_Missing Turnover                                ${cp_app_id}            ${EMPTY}         ${Turnover}    #Rs
# TC_CP15_Invalid Turnover                                ${cp_app_id}            2.7              ${Turnover}            
TC_CP16_AlphaNumeric in Turnover                        ${cp_app_id}            122abc           ${Turnover}
TC_CP17_Symbols in Turnover                             ${cp_app_id}            1@##             ${Turnover}
TC_CP18_Negative value in Turnover                      ${cp_app_id}            -12              ${Turnover}
TC_CP19_invalid length in TUrnover                      ${cp_app_id}            16526252721      ${Turnover}

TC_CP20_Missing TotalDebt                                ${cp_app_id}            ${EMPTY}         ${TotalDebt}    #%
TC_CP21_AplhaNumeric in TotalDebt                        ${cp_app_id}            12ab             ${TotalDebt}
# TC_CN_02_Invalid TotalDebt                              ${cp_app_id}            2.7              ${TotalDebt}            
TC_CP22_Symbols in TotalDebt                             ${cp_app_id}            2@3              ${TotalDebt}
TC_CP23_Negative value in TotalDebt                      ${cp_app_id}            -1200            ${TotalDebt} 
TC_CP24_invalid length in TotalDebt                      ${cp_app_id}            16526252721      ${TotalDebt}

TC_CP25_Missing SalesGrowth                           ${cp_app_id}            ${EMPTY}         ${SalesGrowth}
TC_CP26_AplhaNumeric in SalesGrowth                   ${cp_app_id}            12ab             ${SalesGrowth}
# TC_CN_02_Invalid SalesGrowth                         ${cp_app_id}            2.7              ${SalesGrowth}  
TC_CP27_Symbols in SalesGrowth                        ${cp_app_id}            2@3              ${SalesGrowth}
TC_CP28_Negative value in SalesGrowth                 ${cp_app_id}            -1200            ${SalesGrowth} 
TC_CP29_invalid length in SalesGrowth                 ${cp_app_id}            16526252721      ${SalesGrowth}

TC_CP30_Missing ATNW                        ${cp_app_id}            ${EMPTY}         ${ATNW}    #months
# TC_CN_02_Invalid ATNW                      ${cp_app_id}            2.7              ${ATNW} 
TC_CP31_AlphaNumeric value in ATNW          ${cp_app_id}            12abd            ${ATNW}
TC_CP32_Symbols in ATNW                     ${cp_app_id}            12$%             ${ATNW}
TC_CP33_Negative value in ATNW              ${cp_app_id}            -12              ${ATNW}
TC_CP34_Invalid length for ATNW             ${cp_app_id}            1321112121212    ${ATNW}

TC_CP35_Missing PAT                         ${cp_app_id}            ${EMPTY}         ${PAT}    #Rs 
# TC_CN_02_Invalid ATNW                      ${cp_app_id}            2.7              ${PAT}
TC_CP36_AlphaNumeric in PAT                 ${cp_app_id}            122abc           ${PAT}
TC_CP37_Symbols in PAT                      ${cp_app_id}            1@##             ${PAT}
# TC_CN_05_Negative value in ATNW            ${cp_app_id}            -12              ${PAT}
TC_CP38_invalid length in PAT               ${cp_app_id}            16526252721      ${PAT}

TC_CP39_Missing CurrentRatio                                ${cp_app_id}            ${EMPTY}         ${CurrentRatio}    
# TC_CN_02_Invalid CurrentRatio                              ${cp_app_id}            2.7              ${CurrentRatio}
TC_CP40_AplhaNumeric in CurrentRatio                        ${cp_app_id}            12ab             ${CurrentRatio}
TC_CP41_Symbols in CurrentRatio                             ${cp_app_id}            2@3              ${CurrentRatio}
TC_CP42_Negative value in CurrentRatio                      ${cp_app_id}            -1200            ${CurrentRatio} 
TC_CP43_invalid length in CurrentRatio                      ${cp_app_id}            16526252721      ${CurrentRatio}

TC_CP44_Missing TOL_ATNW                                ${cp_app_id}            ${EMPTY}         ${TOL_ATNW}    
# TC_CN_02_Invalid TOL_ATNW                              ${cp_app_id}            2.7              ${TOL_ATNW
TC_CP45_AplhaNumeric in TOL_ATNW                        ${cp_app_id}            12ab             ${TOL_ATNW}
TC_CP46_Symbols in TOL_ATNW                             ${cp_app_id}            2@3              ${TOL_ATNW}
TC_CP47_Negative value in TOL_ATNW                      ${cp_app_id}            -1200            ${TOL_ATNW} 
TC_CP48_invalid length in TOL_ATNW                      ${cp_app_id}            16526252721      ${TOL_ATNW}

TC_CP49_Missing WorkingCapital                                ${cp_app_id}            ${EMPTY}         ${WorkingCapital}    
TC_CP50_Invalid WorkingCapital                                ${cp_app_id}            2.7              ${WorkingCapital}
TC_CP51_AplhaNumeric in WorkingCapital                        ${cp_app_id}            12ab             ${WorkingCapital}
TC_CP52_Symbols in WorkingCapital                             ${cp_app_id}            2@3              ${WorkingCapital}
TC_CP53_Negative value in WorkingCapital                      ${cp_app_id}            -1200            ${WorkingCapital} 
TC_CP54_invalid length in WorkingCapital                      ${cp_app_id}            16526252721      ${WorkingCapital}

TC_CP55_Missing InwardCheque                                  ${cp_app_id}          ${EMPTY}         ${InwardCheque}
# TC_CP55_valid InwardCheque                                ${cp_app_id}            2.7              ${InwardCheque}
TC_CP56_AplhaNumeric in InwardCheque                        ${cp_app_id}            12ab             ${InwardCheque}
TC_CP57_Symbols in InwardCheque                             ${cp_app_id}            2@3              ${InwardCheque}
TC_CP58_Negative value in InwardCheque                      ${cp_app_id}            -1200            ${InwardCheque} 
TC_CP59_invalid length in InwardCheque                      ${cp_app_id}            16526252721      ${InwardCheque}

TC_CP60_Missing BankChurn                                ${cp_app_id}            ${EMPTY}         ${BankChurn}    
# TC_CN_02_Invalid BankChurn                              ${cp_app_id}            2.7              ${BankChurn
TC_CP61_AplhaNumeric in BankChurn                        ${cp_app_id}            12ab             ${BankChurn}
TC_CP62_Symbols in BankChurn                             ${cp_app_id}            2@3              ${BankChurn}
TC_CP63_Negative value in BankChurn                      ${cp_app_id}            -1200            ${BankChurn} 
TC_CP64_valid length in BankChurn                      ${cp_app_id}            16526252721      ${BankChurn}

TC_CP65_Missing Comm_CurrentOD_CC                                ${cp_app_id}            ${EMPTY}         ${Comm_CurrentOD_CC}    
# TC_CN_02_Invalid Comm_CurrentOD_CC                              ${cp_app_id}            2.7              ${Comm_CurrentOD_CC
TC_CP66_AplhaNumeric in Comm_CurrentOD_CC                        ${cp_app_id}            12ab             ${Comm_CurrentOD_CC}
TC_CP67_Symbols in Comm_CurrentOD_CC                             ${cp_app_id}            2@3              ${Comm_CurrentOD_CC}
TC_CP68_Negative value in Comm_CurrentOD_CC                      ${cp_app_id}            -1200            ${Comm_CurrentOD_CC} 
TC_CP69_invalid length in Comm_CurrentOD_CC                      ${cp_app_id}            16526252721      ${Comm_CurrentOD_CC}

TC_CP70_Missing Comm_CurrentOD_NCC                                ${cp_app_id}            ${EMPTY}         ${Comm_CurrentOD_NCC}    
# TC_CN_02_Invalid Comm_CurrentOD_NCC                              ${cp_app_id}            2.7              ${Comm_CurrentOD_NCC
TC_CP71_AplhaNumeric in Comm_CurrentOD_NCC                        ${cp_app_id}            12ab             ${Comm_CurrentOD_NCC}
TC_CP72_Symbols in Comm_CurrentOD_NCC                             ${cp_app_id}            2@3              ${Comm_CurrentOD_NCC}
TC_CP73_Negative value in Comm_CurrentOD_NCC                      ${cp_app_id}            -1200            ${Comm_CurrentOD_NCC} 
TC_CP74_invalid length in Comm_CurrentOD_NCC                      ${cp_app_id}            16526252721      ${Comm_CurrentOD_NCC}

TC_CP75_Missing SMA1                                ${cp_app_id}            ${EMPTY}         ${SMA1}    
TC_CP76_Invalid SMA1                                ${cp_app_id}            2.7              ${SMA1}
TC_CP77_AplhaNumeric in SMA1                        ${cp_app_id}            12ab             ${SMA1}
TC_CP78_Symbols in SMA1                             ${cp_app_id}            2@3              ${SMA1}
TC_CP79_Negative value in SMA1                      ${cp_app_id}            -1200            ${SMA1} 
TC_CP80_invalid length in SMA1                      ${cp_app_id}            16526252721      ${SMA1}

TC_CP81_Missing SMA2                                ${cp_app_id}            ${EMPTY}         ${SMA2}    
TC_CP82_Invalid SMA2                                ${cp_app_id}            2.7              ${SMA2}
TC_CP83_AplhaNumeric in SMA2                        ${cp_app_id}            12ab             ${SMA2}
TC_CP84_Symbols in SMA2                             ${cp_app_id}            2@3              ${SMA2}
TC_CP85_Negative value in SMA2                      ${cp_app_id}            -1200            ${SMA2} 
TC_CP86_invalid length in SMA2                      ${cp_app_id}            16526252721      ${SMA2}

TC_CP87_Missing SMA2_6to12                                ${cp_app_id}            ${EMPTY}         ${SMA2_6to12}    
TC_CP88_Invalid SMA2_6to12                                ${cp_app_id}            2.7              ${SMA2_6to12}
TC_CP89_AplhaNumeric in SMA2_6to12                        ${cp_app_id}            12ab             ${SMA2_6to12}
TC_CP90_Symbols in SMA2_6to12                             ${cp_app_id}            2@3              ${SMA2_6to12}
TC_CP91_Negative value in SMA2_6to12                      ${cp_app_id}            -1200            ${SMA2_6to12} 
TC_CP92_invalid length in SMA2_6to12                      ${cp_app_id}            16526252721      ${SMA2_6to12}

TC_CP93_Missing Comm_Subs                                ${cp_app_id}            ${EMPTY}         ${Comm_Subs}    
TC_CP94_Invalid Comm_Subs                                ${cp_app_id}            2.7              ${Comm_Subs}
TC_CP95_AplhaNumeric in Comm_Subs                        ${cp_app_id}            12ab             ${Comm_Subs}
TC_CP96_Symbols in Comm_Subs                             ${cp_app_id}            2@3              ${Comm_Subs}
TC_CP97_Negative value in Comm_Subs                      ${cp_app_id}            -1200            ${Comm_Subs} 
TC_CP98_invalid length in Comm_Subs                      ${cp_app_id}            16526252721      ${Comm_Subs}

TC_CP100_Missing Comm_Wilful                                ${cp_app_id}            ${EMPTY}         ${Comm_Wilful}    
TC_CP101_Invalid Comm_Wilful                                ${cp_app_id}            2.7              ${Comm_Wilful}
TC_CP102_AplhaNumeric in Comm_Wilful                        ${cp_app_id}            12ab             ${Comm_Wilful}
TC_CP103_Symbols in Comm_Wilful                             ${cp_app_id}            2@3              ${Comm_Wilful}
TC_CP104_Negative value in Comm_Wilful                      ${cp_app_id}            -1200            ${Comm_Wilful} 
TC_CP105_invalid length in Comm_Wilful                      ${cp_app_id}            16526252721      ${Comm_Wilful}

TC_CP106_Missing bureau_cons                                ${cp_app_id}            ${EMPTY}         ${bureau_cons}    
# TC_CN_02_Invalid bureau_cons                              ${cp_app_id}            2.7              ${bureau_cons
TC_CP107_AplhaNumeric in bureau_cons                        ${cp_app_id}            12ab             ${bureau_cons}
TC_CP108_Symbols in bureau_cons                             ${cp_app_id}            2@3              ${bureau_cons}
TC_CP109_Negative value in bureau_cons                      ${cp_app_id}            -1200            ${bureau_cons} 
TC_CP110_invalid length in bureau_cons                      ${cp_app_id}            16526252721      ${bureau_cons}

TC_CP111_Missing Con_CurrentOD_CC                                ${cp_app_id}            ${EMPTY}         ${Con_CurrentOD_CC}    
# TC_CN_02_Invalid Con_CurrentOD_CC                              ${cp_app_id}            2.7              ${Con_CurrentOD_CC
TC_CP112_AplhaNumeric in Con_CurrentOD_CC                        ${cp_app_id}            12ab             ${Con_CurrentOD_CC}
TC_CP113_Symbols in Con_CurrentOD_CC                             ${cp_app_id}            2@3              ${Con_CurrentOD_CC}
TC_CP114_Negative value in Con_CurrentOD_CC                      ${cp_app_id}            -1200            ${Con_CurrentOD_CC} 
TC_CP115_invalid length in Con_CurrentOD_CC                      ${cp_app_id}            16526252721      ${Con_CurrentOD_CC}


TC_CP116_Missing Con_CurrentOD_NCC                                ${cp_app_id}            ${EMPTY}         ${Con_CurrentOD_NCC}    
# TC_CN_02_Invalid Con_CurrentOD_NCC                              ${cp_app_id}            2.7              ${Con_CurrentOD_NCC
TC_CP117_AplhaNumeric in Con_CurrentOD_NCC                        ${cp_app_id}            12ab             ${Con_CurrentOD_NCC}
TC_CP118_Symbols in Con_CurrentOD_NCC                             ${cp_app_id}            2@3              ${Con_CurrentOD_NCC}
TC_CP119_Negative value in Con_CurrentOD_NCC                      ${cp_app_id}            -1200            ${Con_CurrentOD_NCC} 
TC_CP120_invalid length in Con_CurrentOD_NCC                      ${cp_app_id}            16526252721      ${Con_CurrentOD_NCC}

TC_CP121_Missing Con_Subs                                ${cp_app_id}            ${EMPTY}         ${Con_Subs}    
TC_CP122_Invalid Con_Subs                                ${cp_app_id}            2.7              ${Con_Subs}
TC_CP123_AplhaNumeric in Con_Subs                        ${cp_app_id}            12ab             ${Con_Subs}
TC_CP124_Symbols in Con_Subs                             ${cp_app_id}            2@3              ${Con_Subs}
TC_CP125_Negative value in Con_Subs                      ${cp_app_id}            -1200            ${Con_Subs} 
TC_CP126_invalid length in Con_Subs                      ${cp_app_id}            16526252721      ${Con_Subs}

TC_CP127_Missing Cons_Wilful                                ${cp_app_id}            ${EMPTY}         ${Cons_Wilful}    
TC_CP128_Invalid Cons_Wilful                                ${cp_app_id}            2.7              ${Cons_Wilful}
TC_CP129_AplhaNumeric in Cons_Wilful                        ${cp_app_id}            12ab             ${Cons_Wilful}
TC_CP130_Symbols in Cons_Wilful                             ${cp_app_id}            2@3              ${Cons_Wilful}
TC_CP131_Negative value in Cons_Wilful                      ${cp_app_id}            -1200            ${Cons_Wilful} 
TC_CP132_invalid length in Cons_Wilful                      ${cp_app_id}            16526252721      ${Cons_Wilful}

TC_CP133_Missing LatestGSTPayment                                ${cp_app_id}            ${EMPTY}         ${LatestGSTPayment}    
TC_CP134_Invalid LatestGSTPayment                                ${cp_app_id}            2.7              ${LatestGSTPayment}
TC_CP135_AplhaNumeric in LatestGSTPayment                        ${cp_app_id}            12ab             ${LatestGSTPayment}
TC_CP136_Symbols in LatestGSTPayment                             ${cp_app_id}            2@3              ${LatestGSTPayment}
TC_CP137_Negative value in LatestGSTPayment                      ${cp_app_id}            -1200            ${LatestGSTPayment} 
TC_CP138_invalid length in LatestGSTPayment                      ${cp_app_id}            16526252721      ${LatestGSTPayment}

TC_CP139_Missing LatestEPFOPayment                                ${cp_app_id}            ${EMPTY}         ${LatestEPFOPayment}    
TC_CP140_Invalid LatestEPFOPayment                                ${cp_app_id}            2.7              ${LatestEPFOPayment}
TC_CP141_AplhaNumeric in LatestEPFOPayment                        ${cp_app_id}            12ab             ${LatestEPFOPayment}
TC_CP142_Symbols in LatestEPFOPayment                             ${cp_app_id}            2@3              ${LatestEPFOPayment}
TC_CP143_Negative value in LatestEPFOPayment                      ${cp_app_id}            -1200            ${LatestEPFOPayment} 
TC_CP144_invalid length in LatestEPFOPayment                      ${cp_app_id}            16526252721      ${LatestEPFOPayment}

TC_CP145_Missing VintagewithAnchor                                ${cp_app_id}            ${EMPTY}         ${VintagewithAnchor}    
TC_CP146_Invalid VintagewithAnchor                                ${cp_app_id}            2.7              ${VintagewithAnchor}
TC_CP147_AplhaNumeric in VintagewithAnchor                        ${cp_app_id}            12ab             ${VintagewithAnchor}
TC_CP148_Symbols in VintagewithAnchor                             ${cp_app_id}            2@3              ${VintagewithAnchor}
TC_CP149_Negative value in VintagewithAnchor                      ${cp_app_id}            -1200            ${VintagewithAnchor} 
TC_CP150_invalid length in VintagewithAnchor                      ${cp_app_id}            16526252721      ${VintagewithAnchor}

TC_CP151_Missing MinMonthlyPurchase                                ${cp_app_id}            ${EMPTY}         ${MinMonthlyPurchase}    
# TC_CN_02_Invalid MinMonthlyPurchase                              ${cp_app_id}            2.7              ${MinMonthlyPurchase
TC_CP152_AplhaNumeric in MinMonthlyPurchase                        ${cp_app_id}            12ab             ${MinMonthlyPurchase}
TC_CP153_Symbols in MinMonthlyPurchase                             ${cp_app_id}            2@3              ${MinMonthlyPurchase}
TC_CP154_Negative value in MinMonthlyPurchase                      ${cp_app_id}            -1200            ${MinMonthlyPurchase} 
TC_CP155_invalid length in MinMonthlyPurchase                      ${cp_app_id}            16526252721      ${MinMonthlyPurchase}

