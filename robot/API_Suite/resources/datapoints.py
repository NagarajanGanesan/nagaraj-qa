# api_payloads.py

def get_variables():
    # This dictionary stores all your 28 API structures
    payloads = {
        "pan": {
            "dataPointName": "pan",
            "displayName": "pan",
            "dataType": 1,
            "regex": "^[A-Z]{5}[0-9]{4}[A-Z]$"
        },
        "email": {
            "dataPointName": "email",
            "displayName": "email",
            "dataType": 1,
            "regex": "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,6}$"
        },
        "contactNo": {
            "dataPointName": "contactNo",
            "displayName": "contactNo",
            "dataType": 1,
            "regex": r"\d{10,15}"  # 'r' prefix handles regex backslashes perfectly
        },
        # "accountType": {
        #     "dataPointName": "accountType",
        #     "displayName": "accountType",
        #     "dataType": 2,
        #     "codesId": {"id": 1,
        #     "name": "accountType"}
        # }
    }
    return {"API_DATA": payloads}