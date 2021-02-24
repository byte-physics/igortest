#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1

Function/WAVE dataGenGlobal()
	Make/FREE/T data = {"ProcGlobal"}
	return data
End

static Function/WAVE dataGenTestExample()
	Make/FREE/T data = {"ProcGlobal"}
	return data
End
