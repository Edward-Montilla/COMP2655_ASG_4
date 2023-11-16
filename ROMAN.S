;----------------------Register Table---------------;
;	d0 = ONLY holds input and output data
;	d1 = ONLY holds index values for 'all_roman' Array
;	d2 = holds user input
;	a0 = ONLY holds the address to the 'all_roman' array
;	a1 = ONLY holds the address for the user input string
;	a2 = EITHER holds the address for the program output strings
;			ALSO holds the address for the 'sum' variable
;	a3 = ONLY holds address for `s_index` variable
;	a4 = ONLY holds address for `r_last` variable
;	a5 = ONLY holds address for `error` variable
;	a6 = ONLY holds address for `r_index` variable



			xref		write_char
			xref		read_char
			xref		exit

;-----------Constants-----------------;
; Screen Controls:
CR				equ			13
LF				equ			10
NULL				equ			0

; Booleans
true			equ			1
false			equ			0

; Structures
digit			equ			0	; char, 1 byte + 1 pad, next field is a long
arab_value		equ			2	; int,  4 bytes
sub_index		equ			6	; int,  4 bytes
count			equ			10	; int,  4 bytes
modified		equ			14	; bool, 1 byte
modifier		equ			15	; bool,	1 byte
max_times		equ			16	; int,  4 bytes
ROMAN_SIZE		equ			20	; size of records

;------Program Specific Constants-----;
MAX_ROMAN		equ			7
MAX_STRING		equ			20
NO_ERROR		equ			0
MAX_DIGIT_COUNT	equ			3
C_NULL			equ			'\0'
QUIT			equ			'Q'

; Initialize Array
start:
			clr.l		d0
			clr.l		d1

			lea			all_roman,a0
			clr.l		d1

			move.b 		#'I',digit(a0,d1)			; index 0
			move.l		#1,arab_value(a0,d1)
			move.l 		#-1,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#MAX_DIGIT_COUNT,max_times(a0,d1)

			add.w		#ROMAN_SIZE,d1				; i++

			move.b 		#'V',digit(a0,d1)			; index 1
			move.l		#5,arab_value(a0,d1)
			move.l 		#0,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#1,max_times(a0,d1)

			add.w		#ROMAN_SIZE,d1

			move.b 		#'X',digit(a0,d1)			; index 2
			move.l		#10,arab_value(a0,d1)
			move.l 		#0,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#MAX_DIGIT_COUNT,max_times(a0,d1)

			add.w		#ROMAN_SIZE,d1

			move.b 		#'L',digit(a0,d1)			; index 3
			move.l		#50,arab_value(a0,d1)
			move.l 		#2,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#1,max_times(a0,d1)

			add.w		#ROMAN_SIZE,d1

			move.b 		#'C',digit(a0,d1)			; index 4
			move.l		#100,arab_value(a0,d1)
			move.l 		#2,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#MAX_DIGIT_COUNT,max_times(a0,d1)

			add.w		#ROMAN_SIZE,d1

			move.b 		#'D',digit(a0,d1)			; index 5
			move.l		#500,arab_value(a0,d1)
			move.l 		#4,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#1,max_times(a0,d1)

			add.w		#ROMAN_SIZE,d1				; i = size of array

			move.b 		#'M',digit(a0,d1)			; index 5
			move.l		#1000,arab_value(a0,d1)
			move.l 		#4,sub_index(a0,d1)
			move.l 		#0,count(a0,d1)
			move.b 		#false,modified(a0,d1)
			move.b    	#false,modifier(a0,d1)
			move.l		#MAX_DIGIT_COUNT,max_times(a0,d1)

; Print Opening Lines:
			lea			open0,a2
prt_open0:
			move.b		(a2)+,d0
			beq			prt_open3
			jsr			write_char
			bra			prt_open0

			lea			open3,a2
prt_open3:	; prt_open3 to be called again every conversion
			move.b		(a2)+,d0
			beq			read_input
			jsr			write_char
			bra			prt_open3

; Read User Input
			lea			string,a1
read_input:	;scanf(format_string,string)
			jsr			read_char
			cmp			#CR,d0
			beq			check_Q
			move.b			d0,(a0)+
			bra			read_input

while0:	; while(string[0] != QUIT)
			lea			string,a3			; Temporarily points to the 0th element of the string.
			cmp.b		#QUIT,(a3)
			clr.l		(a3)
			beq			end_prog
			cmp.b		#CR,(a3)			; Checks if user entered empty string
			beq			while0

			;Initialize variables

;-------------UNTESTED,START--------------------------			
			;sum = 0
init_vars:
			lea			sum,a2				; a2 holds address for `sum`
			clr.l		(a2)
			
			;s_index = 0
			lea			s_index,a3			; a3 holds address for `s_index`
			clr.l		(a3)
			
			;r_last = MAX_ROMANS -1
			lea			r_last,a4			; a4 holds address for `r_last`
			clr.l		(a4)
			move.b		MAX_ROMAN-1,(a4)
			
			;error = NO_ERROR
			lea			error,a5			; a5 holds address for `error`
			clr.l		(a5)
			move.b		#NO_ERROR,(a5)
			
while1:		; STM:::  string[s_index] != C_NULL && error == NO_ERROR
			move.l 		(a3),d3
			cmp.l		(a1,d3),C_NULL
			beq			case_error
			move.l		(a5),d3
			tst			d3
			bne			case_error
			
			; BDY::: r_index = MAX_ROMAN-1
			lea			r_index,a6			; a6 holds address for `r_index
			clr.l		(a6)
			move.b 		MAX_ROMAN-1,(a6)
			
while2:		; STM::: (r_index >= 0 && string[s_index] != all_roman[r_index].digit)			


			; BDY::: r_index--
			sub.b 		#1,d3
;-------------End_Untested---------------
			
			
			

case_error:		nop


end_prog:		jsr			exit

; Print opening lines

; Handle Error

; Do Mathematics



; Variables

open0:			dc.b		"This program converts numbers in Improved Roman notation to Arabic notation."
				dc.b		CR,LF,"Input is limited to UPPER case Roman digits only"
				dc.b		CR,LF,"To exit the program type only the Enter key.",NULL

open3:			dc.b		CR,LF, "Input a Roman number (Press 'Q' to exit): ",NULL

error0:			dc.b		"Character at position ",NULL
error1:			dc.b		"is not a valid Roman digit",NULL
error2:			dc.b		"is out of order for a Improved Roman number",NULL
error3:			dc.b		"has been used as a modifier and can't be used unmodified", NULL
error4:			dc.b		"combination of the modified prior digit and this digit is", CR, LF, "an invalid Roman number", NULL
error5:			dc.b		"has exceeded the maximum occurences for this digit", NULL
error_Def:		dc.b		"In error handling with an invalid error code", NULL
				even

; Array of Structures:
all_roman: 		ds.b		ROMAN_SIZE*6
				even
				
; Program Vaiables:
string:			ds.b		MAX_STRING+1
				even
sum:			ds.b 		4
s_index:		ds.b		4
r_last:			ds.b		4
r_index:		ds.b		4
error:			ds.b		4
				even