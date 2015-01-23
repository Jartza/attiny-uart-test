;
; ASM Uart ISR vector for Attiny
;
#define _SFR_ASM_COMPAT 1
#define __SFR_OFFSET 0
#include <avr/io.h>
#include "uart.h"

.global TIM0_COMPA_vect

TIM0_COMPA_vect:

	push r18
	push r0
	in r0, SREG				; store SREG

	in r18, state			; read current state
	cpi r18, START			; start bit?
	brcs done				; it was zero. get out of here.
	breq startbit			; yes it was
	cpi r18, STOP			; stop bit?
	brne databit			; jump if it was data

stopbit:
	sbi UART_PORT, UART_TX	; stop bit (high)
	clr r18					; zero state
	rjmp store

startbit:
	cbi UART_PORT, UART_TX	; start bit (low)
	rjmp incstate

databit:
	in r18, current_byte	; read current tx byte
	lsr r18					; shift right
	out current_byte, r18	; store it back
	brcs one				; was LSB one?
	cbi UART_PORT, UART_TX	; it was zero
	rjmp incstate

one:
	sbi UART_PORT, UART_TX	; bit zero

incstate:
	in r18, state			; read state
	inc r18					; increment

store:
	out state, r18			; store back

done:
	out SREG, r0			; restore SREG
	pop r0
	pop r18
	reti
