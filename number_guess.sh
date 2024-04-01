#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

ALGORITHM() {
  read NUMBER
  NUMBER_OF_GUESSES=0
  while [[ $NUMBER -ne $RANDOM_NUMBER ]]
    do
      if [[ ! $NUMBER =~ ^-?[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
        NUMBER_OF_GUESSES=`expr $NUMBER_OF_GUESSES + 1`
      else
        if [[ $NUMBER -lt $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          NUMBER_OF_GUESSES=`expr $NUMBER_OF_GUESSES + 1`
        elif [[ $NUMBER -gt $RANDOM_NUMBER ]]
        then
          echo "It's lower than that, guess again:"
          NUMBER_OF_GUESSES=`expr $NUMBER_OF_GUESSES + 1`
        fi
      fi
      read NUMBER
    done
  NUMBER_OF_GUESSES=`expr $NUMBER_OF_GUESSES + 1`

}

echo "Enter your username:"
read NAME

# get username
USERNAME=$($PSQL "SELECT username FROM users WHERE username='$NAME'")
# if not found
if [[ -z $USERNAME ]] 
then
  # save new user
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")
  # output
  echo "Welcome, $NAME! It looks like this is your first time here."
  # get user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$NAME'")
  # guess number
  echo $RANDOM_NUMBER
  echo "Guess the secret number between 1 and 1000:"
  # algorithm
  ALGORITHM
  # Insert results in database
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

else # if found
  # get user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$NAME'")
  # get user_history
  GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  # output
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  # guess number
  echo $RANDOM_NUMBER
  echo "Guess the secret number between 1 and 1000:"
  # algorithm
  ALGORITHM
  # Insert results in database
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
fi
