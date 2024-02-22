from cs50 import get_int

while True:
    height = get_int("Height: ")
    if height > 0 and height < 9cd :
        break

for i in range(height):
    h = i + 1
    block = height - h
    print(" "*block, end="")
    print("#"*h, end="  ")
    print("#"*h)
