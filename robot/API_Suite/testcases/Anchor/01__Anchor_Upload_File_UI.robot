*** Settings ***
Documentation     A test suite for anchor file upload
Library           SeleniumLibrary  

*** Variables ***
${browser}        chrome
&{url}            QA1=http://ip:port/triton/index.html     QA2=http://ip:port/triton/index.html
${anchorName}=    Bumble Bee
${pan}=           BUMFG4151Z  
${cin}=           U13445SS9312PLB156733

*** Test Cases ***
Test_Anchor_File_Upload_in_UI
    [Documentation]    Anchor file Upload in UI
    Set Selenium Implicit Wait    10 seconds
    Open Browser and login to Triton
    De_Dupe check
    Upload File
    Check in Anchor details
    Logout and close browser

*** Keywords ***
Open Browser and login to Triton
    Open Browser    ${url.QA1}    ${browser}
    Maximize Browser Window
    Set Selenium Implicit Wait    10 seconds
    Input Text      xpath://input[@formcontrolname='email']       cpa_lead
    Input Text      xpath://input[@formcontrolname='password']    admin@1234
    Click Element   xpath://span[text()='Login']
    
De_Dupe check
    Click Element   xpath://span[text()='New Anchor']
    Input Text      name:anchorName2    ${anchorName}
    Input Text      name:panNumber2    ${pan}
    Input Text      name:cinNumber2    ${cin}
    Execute Javascript    window.scrollTo(0,500)
    Click Element   xpath://button[text()='De-Dupe']
    Click Element    xpath:(//div[@class='ng-star-inserted']//child::button)[1]
    Wait Until Page Contains     New Anchor

Upload File
    Click Element    xpath://input[@class="form-control"]
    Choose File      xpath://input[@class="form-control"]    ${CURDIR}\\NewAnchorFile.xlsx
    Click Element    xpath://button[text()='Upload']
    Input Text       xpath://textarea[@class='swal2-textarea']     Anchor onboard file
    Click Element    xpath://button[text()='Submit']


Check in Anchor details
    Click Element    xpath://span[text()='Anchor Details']
    Element Should Be Visible    xpath://td[text()='${anchorName}']
    Log To Console    File uploaded

Logout and close browser
    Mouse Over      xpath://*[text()='Admin ']
    Click Element   xpath://span[text()='Log Out']
    Close Browser




