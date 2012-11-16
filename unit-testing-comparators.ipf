#pragma rtGlobals=3		// Use modern global access method.

/// Tests two variables for equality
/// @return 1 if both variables are equal and zero otherwise
ThreadSafe static Function EQUAL_VAR(var1, var2)
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
ThreadSafe static Function SMALL_VAR(var, tol)
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
ThreadSafe static Function CLOSE_VAR(var1, var2, tol, strong_or_weak)
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
ThreadSafe static Function EQUAL_STR(str1, str2, case_sensitive)
	string str1, str2
	variable case_sensitive
	
	variable result = ( cmpstr(str1, str2, case_sensitive) == 0 )
	
	string str
	sprintf str, "\"%s\" == \"%s\" %s case", str1, str2, SelectString(case_sensitive,"not respecting","respecting")
	DEBUG_OUTPUT(str, result)
	return result
End

///@name actionFlags Action flags
///@{
Constant OUTPUT_MESSAGE = 0x01
Constant INCREASE_ERROR = 0x02
Constant ABORT_FUNCTION = 0x04
Constant WARN_MODE      = 0x01 // == OUTPUT_MESSAGE
Constant CHECK_MODE     = 0x03 // == OUTPUT_MESSAGE | INCREASE_ERROR
Constant REQU_MODE      = 0x07 // == OUTPUT_MESSAGE | INCREASE_ERROR | ABORT_FUNCTION
///@}

/// Tests if var is true (1)
/// @param var 	variable to test
/// @param flags   actions flags
ThreadSafe static Function TRUE_WRAPPER(var, flags)
	variable var
	variable flags
	
	if( ShouldDoAbort() )
		return NaN
	endif

	variable result = ( var == 1 )
	DEBUG_OUTPUT(num2istr(var), result)
	
	if( !result )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Warns if var is not true (1)
ThreadSafe Function WARN(var)
	variable var
	
	return TRUE_WRAPPER(var, WARN_MODE)
End

/// Checks that var is true (1)
ThreadSafe Function CHECK(var)
	variable var
	
	return TRUE_WRAPPER(var, CHECK_MODE)
End

/// Requires that var is true (1)
ThreadSafe Function REQUIRE(var)
	variable var
	
	return TRUE_WRAPPER(var, REQU_MODE)
End

/// Tests two variables for equality
/// @param var1 	first variable
/// @param var2 	second variable
/// @param flags   actions flags
ThreadSafe static Function EQUAL_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	if( ShouldDoAbort() )
		return NaN
	endif

	if( !EQUAL_VAR(var1, var2) )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Tests two variables for equality
/// @param str1 			 first variable
/// @param str2 			 second variable
ThreadSafe Function WARN_EQUAL_VAR(var1, var2)
	variable var1, var2
	
	return EQUAL_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// Checks two variables for equality
/// @param str1 			 first variable
/// @param str2 			 second variable
ThreadSafe Function CHECK_EQUAL_VAR(var1, var2)
	variable var1, var2
	
	return EQUAL_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// Requires that two variables are equal
/// @param str1 			 first variable
/// @param str2 			 second variable
ThreadSafe Function REQU_EQUAL_VAR(var1, var2)
	variable var1, var2
	
	return EQUAL_VAR_WRAPPER(var1, var2, REQU_MODE)
End

/// Compares two strings for equality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function EQUAL_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string str1, str2
    variable case_sensitive
    variable flags

	if( ShouldDoAbort() )
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif

	if( !EQUAL_STR(str1, str2, case_sensitive) )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Tests two strings for equality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function WARN_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
	 variable case_sensitive
	 
	if(ParamIsDefault(case_sensitive))
	    return EQUAL_STR_WRAPPER(str1, str2, WARN_MODE)
	else
	    return EQUAL_STR_WRAPPER(str1, str2, WARN_MODE, case_sensitive=case_sensitive)
	endif
End

