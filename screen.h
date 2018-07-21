unsigned long long printAt(char *str, unsigned long long row, unsigned long long col);

unsigned long long printTargeted(char *src, char *dest);

unsigned long long print(char *str);

unsigned long long getCursorPosition();

void setCursorPosition(unsigned long long newPos);

void setCursorRowCol(unsigned long long row, unsigned long long col);

void printChar(char c);

void printCharColor(short c);

unsigned long long printCharColorAt(short c, unsigned long long row, unsigned long long col);

unsigned long long printCharAt(char c, unsigned long long row, unsigned long long col);

void clearScreen();

unsigned char rowFromPosition(unsigned short pos);

unsigned char colFromPosition(unsigned short pos);
