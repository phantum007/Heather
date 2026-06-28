# Client Manual Test Cases

This checklist turns the current automated test coverage into plain-English test cases a client can walk through in the product.

## How to use this document

- Run each case in a local or staging environment with sample teacher and student accounts.
- Mark each item as `Pass`, `Fail`, or `Not Tested`.
- If something fails, capture the exact page, action taken, and what happened instead of the expected result.

## Suggested test accounts and data

- `Teacher account`: existing teacher user with access to student management
- `Student account`: existing student user linked to a grade
- `Sample student`: a student that can be created, edited, assigned work, and deleted
- `Sample lesson`: a lesson with units/questions already available
- `Sample toy`: a toy with a positive coin value

## 1. Login and access control

### TC-01 Teacher can log in

- Steps: Open `/login/`, enter valid teacher email and password, submit.
- Expected result: User is redirected to the teacher dashboard at `/teacher/`.

### TC-02 Student can log in

- Steps: Open `/login/`, enter valid student email and password, submit.
- Expected result: User is redirected to `/student/assignments/`.

### TC-03 Invalid login is rejected

- Steps: Open `/login/`, enter a valid email with the wrong password, submit.
- Expected result: Login does not succeed and the page shows an error or stays on the login screen.

### TC-04 Logout ends the session

- Steps: Log in, then use the logout action.
- Expected result: User is redirected to `/login/` and protected pages are no longer accessible without logging in again.

### TC-05 Unauthenticated user cannot access protected pages

- Steps: Without logging in, open `/teacher/`, `/student/assignments/`, and `/student/coins/`.
- Expected result: Each page redirects to `/login/`.

### TC-06 Student cannot access teacher-only pages

- Steps: Log in as a student and open `/teacher/`.
- Expected result: Access is denied.

### TC-07 Teacher cannot access student-only pages

- Steps: Log in as a teacher and open `/student/assignments/`.
- Expected result: Access is denied.

## 2. Teacher profile

### TC-08 Teacher profile page loads

- Steps: Log in as a teacher and open `/teacher/profile/`.
- Expected result: Current teacher details are displayed.

### TC-09 Teacher profile requires a name

- Steps: Clear the name field and submit the profile form.
- Expected result: The form is not saved and a validation message is shown.

### TC-10 Teacher can update profile without changing password

- Steps: Update teacher name or email, leave password fields empty, submit.
- Expected result: Changes are saved successfully.

## 3. Teacher student management

### TC-11 Students list loads

- Steps: Log in as a teacher and open `/teacher/students/`.
- Expected result: The student list page loads successfully.

### TC-12 Add student page loads

- Steps: Open `/teacher/students/add/`.
- Expected result: The add-student form loads with grade options.

### TC-13 Add student rejects missing required fields

- Steps: Submit the add-student form with blank required fields such as first name, last name, and email.
- Expected result: Student is not created and validation feedback is shown.

### TC-14 Add student rejects duplicate email

- Steps: Submit the add-student form using an email already used by another account.
- Expected result: Student is not created and the user is told the email is already in use.

### TC-15 Add student succeeds with valid data

- Steps: Submit the add-student form with valid names, contact details, grade, email, and password.
- Expected result: Student is created and the teacher is redirected back to the student area.

### TC-16 Delete student succeeds

- Steps: Delete an existing student from the teacher area.
- Expected result: Student is removed and the teacher is redirected back to the student list.

## 4. Teacher assignment workflow

### TC-17 Create assignment page loads

- Steps: Open `/teacher/create-assignment/`.
- Expected result: The page loads with student and lesson choices.

### TC-18 Assignment cannot be created without selecting a student

- Steps: Submit the create-assignment form without choosing a student.
- Expected result: Assignment is not created and validation feedback is shown.

### TC-19 Assignment cannot be created with a question missing the correct answer

- Steps: Create an assignment where at least one question has question text but no correct answer.
- Expected result: Assignment is rejected.

### TC-20 Assignment cannot be created for an invalid lesson

- Steps: Attempt to create an assignment against a lesson that no longer exists or is invalid.
- Expected result: The request fails safely and no assignment is created.

### TC-21 Teacher can create a valid assignment

- Steps: Select a valid student and lesson, add valid questions with correct answers, and submit.
- Expected result: Assignment is created successfully.

## 5. Teacher results and progress

### TC-22 Teacher results page loads even when no student is selected

- Steps: Open `/teacher/results/` without filtering to a student.
- Expected result: Page loads without crashing.

### TC-23 Unit attempts endpoint requires assignment id

- Steps: Open a student unit-attempts URL without the `assignment_id` query parameter.
- Expected result: The request is rejected with a clear error.

### TC-24 Unit attempts can be viewed for a valid assignment

- Steps: Open a student unit-attempts URL with a valid `assignment_id`.
- Expected result: Attempt history is returned and visible.

### TC-25 Reset student unit requires assignment id

- Steps: Trigger unit reset without sending an `assignment_id`.
- Expected result: The request is rejected with a clear error.

### TC-26 Reset student unit succeeds for a valid assignment

- Steps: Reset a student unit with a valid `assignment_id`.
- Expected result: Existing attempt records for that unit are deleted and success is returned.

## 6. Toys and coin redemption

### TC-27 Teacher toys page loads

- Steps: Open `/teacher/toys/`.
- Expected result: Existing toys are listed.

### TC-28 Toy cannot be added without a name

- Steps: Submit the add-toy form with an empty name.
- Expected result: Toy is not created.

### TC-29 Toy cannot be added with zero or invalid coin value

