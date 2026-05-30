# Local variable, Enclosing variable, Global variable, BuildIn

delivery_partner="swiggy"
def hotel():
    order="cake"

    def order_now():
        quantity=3
        print(f"ordering {quantity} {order} using {delivery_partner}")
    order_now()

hotel()
