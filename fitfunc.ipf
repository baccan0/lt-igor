#pragma rtGlobals=1		// Use modern global access method.

Function eWLCFitting(wavex,wavey,minvalue,maxvalue)
	wave wavex,wavey
	variable minvalue,maxvalue
	wave W_coef=root:w_coef
	wave epi=root:episilon
	FuncFit/NTHR=0 mod_MuS W_coef  wavey[minvalue,maxvalue] /X=wavex /D /E=epi 
end

Function eWLCFitting_offset(wavex,wavey,minvalue,maxvalue)
	wave wavex,wavey
	variable minvalue,maxvalue
	wave W_coef=root:w_coef
	wave epi=root:episilon
	FuncFit/H="01100"/NTHR=0 mod_MuS_offset W_coef  wavey[minvalue,maxvalue] /X=wavex /D /E=epi 
end


Function mod_MuS(w, x) : FitFunc
   Wave w
   Variable x
 
   //CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
   //CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
   //CurveFitDialog/ Equation:
   //CurveFitDialog/ f(F) = F^(-1)(x) //+ F/kC
   //CurveFitDialog/ End of Equation
   //CurveFitDialog/ Independent Variables 1
   //CurveFitDialog/ F
   //CurveFitDialog/ Coefficients 3
   //CurveFitDialog/ w[0] = pers
   //CurveFitDialog/ w[1] = T
   //CurveFitDialog/ w[2] = L
   //CurveFitDialog/ w[3] = K
 
   Variable kB = 138e-4//1.38062e-23
   Variable R = x / w[2]
   Variable D = (kB * w[1]) / (w[0] * w[3])
 
   Variable a, b, c
   a = (8-8*R + 9*D - 12*R*D) / (4 + 4*D)
   b = (4 - 8*R + 4*R^2 + 6*D -18*D*R +12*D*R^2) / (4 + 4*D)
   c = D * (-6*R + 9*R^2 - 4*R^3) / (4 + 4*D)
     Variable p, q
   p = b - a^2 / 3
   q = c + (2 * a^3 - 9 * a * b) / 27
     Variable/C u
   Variable Dis
   Dis = q^2 / 4 + p^3 / 27
   u = (-q / 2 + sqrt(Dis))^(1 / 3)
 
   Variable/C F                            // F = Kraft / K
   F = -p / (3 * u) + u - a / 3
     return (w[3] * F)
  End    //mod_MuS
 
 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//****************************
//Inverted modified M and S model
//****************************

Function inv_mod_MuS(w, F) : FitFunc
   Wave w
   Variable F
 
   //CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
   //CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
   //CurveFitDialog/ Equation:
   //CurveFitDialog/ f(F) = F^(-1)(x) //+ F/kC
   //CurveFitDialog/ End of Equation
   //CurveFitDialog/ Independent Variables 1
   //CurveFitDialog/ F
   //CurveFitDialog/ Coefficients 4
   //CurveFitDialog/ w[0] = pers
   //CurveFitDialog/ w[1] = T
   //CurveFitDialog/ w[2] = L
   //CurveFitDialog/ w[3] = K
 
   if(F<0)
     return NaN
   endif  
 
   Variable kB = 138e-4//1.38062e-23
   Variable Z = F / w[3]
   Variable D = (kB * w[1]) / (w[0] * w[3])
 
   Variable a, b, c
   a = (4*Z + 9*D + 12*D*Z) / (-4*D)
   b = (-8*Z - 8*Z^2 - 6*D - 18*D*Z - 12*D*Z^2) / (-4*D)
   c = (4*Z + 8*Z^2 + 4*Z^3 + 6*D*Z + 9*D*Z^2 + 4*D* Z^3) / (-4*D)
     Variable p, q
   p = b - a^2 / 3
   q = c + (2 * a^3 - 9 * a * b) / 27
     Variable/C u
   Variable Dis
   Dis = q^2 / 4 + p^3 / 27
   u = (q / 2 + sqrt(Dis))^(1 / 3)
 
   Variable/C R                            // R = x / L
   R = p / (3 * u) - u - a / 3
     return (w[2] * R)
  End    //inv_mod_MuS
  
Function mod_MuS_offset(w, x) : FitFunc
   Wave w
   Variable x
 
   //CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
   //CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
   //CurveFitDialog/ Equation:
   //CurveFitDialog/ f(F) = F^(-1)(x) //+ F/kC
   //CurveFitDialog/ End of Equation
   //CurveFitDialog/ Independent Variables 1
   //CurveFitDialog/ F
   //CurveFitDialog/ Coefficients 5
   //CurveFitDialog/ w[0] = pers
   //CurveFitDialog/ w[1] = T
   //CurveFitDialog/ w[2] = L
   //CurveFitDialog/ w[3] = K
   //CurveFitDialog/ w[4] = offset
  
 
   Variable kB = 138e-4//1.38062e-23
   Variable R = (x-w[4]) / w[2]
   Variable D = (kB * w[1]) / (w[0] * w[3])
 
   Variable a, b, c
   a = (8-8*R + 9*D - 12*R*D) / (4 + 4*D)
   b = (4 - 8*R + 4*R^2 + 6*D -18*D*R +12*D*R^2) / (4 + 4*D)
   c = D * (-6*R + 9*R^2 - 4*R^3) / (4 + 4*D)
     Variable p, q
   p = b - a^2 / 3
   q = c + (2 * a^3 - 9 * a * b) / 27
     Variable/C u
   Variable Dis
   Dis = q^2 / 4 + p^3 / 27
   u = (-q / 2 + sqrt(Dis))^(1 / 3)
 
   Variable/C F                            // F = Kraft / K
   F = -p / (3 * u) + u - a / 3
     return (w[3] * F)
  End    //mod_MuS