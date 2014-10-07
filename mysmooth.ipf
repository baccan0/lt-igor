#pragma rtGlobals=1		// Use modern global access method.

Function initMySmooth()
	make/O g_smoothPara={{1,21,0,0.2,0.3,10},{1,21,0,0.2,0.3,0}}
	MatrixTranspose g_smoothPara
end

Function buildMySmoothPanel()
	wave  sp=root:g_smoothPara
	if(!ifExisted("MySmoothSetup"))
		NewPanel/W=(210,193,500,350) /N=MySmoothSetup /K=1
		DrawText 179,18,"main"
		checkBox mySmoothChkBox_1_0,pos={10,20},size={50,20},title="Box_smooth",value=(sp[0][0]==1),proc=mySmoothchkBoxController,win=MySmoothSetup
		checkBox mySmoothChkBox_2_0,pos={10,60},size={50,20},title="Low_pass_filter",value=(sp[0][0]==2),proc=mySmoothchkBoxController,win=MySmoothSetup
		checkBox mySmoothChkBox_3_0,pos={10,100},size={50,20},title="Polynomial_fit",value=(sp[0][0]==3),proc=mySmoothchkBoxController,win=MySmoothSetup
		checkBox mySmoothChkBox_0_1,pos={160,20},size={50,20},title="None",value=(sp[1][0]==0),proc=mySmoothchkBoxController,win=MySmoothSetup
		checkBox mySmoothChkBox_1_1,pos={160,40},size={50,20},title="Box_smooth",value=(sp[1][0]==1),proc=mySmoothchkBoxController,win=MySmoothSetup
		checkBox mySmoothChkBox_2_1,pos={160,80},size={50,20},title="Low_pass_filter",value=(sp[1][0]==2),proc=mySmoothchkBoxController,win=MySmoothSetup
		setvariable mySmoothVar_0_1_0,pos={15,40},size={60,20},title="num",value=sp[0][1],win=MySmoothSetup
		setvariable mySmoothVar_0_2_0,pos={15,80},size={50,20},title="lo",value=sp[0][3],win=MySmoothSetup
		setvariable mySmoothVar_1_2_0,pos={80,80},size={50,20},title="hi",value=sp[0][4],win=MySmoothSetup
		setvariable mySmoothVar_0_3_0,pos={15,120},size={60,20},title="num",value=sp[0][5],win=MySmoothSetup
		setvariable mySmoothVar_0_1_1,pos={165,60},size={60,20},title="num",value=sp[1][1],win=MySmoothSetup
		setvariable mySmoothVar_1_2_1,pos={165,100},size={50,20},title="lo",value=sp[1][3],win=MySmoothSetup
		setvariable mySmoothVar_2_2_1,pos={230,100},size={50,20},title="hi",value=sp[1][4],win=MySmoothSetup
	endif
end

Function invokeMySmoothPanel(ctrlname):buttoncontrol
	string ctrlname
	buildMySmoothPanel()
end

Function mySmoothchkBoxController(name,value):checkboxcontrol
	string name
	variable value
	wave  sp=root:g_smoothPara
	variable method=str2num(getSuffix(name))
	variable type=str2num(getSuffix(removeSuffix(name)))
	sp[method][0]=type
	switch(str2num(getSuffix(name)))
		case 0:
			checkBox mySmoothChkBox_1_0,value=(type==1),win=MySmoothSetup
			checkBox mySmoothChkBox_2_0,value=(type==2),win=MySmoothSetup
			checkBox mySmoothChkBox_3_0,value=(type==3),win=MySmoothSetup
		break
		case 1:
			checkBox mySmoothChkBox_0_1,value=(type==0),win=MySmoothSetup
			checkBox mySmoothChkBox_1_1,value=(type==1),win=MySmoothSetup
			checkBox mySmoothChkBox_2_1,value=(type==2),win=MySmoothSetup
		break
	endswitch
end

Function setLowPassFilter(flag)
	variable flag
	wave smoothPara=root:g_smoothPara
	smoothPara[0][2]=flag
	smoothPara[1][2]=flag
end

Function smoothTraces(sourWave,destWave,selector)
/// inprement to smooth the data 
/// para[0],para[1] represent two set of parameter
/// para[0 or 1][0] tells which method to use
///			0: box smoothing	(using para[][1])
///			1: low pass filter (using para[][2],para[][3] and para[][4])
///			2: polynomial fitting (using para[][5])
	wave sourWave,destWave
	variable selector
	wave para=root:g_smoothPara
	switch(para[selector][0])
		case 0:
			Duplicate/O sourWave,destWave;
		break
		case 1:
			Duplicate/O sourWave,destWave;DelayUpdate
			if(numpnts(destWave)<para[selector][1]*2)			
				Smooth/B ceil(numpnts(destWave)/2), destWave
			else
				Smooth/B para[selector][1], destWave
			endif
		break
		case 2:
			if(para[selector][2])
				make/O/N=0 root:filtered
				wave temp=root:filtered
				Duplicate/O sourWave, temp
				Make/O/D/N=0 root:coefs
				FilterFIR/DIM=0/LO={para[selector][3],para[selector][4],101}/COEF root:coefs, temp //101 may have to be changed
				duplicate/O temp, destWave	
			else
				Duplicate/O sourWave,destWave
			endif
		break
		case 3:	
			make/O/N=0 root:filtered
			wave temp=root:filtered
			Duplicate/O sourWave, temp
			duplicate/O temp,destWave
			CurveFit/NTHR=0 poly para[selector][5],  temp /D=destWave	
		break
	endswitch
end