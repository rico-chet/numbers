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
