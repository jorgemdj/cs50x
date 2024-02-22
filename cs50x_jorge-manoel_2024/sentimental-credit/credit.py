from cs50 import get_string

number_card = get_string("Number: ")

valid_len = [13, 15, 16]
total_sum = 0

if len(number_card) in valid_len:

    for i in range(len(number_card) - 1, -1, -2):
        total_sum += int(number_card[i])

    for i in range(len(number_card) - 2, -1, -2):
        partial_sum = int(number_card[i]) * 2
        if partial_sum < 10:
            total_sum += partial_sum
        else:
            for n in str(partial_sum):
                total_sum += int(n)

    print(total_sum)

    if total_sum % 10 == 0:
        if number_card[0] == "4" and (len(number_card) == 13 or len(number_card) == 16):
            print("VISA")
        elif int(number_card[0:2]) in range(51, 56) and len(number_card) == 16:
            print("MASTERCARD")
        elif int(number_card[0:2]) in [34, 37] and len(number_card) == 15:
            print("AMEX")
        else:
            print("INVALID")
    else:
        print("INVALID")

else:
    print("INVALID")
