/* Name: uart.c
 * Author: Jari Tulilahti
 *
 * UART TEST
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "uart.h"

#define SET(x,y)    (x |= (1 << y))

/* 
 * Baud rate definition
 * 1MHz: 9600 - 19200 baud
 * 8MHz: 38400 - 230400 baud
 * 16MHz: 115200 - 460800 baud
 */
#define BAUD        460800
#define BAUD_DIV    (F_CPU / BAUD) - 0.5

/* Transmit a byte. Blocking, no buffering */
static void tx(const uint8_t c) {
    while (state);
    state = START;
    current_byte = c;
    TIMSK0 = (1 << OCIE0A);     // Enable compare interrupt
}

/* Set up Timer0 for interrupts */
void init_serial() {
    /* TX pin as output */
    SET(UART_DDR, UART_TX);

    /* Init Timer0 and enable interrupts */
    cli();
    TCCR0A |= (1 << WGM01);     // CTC mode
    TCCR0B |= (1 << CS10);      // Clock source CPU clock
    OCR0A = BAUD_DIV;           // Compare value
    sei();
}

int main (void)
{
    init_serial();

    for(;;) {
        for(uint8_t i = 33; i < 126; i++) {
            tx(i);
        }
        tx(10);
    }

    return 1;
}
