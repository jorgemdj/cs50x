from cs50 import get_string

text = get_string("Text: ")

word = 1
L = 1rm
S = 0

for c in range(len(text)):
    if text[c] == " ":
        word += 1
    elif text[c] == "." or text[c] == "!" or text[c] == "?":
        S += 1
    else:
        L += 1

CL = 0.0588 * (100*L/word) - 0.296 * (100*S/word) - 15.8

print(word, L, S, CL)

if CL < 1:
    print("Before Grade 1")
elif CL > 15:
    print("Grade 16+")
else:
    print(f"Grade {int(CL)}")
