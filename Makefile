# This file is part of the mkcheck project.
# Licensing information can be found in the LICENSE file.
# (C) 2017 Nandor Licker. All rights reserved.

CC = gcc
OUT = out

.PHONY: dirs clean

all : dirs $(OUT)/main $(OUT)/a.txt

dirs : $(OUT)

$(OUT) :
	mkdir -p $(OUT)

$(OUT)/lib_a.o : lib_a/lib_a.c lib_a/lib_a.h
	$(CC) -c -o $(OUT)/lib_a.o lib_a/lib_a.c

# missing deps on lib_b/lib_b1.h
$(OUT)/lib_b.o : lib_b/lib_b.c lib_b/lib_b.h
	$(CC) -c -o $(OUT)/lib_b.o lib_b/lib_b.c

# missing deps on lib_b/lib_b.h lib_b/lib_b1.h e.h
$(OUT)/a.o : a.c a.h
	$(CC) -c -o $(OUT)/a.o a.c

# missing deps on e.h
# extra deps on c.h
$(OUT)/b.o : b.c b.h a.h c.h
	$(CC) -c -o $(OUT)/b.o b.c

# missing deps on a.h, d.h e.h
$(OUT)/c.o : c.c c.h
	$(CC) -c -o $(OUT)/c.o c.c

# missing deps on a.h, b.h, c.h, lib_a/lib_a.h, lib_b/lib_b.h
$(OUT)/main.o : main.c
	$(CC) -c -o $(OUT)/main.o main.c

$(OUT)/main : $(OUT)/main.o $(OUT)/a.o $(OUT)/b.o $(OUT)/c.o $(OUT)/lib_a.o $(OUT)/lib_b.o
	$(CC) -o $(OUT)/main $(OUT)/main.o $(OUT)/a.o $(OUT)/b.o $(OUT)/c.o $(OUT)/lib_a.o $(OUT)/lib_b.o

$(OUT)/a.txt: b.txt c.txt
	cat b.txt c.txt d.txt > out/a.txt

clean :
	rm -rf $(OUT)
	
test :
	make clean
	../../build/mkcheck -o /tmp/graph -- make -j1
	@echo "Fuzzing parallel"
	python3 ../../tools/fuzz_test --graph-path=/tmp/graph fuzz
