#!/bin/bash

# File paths
BOOKS_FILE="books.txt"
BORROWED_FILE="borrowed.txt"
USERS_FILE="users.txt"

# Initialize files if they don't exist
touch $BOOKS_FILE $BORROWED_FILE $USERS_FILE

# Function to hash passwords
hash_password() {
    echo -n "$1" | sha256sum | awk '{print $1}'
}

# User registration
register() {
    echo "Enter username:"
    read username
    if grep -q "^$username:" $USERS_FILE; then
        echo "Username already exists. Please choose another username."
        return
    fi

    echo "Enter password:"
    read -s password
    echo "Confirm password:"
    read -s password_confirm

    if [ "$password" != "$password_confirm" ]; then
        echo "Passwords do not match. Registration failed."
        return
    fi

    echo "Enter user type (Librarian/Student/Admin):"
    read user_type

    if [[ "$user_type" != "Librarian" && "$user_type" != "Student" && "$user_type" != "Admin" ]]; then
        echo "Invalid user type. Registration failed."
        return
    fi

    hashed_password=$(hash_password "$password")
    echo "$username:$hashed_password:$user_type" >> $USERS_FILE
    echo "Registration successful."
}

# User login
login() {
    echo "Enter username:"
    read username
    echo "Enter password:"
    read -s password

    hashed_password=$(hash_password "$password")

    if grep -q "^$username:$hashed_password:" $USERS_FILE; then
        user_type=$(grep "^$username:$hashed_password:" $USERS_FILE | cut -d':' -f3)
        echo "Login successful."
        main_menu $user_type
    else
        echo "Invalid username or password."
    fi
}

# Functions for Librarian
add_book() {
    echo "Enter book title:"
    read title
    echo "Enter book author:"
    read author
    echo "$title by $author" >> $BOOKS_FILE
    echo "Book added."
}


remove_book(){
    echo "Enter the name of the book you want to remove: "
    read book_name
    sed -i "/$book_name/d" books.txt
    echo "Book removed successfully"
}
see_books() {
    echo "Books available:"
    cat $BOOKS_FILE
}

# Functions for Student
see_books_student() {
    see_books
}

borrow_book() {
    echo "Enter your name:"
    read name
    echo "Enter book title to borrow:"
    read title
    if grep -q "^$title by" $BOOKS_FILE; then
        echo "$name borrowed $title" >> $BORROWED_FILE
        grep -v "^$title by" $BOOKS_FILE > temp.txt && mv temp.txt $BOOKS_FILE
        echo "Book borrowed."
    else
        echo "Book not available."
    fi
}

submit_book() {
    echo "Enter your name:"
    read name
    echo "Enter book title to submit:"
    read title
    if grep -q "$name borrowed $title" $BORROWED_FILE; then
        grep -v "$name borrowed $title" $BORROWED_FILE > temp.txt && mv temp.txt $BORROWED_FILE
        echo "$title" >> $BOOKS_FILE
        echo "Book submitted."
    else
        echo "You did not borrow this book."
    fi
}

# Functions for Admin
edit_books() {
    echo "Enter book title to edit:"
    read old_title
    echo "Enter new book title:"
    read new_title
    echo "Enter new book author:"
    read new_author
    sed -i "s/^$old_title.*/$new_title by $new_author/" $BOOKS_FILE
    echo "Book edited."
}

see_borrowed_books() {
    echo "Borrowed books:"
    cat $BORROWED_FILE
}

see_student_list() {
    echo "Student list:"
    cut -d ' ' -f 1 $BORROWED_FILE | sort | uniq
}

# Main menu based on user type
main_menu() {
    user_type=$1


while true; do
        if [ "$user_type" == "Librarian" ]; then
            echo "Librarian options: (1) Add Book (2) Remove Book (3) See Books (4) Logout"
            read librarian_option
            case $librarian_option in
                1) add_book ;;
                2) remove_book ;;
                3) see_books ;;
                4) break ;;
                *) echo "Invalid option" ;;
            esac
        elif [ "$user_type" == "Student" ]; then
            echo "Student options: (1) See Books (2) Borrow Book (3) Submit Book (4) Logout"
            read student_option
            case $student_option in
                1) see_books_student ;;
                2) borrow_book ;;
                3) submit_book ;;
                4) break ;;
                *) echo "Invalid option" ;;
            esac
        elif [ "$user_type" == "Admin" ]; then
            echo "Admin options: (1) Edit Books (2) See Borrowed Books (3) See Student List (4) Logout"
            read admin_option
            case $admin_option in
                1) edit_books ;;
                2) see_borrowed_books ;;
                3) see_student_list ;;
                4) break ;;
                *) echo "Invalid option" ;;
            esac
        fi
    done
}

# Initial menu for registration or login
while true; do
    echo "Library Management System"
    echo "1. Register"
    echo "2. Login"
    echo "3. Exit"
    read option

    case $option in
        1) register ;;
        2) login ;;
        3) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done