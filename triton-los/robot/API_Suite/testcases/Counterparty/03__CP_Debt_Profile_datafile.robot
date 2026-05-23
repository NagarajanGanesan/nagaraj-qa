*** Settings ***
Resource    ../../keywords/variables.robot
Test Template      TC_CP_debt_profile_datafile_negative_id
Suite Setup    CPA_Authentication
*** Keywords ***
CPA_Authentication
    ${username}    Set Variable       cpa_lead
    ${password}    Set Variable       admin@1234
    Obtain_Auth_Token    ${username}    ${password}
*** Test Cases ***                       appId           bankFI      emi     facilityType         id     interestRate     outstandingOnDate     remarks       sanctionDate       sanctionLimit     security     specificLimit     tenure         
TC_CPDP_01_invalid_bankFI01             ${cp_app_id}      ab13@#     12       Facility            0        10                     0               89              Test              ss                Yes          yes             12            
TC_CPDP_02_invalid_bankFI02             ${cp_app_id}       @$%$      12       Facility            0        Test                   12            Approved           12               Test              23           Test            12
TC_CPDP_03_invalid_emi01                ${cp_app_id}        abcd     $%^      Facility            0        Test                   12            Approved           15               ab                12           Afd             12
TC_CPDP_04_invalid_emi02                ${cp_app_id}        abcd     Test     Facility            0        Test                   12            Approved           15               ab                12           Afd             12 
TC_CPDP_05_invalid_facilityType01       ${cp_app_id}        abcd     12       52315255            0        Test                   10            Approved           15               ab                12           Afd             12
TC_CPDP_06_invalid_facilityType02       ${cp_app_id}        abcd     12       %@%!%!%%            0        Test                    7            Approved           15               ab                12           Afd             12
TC_CPDP_07_invalid_facilityType03       ${cp_app_id}        abcd     12       fac134!#            0        Test                    4            Approved           15               ab                12           Afd             12
TC_CPDP_08_invalid_interestRate01       ${cp_app_id}        abcd     12       Facility            0        rs$%)                  12            Approved           12               ab                12           Afd             12
TC_CPDP_09_invalid_interestRate02       ${cp_app_id}        abcd     12       Facility            0        7689                   23            Approved           13               ab                12           Afd             12
TC_CPDP_10_invalid_interestRate03       ${cp_app_id}        abcd     12       Facility            0        Te#$                   12            Approved           14               ab                12           Afd             12
TC_CPDP_11_invalid_OutstandingDate01    ${cp_app_id}        abcd     12       Facility            0        Test                  Test           Approved           15               ab                12           Afd             12
TC_CPDP_12_invalid_OutstandingDate02    ${cp_app_id}        abcd     12       Facility            0        Test                 5#$%#           Approved           16               ab                12           Afd             12
TC_CPDP_13_invalid_OutstandingDate03    ${cp_app_id}        abcd     12       Facility            0        Test                  Test           Approved           13               ab                12           Afd             12
TC_CPDP_14_invalid_Remarks01            ${cp_app_id}        abcd     12       Facility            0        Test                   12              2#$#R%           14               ab                12           Afd             12
TC_CPDP_15_invalid_Remarks01            ${cp_app_id}        abcd     12       Facility            0        Test                   12              24325            15               ab                12           Afd             12
TC_CPDP_16_invalid_Remarks01            ${cp_app_id}        abcd     12       Facility            0        Test                   12              123%$^           14               ab                12           Afd             12
TC_CPDP_17_invalid_sanctionDate01       ${cp_app_id}        abcd     12       Facility            0        Test                   12            Approved          $%^$^%            ab                12           Afd             12
TC_CPDP_18_invalid_sanctionDate02       ${cp_app_id}        abcd     12       Facility            0        Test                   12            Approved          Test              ab                12           Afd             12
TC_CPDP_19_invalid_sanctionDate03       ${cp_app_id}        abcd     12       Facility            0        Test                   12            Approved          Tes^&45           ab                12           Afd             12
TC_CPDP_20_invalid_sanctionLimit01      ${cp_app_id}        abcd     12       Facility            0        Test                   12            Approved            13             $%^$^%             12           Afd             12
TC_CPDP_21_invalid_sanctionLimit02      ${cp_app_id}        abcd     12       Facility            0        Test                   12            Approved            12             TK@#%              12           Afd             12
TC_CPDP_22_invalid_sanctionLimit03      ${cp_app_id}        abcd     12       Facility            0        Test                   14            Approved            12             Tested             12           Afd             12
TC_CPDP_23_invalid_security01           ${cp_app_id}        abcd     12       Facility            0        Test                   13            Approved            12              ab               $%^$^%        Afd             12
TC_CPDP_24_invalid_security02           ${cp_app_id}        abcd     12       Facility            0        Test                   13            Approved            12              ab               TK@#%         Afd             12
TC_CPDP_25_invalid_security03           ${cp_app_id}        abcd     12       Facility            0        Test                   16            Approved            12              ab                1234         Afd             12
TC_CPDP_26_invalid_specificLimit01      ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            12              ab                12          $%^$^%           12
TC_CPDP_27_invalid_specificLimit02      ${cp_app_id}        abcd     12       Facility            0        Test                   12            Approved            12              ab                12          TK@#%            12
TC_CPDP_28_invalid_specificLimit03      ${cp_app_id}        abcd     12       Facility            0        Test                   13            Approved            15              ab                12          1234             12
TC_CPDP_29_invalid_tenure01             ${cp_app_id}        abcd     12       Facility            0        Test                   15            Approved            17              ab                12           Afd             $%^$^%
TC_CPDP_30_invalid_tenure02             ${cp_app_id}        abcd     12       Facility            0        Test                   19            Approved            18              ab                12           Afd             TK@#%
TC_CPDP_31_invalid_tenure03             ${cp_app_id}        abcd     12       Facility            0        Test                   20            Approved            19              ab                12           Afd             1234
TC_CPDP_32_missing_bankFi               ${cp_app_id}       ${EMPTY}  12       Facility            0        Test                   12            Approved            20              ab                12           Afd             12
TC_CPDP_33_missing_emi                  ${cp_app_id}        abcd    ${EMPTY}  Facility            0        Test                   13            Approved            21              ab                12           Afd             12
TC_CPDP_34_missing_facilityType         ${cp_app_id}        abcd     12       ${EMPTY}            0        Test                   14            Approved            22              ab                12           Afd             12
TC_CPDP_35_missing_interestRate         ${cp_app_id}        abcd     12       Facility            0       ${EMPTY}                16            Approved            23              ab                12           Afd             12
TC_CPDP_36_missing_outstandingOnDate    ${cp_app_id}        abcd     12       Facility            0        Test              ${EMPTY}           Approved            12              ab                12           Afd             12
TC_CPDP_37_missing_remarks              ${cp_app_id}        abcd     12       Facility            0        Test                   17            ${EMPTY}            12              ab                12           Afd             12
TC_CPDP_38_missing_sanctionDate         ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved        ${EMPTY}            ab                12           Afd             12
TC_CPDP_39_missing_sanctionLimit        ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            12          ${EMPTY}              12           Afd             12
TC_CPDP_40_missing_security             ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            12              ab            ${EMPTY}         Afd             12
TC_CPDP_41_missing_specificLimit        ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            23              ab              12           ${EMPTY}          12
TC_CPDP_42_missing_tenure               ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            23              ab              12             Afd           ${EMPTY}
TC_CPDP_43_missing_appid                ${EMPTY}            abcd     12       Facility            0        Test                   17            Approved            12              ab              12             Afd             12
TC_CPDP_44_digitcount_tenure            ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            11              ab              12             Afd          123.4355
TC_CPDP_45_digitcount_sanctionLimit     ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            12          1234.346            12             Afd             12
TC_CPDP_46_digitcount_security          ${cp_app_id}        abcd     12       Facility            0        Test                   17            Approved            12              ab              12.123         Afd             12
