


main: main.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lSDL3 -o main -no-pie main.o 

main.o: main.s
	as --64 -o main.o main.s
