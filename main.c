/* Name: uart.c
 * Author: Jari Tulilahti
 *
 * UART TEST
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include "uart.h"

/* 
 * Baud rate definition
 * 1MHz: 9600 - 19200 baud
 * 8MHz: 38400 - 115200 baud
 * 16MHz: 115200 - 230400 baud
 */
#define BAUD        230400
#define BAUD_DIV    (F_CPU / BAUD) - 0.5
// #define BAUD_DIV 32 (460800 baud testing)

/* Transmit a byte. Blocking, no buffering */
static void tx(const uint8_t c) {
    while (state);
    current_byte = c;
    state = START;
}

/* Set up Timer0 for interrupts */
void init_serial() {
    /* TX pin as output */
    SET(UART_DDR, UART_TX);

    /* Init Timer0 and enable interrupts */
    cli();
    TCCR0A |= (1 << WGM01);     // CTC mode
    TCCR0B |= (1 << CS10);      // No prescaler
    OCR0A = BAUD_DIV;           // Compare value
    TIMSK0 |= (1 << OCIE0A);    // Enable compare interrupt
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