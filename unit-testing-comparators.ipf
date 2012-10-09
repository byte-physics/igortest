#pragma rtGlobals=3		// Use modern global access method.

static Function EQUAL_VAR(var1, var2)
	variable var1, var2

	variable result = ( var1 == var2 )
	
	string str
	sprintf str, "%g == %g", var1, var2
	DEBUG_OUTPUT(str, result)
	return result
End

static Function SMALL_VAR(var, tol)
	variable var
	variable tol
	
	variable result = ( abs(var) < abs(tol) )

	string str
	sprintf str, "%g ~ 0 with tol %g", var, tol
	DEBUG_OUTPUT(str, result)
	return result
End

// Based on the implementation of "Floating-point comparison algorithms" in the C++ Boost unit testing framework
// 
// Literature:
// The art of computer programming (Vol II). Donald. E. Knuth. 0-201-89684-2. Addison-Wesley Professional;
// 3 edition, page 234 equation (34) and (35)
static Function CLOSE_VAR(var1, var2, tol, strong_or_weak)
	variable var1, var2
	variable tol
	variable strong_or_weak
	
	variable diff  = abs(var1 - var2)
	variable d1 	= diff/var1
	variable d2 	= diff/var2

	variable result
	if(strong_or_weak == 1)
		result = ( d1 <= tol && d2 <= tol )
	elseif(strong_or_weak == 0)
		result = ( d1 <= tol || d2 <= tol ) 
	else
		printf "Unknown mode %d\r", strong_or_weak
	endif
		
	string str
	sprintf str, "%g ~ %g with %s check and tol %g", var1, var2, SelectString(strong_or_weak,"weak","strong"), tol
	DEBUG_OUTPUT(str, result)
	return result
End

static Function EQUAL_STR(str1, str2)
	string str1, str2

	variable result = ( cmpstr(str1, str2) == 0 )
	
	string str
	sprintf str, "\"%s\" == \"%s\"", str1, str2
	DEBUG_OUTPUT(str, result)
	return result
End

Function CHECK_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
	variable tol
	variable strong_or_weak
	
	if(ParamIsDefault(strong_or_weak))
		strong_or_weak	= 1
	endif

	if(ParamIsDefault(tol))
		tol = 1e-8
	endif

	if( !CLOSE_VAR(var1, var2, tol, strong_or_weak) )
		incrError()
		printFailInfo()
	endif
End

Function CHECK_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		tol = 1e-8
	endif

	if( !SMALL_VAR(var, tol) )
		incrError()
		printFailInfo()
	endif
End

Function printFailInfo()
	printInfo(0)
End

Function printSuccessInfo()
	printInfo(1)
End

Function printInfo(result)
	variable result

	string callStack = GetRTStackInfo(3)
	
	string initialCaller 	= StringFromList(1,callStack,";")
	string procedure		= StringFromList(1,initialCaller,",")
	string line				= StringFromList(2,initialCaller,",")

	// get the line which called the caller of this function
	string procedureContents = ProcedureText("",-1,procedure)
	string text = StringFromList(str2num(line),procedureContents,"\r")
	
	// remove leading and trailing whitespace
	string cleanText
	SplitString/E="^[[:space:]]*(.+?)[[:space:]]*$" text, cleanText

	printf "Assertion \"%s\" %s in line %s, procedure %s\r", cleanText,  SelectString(result,"failed","suceeded"), line, procedure
End

Function CHECK(var)
	variable var

	variable result = ( var == 1 )
	if( !result )
		incrError()
		printFailInfo()
	endif
	
	string str
	sprintf str, "%g", var
	DEBUG_OUTPUT(str, result)
End

Function CHECK_EQUAL_VAR(var1, var2)
	variable var1, var2
	
	if( !EQUAL_VAR(var1, var2) )
		incrError()
		printFailInfo()
	endif
End

Function CHECK_EQUAL_STR(str1, str2)
	string str1, str2
	
	if( !EQUAL_STR(str1, str2) )
		incrError()
		printFailInfo()
	endif
End

Function CHECK_NE_VAR(var1, var2)
	variable var1, var2
	
	if( EQUAL_VAR(var1, var2) )
		incrError()
		printFailInfo()
	endif
End

Function CHECK_NE_STR(str1, str2)
	string str1, str2
	
	if( EQUAL_STR(str1, str2) )
		incrError()
		printFailInfo()
	endif
End
