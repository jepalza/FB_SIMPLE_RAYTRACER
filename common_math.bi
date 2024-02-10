
' DBL_MAX -> https://www.mql5.com/es/docs/constants/namedconstants/typeconstants
#Define DBL_MAX 1.7976931348623158e+308

#ifndef min
#define min(a, b) IIf(((a) < (b)) , (a) , (b))
#endif

#ifndef max
#define max(a, b) IIf(((a) > (b)) , (a) , (b))
#endif

Declare Function vec_normalize(vec() As Double) As Double 
Declare Function vec_dot(a() As Double , b() As Double) As Double 

