#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = TEST_Tracing_Complexity

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)

static Function Test_Complexity_Simple()
	// statements that have no influence into the complexity
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("#pragma ModuleName=abc"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("#if (IgorVersion() >= 9.00)"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity(""))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("string abc = \"def\""))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("\t\tFoo#Bar(42)"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("\tswitch(foo)"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("\ttry"))

	// statements that have an influence of 1
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("static Function Test()"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("\tif(a < b)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("while(1)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("for(i = 0; i < length; i += 1)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("case MAGIC_CONSTANT:"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("SelectString(ParamIsDefault(op), op, \"\")"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("SelectNumber(a < b, b, a)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("\tcatch"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("variable a = mode1 || mode2"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("variable a = mode1 && mode2"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("variable op = ParamIsDefault(op) ? 0 : op"))
End

static Function Test_Complexity_Faulty()
	// malicious code that shouldn't match
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("FunctionCaller"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("CallFunction"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("awhile"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("while_constant"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("for0"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("WrongCase"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("MySelectString"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("CustomSelectNumber"))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("string mode = \"a || b\""))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("printf \"check if okay\""))
	CHECK_EQUAL_VAR(0, IUTF_Tracing#GetCyclomaticComplexity("// wrong case"))
End

static Function Test_Complexity_Combined()
	// combined keywords that increase the complexity
	CHECK_EQUAL_VAR(2, IUTF_Tracing#GetCyclomaticComplexity("if(a || b < 5)"))
	CHECK_EQUAL_VAR(3, IUTF_Tracing#GetCyclomaticComplexity("if(a || (b < 5 && !error))"))
	CHECK_EQUAL_VAR(2, IUTF_Tracing#GetCyclomaticComplexity("try; Call(err); catch; if(err)"))
End

static Function Test_Complexity_Casing()
	// Igor is case insensitive
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("static FunCtion Test()"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("\tIF(a < b)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("whILE(1)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("FOr(i = 0; i < length; i += 1)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("cASe MAGIC_CONSTANT:"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("selectstring(ParamIsDefault(op), op, \"\")"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("selectnumber(a < b, b, a)"))
	CHECK_EQUAL_VAR(1, IUTF_Tracing#GetCyclomaticComplexity("\tcatcH"))
End

#endif
