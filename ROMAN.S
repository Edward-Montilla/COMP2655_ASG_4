;-------------------------------------------------------------------;
; PROGRAMMER NAME: 			EDWARD MONTILLA							;
;																	;
; PROGRAMMER EMAIL: 		gmont153@mtroyal.ca						;
;																	;
; COURSE NAME & NUMBER: 	COMPUTING MACHINERY - COMP2655			;
; 																	;
;  					ASSIGNMENT 4									;
;																	;
; DUE DATE: 				NOVEMBER 19,2023						;
;																	;
; FILE NAME: 				ROMAN.S									;
;																	;
; INSTRUCTOR NAME: 			STEVE KALMAR							;
;-------------------------------------------------------------------;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
; PURPOSE: Convert numbers from Improved Roman Notation to decimal 	;
; 																	;
; DETAILS: 															;
;		input: any of the capitalized letter "I,V,X,L,C,D,M"		;
;				built in error detection will enforce the choices	;	
;																	;
;		output: the decimal value of ROMAN number on the console	;		
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; PROGRAM STATUS: 													;
;																	;
; TESTED ON VALUES:													;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;


;--------------------------Register Table---------------------------;
;	d0 = ONLY holds input and output data							;
;	d1-d7 = will hold variety of values, end of line 				;
;			documentation indicaites values contained 				;
;			in each Dn at the time.									;
;																	;
;	a0 = ONLY holds the address to the 'all_roman' array			;
;	a1 = ONLY holds the address for the user input string			;
;	a2-a4 = will point to various addresses, end of line 			;
;			documentation will indicate wich address 				;
;			each An points to at the time							;
;-------------------------------------------------------------------;
			xref		write_char
			xref		read_char
			xref		exit

;-----------Constants-----------------;
; Screen Control Constants:
CR				equ			13
TAB				equ			9
LF				equ			10
NULL			equ			0

; Boolean Constants
TRUE			equ			1
FALSE			equ			0

; Structures Offset Constants
DIGIT			equ			0	; char, 2 bytes
ARAB_VAL		equ			2	; int,  2 bytes
SUB_INDEX		equ			4	; int,  2 bytes
COUNT			equ			6	; int,  2 bytes
MODIFIED		equ			8	; bool, 2 byte
MODIFIER		equ			10	; bool,	2 byte
MAX_TIMES		equ			12	; int,  2 bytes
ROMAN_SIZE		equ			14	; size of record

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
				
				
start:			lea			all_roman,a0		; a0 holds all_roman
				lea			string,a1			; a1 holds string

				; Clear 'string'
				clr.l
				move.b		#MAX_STRING+1,d1	; d1 holds length of 'string' acts as counter
clr_str:		clr.b		(a1)+
				dbra		d1,clr_str
				clr.b		d1


				; Read user Improved Roman Nnumeral notation 
				lea			string,a1			; a1 holds the start of the 'string'
				
read_input:		; Read User Input == scanf(format_string,string)
				jsr			read_char
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
				cmp.b		#0,d1
				blt			invalid_digit
				
				move.b		(a1,d2),d3			; d3 holds value of `string[s_index]`
		
				mulu.w		d1,d4				
				cmp.w		DIGIT(a0,d4),d3		; d4 holds value of 'r_index' in ROMAN_SIZEs
				beq			invalid_digit
				move.b		#ROMAN_SIZE,d4		
				; BDY::: r_index--
				subq.b 		#1,(a2)
				bra			ptr_reverse
				
invalid_digit:	; STM:::: r_index < 0
				cmp.b		#0,d1
				bge			index_GT_last
				
				; BDY::: error = 1	=> invalid roman digit
				lea			error,a3			
				move.b		#1,(a3)
				bra			cnt_read_input			
;-------------------------------SEMI-UNTESTED,START: wokrs on expected values--------------------------------;					
index_GT_last: ; STM::: else if( r_index > r_last)
				lea			r_last,a3			; a3 points to 'r_last`
				cmp.b		(a3),d1
				ble			index_LE_last

out_of_order:	;STM::: (all_roman[r_index].subtractor_index != r_last) || (all_roman[r_last].count > 1)				else1a2b:
				clr.l		d2
				move.b		(a3),d2				; d2 holds'r_last` value
				
				cmp.b		SUB_INDEX(a0,d4),d2	; d4 holds value of 'r_index' in ROMAN_SIZEs
				beq			order_error

				clr.l		d5
				clr.l		d6
				move.b		#ROMAN_SIZE,d5
				mulu.w		d2,d5
				move.b		COUNT(a0,d5),d6		; d6 = all_roman[r_last].count 		
				cmp.b		#1,d6
				ble			order_error

