#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Utils

static Function/S ReferenceTextWaveToList(txtWave, sep)
	WAVE/T txtWave
	string sep

	variable i, numRows
	string list = ""

	numRows = DimSize(txtWave, 0)
	for(i = 0; i < numRows; i += 1)
		list = AddListItem(txtWave[i], list, sep, Inf)
	endfor

	return list
End

static Function CheckTextWaveToList(numRows)
	variable numRows

	Make/FREE/T/N=(numRows) wvWave
	WAVE/T wv = wvWave
	wv = SelectString(mod(p, 3), "", "item" + num2istr(p))

	INFO("number of elements %d", n0 = numRows)
	CHECK_EQUAL_STR(ReferenceTextWaveToList(wv, ";"), IUTF_Utils#TextWaveToList(wv, ";"))

	// the reference uses AddListItem(), which only appends the first character of the separator in Igor Pro 6
	if(IgorVersion() >= 7)
		INFO("number of elements %d", n0 = numRows)
		CHECK_EQUAL_STR(ReferenceTextWaveToList(wv, "\r\n"), IUTF_Utils#TextWaveToList(wv, "\r\n"))
	endif
End

static Function Test_TextWaveToList()
	variable numRows

	// up to three levels of splitting into halves in Igor Pro 6
	for(numRows = 0; numRows <= 70; numRows += 1)
		CheckTextWaveToList(numRows)
	endfor

	CheckTextWaveToList(1001)
End

static Function Test_TextWaveToList_LongSep()
	Make/FREE/T wvWave = {"a", "", "b"}
	WAVE/T wv = wvWave

	CHECK_EQUAL_STR("a\r\n\r\nb\r\n", IUTF_Utils#TextWaveToList(wv, "\r\n"))
End
