#include "uart.h"

int main()
{
    init_uart(50000000, 115200);
    print_uart("Hello World!\r\n");

    int res = 0;

    if (res == 0)
    {
        // jump to the address
        __asm__ volatile(
            "li s0, 0x80000000;"
            "la a1, _dtb;"
            "jr s0");
    }

    while (1)
    {
        // do nothing
    }
}

void handle_trap(void)
{
    // print_uart("trap\r\n");
}