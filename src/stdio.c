#include <stdarg.h>
#include <stdbool.h>
#include "string.h"
#include "vga.h"
#include "stdio.h"


int printInt(uint64_t val, uint8_t base, int8_t index, bool sign) {
	int written = 0;
	if (sign && (int64_t)val < 0) {
		printChar('-');
		val = (uint64_t)(-(int64_t)val);
		written++;
	}
	uint64_t order = 1;
	for (uint8_t i = 0; i < index; i++) {
		order *= base;
	}
	for (bool empty = true; order; order /= base) {
		uint8_t digit = (uint8_t) (val / order);
		val %= order;
		index--;
		if (empty) {
			if (!digit && index >= 0) {
				continue;
			}
			else {
				empty = false;
				written += index + 2;
			}
		}
		if (digit < 0xa) {
			printChar(digit + '0');
		}
		else {
			printChar(digit + 87);
		}
	}
	return written;
}


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
					unsigned val = va_arg(parameters, unsigned);
					written += printInt((uint64_t)val, 0x10, 7, false);
					format++;
					break;
				}
				case ('i') : {
					int val = va_arg(parameters, int);
					written += printInt((uint64_t)val, 10, 9, true);
					format++;
					break;
				}
				case ('u') : {
					unsigned val = va_arg(parameters, unsigned);
					written += printInt((uint64_t)val, 10, 9, false);
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

