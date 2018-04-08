//
// Copyright (C) 2018 Alex Thiessen <alex.thiessen.de+github@gmail.com>
//
// This file is part of Numbers.
//
// Numbers is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
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
// SPDX-License-Identifier: GPL-3.0-or-later
// <https://spdx.org/licenses/GPL-3.0-or-later.html>
//

#include <inttypes.h>
#include <stdio.h>

#include "numbers.h"

int main(const int argc, const char* const argv[])
{
	if (argc <= 1)
		return 1;

	result_t result = 0;
	sign_t   sign   = 0;
	if (numbers(argv[1], &result, &sign))
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
