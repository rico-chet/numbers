%top{

#include <stdbool.h>
#include <stdint.h>

typedef uint64_t result_t;

#define YY_DECL bool yylex(result_t* result, int* sign)

#define yyterminate() return false

}

%{

static result_t get_digit(const char* const digit_text)
{
	if (!digit_text)
		return 0;

	const char digit_char = digit_text[0];
	if ('0' <= digit_char && digit_char <= '9')
		return digit_char - '0';
	else if ('a' <= digit_char && digit_char <= 'f')
		return 10 + digit_char - 'a';
	else if ('A' <= digit_char && digit_char <= 'F')
		return 10 + digit_char - 'A';
	else
		return 0;
}

static bool overflows(const result_t  current_result,
                      const result_t  next_digit,
                      result_t* const next_result,
                      const uint32_t  base)
{
	result_t next_result_m = 0;
	if (__builtin_umull_overflow(current_result, base, &next_result_m))
		return true;

	result_t next_result_ma = next_result_m + next_digit;
	if (__builtin_uaddl_overflow(next_result_m, next_digit, &next_result_ma))
		return true;

	if (next_result)
		*next_result = next_result_ma;

	return false;
}

static bool process_digit(result_t* const   result,
                          const char* const digit_text,
                          const uint32_t    base)
{
	if (!(result && digit_text))
		return false;

	const result_t digit = get_digit(yytext);
	if (overflows(*result, digit, result, base))
	{
		*result = 0;
		return false;
	}

	return true;
}

%}

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
	bool have_sign = false;

	if (!(result && sign))
		yyterminate();

	*result = 0;
	*sign = 0;

%}

[+-] { have_sign = true; *sign = yytext[0] == '-' ? -1 : 1; }

b({BIN}|{SEP})   { BEGIN(binary     ); base =  2; /* skip prefix and re-parse */ yyless(1); }
0                { BEGIN(octal      ); base =  8; have_digit = true;                        }
[1-9]            { BEGIN(decimal    ); base = 10; /* skip prefix and re-parse */ yyless(0); }
0x({HEX}|{SEP})  { BEGIN(hexadecimal); base = 16; /* skip prefix and re-parse */ yyless(2); }

<binary,octal,decimal,hexadecimal>{SEP} { /* ignore separators */ }

<binary>{BIN}      { if (!process_digit(result, yytext, base)) yyterminate(); else have_digit = true; }
<octal>{OCT}       { if (!process_digit(result, yytext, base)) yyterminate(); else have_digit = true; }
<decimal>{DEC}     { if (!process_digit(result, yytext, base)) yyterminate(); else have_digit = true; }
<hexadecimal>{HEX} { if (!process_digit(result, yytext, base)) yyterminate(); else have_digit = true; }

<binary,octal,decimal,hexadecimal><<EOF>> { return have_digit; }
<binary,octal,decimal,hexadecimal>. { yyterminate(); }
. { yyterminate(); }
%%

#undef yywrap
int yywrap()
{
	return 1;
}

#include <inttypes.h>

int main(int argc, char* argv[])
{
	if (argc <= 1)
		return 1;

	result_t        result = 0;
	int             sign   = 0;
	YY_BUFFER_STATE buffer = yy_scan_string(argv[1]);
	const bool      good   = yylex(&result, &sign);
	yy_delete_buffer(buffer);

	if (good)
	{
		printf("%s%" PRIu64 "\n", sign < 0 ? "-" : "", result);
		return 0;
	}
	else
	{
		puts("bad");
		return 1;
	}
}
