from pymongo import MongoClient
from bson.objectid import ObjectId

class MongoManager:

    CONFIGS = {
        "local": {"uri": "mongodb://localhost:27017", "db": "loan_origination"},
        "dev": {"uri": "mongodb://your_dev_mongo_user:your_dev_mongo_password@your-dev-db-host:4047/xxx.banking-log?authSource=xxx", "db": "xxx"},
        "qa":  {"uri": "mongodb://your_qa_mongo_user:your_qa_mongo_password@your-qa-db-host:4049/xxx.banking-log?authSource=xxx",  "db": "xxx"},
    }

    def __init__(self, env="dev"):
        if env not in self.CONFIGS:
            raise ValueError(f"Environment '{env}' is not defined in CONFIGS")

        current_config = self.CONFIGS[env]
        self.client = MongoClient(current_config['uri'])
        self.db = self.client[current_config['db']]
        print(f"Connected to {env} - DB: {current_config['db']}")

    # ---------- Generic Collection Getter ----------
    def get_collection(self, collection_name):
        return self.db[collection_name]
    
    #Customer_Table
    def get_panNo_mobileNo_for_dedupe(self):
        col = self.get_collection("customer")
        doc = col.find(
            {},
            {"pan": 1, "mobile_number": 1, "_id": 0})
        return list(doc)

    def get_platform_customer_id_by_pan(self, pan):
        col = self.get_collection("customer")
        doc = col.find(
            {"pan": pan},
            {"platform_customer_id": 1}
        ).sort("created_at", -1).limit(1)[0]
        return str(doc["platform_customer_id"])

    def get_customer_id_by_pan(self, pan):
        col = self.get_collection("customer")
        doc = col.find(
            {"pan": pan},
            {"_id": 1}
        ).sort("created_at", -1).limit(1)[0]
        return str(doc["_id"])

    def get_loan_app_id_by_loan_number(self, loan_application_no):
        col = self.get_collection("loan_applications")
        doc = col.find(
            {"loan_application_no": loan_application_no},
            {"_id": 1}
        ).sort("_id", -1).limit(1)[0]
        return str(doc["_id"])

    #Lender_Customer_Id - Customer Lender Mapping Table
    def get_lender_customer_id_by_customer_id(self, customer_id):
        col = self.get_collection("customer_lender_mapping")
        doc = col.find(
            {"customer_id": customer_id},
            {"lender_customer_id": 1}
        ).sort("lender_customer_id", -1).limit(1)[0]
        return str(doc["lender_customer_id"])
    
    #Loan Application ID - Loan Application Table
    #Note - Using in 02_create_LoanAppBy_Pan.robot
    def get_loan_app_no_by_customer_id(self, customer_id):
        col = self.get_collection("loan_applications")
        doc = col.find(
            {"customer_id": customer_id},
            {"loan_application_no": 1}
        ).sort("loan_application_no", -1).limit(1)[0]
        return str(doc["loan_application_no"])

    def get_latest_loan_app_id(self):
        col = self.get_collection("loan_applications")
        doc = col.find({}, {"_id": 1}) \
        .sort("_id", -1) \
        .limit(1)[0]
        return str(doc["_id"])

    # Note - Using in 03_createLoanBy_lendCustID.robot
    def get_latest_loan_app_no(self, loan_app_id):
        col = self.get_collection("loan_applications")
        query_id = ObjectId(loan_app_id)
        result = col.find_one({"_id": query_id}, {"loan_application_no": 1})
        return result.get("loan_application_no") if result else None

    #Get bank Account number by customer bank details table
    def get_bankAccount_number_for_validate(self):
        col = self.get_collection("customer_bank_account_details")
        doc = col.find(
            {},
            {"bank_account_number": 1, "_id": 0})
        return list(doc)

    def close_connection(self):
        self.client.close()

