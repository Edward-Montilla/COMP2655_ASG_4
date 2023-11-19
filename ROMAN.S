
;----------------------Register Table---------------;
;	d0 = ONLY holds input and output data
;	d1 = ONLY holds index values for 'all_roman' Array
;	d2 = holds user input
;
;
;	a0 = ONLY holds the address to the 'all_roman' array
;	a1 = ONLY holds the address for the user input string
;	a2 = EITHER holds the address for the program output strings
;			ALSO holds the address for the 'sum' variable
;	a3 = ONLY holds address for `s_index` variable
;	a4 = ONLY holds address for `r_last` variable
;
;



			xref		write_char
			xref		read_char
			xref		exit

;-----------Constants-----------------;
; Screen Control Constants:
CR				equ			13
TAB			equ			9
LF				equ			10
NULL			equ			0

; Boolean Constants
TRUE			equ			1
FALSE			equ			0

; Structures Offset Constants
DIGIT			equ			0	; char, 1 byte + 1 pad, next field is a long
ARAB_VAL		equ			2	; int,  4 bytes
SUB_INDEX		equ			4	; int,  4 bytes
COUNT			equ			6	; int,  4 bytes
MODIFIED		equ			8	; bool, 1 byte
MODIFIER		equ			10	; bool,	1 byte
MAX_TIMES		equ			12	; int,  4 bytes
ROMAN_SIZE		equ			14	; size of records

;------Program Specific Constants-----;
MAX_ROMANS		equ			7
MAX_STRING		equ			20
NO_ERROR		equ			0
MAX_DIGIT_COUNT	equ			3
C_NULL			equ			0
QUIT			equ			'Q'

				; Print Opening Lines:
				lea			intro,a5
prt_intro:
				move.b		(a5)+,d0
				beq			prt_rst
				jsr			write_char
				bra			prt_intro

				; prt_rst: Prints the rst_str to be called again every conversion

prt_rst:		lea			rst_str,a5
prt_loop:		move.b		(a5)+,d0
				beq			start
				jsr			write_char
				bra			prt_loop

				; Read User Input == scanf(format_string,string)
start:			lea			all_roman,a0		; a0 holds all_roman
				lea			string,a1			; a1 holds string

				; Clear 'string'
				move.b		#MAX_STRING+1,d1	; d1 holds length of 'string' acts as counter
clr_str:		clr.b		(a1)+
				dbra		d1,clr_str
				clr.b		d1

				; Read user Improved Roman Nnumeral notation
				lea			string,a1			; a1 holds the start of the 'string'
read_input:		jsr			read_char
				cmp			#CR,d0
				beq			chk_quit
				move.b		d0,(a1)+
				bra			read_input

chk_quit:		; STM::: while(string[0] != QUIT)
				lea			string,a1			; a1 holds string, points to 0th element of string
				cmp.b		#QUIT,(a1)
				beq			end_prog
				cmp.b		#CR,(a1)			; Checks if user entered empty string
				beq			start

				; Initialize variables
init_vars:		; sum = 0
				lea			sum,a2				; a2 holds address for `sum`
				clr.w		(a2)

				; s_index = 0
				lea			s_index,a2			; a2 holds address for `s_index`
				clr.w		(a2)

				; r_last = MAX_ROMANS -1
				lea			r_last,a2			; a2 holds address for `r_last`
				clr.w		(a2)
				move.b		#MAX_ROMANS-1,(a2)

				; error = NO_ERROR
				lea			error,a2			; a2 holds address for `error`
				clr.w		(a2)
				move.b		#NO_ERROR,(a2)

find_error:		; STM:::  string[s_index] != C_NULL && error == NO_ERROR
				lea			s_index,a2			; a2 holds 's_index'
				move.b		(a2),d1
				adda.w		d1,a1				; d1 = string[s_index]
				move.b		(a1),d1
				cmp.b		#C_NULL,d1
				beq			check_error
				
				lea			error,a3			; a3 holds 'error'
				move.b		(a3),d2				; d2 = error
				cmp.b		#NO_ERROR,d2
				bne			check_error
				clr.w		d1
				clr.w		d2

				; while body: r_index = MAX_ROMAN-1
				lea			r_index,a2			; a2 points to r_index
				move.b		#MAX_ROMANS-1,(a2)	; r_index now holds MAX_ROMANS-1
				
				lea			string,a1			; a1 points toward start of 'string'
				lea			s_index,a3			; a3 points to `s_index`
				move.b		(a3),d2				; d2 holds value of `s_index`
				move.b		#ROMAN_SIZE,d4		; d4 holds value of 'r_index' in ROMAN_SIZEs
				
ptr_reverse:	; STM::: (r_index >= 0 && string[s_index] != all_roman[r_index].digit)
				
				move.b		(a2),d1				; d1 holds value of `r_index`
				tst			d1
				blt			invalid_digit
				
				move.b		(a1,d2),d3			; d3 holds value of `string[s_index]`
		
				mulu.w		d1,d4				
				cmp.w		DIGIT(a0,d4),d3		; d4 holds value of 'r_index' in ROMAN_SIZEs
				beq			invalid_digit
				move.b		#ROMAN_SIZE,d4		
				; BDY::: r_index--
				subq.b 		#1,(a2)
				bra			ptr_reverse
