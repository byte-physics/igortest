#pragma rtGlobals=3
#pragma version=1.08
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Checks

// Licensed under 3-Clause BSD, see License.txt

/// @cond HIDDEN_SYMBOL

static Constant NUMTYPE_NAN = 2

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

static Function IsTrue(var)
	variable var

	return (var == 1)
End

static Function IsNullString(str)
	string &str

	return (numtype(strlen(str)) == NUMTYPE_NAN)
End

static Function IsEmptyString(str)
	string &str

	return (strlen(str) == 0)
End

static Function IsProperString(str)
	string &str

	return !IsEmptyString(str) && !IsNullString(str)
End

static Function AreVariablesEqual(var1, var2)
	variable var1, var2

	variable type1 = numType(var1)
	variable type2 = numType(var2)

	if(type1 == type2 && type1 == NUMTYPE_NAN) // both variables being NaN is also true
		return 1
	else
		return (var1 == var2)
	endif
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
static Function AreStringsEqual(str1, str2, case_sensitive)
	string &str1, &str2
	variable case_sensitive

	case_sensitive = !!case_sensitive

	if(IsNullString(str1) && IsNullString(str2))
		return 1
	elseif(IsNullString(str1) || IsNullString(str2))
		return 0
	else
		return (cmpstr(str1, str2, case_sensitive) == 0)
	endif
End

/// @endcond // HIDDEN_SYMBOL
