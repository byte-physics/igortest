#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=TestExampleSub1

#include "igortest"

static Function/WAVE dataGenGlobal()
	Make/FREE/T data = {"TestExampleSub1"}
	return data
End

static Function/WAVE dataGenTestExample()
	Make/FREE/T data = {"TestExampleSub1"}
	return data
End