/// Checks two strings for equality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function CHECK_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
	 variable case_sensitive
	 
	if(ParamIsDefault(case_sensitive))
	    return EQUAL_STR_WRAPPER(str1, str2, CHECK_MODE)
	else
	    return EQUAL_STR_WRAPPER(str1, str2, CHECK_MODE, case_sensitive=case_sensitive)
	endif
End

/// Requires that two strings are equal
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function REQU_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
    variable case_sensitive
	 
	if(ParamIsDefault(case_sensitive))
	    return EQUAL_STR_WRAPPER(str1, str2, REQU_MODE)
	else
	    return EQUAL_STR_WRAPPER(str1, str2, REQU_MODE, case_sensitive=case_sensitive)
	endif
End

/// Tests two variables for unequality
/// @param var1    first variable
/// @param var2    second variable
/// @param flags   actions flags
ThreadSafe static Function NEQ_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	if( ShouldDoAbort() )
		return NaN
	endif

	if( EQUAL_VAR(var1, var2) )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Tests two variables for unequality
/// @param str1 			 first variable
/// @param str2 			 second variable
ThreadSafe Function WARN_NEQ_VAR(var1, var2)
	variable var1, var2
	
	return NEQ_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// Checks two variables for unequality
/// @param str1 			 first variable
/// @param str2 			 second variable
ThreadSafe Function CHECK_NEQ_VAR(var1, var2)
	variable var1, var2
	
	return NEQ_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// Requires that two variables are unequal
/// @param str1 			 first variable
/// @param str2 			 second variable
ThreadSafe Function REQU_NEQ_VAR(var1, var2)
	variable var1, var2
	
	return NEQ_VAR_WRAPPER(var1, var2, REQU_MODE)
End

/// Compares two strings for unequality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param flags           actions flags
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function NEQ_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string str1, str2
    variable case_sensitive
    variable flags

	if( ShouldDoAbort() )
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif

	if( EQUAL_STR(str1, str2, case_sensitive) )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Tests two strings for unequality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function WARN_NEQ_STR(str1, str2, [case_sensitive])
	string str1, str2
	 variable case_sensitive
	 
	if(ParamIsDefault(case_sensitive))
	    return NEQ_STR_WRAPPER(str1, str2, WARN_MODE)
	else
	    return NEQ_STR_WRAPPER(str1, str2, WARN_MODE, case_sensitive=case_sensitive)
	endif
End

/// Checks two strings for unequality
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function CHECK_NEQ_STR(str1, str2, [case_sensitive])
	string str1, str2
	 variable case_sensitive
	 
	if(ParamIsDefault(case_sensitive))
	    return NEQ_STR_WRAPPER(str1, str2, CHECK_MODE)
	else
	    return NEQ_STR_WRAPPER(str1, str2, CHECK_MODE, case_sensitive=case_sensitive)
	endif
End

/// Requires that two strings are unequal
/// @param str1 			 first string
/// @param str2 			 second string
/// @param case_sensitive  should the comparison be done case sensitive (1) or case insensitive (0, the default)
ThreadSafe Function REQU_NEQ_STR(str1, str2, [case_sensitive])
	string str1, str2
    variable case_sensitive
	 
	if(ParamIsDefault(case_sensitive))
	    return EQUAL_STR_WRAPPER(str1, str2, REQU_MODE)
	else
	    return EQUAL_STR_WRAPPER(str1, str2, REQU_MODE, case_sensitive=case_sensitive)
	endif
End

/// Compares two variables and determines if they are close
/// @param var1 			first variable
/// @param var2 			second variable
/// @param flags          actions flags
/// @param tol				tolerance, defaults to 1e-8
/// @param strong_or_weak	defaults to 1 (strong condition)
/// 
/// @see CLOSE_VAR
ThreadSafe static Function CLOSE_VAR_WRAPPER(var1, var2, flags, [tol, strong_or_weak])
	variable var1, var2
	variable flags
	variable tol
	variable strong_or_weak

	if( ShouldDoAbort() )
		return NaN
	endif
	
	if(ParamIsDefault(strong_or_weak))
		strong_or_weak	= 1
	endif

	if(ParamIsDefault(tol))
		tol = 1e-8
	endif

	if( !CLOSE_VAR(var1, var2, tol, strong_or_weak) )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Compares two variables and determines if they are close
