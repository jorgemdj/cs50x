-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Find crime scene description
SELECT description
FROM crime_scene_reports
WHERE day = 28 AND month = 7 AND year = 2023 AND street = 'Humphrey Street';
-- the crime happened at 10:15 am
-- found that the crime have 3 witnesses and all of them mentioned the bakery

-- Find the interviews of the crime (hope to find 3 interviews and see mentions of bakery)
SELECT id, name, transcript
FROM interviews
WHERE day = 28 AND month = 7 AND year = 2023;
-- Ruth saw run away in a car in the bakery parking lot 10 minutes after the theft. (~10:25)
-- Eugene knew the thief's face. The thief withdraw money from an ATM in the morning before the crime. (Leggett Street)
-- Raymond listened that the thief asked his accomplice to buy the earliest flight in the day after the crime.

-- First list of suspects based on Eugene's interview (withdraw money from ATM at Leggett Street)
SELECT account_number as suspect_account_number, amount
FROM atm_transactions
WHERE day = 28 AND month = 7 AND year = 2023 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw';

-- Finding information about the suspects_account number from bank_accounts and people tables:
SELECT atm_transactions.account_number, people.id, people.name
FROM atm_transactions
    INNER JOIN bank_accounts ON atm_transactions.account_number = bank_accounts.account_number
    INNER JOIN people ON bank_accounts.person_id = people.id
WHERE day = 28 AND month = 7 AND year = 2023 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw';
-- List of suspects: Bruce, Diana, Brooke, Kenny, Iman, Luca, Taylor, Benista

-- List of plates found exiting the bakery from 10:00 and 10:30
SELECT license_plate
FROM bakery_security_logs
WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit';

-- Crossing the plate list with people list by the people.license_plate to compare with actual list of suspects:
SELECT *
FROM people
JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
    WHERE people.license_plate IN (
        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
    )
ORDER BY hour, minute;
-- Suspects remaining(duration in bakery): Bruce(1:55), Diana(1:47), Iman(2:03), Luca(1:05)

-- passport of remaining suspects:
SELECT DISTINCT passport_number
FROM people
JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
    WHERE people.license_plate IN (
        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
        )
        AND (name = 'Bruce' OR name = 'Diana' OR name = 'Iman' OR name = 'Luca')
ORDER BY name;

--list of calls from suspects on the day of the crime:
SELECT *
    FROM phone_calls
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce' OR name = 'Diana' OR name = 'Iman' OR name = 'Luca')
            );
-- there is only 2 differents numbers. now we have to find by the people table who those numbers consern and who was the accomplice (receiver)

SELECT name FROM people
WHERE phone_number IN (
    SELECT caller
    FROM phone_calls
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce' OR name = 'Diana' OR name = 'Iman' OR name = 'Luca')
        )
);

-- now the accomplice suspects:
SELECT name, phone_number FROM people
WHERE phone_number IN (
    SELECT receiver
    FROM phone_calls
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce' OR name = 'Diana' OR name = 'Iman' OR name = 'Luca')
        )
);

-- the remaining suspects are Diana and Bruce and the accomplice suspects are Gregory, Carl, Philip, Robin and Deborah. (Philip is the accomplice in case that Diana is the thief)
-- if Bruce is the thief we have to find who the accomplice is between the others.

--Passport of the remain suspects:
SELECT DISTINCT passport_number
FROM people
JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
    WHERE people.license_plate IN (
        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
        )
        AND (name = 'Bruce' OR name = 'Diana')
ORDER BY name;

-- Finding the thief:
SELECT name as thief FROM people
WHERE passport_number IN (
    SELECT passport_number FROM passengers
    JOIN flights ON passengers.flight_id = flights.id
    WHERE day = 29 AND month = 7 AND year = 2023 AND passport_number IN (
        SELECT DISTINCT passport_number
        FROM people
        JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
            WHERE people.license_plate IN (
                SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                )
                AND (name = 'Bruce' OR name = 'Diana')
    )
    ORDER BY hour, minute
    LIMIT 1
);

-- The thief is Bruce because he got in the first flight of the 28's day. (Diana only got her flight 8 hours after him. The diff is very large.)

-- now the accomplice suspects:
SELECT name, phone_number, passport_number FROM people
WHERE phone_number IN (
    SELECT receiver
    FROM phone_calls
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce')
            )
    );


-- lets found the flihgt that the thief scaped:
SELECT * FROM flights
WHERE id IN (
    SELECT flight_id FROM passengers
    JOIN flights ON passengers.flight_id = flights.id
    WHERE day = 29 AND month = 7 AND year = 2023 AND passport_number IN (
        SELECT DISTINCT passport_number
        FROM people
        JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
            WHERE people.license_plate IN (
                SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                )
                AND (name = 'Bruce')
    )
);