;-------------------------------SEMI-UNTESTED,START: wokrs on expected values--------------------------------;	
invalid_digit:	; STM:::: r_index < 0
				cmp.b		#0,d1
				bge			index_GT_last
				
				; BDY::: error = 1	=> invalid roman digit
				lea			error,a3			
				move.b		#1,(a3)
				bra			check_error				; handle error
				
index_GT_last: ; STM::: else if( r_index > r_last)
				lea			r_last,a3			; a3 points to 'r_last`
				cmp.b		(a3),d1
				ble			index_LE_last

out_of_order:	;STM::: (all_roman[r_index].subtractor_index != r_last) || (all_roman[r_last].count > 1)				else1a2b:
				clr.l		d2
				move.b		(a3),d2				; d2 holds'r_last` value
				
				cmp.b		SUB_INDEX(a0,d4),d2	; d4 holds value of 'r_index' in ROMAN_SIZEs
				bne			error_body

				clr.l		d5
				clr.l		d6
				move.b		#ROMAN_SIZE,d5
				mulu.w		d2,d5
				move.b		COUNT(a0,d5),d6		; d6 = all_roman[r_last].count 		
				cmp.b		#1,d6
				ble			in_order

error_body:		;BDY::: error = 2
				lea			error,a3			; a3 points to 'error'					
				move.b		#2,(a3)				; d3 holds 'error' value
				bra			check_error
				
in_order: 		; STM::: else 
				
				; BDY::: sum = sum + all_roman[r_index].arab_value - 2 * all_roman[r_last].arrab_value
				lea			sum,a2
				clr.l		d1
				move.b		(a2),d1				; d1 = sum
				
				lea			r_index,a2			; a2 points to 'r_index`
				clr.l		d2
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2
				add.w		ARAB_VAL(a0,d2),d1	
				
				lea			r_last,a2			
				clr.l		d2
				clr.l		d3
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2
				move.w		ARAB_VAL(a0,d2),d3	
				mulu.w		#2,d3				
				
				sub.b		d3,d1
				lea			sum,a2
				move.b		d1,(a2)
				
				;		(all_roman[all_roman[r_index].subtractor_index].count)--
				lea			r_index,a2			; a2 points to 'r_index`
				clr.l		d2
				clr.l		d3			
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2
				move.w		SUB_INDEX(a0,d2),d3 ; d3 = all_roman[r_index].subtractor_index
				
				mulu.w		#ROMAN_SIZE,d3
				sub.w		#1,COUNT(a0,d3)
				
				;		all_roman[r_index].count++
				;		all_roman[r_index].modified = TRUE
				;		all_roman[all_roman[r_index].subtractor_index].modifier = TRUE
				;		all_roman[all_roman[r_index].subtractor_index].modifier = TRUE

index_LE_last: ; STM::: else




check_error:	; STM::: if (error)
				clr.l		d1
				lea			error,a2
				move.w 		(a2),d1
				cmp.w		#NO_ERROR,d1
				beq			else1

cases: ; what errror did the user do?

else1: ; given digit is valid, print number

while1a: ; clear array modifiers and counts

re_prt:
				clr.l	d0
				lea		rst_str,a3
				move.b	(a3)+,d0
				beq		rst_bra
				jsr		write_char
				bra		re_prt

rst_bra:
				bra 	start
;-------------End_Untested---------------


end_prog:		jsr			exit

; Print opening lines

; Handle Error

; Do Mathematics



; Variables

intro:			dc.b		"This program converts numbers in Improved Roman notation to Arabic notation."
				dc.b		CR,LF,"Input is limited to UPPER case Roman digits only"
				dc.b		CR,LF,"To exit the program type only the Enter key.",NULL
				even

rst_str:		dc.b		CR,LF, "Input a Roman number (Press 'Q' to exit): ",NULL

error0:			dc.b		"Character at position ",NULL
error1:			dc.b		"is not a valid Roman digit",NULL
error2:			dc.b		"is out of order for a Improved Roman number",NULL
error3:			dc.b		"has been used as a modifier and can't be used unmodified", NULL
error4:			dc.b		"combination of the modified prior digit and this digit is", CR, LF, "an invalid Roman number", NULL
error5:			dc.b		"has exceeded the maximum occurences for this digit", NULL
error_Def:		dc.b		"In error handling with an invalid error code", NULL
				even

; Program Vaiables:
string:			ds.b		MAX_STRING+1
				even
sum:			ds.b 		2
s_index:		ds.b		2
r_last:			ds.b		2
r_index:		ds.b		2
error:			ds.b		2
				even

; Array of Structures:
all_roman: 		dc.w		'I',1,-1,0,FALSE,FALSE,MAX_DIGIT_COUNT	
				even
				dc.w		'V',5,0,0,FALSE,FALSE,1
				even
				dc.w		'X',10,0,0,FALSE,FALSE,MAX_DIGIT_COUNT
				even
				dc.w		'L',50,2,0,FALSE,FALSE,1
				even
				dc.w		'C',100,2,0,FALSE,FALSE,MAX_DIGIT_COUNT
				even
				dc.w		'D',500,4,0,FALSE,FALSE,1
				even
				dc.w		'M',1000,4,0,FALSE,FALSE,MAX_DIGIT_COUNT
				even