;
; ASM Uart ISR vector for Attiny
;
#define _SFR_ASM_COMPAT 1
#define __SFR_OFFSET 0
#include <avr/io.h>
#include "uart.h"

.global TIM0_COMPA_vect

TIM0_COMPA_vect:
	; (7)
	push r18		; (2)
	in r18, SREG		; (1)
	out sregstore, r18	; (1)

	in r18, state		; read current state (1)
	cpi r18, START		; start bit? (1) (=13)
	brcs done		; it was zero. get out of here. (1 or 2)
	breq startbit		; yes it was (1 or 2)
	cpi r18, STOP		; stop bit? (1)
	brne databit		; jump if it was data (1 or 2)

stopbit:
	sbi UART_PORT, UART_TX	; stop bit (high) (2)
	clr r18			; zero state (1)
	rjmp store		; (2)

startbit:
	cbi UART_PORT, UART_TX	; start bit (low) (2)
	rjmp incstate		; (2)


databit:
	in r18, current_byte	; read current tx byte (1)
	bst r18, 0		; store LSB in T (1)
	lsr r18			; shift right (1)
	out current_byte, r18	; store it back (1)
	in r18, UART_PORT	; read current state (1)
	bld r18, UART_TX	; set bit from T (1)
	out UART_PORT, r18	; write value (1)

incstate:
	in r18, state		; read state (1)
	inc r18			; increment (1)

store:
	out state, r18		; store back (1)

done: ; (8)
	in r18, sregstore	; (1)
	out SREG, r18		; restore SREG (1)
	pop r18			; (2)
	reti			; (4)


; none = 23
; start = 31
; zero bit = 34
; one bit = 36
; stop = 31
