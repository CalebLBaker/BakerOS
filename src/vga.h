#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>

void setColor(uint8_t color);

void setCursorPosition(uint8_t newPos);

void print(const char *str);

void printAt(const char *str, uint64_t row, uint64_t col);

void printTargeted(const char *src, const char *dest);

void scroll();

uint64_t getCursorPosition();

void setCursorRowCol(uint64_t row, uint64_t col);

void printChar(char c);

void printCharColor(int16_t c);

void printNewLine();

uint64_t printCharColorAt(int16_t c, uint64_t row, uint64_t col);

uint64_t printCharAt(char c, uint64_t row, uint64_t col);

void clearScreen();

unsigned char rowFromPosition(uint16_t pos);

unsigned char colFromPosition(uint16_t pos);

unsigned short getCursorRowCol();

#endif