-- find the city that he scaped:
SELECT * FROM airports
WHERE id IN (
    SELECT destination_airport_id FROM flights
    WHERE id IN (
        SELECT flight_id FROM passengers
        JOIN flights ON passengers.flight_id = flights.id
        WHERE day = 29 AND month = 7 AND year = 2023 AND passport_number IN (
            SELECT DISTINCT passport_number
            FROM people
            JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                WHERE people.license_plate IN (
                    SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                    )
                    AND (name = 'Bruce')
        )
    )
);
-- Bruce scaped to New York City

-- searching for flights of the accomplice suspects on the day after the theft
SELECT * FROM passengers
JOIN flights ON passengers.flight_id
JOIN people ON passengers.passport_number = people.passport_number
WHERE
    day = 29
    AND month = 7
    AND year = 2023
    AND destination_airport_id = (
        SELECT id FROM airports
        WHERE id IN (
            SELECT destination_airport_id FROM flights
            WHERE id IN (
                SELECT flight_id FROM passengers
                JOIN flights ON passengers.flight_id = flights.id
                WHERE day = 29 AND month = 7 AND year = 2023 AND passport_number IN (
                    SELECT DISTINCT passport_number
                    FROM people
                    JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                        WHERE people.license_plate IN (
                            SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                            )
                            AND (name = 'Bruce')
                )
            )
        )
    )
    AND passengers.passport_number IN (
        SELECT passport_number FROM people
        WHERE phone_number IN (
            SELECT receiver
            FROM phone_calls
                WHERE
                    day = 28
                    AND month = 7
                    AND year = 2023
                    AND caller IN (
                        SELECT DISTINCT phone_number
                        FROM people
                        JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                            WHERE people.license_plate IN (
                                SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                                )
                                AND (name = 'Bruce')
                    )
            )
    );
-- Now I know that Gregory, Carl and Deborah had a flight to NY in the same day (2023/07/29) at 8:20am

SELECT *
    FROM phone_calls
    JOIN people ON receiver = phone_number
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce')
            );

-- I assume that the accomplice is Carl, because the duration of the call was the shortest (75) in comparison of 120 and 241 of the day of the crime.
-- I assumed that this value represent a second.
-- the witness interview said that the call from the thief had a duration smaller than one minute.


-- checking flights table of the flights of the day 29/06/2023

SELECT * FROM flights
WHERE day = 29 AND month = 7 AND year = 2023 ORDER BY hour, minute;

SELECT * FROM passengers
JOIN flights ON passengers.flight_id
JOIN people ON passengers.passport_number = people.passport_number
WHERE
    day = 29
    AND month = 7
    AND year = 2023
    AND (name = 'Gregory' OR name = 'Carl' OR name = 'Robin' OR name = 'Debora')
    AND destination_airport_id = 4;

SELECT * FROM flights
WHERE
    day > 28
    AND destination_airport_id = 4
    AND flights.id IN (
        SELECT flight_id FROM passengers
        JOIN flights ON passengers.flight_id
        JOIN people ON passengers.passport_number = people.passport_number
        WHERE
            day = 29
            AND month = 7
            AND year = 2023
            AND (name = 'Gregory' OR name = 'Carl' OR name = 'Robin' OR name = 'Debora')
            AND destination_airport_id = 4
        )

ORDER BY day, hour, minute;

SELECT * FROM passengers
JOIN people ON passengers.passport_number = people.passport_number
WHERE flight_id IN (
    SELECT id FROM flights
    WHERE day > 28 AND month = 7 AND year = 2023 AND destination_airport_id = 4
    ORDER BY hour, minute
)
    AND name IN (
        SELECT name FROM people
WHERE phone_number IN (
    SELECT receiver
    FROM phone_calls
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce')
            ))
    );

SELECT name FROM people
WHERE phone_number IN (
    SELECT receiver
    FROM phone_calls
        WHERE
            day = 28
            AND month = 7
            AND year = 2023
            AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce')
            ));

-- checking calls patterns between accomplice suspects:
SELECT * FROM phone_calls
JOIN people ON phone_calls.receiver = people.phone_number
WHERE day > 27 AND month = 7 AND year = 2023 AND caller IN (
                SELECT DISTINCT phone_number
                FROM people
                JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
                    WHERE people.license_plate IN (
                        SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                        )
                        AND (name = 'Bruce'))
ORDER BY month, day, duration;


AND caller IN (
        SELECT DISTINCT phone_number
        FROM people
        JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
            WHERE people.license_plate IN (
                SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2023 AND hour = 10 AND minute < 30 AND activity = 'exit'
                )
                AND (name = 'Carl' OR name = 'Gregory' OR name = 'Deborah' OR name = 'Robin'))
