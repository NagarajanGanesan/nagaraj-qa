#Operators

"""
amount = 1500
tax=amount * 0.18
total=amount + tax

if total>1000:
    discount = total * 0.10
    total -=discount
print(total)


age=60
student='yes'
if age>=60 or student=='yes':
    print("yes discount is available")
else:
    print("no discount") 

"""

a=int(input("Enter input1 :"))
b=str(input("Enter input2 :"))

print(a,b)

#Run time input - like scheduler
import sys

full_name=sys.argv[1]

#format_name
email=full_name.lower().replace(" " , ".") + "@company.com"

#output
print("Generated email:", email)