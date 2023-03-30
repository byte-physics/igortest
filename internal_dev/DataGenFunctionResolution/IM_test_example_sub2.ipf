#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma IndependentModule=TestExample_IM

Function/WAVE dataGenGlobal()
	Make/FREE/T data = {"ProcGlobal"}
	return data
End

static Function/WAVE dataGenTestExample()
	Make/FREE/T data = {"ProcGlobal"}
	return data
End
