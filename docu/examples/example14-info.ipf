#pragma TextEncoding = "UTF-8"
#pragma version=1.09
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma ModuleName=InfoTest

#include "unit-testing"

static Function Test1()

	// An assertion without an information
	WARN(0)

	// An assertion with an information
	INFO("Information")
	WARN(0)

	// An assertion with multiple information
	INFO("First info")
	INFO("Second info")
	WARN(0)

	// Information with string parameter
	INFO("Param: %s", s0 = "abc")
	INFO("Param: \"%s\", %s", s0 = "abc", s1 = "def")
	INFO("Param: %s %s %s %s %s", s0 = "a", s1 = "b", s2 = "c", s3 = "d", s4 = "e") // up to 5 args
	INFO("Param: %s", s3 = "abc") // skipping index doesn't matter as long as enough values are provided
	WARN(0)

	// Information with string parameter wave
	INFO("Param: %s", s = { "a" })
	INFO("Param: %s %s %s %s %s %s %s", s = { "1", "2", "3", "4", "5", "6", "7" })
	INFO("Param: @%s", s = { "a", "b", "c" }) // print wave at once
	WARN(0)

	// Information with numeric parameter
	INFO("Param: %d", n0 = 1)
	INFO("Param: %d %d", n0 = 1, n1 = 2)
	INFO("Param: %d %d %d %d %d", n0 = 1, n1 = 2, n2 = 3, n3 = 4, n4 = 5) // up to 5 args
	INFO("Param: %d", n3 = 1) // skipping index doesn't matter as long as enough values are provided
	WARN(0)

	// Information with numeric parameter wave
	INFO("Param: %d", n = { 1 })
	INFO("Param: %d %d %d %d %d %d %d", n = { 1, 2, 3, 4, 5, 6, 7 })
	INFO("Param: @%d", n = { 1, 2, 3 })
	WARN(0)

	// Mixing numeric and string parameter
	INFO("Param: %s %d", n0 = 5, s0 = "foo")
	INFO("Param: %s %d %d %s %d", s0 = "foo", n0 = 1, n1 = 2, n2 = 3, s1 = "bar")
	WARN(0)

	// use special formating for numeric parameter
	INFO("Param: %.3f %g %.1W0P", n = { 3.1415, 5.01, 1e6 })
	WARN(0)

	// no info is carried over to the next test case
	INFO("Not carried over")
End

static Function Test2()
	// no info
	WARN(0)

	// no info is printed if assertion succeed
	INFO("succeed")
	WARN(1)

	INFO("no message from succeeded assertion")
	WARN(0)
End
