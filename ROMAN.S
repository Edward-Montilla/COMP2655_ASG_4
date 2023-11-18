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
COUNTS			equ			6	; int,  4 bytes
MODIFIED		equ			8	; bool, 1 byte
MODIFIER		equ			10	; bool,	1 byte
MAX_TIMES		equ			12	; int,  4 bytes
ROMAN_SIZE		equ			14	; size of records

;------Program Specific Constants-----;
MAX_ROMAN		equ			7
MAX_STRING		equ			20
NO_ERROR		equ			0
MAX_DIGIT_COUNT	equ			3
C_NULL			equ			'\0'
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
;-------------------------------UNTESTED,START--------------------------------;
init_vars:		; sum = 0
				lea			sum,a2				; a2 holds address for `sum`
				clr.w		(a2)

				; s_index = 0
				lea			s_index,a2			; a2 holds address for `s_index`
				clr.w		(a2)

				; r_last = MAX_ROMANS -1
				lea			r_last,a2			; a2 holds address for `r_last`
				clr.w		(a2)
				move.b		#MAX_ROMAN-1,(a2)

				; error = NO_ERROR
				lea			error,a2			; a2 holds address for `error`
				clr.w		(a2)
				move.b		#NO_ERROR,(a2)

find_error:		; STM:::  string[s_index] != C_NULL && error == NO_ERROR
				lea			s_index,a2			; a2 holds 's_index'
				move.w		(a2),d1
				adda.w		d1,a1				; d1 = string[s_index]
				move.b		(a1),d1
				cmp.w		#C_NULL,d1
				bne			check_error
				lea			error,a3			; a3 holds 'error'
				move.w		(a3),d2				; d2 = error
				cmp.w		#NO_ERROR,d2
				bne			check_error
				clr.w		d1
				clr.w		d2

prt_reverse:	; STM::: (r_index >= 0 && string[s_index] != all_roman[r_index].digit)

; BDY::: r_index--
				sub.b 		#1,d3
				inv_rom_dgt:	; STM:::: r_index < 0
; BDY::: error = 1
inv_rom_dgt_else: ; STM::: else

index_GT_last: ; STM::: r_index > r_last
; BDY::: decisions

out_of_order:	;STM::: (all_roman[r_index].subtractor_index != r_last) || (all_roman[r_last].count > 1)				else1a2b:
		;BDY::: error = 2

out_of_order_else: ; STM:::
		; BDY::: sum = sum + all_roman[r_index].arab_value - 2 * all_roman[r_last].arrab_value
		;		(all_roman[all_roman[r_index].subtractor_index].count)--
		;		all_roman[r_index].count++
		;		all_roman[r_index].modified = TRUE
		;		all_roman[all_roman[r_index].subtractor_index].modifier = TRUE

		;		all_roman[all_roman[r_index].subtractor_index].modifier = TRUE
index_GT_last_else: ; STM::: else


find_error3:

if1b2:

else1b2:

if1b2c:

else1b2c:

if1b: ; while no error increment s_index and reset r_last

check_error:
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
				dc.w		'V',5,0,0,FALSE,FALSE,1
				dc.w		'X',10,0,0,FALSE,FALSE,MAX_DIGIT_COUNT
				dc.w		'L',50,2,0,FALSE,FALSE,1
				dc.w		'C',100,2,0,FALSE,FALSE,MAX_DIGIT_COUNT
				dc.w		'D',500,4,0,FALSE,FALSE,1
				dc.w		'M',1000,4,0,FALSE,FALSE,MAX_DIGIT_COUNT
				even