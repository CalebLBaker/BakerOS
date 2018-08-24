#include <stdarg.h>
#include <stdbool.h>
#include "string.h"
#include "vga.h"
#include "stdio.h"

int printf(const char* format, ...) {
	va_list parameters;
	va_start(parameters, format);
	int written = 0;
	while (*format) {
		if (*format != '%' || format[1] == '%') {
			if (*format == '%') {
				format++;
			}
			for (; *format && *format != '%'; format++) {
				printChar(*format);
				written++;
			}
		}
		else {
			format++;
			switch (*format) {
				case ('c') : {
					printChar((char)va_arg(parameters, int));
					written++;
					format++;
					break;
				}
				case ('s') : {
					const char *s = va_arg(parameters, const char*);
					int len = strlen(s);
					print(s);
					written += len;
					format++;
					break;
				}
				case ('x') : {
					uint32_t hex = va_arg(parameters, int);
					bool empty = true;
					int8_t index = 7;
					for (uint32_t mask = 0xf0000000; mask != 0; mask >>= 4) {
						uint8_t data = (uint8_t) ((hex & mask) >> (index << 2));
						index--;
						if (empty) {
							if (!data && index >= 0) {
								continue;
							}
							else {
								empty = false;
								written += (index + 2);
							}
						}

						// Add '0' for 0-9 add 'a'-10 for a-f
						if (data < 0xa)	{
							printChar(data + '0');
						}
						else {
							printChar(data + 87);
						}
					}
					format++;
					break;
				}
				default : {
					va_end(parameters);
					return -1;
				}					
			}
		}
	}
	va_end(parameters);
	return written;
}

