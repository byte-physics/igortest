#pragma rtGlobals=3		// Use modern global access method.

/// Checks if both variables are equal
/// @return 1 if both variables are equal and zero otherwise
static Function EQUAL_VAR(var1, var2)
	variable var1, var2

	variable result = ( var1 == var2 )
	
	string str
	sprintf str, "%g == %g", var1, var2
	DEBUG_OUTPUT(str, result)
	return result
End

/// Checks if a variable is small
/// @param var variable to check
/// @param tol tolerance for comparison
/// @return 1 if var is small compared to tol
static Function SMALL_VAR(var, tol)
	variable var
	variable tol
	
	variable result = ( abs(var) < abs(tol) )

	string str
	sprintf str, "%g ~ 0 with tol %g", var, tol
	DEBUG_OUTPUT(str, result)
	return result
End

/// Compares two variables (floating point type) if they are close
/// @param var1 				first variable
/// @param var3 				second variable
/// @param tol 				absolute tolerance of the comparison
/// @param strong_or_weak	Use the strong (1) condition or the weak (0)
/// @return					1 if they are close and zero otherwise
///
/// Based on the implementation of "Floating-point comparison algorithms" in the C++ Boost unit testing framework
/// 
/// Literature:
/// The art of computer programming (Vol II). Donald. E. Knuth. 0-201-89684-2. Addison-Wesley Professional;
/// 3 edition, page 234 equation (34) and (35)
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

/// @return 1 if both strings are equal and zero otherwise
static Function EQUAL_STR(str1, str2, case_sensitive)
	string str1, str2
	variable case_sensitive
	
	variable result = ( cmpstr(str1, str2, case_sensitive) == 0 )
	
	string str
	sprintf str, "\"%s\" == \"%s\" %s case", str1, str2, SelectString(case_sensitive,"not respecting","respecting")
	DEBUG_OUTPUT(str, result)
	return result
End

/// Checks if two variables are close
/// @param var1 			first variable
/// @param var2 			second variable
/// @param tol				defaults to 1e-8
/// @param strong_or_weak	defaults to 1 (strong condition)
/// 
/// @see CLOSE_VAR
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

/// Checks if var is small
/// @param var		variable
/// @param tol 	defaults to 1e-8
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


/// Checks if var is true (1)
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

/// Compares two variables for equality
Function CHECK_EQUAL_VAR(var1, var2)
	variable var1, var2
	
	if( !EQUAL_VAR(var1, var2) )
		incrError()
		printFailInfo()
		printf "var1 %g, var2 %g\r", var1, var2
	endif
End

/// Compares two strings for equality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
Function CHECK_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
	 variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif
	
	if( !EQUAL_STR(str1, str2, case_sensitive) )
		incrError()
		printFailInfo()
	endif
End

/// Checks if two variable are unequal
/// @param var1 			 first variable
/// @param var2 			 second variable
Function CHECK_NE_VAR(var1, var2)
	variable var1, var2
	
	if( EQUAL_VAR(var1, var2) )
		incrError()
		printFailInfo()
	endif
End

/// Checks if two strings are unequal
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
/// @return 1 if both strings are unequal and zero otherwise
Function CHECK_NE_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif
	
	if( EQUAL_STR(str1, str2, case_sensitive) )
		incrError()
		printFailInfo()
	endif
End

Constant TEXT_WAVE    = 2
Constant NUMERIC_WAVE = 1

Constant COMPLEX_WAVE = 0x01
Constant FLOAT_WAVE   = 0x02
Constant DOUBLE_WAVE  = 0x04
Constant INT8_WAVE    = 0x08
Constant INT16_WAVE   = 0x16
Constant INT32_WAVE   = 0x20
Constant UNSIGNED_WAVE= 0x40

/// Checks the wave for existence and its type
/// @param wv 			wave reference to check
/// @param mainType 	main type, either TEXT_WAVE or NUMERIC_WAVE
/// @param minorType 	minor type, either TEXT_WAVE or NUMERIC_WAVE
Function CHECK_WAVE(wv, mainType, [minorType])
	Wave/Z wv
	variable mainType, minorType
	
	string errMsg
	
	if(!WaveExists(wv))
		incrError()
		printFailInfo()
		DEBUG_OUTPUT("Assumption that the wave exists",0)
		return 0
	endif

	if(WaveType(wv,1) != mainType)
		incrError()
		printFailInfo()
		return 0
	endif

	if(!ParamIsDefault(minorType))
			variable type      = WaveType(wv,0)
			variable isSubType = type & minorType
			if( !isSubType )
				incrError()
				printFailInfo()
				return 0
		endif
	endif
End
