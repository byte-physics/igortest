#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Utils

static Function/S ReferenceConcatenate(txtWave)
	WAVE/T txtWave

	variable i, numRows
	string result = ""

	numRows = DimSize(txtWave, 0)
	for(i = 0; i < numRows; i += 1)
		result += txtWave[i]
	endfor

	return result
End

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

static Function Test_ConcatenateTextWave()
	variable numRows

	for(numRows = 0; numRows <= 9; numRows += 1)
		Make/FREE/T/N=(numRows) wvWave
		WAVE/T wv = wvWave
		wv = "item" + num2istr(p)

		INFO("number of elements %d", n0 = numRows)
		CHECK_EQUAL_STR(ReferenceConcatenate(wv), IUTF_Utils#ConcatenateTextWave(wv))
	endfor

	Make/FREE/T/N=1001 wvWave
	WAVE/T wv = wvWave
	wv = SelectString(mod(p, 3), "", "a" + num2istr(p))
	CHECK_EQUAL_STR(ReferenceConcatenate(wv), IUTF_Utils#ConcatenateTextWave(wv))

	// the argument is not changed
	Make/FREE/T wvWave = {"a", "b", "c"}
	WAVE/T wv = wvWave
	IUTF_Utils#ConcatenateTextWave(wv)
	CHECK_EQUAL_VAR(3, DimSize(wv, 0))
	CHECK_EQUAL_STR("c", wv[2])
End

static Function Test_TextWaveToList()
	variable numRows

	for(numRows = 0; numRows <= 5; numRows += 1)
		Make/FREE/T/N=(numRows) wvWave
		WAVE/T wv = wvWave
		wv = SelectString(mod(p, 2), "", "item" + num2istr(p))

		INFO("number of elements %d", n0 = numRows)
		CHECK_EQUAL_STR(ReferenceTextWaveToList(wv, ";"), IUTF_Utils#TextWaveToList(wv, ";"))
		INFO("number of elements %d", n0 = numRows)
		CHECK_EQUAL_STR(ReferenceTextWaveToList(wv, "\r\n"), IUTF_Utils#TextWaveToList(wv, "\r\n"))
	endfor
End

static Function CheckListToTextWave(list, sep)
	string list, sep

	variable i, numItems

	WAVE/T result = ListToTextWave(list, sep)

	numItems = ItemsInList(list, sep)
	INFO("list \"%s\"", s0 = list)
	CHECK_EQUAL_VAR(numItems, DimSize(result, 0))

	for(i = 0; i < numItems; i += 1)
		INFO("list \"%s\", item %d", s0 = list, n0 = i)
		CHECK_EQUAL_STR(StringFromList(i, list, sep), result[i])
	endfor
End

static Function Test_ListToTextWave()
	CheckListToTextWave("", ";")
	CheckListToTextWave(";", ";")
	CheckListToTextWave(";;", ";")
	CheckListToTextWave("a", ";")
	CheckListToTextWave("a;", ";")
	CheckListToTextWave("a;b", ";")
	CheckListToTextWave("a;;b;", ";")
	CheckListToTextWave(";a", ";")
	CheckListToTextWave("1ab2abab3", "ab")
	CheckListToTextWave("1ab2ab", "ab")
End
