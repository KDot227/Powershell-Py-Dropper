import random

class main:
    def __init__(self) -> None:
        self.random_number = random.randint(1, 100)
        self.main()
    def main(self) -> None:
        while True:
            try:
                user_input = int(input("Enter a number: "))
                if user_input == self.random_number:
                    print("You guessed the number!")
                    break
                elif user_input > self.random_number:
                    print("The number is lower than that!")
                elif user_input < self.random_number:
                    print("The number is higher than that!")
            except ValueError:
                print("Please enter a number!")
                continue

if __name__ == "__main__":
    main()