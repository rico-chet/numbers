%top{
#include <stdbool.h>
#include <stdint.h>

typedef uint64_t result_t;

#define YY_DECL bool yylex(result_t* result)

#define yyterminate() return false

}

%x binary
%x octal
%x decimal
%x hexadecimal

BIN [01]
OCT [0-7]
DEC [[:digit:]]
HEX [[:xdigit:]]
SEP [_]

%%
%{
	uint32_t base = 0;
    bool have_digit = false;

    if (!result)
        return false;

	bool overflows(const result_t next_digit) {
		return !(*result <= *result * base + next_digit);
	}

	result_t get_digit(const char* const digit_text) {
		const char digit_char = digit_text[0];
		if ('0' <= digit_char && digit_char <= '9')
			return digit_char - '0';
		else if ('a' <= digit_char && digit_char <= 'f')
			return 10 + digit_char - 'a';
		else if ('A' <= digit_char && digit_char <= 'F')
			return 10 + digit_char - 'A';
		else return 0;
	}

    bool process_digit(const char* const digit_text) {
		const result_t digit = get_digit(yytext);
		if (overflows(digit)) {
            return false;
		}

		*result = *result * base + digit;
        return true;
	}

%}

b({BIN}|{SEP})   { BEGIN(binary     ); base =  2; /* skip prefix and re-parse */ yyless(1); }
0                { BEGIN(octal      ); base =  8; have_digit = true;                        }
[1-9]            { BEGIN(decimal    ); base = 10; /* skip prefix and re-parse */ yyless(0); }
0x({HEX}|{SEP})  { BEGIN(hexadecimal); base = 16; /* skip prefix and re-parse */ yyless(2); }

<binary,octal,decimal,hexadecimal>{SEP} { /* ignore separators */ }

<binary>{BIN}      { if (!process_digit(yytext)) yyterminate(); else have_digit = true; }
<octal>{OCT}       { if (!process_digit(yytext)) yyterminate(); else have_digit = true; }
<decimal>{DEC}     { if (!process_digit(yytext)) yyterminate(); else have_digit = true; }
<hexadecimal>{HEX} { if (!process_digit(yytext)) yyterminate(); else have_digit = true; }

<binary,octal,decimal,hexadecimal><<EOF>> { return have_digit; }
<binary,octal,decimal,hexadecimal>. { yyterminate(); }
. { yyterminate(); }
%%

#undef yywrap
int yywrap() {
	return 1;
}

int main(int argc, char* argv[]) {
    if (argc <= 1)
        return 1;

	result_t result = 0;
    YY_BUFFER_STATE buffer = yy_scan_string(argv[1]);
	const bool good = yylex(&result);
	yy_delete_buffer(buffer);

    if (good) {
        printf("%u\n", result);
        return 0;
    } else {
		puts("bad");
        return 1;
    }
}
