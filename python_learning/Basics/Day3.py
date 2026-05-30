#String
message = "your booking id : XYZ123.Please tell for confirmation"
id=message.split(":")[1].split(".")[0].strip()
#strip - remove space
print(id)