- Steps: Submit the add-toy form with `0` or another invalid coin value.
- Expected result: Toy is not created.

### TC-30 Teacher can add a valid toy

- Steps: Submit the add-toy form with a valid name and positive coin value.
- Expected result: Toy is created successfully.

### TC-31 Teacher can delete a toy

- Steps: Delete an existing toy.
- Expected result: Toy is removed successfully.

### TC-32 Student coin page is available

- Steps: Log in as a student and open `/student/coins/`.
- Expected result: Coin balance and redemption options are visible.

### TC-33 Redeem toy rejects missing toy id

- Steps: Submit a redeem request without selecting a toy.
- Expected result: Request fails with an error.

### TC-34 Redeem toy fails if student profile is missing

- Steps: Attempt redemption for a student account with no valid student profile.
- Expected result: Request fails with a profile-related error.

### TC-35 Redeem toy fails when student does not have enough coins

- Steps: Try to redeem a toy costing more coins than the student currently has.
- Expected result: Redemption is rejected and the balance is unchanged.

### TC-36 Redeem toy succeeds when student has enough coins

- Steps: Redeem a valid toy with enough available coins.
- Expected result: Redemption succeeds, coins are deducted, and a redemption record is created.

## 7. Student assignment and practice flow

### TC-37 Student dashboard loads

- Steps: Log in as a student and open `/student/`.
- Expected result: Dashboard loads with grade and assignment information.

### TC-38 Student assignments page loads

- Steps: Open `/student/assignments/`.
- Expected result: Available assignments are displayed without errors.

### TC-39 Submit answers rejects empty submission

- Steps: Submit an assignment without any answers.
- Expected result: Submission is rejected.

### TC-40 Submit answers rejects entries without question id

- Steps: Submit an answer payload where an answer has no question reference.
- Expected result: Submission is rejected.

### TC-41 Submit answers rejects invalid question ids

- Steps: Submit an answer for a question that does not exist.
- Expected result: Submission is rejected safely.

### TC-42 Student can submit valid answers

- Steps: Submit one or more valid answers for a real assignment.
- Expected result: Submission succeeds and the response shows totals such as correct answers, total questions, and percentage.

### TC-43 Student can see their assignments list

- Steps: Open the student assignments list after assignments have been created.
- Expected result: The list loads and shows assigned work.

## 8. Answer checking and grading behavior

These cases come directly from the automated tests around answer normalization and scoring.

### TC-44 Numeric answers ignore commas

- Steps: Create or use a question where the correct answer is `1234` and submit `1,234`.
- Expected result: Answer is marked correct.

### TC-45 Numeric answers ignore harmless formatting differences

- Steps: Test values such as `5` vs `5.0`, `3.5` vs `3.50`, and `007` vs `7`.
- Expected result: Equivalent values are marked correct.

### TC-46 Numeric precision is truncated, not rounded

- Steps: Compare a correct answer of `1.999` against a submitted answer of `1.9999`.
- Expected result: The answer is treated as a match.

### TC-47 Negative sign matters

- Steps: Compare `-10` against `10`.
- Expected result: The answer is marked incorrect.

### TC-48 Text answers are case-insensitive

- Steps: Compare `Hello` with `hello`.
- Expected result: The answer is marked correct.

### TC-49 Blank answers do not count as correct

- Steps: Submit an empty answer where the question has a real correct answer.
- Expected result: The answer is marked incorrect.

## 9. Assignment locking and progression

These are especially important for the client to confirm because they reflect business rules rather than just page loading.

### TC-50 First assignment in a sequence is never locked

- Steps: View the first assignment in a sequence for a student.
- Expected result: It is available immediately.

### TC-51 Later standard or lock-mode assignments stay locked until the previous assignment is complete

- Steps: Leave assignment 1 incomplete, then check assignment 2.
- Expected result: Assignment 2 remains locked.

### TC-52 Completing the previous assignment unlocks the next one

- Steps: Fully complete assignment 1, then refresh or re-open assignment 2.
- Expected result: Assignment 2 becomes available.

### TC-53 Sprint assignments do not get locked by sequence rules

- Steps: Create or inspect assignments in sprint mode.
- Expected result: Sprint assignments remain accessible without the same locking behavior.

### TC-54 Lessons with zero units should not unlock the next assignment

- Steps: Use a lesson with no units, then check whether the next assignment unlocks.
- Expected result: The next assignment should remain locked.

## 10. Unit pass/fail and coin rules

### TC-55 Unit passes with up to 2 wrong answers

- Steps: Complete a unit with 0, 1, or 2 wrong answers.
- Expected result: Unit is marked as passed.

### TC-56 Unit fails with 3 or more wrong answers

- Steps: Complete a unit with 3 wrong answers.
- Expected result: Unit is marked as failed.

### TC-57 First successful pass gives double coins

- Steps: Pass a unit on the first attempt.
- Expected result: Student receives double the normal coin reward.

### TC-58 Later successful passes give standard coins

- Steps: Pass the same unit on a later attempt.
- Expected result: Student receives the standard coin reward, not the doubled reward.

### TC-59 Failed attempts do not award coins

- Steps: Fail a unit attempt.
- Expected result: No coins are awarded.

## Notes on current automated coverage

- The automated tests are strongest around validation, auth rules, answer checking, and key teacher/student workflows.
- Some richer UI behavior is only lightly covered, so the client should pay extra attention to layout, wording, and multi-step workflows in the browser.
- Good areas for extra exploratory testing are curriculum editing, student profile editing, assignment results detail, and any file/image upload behavior.
