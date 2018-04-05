cmake_minimum_required(VERSION 3.1)
project(numbers)

find_package(FLEX)
FLEX_TARGET(Numbers_impl numbers.l ${CMAKE_CURRENT_BINARY_DIR}/numbers.c)

add_executable(numbers ${FLEX_Numbers_impl_OUTPUTS})

enable_testing()
macro(numbers_test name input expected)
    add_test(${name}-${input} /bin/sh -c "[ \"$(./numbers ${input})\" = \"${expected}\" ]")
endmacro(numbers_test)

# simple positive tests
numbers_test(bin-positive b1001  9)
numbers_test(bin-positive b_1001 9)
numbers_test(oct-positive 011    9)
numbers_test(oct-positive 0_11   9)
numbers_test(dec-positive 0      0)
numbers_test(dec-positive 0000   0)
numbers_test(dec-positive 0___   0)
numbers_test(dec-positive 9      9)
numbers_test(dec-positive 9_9    99)
numbers_test(hex-positive 0xa    10)
numbers_test(hex-positive 0x_a_  10)

numbers_test(bin-positive b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 18446744073709551615)
numbers_test(oct-positive 01_777_777_777_777_777_777_777 18446744073709551615)
numbers_test(dec-positive 18446744073709551615 18446744073709551615)
numbers_test(hex-positive 0xFFFF_FFFF_FFFF_FFFF 18446744073709551615)

numbers_test(bin-negative b2  bad)
numbers_test(oct-negative 09  bad)
numbers_test(dec-negative A   bad)
numbers_test(hex-negative 0xG bad)

numbers_test(bin-negative b  bad)
numbers_test(dec-negative A  bad)
numbers_test(hex-negative 0x bad)
numbers_test(hex-negative 0x__ bad)

numbers_test(bin-negative b1_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 bad)
numbers_test(oct-negative 02_777_777_777_777_777_777_777 bad)
numbers_test(dec-negative 18446744073709551616 bad)
numbers_test(hex-negative 0x1_FFFF_FFFF_FFFF_FFFF bad)
