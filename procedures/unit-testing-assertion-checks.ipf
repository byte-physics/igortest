#pragma rtGlobals=3
#pragma version=1.08
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Checks

// Licensed under 3-Clause BSD, see License.txt

/// @cond HIDDEN_SYMBOL

/// @name CountObjects and CountObjectsDFR constant
/// @anchor TypeFlags
/// @{
static Constant COUNTOBJECTS_WAVES      = 1
static Constant COUNTOBJECTS_VAR        = 2
static Constant COUNTOBJECTS_STR        = 3
static Constant COUNTOBJECTS_DATAFOLDER = 4
/// @}

static Function IsDataFolderEmpty(folder)
	string folder

	return ((CountObjects(folder, COUNTOBJECTS_WAVES) + CountObjects(folder, COUNTOBJECTS_VAR) + CountObjects(folder, COUNTOBJECTS_STR) + CountObjects(folder, COUNTOBJECTS_DATAFOLDER)) == 0)
End

static Function NON_NULL_STR(str)
	string &str

	variable result = (numtype(strlen(str)) == 0)

	SetTestStatusAndDebug("Assumption of str being non null is ", result)
	return result
End

static Function NULL_STR(str)
	string &str

	variable result = (numtype(strlen(str)) == 2)

	SetTestStatusAndDebug("Assumption of str being null is ", result)
	return result
End

static Function EQUAL_VAR(var1, var2)
	variable var1, var2

	variable result
	variable type1 = numType(var1)
	variable type2 = numType(var2)

	if(type1 == type2 && type1 == 2) // both variables being NaN is also true
		result = 1
	else
		result = (var1 == var2)
	endif

	string str
	sprintf str, "%g == %g", var1, var2
	SetTestStatusAndDebug(str, result)
	return result
End

static Function SMALL_VAR(var, tol)
	variable var
	variable tol

	variable result = (abs(var) < abs(tol))

	string str
	sprintf str, "%g ~ 0 with tol %g", var, tol
	SetTestStatusAndDebug(str, result)
	return result
End

static Function CLOSE_VAR(var1, var2, tol, strong_or_weak)
	variable var1, var2
	variable tol
	variable strong_or_weak

	variable diff = abs(var1 - var2)
	variable d1   = diff / abs(var1)
	variable d2   = diff / abs(var2)

	variable result
	if(strong_or_weak == 1)
		result = (d1 <= tol && d2 <= tol)
	elseif(strong_or_weak == 0)
		result = (d1 <= tol || d2 <= tol)
	else
		printf "Unknown mode %d\r", strong_or_weak
	endif

	string str
	sprintf str, "%g ~ %g with %s check and tol %g", var1, var2, SelectString(strong_or_weak, "weak", "strong"), tol
	SetTestStatusAndDebug(str, result)
	return result
End

/// @return 1 if both strings are equal and zero otherwise
static Function EQUAL_STR(str1, str2, case_sensitive)
	string &str1, &str2
	variable case_sensitive

	variable result
	if(NULL_STR(str1) && NULL_STR(str2))
		result = 1
	elseif(NULL_STR(str1) || NULL_STR(str2))
		result = 0
	else
		result = (cmpstr(str1, str2, case_sensitive) == 0)
	endif

	string str
	sprintf str, "\"%s\" == \"%s\" %s case", SelectString(NULL_STR(str1), str1, "(null)"), SelectString(NULL_STR(str2), str2, "(null)"), SelectString(case_sensitive, "not respecting", "respecting")
	SetTestStatusAndDebug(str, result)

	return result
End

/// @endcond // HIDDEN_SYMBOL
