%top{

//
// Copyright (C) 2018-2019 Alex Thiessen <alex.thiessen.de+github@gmail.com>
//
// This file is part of Numbers.
//
// Numbers is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// Numbers is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Numbers.  If not, see <http://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: GPL-2.0-or-later
// <https://spdx.org/licenses/GPL-2.0-or-later.html>
//

#include "numbers.h"

#define YY_DECL bool yylex(result_t* result, sign_t* sign)

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
	// positive sign is implicit
	*sign = 1;

#define PROCESS_DIGIT() \
	if (!process_digit(result, yytext, base)) \
		yyterminate(); \
	else \
		have_digit = true

%}

[+-] {
	if (have_sign)
		yyterminate();

	have_sign = true;
	*sign = yytext[0] == '-' ? -1 : 1;
}

b({BIN}|{SEP})   { BEGIN(binary     ); base =  2; /* skip prefix and re-parse */ yyless(1); }
0                { BEGIN(octal      ); base =  8; have_digit = true;                        }
[1-9]            { BEGIN(decimal    ); base = 10; /* skip prefix and re-parse */ yyless(0); }
0x({HEX}|{SEP})  { BEGIN(hexadecimal); base = 16; /* skip prefix and re-parse */ yyless(2); }

<binary,octal,decimal,hexadecimal>{SEP} { /* ignore separators */ }

<binary>{BIN}      { PROCESS_DIGIT(); }
<octal>{OCT}       { PROCESS_DIGIT(); }
<decimal>{DEC}     { PROCESS_DIGIT(); }
<hexadecimal>{HEX} { PROCESS_DIGIT(); }

<binary,octal,decimal,hexadecimal><<EOF>> {
	// zero has no sign
	if (have_digit)
		*sign = *result == 0 ? 0 : *sign;
	return have_digit;
}

<binary,octal,decimal,hexadecimal>. { yyterminate(); }
. { yyterminate(); }
%%

#undef yywrap
int yywrap()
{
	return 1;
}

bool numbers(const char* const text, result_t* const result, sign_t* sign)
{
	if (!(text && result))
		return false;

	// sign is optional
	sign_t dummy_sign = 0;
	if (!sign)
		sign = &dummy_sign;

	YY_BUFFER_STATE buffer = yy_scan_string(text);
	const bool      good   = yylex(result, sign);
	yy_delete_buffer(buffer);

	return good;
}