in_order: 		; STM::: else 
				; BDY::: sum = sum + all_roman[r_index].arab_value - 2 * all_roman[r_last].arrab_value
				lea			sum,a2
				clr.l		d1
				move.b		(a2),d1				; d1 = sum
				
				lea			r_index,a2			; a2 points to 'r_index`
				clr.l		d2
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2
				add.w		ARAB_VAL(a0,d2),d1	; d1 = d1 + all_roman[r_index].arab_value
				
				lea			r_last,a2			; a2 points to 'r_last'
				clr.l		d2
				clr.l		d3
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2
				move.w		ARAB_VAL(a0,d2),d3	; d3 = all_roman[r_last].arrab_value
				mulu.w		#2,d3				
				
				sub.b		d3,d1
				lea			sum,a2
				move.b		d1,(a2)
				
				; (all_roman[all_roman[r_index].subtractor_index].count)--
				lea			r_index,a2			; a2 points to 'r_index`
				clr.l		d2
				clr.l		d3			
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2		; d2 = 'r_index' in ROMAN_SIZEs
				move.w		SUB_INDEX(a0,d2),d3 ; d3 = all_roman[r_index].subtractor_index
				
				mulu.w		#ROMAN_SIZE,d3
				subq.b		#1,COUNT(a0,d3)
				
				; all_roman[r_index].count++
				addq.b		#1,COUNT(a0,d2)
				
				; all_roman[r_index].modified = TRUE
				move.w		#TRUE,MODIFIED(a0,d2)
				
				; all_roman[all_roman[r_index].subtractor_index].modifier = TRUE
				clr.l		d3
				move.w		SUB_INDEX(a0,d2),d3	; d3 = all_roman[r_index].subtractor_index
				
				mulu.w		#ROMAN_SIZE,d3
				move.w		#TRUE,MODIFIER(a0,d3)
				
				bra			cnt_read_input
				
order_error:	;BDY::: error = 2
				lea			error,a3			; a3 points to 'error'					
				move.b		#2,(a3)				; d3 holds 'error' value
				bra			cnt_read_input
				

index_LE_last: ; STM::: else if (all_roman[r_index].modifier)
				lea			r_index,a2			; a2 points to 'r_index`
				clr.l		d2
				move.b		(a2),d2
				mulu.w		#ROMAN_SIZE,d2	
				cmp.b		#TRUE,MODIFIER(a0,d2)
				bne			ilgl_comb
				
				; BDY::: error = 3
				lea			error,a2
				move.b		#3,(a2)
				bra			cnt_read_input

ilgl_comb:		; STM::: else if (all_roman[r_index].subtractor_index == all_roman[r_index+1].subtractor_index
				;				&& all_roman[all_roman[r_index].subtractor_index].modifier)
				clr.l		d3
				move.b		#ROMAN_SIZE,d3
				mulu.w		d2,d3
				clr.l		d4
				move.b		SUB_INDEX(a0,d3),d4	; d4 = all_roman[r_index].subtractor_index
				
				add.b		#ROMAN_SIZE,d3
				clr.l		d5
				move.b		SUB_INDEX(a0,d3),d5	; d5 = all_roman[r_index+1].subtractor_index
				
				cmp.b		d4,d5
				bne			legal_combo
				
				clr.l		d6
				move.b		MODIFIER(a0,d4),d6
				cmp.b		#TRUE,d6
				bne			legal_combo
				
				; BDY::: error = 4
				lea			error,a2
				move.b		#4,(a2)
				bra			cnt_read_input
				
				
legal_combo:		; STM::: else
				addq.b		#1,COUNT(a0,d2)
				clr.l		d1
				; if (all_roman[r_index].count <= all_roman[r_index].max_times)
				move.b		COUNT(a0,d2),d1		; d1 = all_roman[r_index].count
				cmp.b		MAX_TIMES(a0,d2),d1
				bgt			exceed_error
				
				; if-body::: sum = sum + all_roman[r_index].arab_value;
				;			  r_last = r_index;
				
				lea			sum,a2
				lea			r_last,a3
				lea			r_index,a4
				clr.l		d3
				
				move.b		ARAB_VAL(a0,d2),d3
				add.b		d3,(a2)				; sum = sum + all_roman[r_index].arab_value;
				
				move.b		(a4),(a3)			; r_last = r_index;
				bra			cnt_read_input
				
exceed_error:	lea			error,a2
				move.b		#5,(a2)

cnt_read_input:	; STM::: if (error == NO_ERROR)
				lea			error,a2
				clr.l		d1
				move.b		(a2),d1
				cmp.b		#NO_ERROR,d1
				bne			check_error
				lea			s_index,a3
				lea			r_last,a4
				addq.b		#1,(a3)
				addq.b		#1,(a4)
				bra			find_error

