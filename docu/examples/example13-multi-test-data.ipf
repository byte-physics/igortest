#pragma rtGlobals=3
#pragma ModuleName=Example13

#include "unit-testing"

// RunTest("example13-multi-test-data.ipf")

// This examples demonstrates the usage of multi data test cases
// Each test case allows an optional parameter and is tagged by a comment above
// to a data generator. The attributed data generator returns a wave that is of the
// same type as the parameter the test case accepts.
// The test case is executed for each wave element.

// This is the first data generator function used by MDTestCaseVar
static Function/WAVE tcDataGenVar()
	Make/FREE data = {5, 1}
	SetDimLabel 0, 0, first, data
	SetDimLabel 0, 1, second, data
	return data
End

// UTF_TD_GENERATOR tcDataGenVar
static Function MDTestCaseVar([var])
	variable var

	CHECK(var == 1 || var == 5)
End

static Function/WAVE tcDataGenStr()
	Make/FREE/T favorites = {"Dancing with the Source", "A Tear in the Veil", "The Battle for Divinity"}
	return favorites
End

// UTF_TD_GENERATOR tcDataGenStr
static Function MDTestCaseStr([str])
	string str

	CHECK(strsearch(str, "the", 0, 2) >= 0)
End

static Function/WAVE tcDataGenWv()
	Make/FREE wa = {1}
	Make/FREE wb = {1}
	Make/FREE/WAVE w1 = {wa, wb}
	Make/FREE/WAVE w2 = {wa, wb}
	Make/FREE/WAVE wr = {w1, w2}
	return wr
End

// UTF_TD_GENERATOR tcDataGenWv
static Function MDTestCaseWv([wv])
	WAVE wv

	WAVE/WAVE wr = wv

	CHECK_EQUAL_WAVES(wr[0], wr[1])
End

static Function/WAVE tcDataGenDFR()
	DFREF dfr = NewFreeDataFolder()
	string/G dfr:data = "Damn it, Steve!"
	Make/FREE/DF w = {dfr}
	return w
End

// UTF_TD_GENERATOR tcDataGenDFR
static Function MDTestCaseDFR([dfr])
	DFREF dfr

	SVAR/Z s = dfr:data
	CHECK(strsearch(s, "Steve!", 0) >= 0)
End
