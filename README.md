# Student Database Management System (MIPS Assembly)

A low-level command-line application written in **MIPS Assembly**. This project demonstrates the implementation of a student database with memory management, recursive algorithms, and system calls handling without the abstraction of high-level languages.

## Features

* **Add Student:** Takes input (ID + 3 grades), calculates the average efficiently, and stores it in a structured array.
* **View Database:** Iterates through memory to display all stored records.
* **Recursive Analysis:** Implements a **recursive algorithm** to find the highest grade in the database, demonstrating manual stack (`$sp`) management.
* **Search:** Locates specific records by ID using linear search.
* **Error Handling:** Validates database capacity boundaries.

## Technical Highlights

* **Memory Structure:** Implements a custom data structure (Struct-like) using raw bytes (8 bytes per student: 4 for ID, 4 for Grade).
* **Stack Management:** Manual manipulation of the Stack Pointer (`$sp`) and Return Address (`$ra`) to support nested and recursive procedure calls.
* **Macros:** Defines reusable Macros for I/O operations to maintain clean code architecture.
* **Bitwise Operations & Arithmetic:** Uses logical shifting and multiplication for efficient memory offset calculations.

## How to Run

1.  Download **MARS (MIPS Assembler and Runtime Simulator)** or **QtSpim**.
2.  Open the `.asm` file.
3.  Assemble and Run.
4.  Interact with the console menu:
    * `1`: Add a new student.
    * `2`: Print all students.
    * `3`: Find max grade (Recursive).
    * `4`: Search by ID.
    * `5`: Exit.

## 📂 Project Structure

* `.data` segment: Static memory allocation for the array and UI strings.
* `.text` segment: Contains the main execution loop and procedures:
    * `getStudentInput`: Handles I/O.
    * `addStudent`: Logic for average calculation and memory storage.
    * `findMaxGradeRecursive`: The recursive logic.
    * `searchByID`: Linear search implementation.

---
*Created by [Your Name]*