/// @param var1 			first variable
/// @param var2 			second variable
/// @param tol				tolerance, defaults to 1e-8
/// @param strong_or_weak	defaults to 1 (strong condition)
ThreadSafe Function WARN_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
    variable tol
    variable strong_or_weak
	 
	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
	    return CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE)
	elseif(ParamIsDefault(tol))
	    return CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
	    return CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, tol=tol)
	else
	    return CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// Checks if two variables are close
/// @param var1 			first variable
/// @param var2 			second variable
/// @param tol				tolerance, defaults to 1e-8
/// @param strong_or_weak	defaults to 1 (strong condition)
ThreadSafe Function CHECK_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
    variable tol
    variable strong_or_weak
	 
	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
	    return CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
	    return CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
	    return CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, tol=tol)
	else
	    return CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// Requires that two variables are close
/// @param var1 			first variable
/// @param var2 			second variable
/// @param tol 	       tolerance, defaults to 1e-8
/// @param strong_or_weak	defaults to 1 (strong condition)
ThreadSafe Function REQU_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
    variable tol
    variable strong_or_weak
	 
	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
	    return CLOSE_VAR_WRAPPER(var1, var2, REQU_MODE)
	elseif(ParamIsDefault(tol))
	    return CLOSE_VAR_WRAPPER(var1, var2, REQU_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
	    return CLOSE_VAR_WRAPPER(var1, var2, REQU_MODE, tol=tol)
	else
	    return CLOSE_VAR_WRAPPER(var1, var2, REQU_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// Tests if var is small
/// @param var		variable
/// @param flags   actions flags
/// @param tol 	tolerance, defaults to 1e-8
ThreadSafe static Function SMALL_VAR_WRAPPER(var, flags, [tol])
	variable var
	variable flags
	variable tol

	if( ShouldDoAbort() )
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = 1e-8
	endif

	if( !SMALL_VAR(var, tol) )
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
End

/// Tests if var is small
/// @param var 			 variable
/// @param tol 			 tolerance, defaults to 1e-8
ThreadSafe Function WARN_SMALL_VAR(var, [tol])
	variable var
	 variable tol
	 
	if(ParamIsDefault(tol))
	    return SMALL_VAR_WRAPPER(var, WARN_MODE)
	else
	    return SMALL_VAR_WRAPPER(var, WARN_MODE, tol=tol)
	endif
End

/// Checks that var is small
/// @param var 			 variable
/// @param tol 			 tolerance, defaults to 1e-8
ThreadSafe Function CHECK_SMALL_VAR(var, [tol])
	variable var
	 variable tol
	 
	if(ParamIsDefault(tol))
	    return SMALL_VAR_WRAPPER(var, CHECK_MODE)
	else
	    return SMALL_VAR_WRAPPER(var, CHECK_MODE, tol=tol)
	endif
End

/// Requires that var is small
/// @param var 			 variable
/// @param tol 			 tolerance, defaults to 1e-8
ThreadSafe Function REQU_SMALL_VAR(var, [tol])
	variable var
	 variable tol
	 
	if(ParamIsDefault(tol))
	    return SMALL_VAR_WRAPPER(var, REQU_MODE)
	else
	    return SMALL_VAR_WRAPPER(var, REQU_MODE, tol=tol)
	endif
End

///@name mainWaveTypes Main wave types
///@{
Constant TEXT_WAVE    = 2
Constant NUMERIC_WAVE = 1
///@}

///@name minorWaveTypes Minor wave types
///@{
Constant COMPLEX_WAVE = 0x01
Constant FLOAT_WAVE   = 0x02
Constant DOUBLE_WAVE  = 0x04
Constant INT8_WAVE    = 0x08
Constant INT16_WAVE   = 0x16
Constant INT32_WAVE   = 0x20
Constant UNSIGNED_WAVE= 0x40
///@}

/// Tests a wave for existence and its type
/// @param wv 			wave reference
/// @param flags      actions flags
/// @param mainType 	main type, @see mainWaveTypes
/// @param minorType 	minor type,  @see minorWaveTypes
ThreadSafe static Function TEST_WAVE_WRAPPER(wv, flags, mainType, [minorType])
	Wave/Z wv
	variable mainType, minorType
	variable flags

	if( ShouldDoAbort() )
		return NaN
	endif
	
	variable result = WaveExists(wv)
	DEBUG_OUTPUT("Assumption that the wave exists",result)
	
	if(!result)
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif

	result = ( WaveType(wv,1) != mainType )
	string str
	sprintf str, "Assumption that the wave's main type is %d", mainType
	DEBUG_OUTPUT(str,result)

	if(!result)
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif

	if(!ParamIsDefault(minorType))
		result = WaveType(wv,0) & minorType

		sprintf str, "Assumption that the wave's sub type is %d", minorType
		DEBUG_OUTPUT(str,result)

		if(!result)
			if( flags & OUTPUT_MESSAGE )
				printFailInfo()
			endif
			if( flags & INCREASE_ERROR )
				incrError()
			endif
			if( flags & ABORT_FUNCTION )
				AbortNow()
			endif
		endif
	endif
End

/// Tests a wave for existence and its type
/// @param wv 			wave reference
/// @param mainType 	main type, @see mainWaveTypes
/// @param minorType 	minor type,  @see minorWaveTypes
ThreadSafe Function WARN_WAVE(wv, mainType, [minorType])
	Wave/Z wv
	variable mainType, minorType
	
	if(ParamIsDefault(minorType))
		return TEST_WAVE_WRAPPER(wv, mainType, WARN_MODE)
	else
		return TEST_WAVE_WRAPPER(wv, mainType, WARN_MODE, minorType=minorType)
	endif
End

/// Checks a wave for existence and its type
/// @param wv 			wave reference
/// @param mainType 	main type, @see mainWaveTypes
/// @param minorType 	minor type,  @see minorWaveTypes
ThreadSafe Function CHECK_WAVE(wv, mainType, [minorType])
	Wave/Z wv
	variable mainType, minorType
	
	if(ParamIsDefault(minorType))
		return TEST_WAVE_WRAPPER(wv, mainType, CHECK_MODE)
	else
		return TEST_WAVE_WRAPPER(wv, mainType, CHECK_MODE, minorType=minorType)
	endif
End

/// Tests a wave for existence and its type
/// @param wv 			wave reference
/// @param mainType 	main type, @see mainWaveTypes
/// @param minorType 	minor type,  @see minorWaveTypes
ThreadSafe Function REQU_WAVE(wv, mainType, [minorType])
	Wave/Z wv
	variable mainType, minorType
	
	if(ParamIsDefault(minorType))
		return TEST_WAVE_WRAPPER(wv, mainType, REQU_MODE)
	else
		return TEST_WAVE_WRAPPER(wv, mainType, REQU_MODE, minorType=minorType)
	endif
End

///@name CheckWaveModes Available modes for *_EQUAL_WAVES
///@{
Constant WAVE_DATA			=   1
Constant WAVE_DATA_TYPE   =   2
Constant WAVE_SCALING 		=   4
Constant DATA_UNITS 		=   8
Constant DIMENSION_UNITS  =  16
Constant DIMENSION_LABELS =  32		
Constant WAVE_NOTE        =  64
Constant WAVE_LOCK_STATE  = 128
Constant DATA_FULL_SCALE  = 256
Constant DIMENSION_SIZES  = 512
///@}

/// Tests two waves for equality
/// @param wv1		first wave
/// @param wv2		second wave
/// @param flags   actions flags
/// @param mode	features of both waves to compare, defaults to all modes, @see CheckWaveModes
/// @param tol		tolerance for comparison, by default 0.0 which means do byte-by-byte comparison ( relevant only for mode=WAVE_DATA )
ThreadSafe static Function EQUAL_WAVE_WRAPPER(wv1, wv2, flags, [mode, tol])
	Wave/Z wv1, wv2
	variable flags
	variable mode, tol
	
	if( ShouldDoAbort() )
		return NaN
	endif
	
	variable result = WaveExists(wv1)
	DEBUG_OUTPUT("Assumption that the first wave (wv1) exists",result)

	if(!result)
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif

	result = WaveExists(wv2)
	DEBUG_OUTPUT("Assumption that the second wave (wv2) exists",result)

	if(!result)
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
	
	result = !WaveRefsEqual(wv1, wv2)
	DEBUG_OUTPUT("Assumption that both waves are distinct",result)
	
	if(!result)
		if( flags & OUTPUT_MESSAGE )
			printFailInfo()
		endif
		if( flags & INCREASE_ERROR )
			incrError()
		endif
		if( flags & ABORT_FUNCTION )
			AbortNow()
		endif
	endif
	
	if(ParamIsDefault(mode))
		Make/U/I/FREE modes = { WAVE_DATA, WAVE_DATA_TYPE, WAVE_SCALING, DATA_UNITS, DIMENSION_UNITS, DIMENSION_LABELS, WAVE_NOTE, WAVE_LOCK_STATE, DATA_FULL_SCALE, DIMENSION_SIZES}
	else
		Make/U/I/FREE modes = { mode }
	endif
	
	if(ParamIsDefault(tol))
		tol = 0.0
	endif

	variable i
	for(i = 0; i < DimSize(modes,0); i+=1)
		mode = modes[i]
		result = EqualWaves(wv1, wv2, mode, tol)
		string str
		sprintf str, "Assuming equality using mode %03d for waves %s and %s", mode, NameOfWave(wv1), NameOfWave(wv2)
		DEBUG_OUTPUT(str,result)
	
		if(!result)
			if( flags & OUTPUT_MESSAGE )
				printFailInfo()
			endif
			if( flags & INCREASE_ERROR )
				incrError()
			endif
			if( flags & ABORT_FUNCTION )
				AbortNow()
			endif
		endif
	endfor
End

/// Tests two waves for equality
/// @param wv1		first wave
/// @param wv2		second wave
/// @param mode	features of both waves to compare, defaults to all modes, @see CheckWaveModes
/// @param tol		tolerance for comparison, by default 0.0 which means do byte-by-byte comparison ( relevant only for mode=WAVE_DATA )
ThreadSafe Function WARN_EQUAL_WAVES(wv1, wv2, [mode, tol])
	Wave/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	elseif(ParamIsDefault(tol))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode=mode)
	elseif(ParamIsDefault(mode))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, tol=tol)
	else
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, tol=tol, mode=mode)
	endif	
