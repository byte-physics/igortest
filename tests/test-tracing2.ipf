#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TestTracing2

#include "igortest"

// IPT_FORMAT_OFF

#if (exists("TUFXOP_Version") && ((IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812) || (IgorVersion() >= 10.00)))

// Outside of Function comment

threadsafe static Function Workload(variable count)

// Inside Function comment

	count += 1
End

static Function TracingTest()

	Make/FREE/N=100 index
	MultiThread/NT=32 index = Workload(p)

	if(1)
	else
	endif

	if(0)
	elseif(1)
	else
	endif

	if(0)
	else
	endif

	switch(1)
		case 1:
			break
	endswitch

	switch(0)
		case 1:
			break
		default:
			break
	endswitch

	index[0] = \
	0.1 \

End


#endif

// IPT_FORMAT_ON
