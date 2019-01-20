//
// Copyright (C) 2018 Alex Thiessen <alex.thiessen.de+github@gmail.com>
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

#if !defined(NUMBERS_H_INCLUDED)
#define NUMBERS_H_INCLUDED

#include <stdbool.h>
#include <stdint.h>

typedef uint64_t result_t;
typedef int_fast8_t sign_t;

extern bool numbers(const char* text, result_t* result, sign_t* sign);

#endif
