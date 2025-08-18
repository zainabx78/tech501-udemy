import random

def number_guessing_game(): #function called number_guessing_game
    print("🎲 Welcome to the Number Guessing Game!")
    print("I'm thinking of a number between 1 and 100...")

    # Generate a random number between 1 and 100
    secret_number = random.randint(1, 100)
    guess = None  # Placeholder for user's guess
    attempts = 0  # Count how many guesses the user takes

    while guess != secret_number:
        try:
            guess = int(input("Enter your guess: "))
            attempts += 1

            if guess < secret_number:
                print("Too low! Try again.")
            elif guess > secret_number:
                print("Too high! Try again.")
            else:
                print(f"🎉 Correct! The number was {secret_number}.")
                print(f"You guessed it in {attempts} tries.")
        except ValueError:
            print("⚠️ Please enter a valid number!")

# Start the game
number_guessing_game()
