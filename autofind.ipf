#pragma rtGlobals=1		// Use modern global access method.

/////////////////////////////////////////////////////global variables
Function initAutoFindPara()
	Variable/G g_constSpeedAutoMethod=0
	
	Variable/G g_AFPnum=1
	Variable/G g_AFPLowForce=5
	Variable/G g_AFPHighForce=20
	Variable/G g_AFPStepwise=0.1
	Variable/G g_AFPLevelGap=3
	Variable/G g_AFPForceSmth1=11
	Variable/G g_AFPForceSmth2=3
	Variable/G g_constForceAutoMethod=0
end

/////////////////////////////////////////////////////Panel
Window AutoFindPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(145,518,529,765)
	ShowTools/A
	SetDrawLayer UserBack
	DrawText 93,22,"constant speed"
	SetDrawEnv linethick= 1.5,dash= 1
	DrawLine 196,-0,196,240
	DrawText 18,193,"smooth:"
	SetVariable AFPnumInput,pos={21,149},size={90,18},title="#peaks",value= g_AFPnum
	SetVariable AFPLowForceInput,pos={30,77},size={90,18},title="Lo-Fo"
	SetVariable AFPLowForceInput,value= g_AFPLowForce
	SetVariable AFPHighForceInput,pos={32,99},size={89,18},title="Hi-Fo"
	SetVariable AFPHighForceInput,value= g_AFPHighForce
	SetVariable AFPStepwiseInput,pos={38,53},size={68,18},title="Step"
	SetVariable AFPStepwiseInput,value= g_AFPStepwise
	SetVariable AFPGapInput,pos={17,125},size={85,18},title="DistGap"
	SetVariable AFPGapInput,value= g_AFPLevelGap
	SetVariable AFPForceSmth1Input,pos={32,198},size={95,18},title="FindLevel"
	SetVariable AFPForceSmth1Input,value= g_AFPForceSmth1
	SetVariable AFPForceSmth2Input,pos={36,218},size={87,18},title="Locating"
	SetVariable AFPForceSmth2Input,value= g_AFPForceSmth2
EndMacro
