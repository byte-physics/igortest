#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=Example13internal

#include "igortest"

// RunTest("example13-multi-test-data.ipf")

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

static Function/WAVE tcDataGenInt()
	Make/FREE/L data = {5, 1}
	return data
End

// UTF_TD_GENERATOR tcDataGenInt
static Function MDTestCaseInt([int])
	Int64 int

	CHECK(int == 1 || int == 5)
End

static Function/WAVE tcDataGenCmpl()
	Make/FREE/C data = {cmplx(5,1), 1}
	return data
End

// UTF_TD_GENERATOR tcDataGenCmpl
static Function MDTestCaseCmpl([cmpl])
	variable/C cmpl

	CHECK(cmpl == 5 || cmpl == 1)
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


// FAILS
// NO_GENERATOR
static Function MultiTestCaseFail([var])
	variable var

	CHECK(var)
End

// UTF_TD_GENERATOR IdoNotExist
static Function MultiTestCaseFail2([var])
	variable var

	CHECK(var)
End

// wrong generator
// UTF_TD_GENERATOR tcDataGenVar
static Function MultiTestCaseFail3([str])
	string str

End

// wrong generator
// UTF_TD_GENERATOR tcDataGenVar
static Function MultiTestCaseFail4([dfr])
	DFREF dfr

End

// wrong generator
// UTF_TD_GENERATOR tcDataGenVar
static Function MultiTestCaseFail5([wv])
	WAVE wv

End

// wrong generator
// UTF_TD_GENERATOR tcDataGenVar
static Function MultiTestCaseFail6([cmpl])
	Complex cmpl

End

// wrong generator
// UTF_TD_GENERATOR tcDataGenVar
static Function MultiTestCaseFail7([int])
	Int64 int

End

// wrong function format
static Function NoMultiTestCase(var)
	variable var

	CHECK(var)
End
