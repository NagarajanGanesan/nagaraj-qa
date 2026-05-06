*** Settings ***
Resource     ../../keywords/common.robot

*** Keywords ***
create_codeValue
    ${comServ_url}=    Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session     code_value    ${comServ_url}:${comServ_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${api_data}=    Create List
    ...    ${{ [1, 'Savings'] }}
    ...    ${{ [2, 'DEBT'] }}
    ...    ${{ [3, 'Equity'] }}
    # ... add the rest of your 28 items here
    
    FOR    ${item}    IN    @{api_data}
        # 1. Extract values from the current row
        ${id}=      Set Variable    ${item[0]}
        ${name}=    Set Variable    ${item[1]}
        
        # 2. Build the dynamic JSON body
        ${body}=    Create Dictionary    codesId=${id}    name=${name}    status=${True}
        
        # 3. Hit the POST API
        ${response}=    POST On Session    code_value    /api/v1/code-value    
        ...    json=${body}    
         ...   headers=${headers}    
        ...    expected_status=${expected_code}
        
        Log To Console    Sent ID: ${id} Name: ${name} -> Received: ${response.status_code}
    END

# *** Test Cases ***
# TC01_Post_API_CodeValue
#     create_codeValue
    