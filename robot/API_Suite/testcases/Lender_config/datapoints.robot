*** Settings ***
Resource     ../../keywords/common.robot
Library      ../../resources/datapoints.py

*** Keywords ***
create_dataPoints
    ${comServ_url}=   Get From Dictionary    ${URL_CONFIGS}    ${ENV}
    Create Session    data_points    ${comServ_url}:${comServ_port}
    ${headers}=        Create Dictionary    Content-Type=application/json
    
   FOR    ${api_name}    ${payload}    IN    &{API_DATA}
        Log To Console    \nTesting API: ${api_name}
        
        # Add the status field to the dictionary
        Set To Dictionary    ${payload}    status=${True}
        
        # Hit the API - No 'Evaluate' or 'json.loads' needed!
        ${response}=    POST On Session    data_points    /api/v1/data-points    
        ...    json=${payload}    
        ...    headers=${headers}
        ...    expected_status=${expected_code}
        
        # Assertion for your negative test
        Status Should Be    200    ${response}
    END

# *** Test Cases ***
# TC01_Post_API_DataPoints
#     create_dataPoints
    