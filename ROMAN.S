;----------------------Register Table---------------;
;	d0 = ONLY holds input and output data
;	d1 = ONLY holds 'error' values (0-7)
;	d2 = 

			xref		write_char
			xref		read_char
			xref		exit

; Constants

; Screen Controls:
CR			equ			13
LF			equ			10
NULL		equ			0

; Structures





; initialize things

; Print opening lines

; Handle Error 

; Do Mathematics

; 


; Variables

open0:		dc.b		"This program converts numbers in Improved Roman notation to Arabic notation.", CR, LF,"Input is limited to UPPER case Roman digits only", CR, LF, "To exit the program type only the Enter key.", NULL
open3:		dc.b		"Input a Roman number (Press 'Q' to exit): ", NULL

error0:		dc.b		"Character at position ",NULL
error1:		dc.b		"is not a valid Roman digit",NULL
error2:		dc.b		"is out of order for a Improved Roman number",NULL
error3:		dc.b		"has been used as a modifier and can't be used unmodified", NULL
error4:		dc.b		"combination of the modified prior digit and this digit is", CR, LF, "an invalid Roman number", NULL
error5:		dc.b		"has exceeded the maximum occurences for this digit", NULL
error_Def:	dc.b		"In error handling with an invalid error code", NULL

; Array of Structures:


