﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma ModuleName=UTF_TestTextWaveDiff

#include "unit-testing"

// Licensed under 3-Clause BSD, see License.txt

static Function TC_CheckForWaveDifferences()
	Make/FREE/T/N=4 wv1
	Make/FREE/T/N=4 wv2

	variable i

	wv1[0] = "My example\nDocumentation\nwith a small difference\n"
	wv2[0] = "My example\nDocumentation\nwith a smoll difference\n"

	// very long text
	wv1[1] = ""
	wv2[1] = ""
	PadString(wv1[1], 500, "0")
	PadString(wv2[1], 500, "0")
	wv1[1] += "a"
	wv2[1] += "z"
	PadString(wv1[1], 1000, "1")
	PadString(wv2[1], 1000, "1")

	wv1[2] = "Example\ntext\nwith\nunexpected\nline\nendings."
	wv2[2] = "Example\rtext\rwith\runexpected\rline\rendings."

	// the error should be on the line 3 (counting from zero)
	wv1[3] = "Can also\r\nwork with\r\nWindows\r\nline endings."
	wv2[3] = "Can also\r\nwork with\r\nWindows\r\nline endings!"

	CHECK_EQUAL_WAVES(wv1, wv2)
End