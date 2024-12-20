#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=SortingTestcases

#include "igortest"

// RunTest("issue109-sorting-testcases.ipf")

// This example has multidata and normal tests combined, with the order
// as theire function names, to easily detect a wrong order of test cases.

// This is the first data generator function used by MDTestCaseVar
static Function/WAVE tcDataGenVar()
	Make/FREE data = {5, 1}
	SetDimLabel 0, 0, first, data
	SetDimLabel 0, 1, second, data
	return data
End

// IUTF_TD_GENERATOR tcDataGenVar
static Function MDTestFirst([var])
	variable var

	CHECK(var == 1 || var == 5)
End

static Function TestSecond()
	Check(1)
End

static Function/WAVE tcDataGenStr()
	Make/FREE/T favorites = {"Dancing with the Source", "A Tear in the Veil", "The Battle for Divinity"}
	return favorites
End

// IUTF_TD_GENERATOR tcDataGenStr
static Function MDTestThird([str])
	string str

	CHECK(strsearch(str, "the", 0, 2) >= 0)
End

static Function TestFourth()
	Check(1)
End

static Function/WAVE tcDataGenWv()
	Make/FREE wa = {1}
	Make/FREE wb = {1}
	Make/FREE/WAVE w1 = {wa, wb}
	Make/FREE/WAVE w2 = {wa, wb}
	Make/FREE/WAVE wr = {w1, w2}
	return wr
End

// IUTF_TD_GENERATOR tcDataGenWv
static Function MDTestFifth([wv])
	WAVE wv

	WAVE/WAVE wr = wv

	CHECK_EQUAL_WAVES(wr[0], wr[1])
End

static Function TestSixth()
	Check(1)
End

static Function/WAVE tcDataGenDFR()
	DFREF    dfr      = NewFreeDataFolder()
	string/G dfr:data = "Damn it, Steve!"
	Make/FREE/DF w = {dfr}
	return w
End

// IUTF_TD_GENERATOR tcDataGenDFR
static Function MDTestSeventh([dfr])
	DFREF dfr

	SVAR/Z s = dfr:data
	CHECK(strsearch(s, "Steve!", 0) >= 0)
End
