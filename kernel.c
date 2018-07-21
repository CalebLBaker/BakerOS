extern char* print(const char *message);
extern void clearScreen();
extern void printChar(char c);

void main() {
	const char *message = "hi\n";
	clearScreen();
	print("Successfully entered 64 bit kernel.\n");
	printChar('$');
	print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
	print("h\ne\nl\nl\no\n\nw\no\nr\nl\nd\n!\n\n");
	print(message);
	print("a\nb\n");
	printChar('h');
	printChar('\n');
	printChar('i');
	printChar('\n');
	char *longMessage = "n\1234567890223456789032345678904234567889052345678906234567890723456789082345678";
	print(longMessage);
	print("hi");
	print(longMessage);
	printChar('h');
	printChar('i');
}
