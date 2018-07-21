#ifndef SCREEN_H
#define SCREEN_H

void setCursorPosition(unsigned short newPos);

void print(char *str);

void printAt(char *str, unsigned long long row, unsigned long long col);

void long long printTargeted(char *src, char *dest);

void scroll();

unsigned long long getCursorPosition();

void setCursorRowCol(unsigned long long row, unsigned long long col);

void printChar(char c);

void printCharColor(short c);

void printNewLine();

unsigned long long printCharColorAt(short c, unsigned long long row, unsigned long long col);

unsigned long long printCharAt(char c, unsigned long long row, unsigned long long col);

void clearScreen();

unsigned char rowFromPosition(unsigned short pos);

unsigned char colFromPosition(unsigned short pos);

unsigned short getCursorRowCol();

#endif
