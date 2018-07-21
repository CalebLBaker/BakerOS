extern char* print(const char *message);
extern void clearScreen();

void main() {
	const char *message = "Successfully entered 64 bit kernel.\n$";
	clearScreen();
	print(message);
}
