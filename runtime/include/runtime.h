#pragma once

/// WASM32 pointer size.
typedef unsigned int size_t;

//// MARK: -  JS environment
///// Returns random numbers, used by the implementation of `arc4random`.
//__attribute__((import_module("env"), import_name("random"))) extern unsigned int random(void);
///// Draws an RGBA32 buffer to the screen.
//__attribute__((import_module("env"), import_name("draw"))) extern void draw(const void *buf);
//__attribute__((import_module("env"), import_name("setDisplaySize"))) extern void setDisplaySize(size_t w, size_t h);
//__attribute__((import_module("env"), import_name("getMouseX"))) extern size_t getMouseX(void);
//__attribute__((import_module("env"), import_name("getMouseY"))) extern size_t getMouseY(void);
//__attribute__((import_module("env"), import_name("log"))) extern void log(char *string, int len);
//__attribute__((import_module("env"), import_name("logNum"))) extern void logNum(int num);
//__attribute__((import_module("env"), import_name("warn"))) extern void warn(char *string, int len);
//__attribute__((import_module("env"), import_name("error"))) extern void error(char *string, int len);

extern unsigned char heap;
void *memory_end;

unsigned int memory_size(void);
void memory_grow(unsigned int page_count);

//void initialize(void);
