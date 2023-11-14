;----------------------Register Table---------------;
git;	d0 = ONLY holds input and output data
;	d1 = ONLY holds 'error' values (0-7)
;	d2 = holds user input

			xref		write_char
			xref		read_char
			xref		exit

; Constants

; Screen Controls:
CR				equ			13
LF				equ			10
NULL			equ			0

;
    git push --set-upstream origin test

; Booleans

true			equ			1
false			equ			0

; Structures
digit			equ			0	; char 1 byte + 1 pad, next field is a long 
arab_value		equ			2	; int, 4 bytes
sub_index		equ			6	; int, 4 bytes
count			equ			10	; int, 4 bytes
modified		equ			14	; bool, 1 byte
modifier		equ			15	; bool,	1 byte 
max_times		equ			16	; int, 4 bytes
ROMAN_SIZE		equ			20	; size of records

; Program Specific Constants
MAX_ROMAN		equ			7
MAX_STRING		equ			20
NO_ERROR		equ			0
MAX_DIGIT_COUNT	equ			3
C_NULL			equ			'\0'
QUIT			equ			'Q'

; initialize 
				jsr			read_char
				addq.b 		#3,d0
				jsr			write_char

run:			cmp			#QUIT,d2
				beq			end_prog
				jsr			read_char
				addq.b 		#3,d0
				jsr			write_char
				bra			run
end_prog:		jsr			exit			

; Print opening lines

; Handle Error 

; Do Mathematics

;  


; Variables

open0:			dc.b		"This program converts numbers in Improved Roman notation to Arabic notation.", CR, LF,"Input is limited to UPPER case Roman digits only", CR, LF, "To exit the program type only the Enter key.", NULL
open3:			dc.b		"Input a Roman number (Press 'Q' to exit): ", NULL

error0:			dc.b		"Character at position ",NULL
error1:			dc.b		"is not a valid Roman digit",NULL
error2:			dc.b		"is out of order for a Improved Roman number",NULL
error3:			dc.b		"has been used as a modifier and can't be used unmodified", NULL
error4:			dc.b		"combination of the modified prior digit and this digit is", CR, LF, "an invalid Roman number", NULL
error5:			dc.b		"has exceeded the maximum occurences for this digit", NULL
error_Def:		dc.b		"In error handling with an invalid error code", NULL

; Array of Structures:

string:			ds.b		MAX_STRING+1 
