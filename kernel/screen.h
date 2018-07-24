#ifndef SCREEN_H
#define SCREEN_H

#include "types.h"

void setCursorPosition(uint8 newPos);

void print(const char *str);

void printAt(const char *str, uint64 row, uint64 col);

void printTargeted(const char *src, const char *dest);

void scroll();

uint64 getCursorPosition();

void setCursorRowCol(uint64 row, uint64 col);

void printChar(char c);

void printCharColor(int16 c);

void printNewLine();

uint64 printCharColorAt(int16 c, uint64 row, uint64 col);

uint64 printCharAt(char c, uint64 row, uint64 col);

void clearScreen();

unsigned char rowFromPosition(uint16 pos);

unsigned char colFromPosition(uint16 pos);

unsigned short getCursorRowCol();

#endif
