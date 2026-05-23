*** Settings ***
Resource    ../resources/imports.robot


*** Variables ***
${base_url}=                   http://ip:port/anchor
${CP_base_url}=                http://ip:port/counterParty
${Def_url}=                    http://ip:port/deferralWorkflow
${Auth_url}=                   http://ip:port/auth  
${DMS_Url}=                    http://ip:port

# Status code
${expected_code}=              200
${incorrect_expected_code}=    400
${notFound_exp_code}=          403
${server_err_code}             500

# Validations and Regex
${pan_regex_pattern}=          ^[A-Z]{5}[0-9]{4}[A-Z]{1}$
${Acc_regex_pattern}=          ^[0-9]{8,17}$
${cin_regex_pattern}=          ^[L|U]{1}[0-9]{5}[A-Za-z]{2}[0-9]{4}[A-Za-z]{3}[0-9]{6}$
${gst_regex_pattern}=          ^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$
${Aadhar_regex_pattern}        ^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$
${ifsc_regex_pattern}=         ^[A-Z]{4}0[A-Z0-9]{6}$
${pin_regex_pattern}           ^[1-9]{1}[0-9]{2}\s[0-9]{3}$
${mobile_regex}                ^[6-9]{1}[0-9]{9}$
${exp_name_regex}              ^[A-Za-z\\s]+$
${email_regex}                 ^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$
${expt_anchor_name}=           Right Health Platter Private Limited
${exp_accNum}                  14251617815142
# Anchor ID's
${Anchor_cust_id}               5
${Anchor_App_id}                12170    

# CounterParty ID's
${cp_app_id}                    14898

# Dictionary variables 

&{CP_TermSheet}=       custId=${Anchor_cust_id}      product=Dealer Invoice Finance        creditPeriod=60       applyOfInterest=Rear      interestBorneBy=Counterparty     penaltyBorneBy=Counterparty       regularLimit=12     adhocLimit=12       doorToDoor=70     invoiceAgeing=28     margin=20       interestRate=20     pf=5       renewal=6     interestRateType=Flat    renewalPeriod=10    invoiceFunding=80    graceDays=4              
&{CP_Collateral_detail_entry1}=   value=Test1   cmId=2295   appId=1088
&{CP_Collateral_detail_entry2}=   value=${EMPTY}  cmId=2293   appId=1088
&{CP_Duediligence_details_entry1}=  value=Test   ddId=2253   appId=1088
&{CP_Duediligence_details_entry2}=  value=${EMPTY}  ddId=2260   appId=1088
&{cp_Basic_details}=         activity=Traders  anchorRelationShip=Vendor  appId=15873  assessmentType=Financial   cinNumber=L17110MH1973PLC019745    city=Chennai    companyName=HK Tyres  constitution=Private Company    createdBy=Tester    cusContName=Ganesh    cusContactEmail=sample.user@gmail.com    cusContactNumber=9823785687    custId=139    gstNumber=24APACC1446D2ZK    id=0    panNumber=IHJGH1234G    rmName=Abhishek Sharma     source=Direct   state=Tamil Nadu    subSource=Website    totalInwardCheques=12    updatedBy=Tester 
&{Cp_Debt_Profile}=          appId=${cp_app_id}     bankFI=Bank    emi=1000     facilityType=Yes    id=0    interestRate=10    outstandingOnDate=10    remarks=string    sanctionDate=10-    sanctionLimit=1000    security=Yes    specificLimit=10000    tenure=10
&{Anchor_customerinfodetail_crtdata}=   customerName=Riya   product=SCF     pan=JKOOL9087G     cin=L09374KA2010PTC096675   status=Active

# &{dictionary}=    client_id=ThinkIAM   client_secret=Cj7d397ypEqNxOmzZUes74JCY8ssVhuq   scope=openid   grant_type=password  username=${username}    password=sample_password

&{CP_LimitEligible}=      custId=${Anchor_cust_id}     product=Purchase Bill      anchorName= Jk Tyres    creditPeriod=45   loginLimitAmount=100000    currentLimit=1     proposedLimit=1     eligibleLimit=1     adhocLimit=1     invoiceAgeing=1     doortoDoor=1     expectedGrowth=1     monthlyAverage=1     approtionedLimits=1     existingScfLimits=1     modelLimit=1     anchorRecommendedAmount=1     receivables=1     inventory=1     creditor=1     expectedMonthlyTurnOverWithAnchor=1     modelAdhocLimit=1