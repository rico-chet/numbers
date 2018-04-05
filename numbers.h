#if !defined(NUMBERS_H_INCLUDED)
#define NUMBERS_H_INCLUDED

#include <stdbool.h>
#include <stdint.h>

typedef uint64_t result_t;
typedef int_fast8_t sign_t;

extern bool numbers(const char* text, result_t* result, sign_t* sign);

#endif
