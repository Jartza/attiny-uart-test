;
; ASM Uart ISR vector for Attiny
;
#define _SFR_ASM_COMPAT 1
#define __SFR_OFFSET 0
#include <avr/io.h>
#include "uart.h"

.global TIM0_COMPA_vect

TIM0_COMPA_vect:
	push r18		; store r18
	in r18, SREG		; read SREG
	out sregstore, r18	; store into GPIOR

	in r18, state		; read current state
	cpi r18, START		; start bit?
	brcs done		; it was zero. get out of here.
	breq startbit		; yes it was
	cpi r18, STOP		; stop bit?
	brne databit		; jump if it was data

stopbit:
	sbi UART_PORT, UART_TX	; stop bit (high)
	clr r18			; zero state
	rjmp store		; store state

startbit:
	cbi UART_PORT, UART_TX	; start bit (low)
	rjmp incstate		; increment state

databit:
	in r18, current_byte	; read current tx byte
	bst r18, 0		; store LSB in T
	lsr r18			; shift right
	out current_byte, r18	; store it back
	in r18, UART_PORT	; read current state
	bld r18, UART_TX	; set bit from T
	out UART_PORT, r18	; write value

incstate:
	in r18, state		; read state
	inc r18			; increment

store:
	out state, r18		; store state back

done:
	in r18, sregstore	; read SREG from GPIOR
	out SREG, r18		; restore SREG
	pop r18			; restore r18
	reti			; return
