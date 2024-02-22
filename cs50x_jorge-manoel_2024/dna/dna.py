import csv
import sys


def main():

    # TODO: Check for command-line usage
    if len(sys.argv) != 3:
        print("Usage: dna.py database.csv sequence.txt\n")
        return

    # TODO: Read database file into a variable
    database_file = open(sys.argv[1])
    databases = csv.DictReader(database_file)

    database = []
    for data in databases:
        database.append(data)

    data_subsequences = []
    for i in data:
        data_subsequences.append(i)
    data_subsequences = data_subsequences[1:]

    # TODO: Read DNA sequence file into a variable
    sequence_file = open(sys.argv[2])
    sequence = csv.reader(sequence_file)
    sequence_txt = []
    for line in sequence:
        sequence_txt.append(line)
    dna_sequence = sequence_txt[0][0]

    # TODO: Find longest match of each STR in DNA sequence
    match_list = [0] * len(data_subsequences)

    for i in range(len(data_subsequences)):
        match_list[i] = longest_match(dna_sequence, data_subsequences[i])

    # TODO: Check database for matching profiles
    for person in database:
        check_ID = len(data_subsequences)
        for i in range(len(data_subsequences)):
            if match_list[i] == int(person[data_subsequences[i]]):
                check_ID -= 1
        if check_ID == 0:
            print(person["name"])
            break
    else:
        print("No match")


    return


def longest_match(sequence, subsequence):
    """Returns length of longest run of subsequence in sequence."""

    # Initialize variables
    longest_run = 0
    subsequence_length = len(subsequence)
    sequence_length = len(sequence)

    # Check each character in sequence for most consecutive runs of subsequence
    for i in range(sequence_length):

        # Initialize count of consecutive runs
        count = 0

        # Check for a subsequence match in a "substring" (a subset of characters) within sequence
        # If a match, move substring to next potential match in sequence
        # Continue moving substring and checking for matches until out of consecutive matches
        while True:

            # Adjust substring start and end
            start = i + count * subsequence_length
            end = start + subsequence_length

            # If there is a match in the substring
            if sequence[start:end] == subsequence:
                count += 1

            # If there is no match in the substring
            else:
                break

        # Update most consecutive matches found
        longest_run = max(longest_run, count)

    # After checking for runs at each character in seqeuence, return longest run found
    return longest_run


main()