check_error:	; STM::: if (error)
				clr.l		d1
				lea			error,a2
				move.b 		(a2),d1
				cmp.b		#FALSE,d1
				bne			case0
				bra			prt_sum
				
case0: 			; print error0 message
				lea			error0,a2
prt_case0:		move.b		(a2)+,d0
				beq			digit_place
				jsr			write_char
				bra			prt_case0

digit_place:	lea			s_index,a2
				clr.l		d0
				move.b		#'(',d0
				jsr			write_char
				move.b		(a2),d0
				jsr			write_char
				move.b		#')',d0
				jsr			write_char
				
				move.b		(a2),d2
				clr.l		d0
				move.b		(a1,d2),d0
				jsr			write_char

switch:			; STM::: switch(error)
				lea			error,a2
				clr.l		d1
				move.b		(a2),d1
				
				cmp.b		#1,d1
				beq			case1
				
				cmp.b		#2,d1
				beq			case2
				
				cmp.b		#3,d1
				beq			case3
				
				cmp.b		#4,d1
				beq			case4
				
				cmp.b		#5,d1
				beq			case5
				
default:		lea			error_Def,a3

prt_def:		move.b		(a3)+,d0
				beq			clear_arr
				jsr			write_char
				bra			prt_def
				
case1:			lea			error1,a2
				bra			prt_case
				
case2:			lea			error2,a2
				bra			prt_case
				
case3:			lea			error3,a2
				bra			prt_case
				
case4:			lea			error4,a2
				bra			prt_case
				
case5:			lea			error5,a2
								
prt_case:		move.b		(a2)+,d0
				beq			clear_arr
				jsr			write_char
				bra			prt_case

prt_sum: 		; given digit is valid, print number
				lea			sum,a2
				move.b		#CR,d0
				jsr			write_char
				move.b		#LF,d0
				jsr 		write_char
				
loop_prt_sum:	move.b		(a2)+,d0
				beq			clear_arr
				jsr			write_char
				bra			loop_prt_sum
				
clear_arr: 		; clear array modifiers and counts
				clr.l		d1
				move.b		#MAX_ROMANS,d1			; loop counter
				clr.l		d2
				move.b		#MAX_ROMANS,d2
				mulu.w		#ROMAN_SIZE,d2			; array index value
				
loop_clear_arr:	
				move.b		#0,COUNT(a0,d2)
				move.b		#FALSE,MODIFIED(a0,d2)
				move.b		#FALSE,MODIFIER(a0,d2)
				sub.b		#ROMAN_SIZE,d2
				dbra		d1,loop_clear_arr
				
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

; Variables
				; introduction string to be printed only at the begining of the program
intro:			dc.b		"This program converts numbers in Improved Roman notation to Arabic notation."
				dc.b		CR,LF,TAB,"Input is limited to UPPER case Roman digits only"
				dc.b		CR,LF,TAB,"To exit the program type only the Enter key.",CR,LF,NULL
				even

				; reset string to be printed at every reset of the string
rst_str:		dc.b		CR,LF,TAB,"Input a Roman number (Press 'Q' to exit): ",NULL

				; error message, to be printed at every occurence of an error in the program
error0:			dc.b		CR,LF,TAB,"Character at position ",NULL
				
				; conditional error messages to be printed at the occurence of unique error
error1:			dc.b		CR,LF,TAB,"is not a valid Roman digit",CR,LF,NULL
error2:			dc.b		CR,LF,TAB,"is out of order for a Improved Roman number",CR,LF,NULL
error3:			dc.b		CR,LF,TAB,"has been used as a modifier and can't be used unmodified",CR,LF,NULL
error4:			dc.b		CR,LF,TAB,"combination of the modified prior digit and this digit is",CR,LF,"an invalid Roman number",CR,LF,NULL
error5:			dc.b		CR,LF,TAB,"has exceeded the maximum occurences for this digit",CR,LF,NULL
error_Def:		dc.b		CR,LF,TAB,"In error handling with an invalid error code",CR,LF,NULL
				even

; Program Vaiables:
				; string variable holds user input
string:			ds.b		MAX_STRING+1
				even
				
				; sum holds result of conversion to decimal
sum:			ds.b 		2
				
				; s_index holds index in the 'string' variable of the current digit being converted
s_index:		ds.b		2

				; r_last holds last digit in the array of roman numeral structures
r_last:			ds.b		2

				; r_index holds current index of the roman numeral in the input string
r_index:		ds.b		2
			
				; error holds error code if there is an error found
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