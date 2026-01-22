# Student Database Management System
# Structure: 8 bytes per student (4 bytes ID, 4 bytes Average Grade)
# Max Students: 10
# ---------------------------------------------------------
# DATA SEGMENT
# ---------------------------------------------------------
.data
    student_db:    .space 80       # Space for 10 students (10 * 8 bytes)
    current_count: .word 0         # Current number of students in DB

    # UI Strings
    menu:          .asciiz "\n--- Student Menu ---\n1. Add Student\n2. View All\n3. Find Max (Recursive)\n4. Search by ID\n5. Exit\nChoose: "
    prompt_id:     .asciiz "Enter Student ID: "
    prompt_g1:     .asciiz "Enter Grade 1: "
    prompt_g2:     .asciiz "Enter Grade 2: "
    prompt_g3:     .asciiz "Enter Grade 3: "
    err_full:      .asciiz "\nError: Database Full!\n"
    header:        .asciiz "\nID\t\tGrade\n----------------------------\n"
    line_id:       .asciiz "\nID: "
    line_grade:    .asciiz "\tGrade: "
    max_res:       .asciiz "\nHighest Grade found: "
    search_p:      .asciiz "Enter ID to search: "
    not_found:     .asciiz "Student not found.\n"
    found_msg:     .asciiz "Student Grade: "
    newline:       .asciiz "\n"
    no_students_yet: .asciiz "No student in array at all! \n"

# ---------------------------------------------------------
# MACROS
# ---------------------------------------------------------
.macro print_str(%label)
    li $v0, 4
    la $a0, %label
    syscall
.end_macro

.macro read_int(%reg)
    li $v0, 5
    syscall
    move %reg, $v0
.end_macro

.macro print_int(%reg)
    li $v0, 1
    move $a0, %reg
    syscall
.end_macro

# ---------------------------------------------------------
# CODE SEGMENT
# ---------------------------------------------------------
.text
.globl main

main:
    print_str(newline)
    print_str(menu)
    read_int($t0)
    
    beq $t0, 1, call_add
    beq $t0, 2, call_view
    beq $t0, 3, call_max
    beq $t0, 4, call_search
    beq $t0, 5, exit_prog
    j main

call_add:
    jal getStudentInput
    j main

call_view:
    jal printAll
    j main

call_max:
    lw $a1, current_count
    blez $a1, main             # If empty, skip
    la $a0, student_db         # Load address of array start
    jal findMaxGradeRecursive
    
    move $t1, $v0              # Save result
    print_str(max_res)
    print_int($t1)
    print_str(newline)
    j main

call_search:
    print_str(search_p)
    read_int($a0)
    jal searchByID
    j main

exit_prog:
    li $v0, 10
    syscall

# ---------------------------------------------------------
# PROCEDURE: getStudentInput
# ---------------------------------------------------------
getStudentInput:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    print_str(prompt_id)
    read_int($t0)

    print_str(prompt_g1)
    read_int($t1)

    print_str(prompt_g2)
    read_int($t2)

    print_str(prompt_g3)
    read_int($t3)

    move $a0, $t0
    move $a1, $t1
    move $a2, $t2
    move $a3, $t3

    jal addStudent

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ---------------------------------------------------------
# PROCEDURE: addStudent
# Params: $a0=ID, $a1=G1, $a2=G2, $a3=G3
# ---------------------------------------------------------
addStudent:
    li $t3, 3
    lw $t4, current_count 
    beq $t4, 10, arr_full  # Max 10 students
    
    # Calculate offset (index * 8 bytes)
    mul $t4, $t4, 8 

    # Calculate Average
    add $t0, $a1, $a2
    add $t0, $t0, $a3
    div $t0, $t3
    mflo $v0

    # Save to Array
    sw $a0, student_db($t4)      # Store ID
    addi $t4, $t4, 4
    sw $v0, student_db($t4)      # Store Grade

    # Increment Count
    lw $t5, current_count   
    addi $t5, $t5, 1
    sw $t5, current_count

    jr $ra

arr_full: 
    print_str(err_full)
    jr $ra

# ---------------------------------------------------------
# PROCEDURE: printAll
# ---------------------------------------------------------
printAll:
    lw $t0, current_count
    li $t1, 0      # loop counter
    li $t2, 0      # array offset pointer

loop_print:    
    beq $t1, $t0, end_print_loop
    
    # Print ID
    print_str(line_id)
    lw $t4, student_db($t2)
    print_int($t4)
    
    # Print Grade
    print_str(line_grade)
    addi $t2, $t2, 4
    lw $t5, student_db($t2)
    print_int($t5)
    
    # Advance pointers
    addi $t1, $t1, 1
    addi $t2, $t2, 4   # Advance 4 more bytes (total 8 per student)
    j loop_print
    
end_print_loop:
    print_str(newline)
    jr $ra

# ---------------------------------------------------------
# PROCEDURE: findMaxGradeRecursive (RECURSIVE)
# Params: $a0 = Array Pointer, $a1 = Count (n)
# Returns: $v0 = Max Grade
# ---------------------------------------------------------
findMaxGradeRecursive:
    # Base Case: if (n == 1) return array[0].grade
    li $t0, 1
    beq $a1, $t0, base_case_max

    # Recursive Step:
    # Save context to stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)      # Save current array pointer
    sw $a1, 8($sp)      # Save current count

    # Prepare for next call: findMax(arr + 8, n - 1)
    addi $a0, $a0, 8    # Move pointer to next student
    addi $a1, $a1, -1   # Decrement count
    jal findMaxGradeRecursive

    # On return: $v0 holds the max of the "rest" of the array
    
    # Restore current student pointer
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12   # Restore stack pointer
    
    # Get current student's grade
    lw $t1, 4($a0)      # Grade is at offset 4
    
    # Compare current grade ($t1) with max of rest ($v0)
    bgt $t1, $v0, update_max
    jr $ra              # If current is not greater, return existing max

update_max:
    move $v0, $t1       # Update max to current
    jr $ra

base_case_max:
    lw $v0, 4($a0)      # Load grade of the single student (offset 4)
    jr $ra

# ---------------------------------------------------------
# PROCEDURE: searchByID
# Params: $a0 = Target ID
# ---------------------------------------------------------
searchByID:
    li $t0, 0              # offset
    li $t1, 0              # counter
    li $t2, 0              # temp id from array
    lw $t3, current_count  # loop limit

loop_find_id:   
    beqz $t3, no_students
    beq $t1, $t3, stu_not_found  # FIXED: added comma

    lw $t2, student_db($t0)
    beq $t2, $a0, found_id
    
    addi $t1, $t1, 1
    addi $t0, $t0, 8
    j loop_find_id

no_students:
    print_str(no_students_yet)
    print_str(newline)
    jr $ra

found_id:
    print_str(found_msg)
    addi $t0, $t0, 4       # Move to grade offset
    lw $t0, student_db($t0)
    print_int($t0)
    print_str(newline)
    jr $ra

stu_not_found:
    print_str(not_found)
    print_str(newline)
    jr $ra