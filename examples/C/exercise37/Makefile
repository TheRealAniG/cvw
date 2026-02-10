TARGET = exercise37

$(TARGET).objdump: $(TARGET)
	riscv64-unknown-elf-objdump -S -D $(TARGET) > $(TARGET).objdump
	spike $(TARGET)

$(TARGET): fir.S exercise37.c Makefile
	riscv64-unknown-elf-gcc -o $(TARGET) -g \
	  -march=rv64gc -mabi=lp64d -mcmodel=medany \
	  -O2 \
	  -nostdlib -static -lm -fno-tree-loop-distribute-patterns \
	  -T../common/test.ld -I../common \
	  exercise37.c fir.S ../common/crt.S ../common/syscalls.c

clean:
	rm -f $(TARGET) $(TARGET).objdump
