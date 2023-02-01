#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = TS_GeneratorTestsExtra

#include "unit-testing"

static Function/WAVE GenAbort()
	abort
End

// UTF_TD_GENERATOR GenAbort
static Function TCAbort([var])
	variable var

	PASS()
End

static Function/WAVE GenRTE()
	Make/FREE result = { 1 }

	WAVE/Z wv = $""
	wv[0] = 1

	return result
End

// UTF_TD_GENERATOR GenRTE
static Function TCRTE([var])
	variable var

	PASS()
End

static Function/WAVE GenNull()
	WAVE/Z wv = $""
	return wv
End

// UTF_TD_GENERATOR GenNull
static Function TCNull([var])
	variable var

	PASS()
End

static Function/WAVE Gen2D()
	Make/FREE/N=(2, 2) wv = p + q
	return wv
End

// UTF_TD_GENERATOR Gen2D
static Function TC2D([var])
	variable var

	PASS()
End

static Function/WAVE GenSignature()
	Make/FREE/T/N=1 wv = ""
	return wv
End

// UTF_TD_GENERATOR GenSignature
static Function TCSignature([var])
	variable var

	PASS()
End
