# Program: `hexdump1`

## Problem to be solved

Print the value in a register, say, `EAX`, to the Linux console.  

### Use case 1

Suppose a register, say, `EAX`, contains a numeric value, e.g., `07BA45D3Fh`.  Furthermore, suppose we want to print this specific numeric value to the Linux console.  Perhaps we read this value in from user input, and now we need to confirm to the user that the value entered into the EAX register is exactly the same as the value that the user typed.

### Use case 2

Perhaps a user will feed our program a data file, and we want to get a hex dump of the file and send it to standard output.

## Pseudo-code

```
Given a numeric value in a register
Convert it into the ASCII character codes necessary to display it as a string
Write the string to standard output
```

