*** Settings ***
Resource    ../resources/imports.robot


*** Variables ***
# Override at runtime:  robot --variable ENV:qa  OR  robot --variable ENV:local
${ENV}             qa
${schemeName}      xxx

${LOCAL_URL}       http://localhost
${DEV_URL}         https://your-dev-hostname.example.com
${QA_URL}          http://your-qa-server-ip
${URL}             https://your-db_name-hostname.example.com

&{URL_CONFIGS}     local=${LOCAL_URL}    dev=${DEV_URL}     qa=${QA_URL}

&{DB_CONFIGS}      local=&{Local_DB}     dev=&{DEV_DB}      qa=&{QA_DB}

${comServ_port}    xxxx
${gateway_port}    xxxx
${Auth_port}       xxxx
${login_port}      xxxx
${los_port}        xxxx
${fac_port}        xxxx
${bank_port}       xxxx
${fetch_port}      xxxx
${secrets_port}    xxxx

&{comServ_url}     local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1                                  
&{gateway_url}     local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1       
&{Auth_url}        local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1
&{login_url}       local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1              

&{los_url}         local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1
&{fac_url}         local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1
&{bank_url}        local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1

&{fetch_url}       local=${LOCAL_URL}:xxxx/api/v1     dev=${DEV_URL}:xxxx/api/v1     qa=${QA_URL}:xxxx/api/v1

&{Local_DB}        name=db_userName    Username=db_userName      Password=your_local_db_password     Host=localhost            Port=xxxx     db_charset=None
&{Dev_DB}          name=db_name     Username=db_name_app   Password=your_dev_db_password       Host=your-dev-db-host    Port=xxxx     db_charset=None
&{QA_DB}           name=db_name     Username=db_name_qa    Password=your_qa_db_password        Host=your-qa-db-host     Port=xxxx     db_charset=None

# =============================================================
# Gateway Platform — one-time config IDs
# Run TC01_OneTime_Setup / TC02_OneTime_Setup once, then fill
# these values with the printed IDs before running regression.
# =============================================================

# TC01: app_code_creation=True (app-code / RBAC mode)
${gw_tc01_service_id}       20
${gw_tc01_channel_id}       204
${gw_tc01_channel_path}     /lender-0817
${gw_tc01_app_code}         your-tc01-app-code-uuid
${gw_tc01_client_id}        your-tc01-client-id
${gw_tc01_api_key}          your-tc01-api-key-hex-64chars
${gw_tc01_app_id}           12

# TC02: app_code_creation=False (product / HMAC mode)
${gw_tc02_service_id}       21
${gw_tc02_channel_id}       204
${gw_tc02_channel_path}     /lender-0817
${gw_tc02_product_id}       2
${gw_tc02_client_id}        your-tc02-client-id
${gw_tc02_api_key}          your-tc02-api-key-hex-64chars

# TC03: app_code_creation=True, decryption=True (RBAC + decrypt mode)
${gw_tc03_service_id}       ${EMPTY}
${gw_tc03_channel_id}       ${EMPTY}
${gw_tc03_channel_path}     ${EMPTY}
${gw_tc03_app_code}         ${EMPTY}
${gw_tc03_client_id}        ${EMPTY}
${gw_tc03_api_key}          ${EMPTY}

# TC04: app_code_creation=False, decryption=False (product / HMAC mode)
${gw_tc04_service_id}       ${EMPTY}
${gw_tc04_channel_id}       ${EMPTY}
${gw_tc04_channel_path}     ${EMPTY}
${gw_tc04_product_id}       ${EMPTY}
${gw_tc04_client_id}        ${EMPTY}
${gw_tc04_api_key}          ${EMPTY}

# TC05: app_code_creation=False, decryption=True (product / HMAC + decrypt mode)
${gw_tc05_service_id}       ${EMPTY}
${gw_tc05_channel_id}       ${EMPTY}
${gw_tc05_channel_path}     ${EMPTY}
${gw_tc05_product_id}       ${EMPTY}
${gw_tc05_client_id}        ${EMPTY}
${gw_tc05_api_key}          ${EMPTY}

# Status code
${Created_code}=                201
${expected_code}=               200
${incorrect_expected_code}=     400
${notFound_exp_code}=           404
${server_err_code}=             500
${unauthorized_code}=           401

#MongoDB
${MONGODB_URL}          mongodb://localhost:xxxx/
${MONGODB_NAME}         db_name_db

# Validations and Regex
# Should Match Regexp	${output}	\d{6}	# Output contains six numbers	
# Should Match Regexp	${output}	^\d{6}$	# Six numbers and nothing more	
${pan_regex_pattern}=           ^[A-Z]{5}[0-9]{4}[A-Z]{1}$
${Acc_regex_pattern}=           ^[0-9]{8,17}$
${cin_regex_pattern}=           ^[L|U]{1}[0-9]{5}[A-Za-z]{2}[0-9]{4}[A-Za-z]{3}[0-9]{6}$
${gst_regex_pattern}=           ^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$
${Aadhar_regex_pattern}         ^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$
${ifsc_regex_pattern}=          ^[A-Z]{4}0[A-Z0-9]{6}$
${pin_regex_pattern}            ^[1-9]{1}[0-9]{2}\s[0-9]{3}$
${mobile_regex}                 ^[6-9]{1}[0-9]{9}$
${exp_name_regex}               ^[A-Za-z\\s]+$
${email_regex}                  ^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$