End

/// Checks two waves for equality
/// @param wv1		first wave
/// @param wv2		second wave
/// @param mode	features of both waves to compare, defaults to all modes, @see CheckWaveModes
/// @param tol		tolerance for comparison, by default 0.0 which means do byte-by-byte comparison ( relevant only for mode=WAVE_DATA )
ThreadSafe Function CHECK_EQUAL_WAVE(wv1, wv2, [mode, tol])
	Wave/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode=mode)
	elseif(ParamIsDefault(mode))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, tol=tol)
	else
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, tol=tol, mode=mode)
	endif	
End

/// Checks two waves for equality
/// @param wv1		first wave
/// @param wv2		second wave
/// @param mode	features of both waves to compare, defaults to all modes, @see CheckWaveModes
/// @param tol		tolerance for comparison, by default 0.0 which means do byte-by-byte comparison ( relevant only for mode=WAVE_DATA )
ThreadSafe Function REQU_EQUAL_WAVE(wv1, wv2, [mode, tol])
	Wave/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, REQU_MODE)
	elseif(ParamIsDefault(tol))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, REQU_MODE, mode=mode)
	elseif(ParamIsDefault(mode))
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, REQU_MODE, tol=tol)
	else
	    return EQUAL_WAVE_WRAPPER(wv1, wv2, REQU_MODE, tol=tol, mode=mode)
	endif	
End
