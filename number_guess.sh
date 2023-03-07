#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# number and count
RANDOM_NUM=$(( $RANDOM % 1000 + 1 ))
GUESS_COUNT=0

# get username
echo "Enter your username:"
read USER
USER_CHECK=$($PSQL "SELECT username, games_played, best_game FROM user_data WHERE username = '$USER'")

# if username is found

if [[ -n $USER_CHECK ]]
then
echo $USER_CHECK | while IFS=\| read USERNAME GAMES_PLAYED BEST_GAME
do
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
# update games played
((GAMES_PLAYED=$GAMES_PLAYED + 1))
ADD_GAME=$($PSQL "UPDATE user_data SET games_played = $GAMES_PLAYED WHERE username = '$USER'")
done
fi

# if username is not found

if [[ -z $USER_CHECK ]]
then
echo "Welcome, $USER! It looks like this is your first time here."
ADD_USER=$($PSQL "INSERT INTO user_data(username, games_played) VALUES('$USER', 1)")
fi

# guess number

echo "Guess the secret number between 1 and 1000:"
GUESS_FUNC() {

read GUESS
((GUESS_COUNT=$GUESS_COUNT + 1))

  # wrong guess

    # if not int
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
    echo "That is not an integer, guess again:"
    GUESS_FUNC
    fi

    # if too high
    if (( $GUESS > $RANDOM_NUM ))
    then 
    echo "It's lower than that, guess again:"
    GUESS_FUNC
    fi
  
    # if too low
    if (( $GUESS < $RANDOM_NUM )) 
    then
    echo "It's higher than that, guess again:"
    GUESS_FUNC
    fi
}

if (( $GUESS_COUNT == 0 ))
then
GUESS_FUNC
fi

# correct guess

# update best game
BEST_ROUND=$($PSQL "SELECT best_game FROM user_data WHERE username = '$USER'")
if [[ ( $GUESS_COUNT < $BEST_ROUND ) || ( -z $BEST_ROUND ) ]]
then
ADD_BEST_GAME=$($PSQL "UPDATE user_data SET best_game = $GUESS_COUNT WHERE username = '$USER'")
fi
echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
