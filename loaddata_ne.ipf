#pragma rtGlobals=1		// Use modern global access method.

Window startAnalysis():Panel
	invokeLoadingPanel()
end

//Window Autodetectpeaks() : Panel
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /W=(1289,219,1585,569)
//	ShowTools
//	SetDrawLayer UserBack
//	SetDrawEnv linethick= 2,dash= 1
//	DrawLine 1,38,257,38
//	SetDrawEnv linethick= 2,dash= 1
//	DrawLine 4,311,260,311
//	checkIfInit()
//	Button button1,pos={6,8},size={130,18},proc=InitPara,title="Init Parameters"
//	Button button3,pos={6,50},size={130,18},proc=chooseFile,title="Choose File"
//	Button button2,pos={1,120},size={130,18},proc=LoadLTFiles1,title="Loadfile(with skips)"
//	Button button5,pos={133,120},size={130,18},proc=LoadLTFiles2,title="Loadfile(no skips)"
//	Button button4,pos={8,320},size={92,19},proc=modespliter,title="Split"
//	SetVariable setvar1,pos={10,204},size={157,18},title="CycleCount"
//	SetVariable setvar1,value= g_cyclecountName
//	SetVariable setvar6,pos={25,232},size={141,18},proc=avgDistChg,title="A_dist_Y"
//	SetVariable setvar6,value= g_AdistName
//	SetVariable setvar2,pos={24,259},size={144,18},proc=avgDistChg,title="B_dist_Y"
//	SetVariable setvar2,value= g_BdistName
//	SetVariable setvar3,pos={28,151},size={139,18},title="Tension"
//	SetVariable setvar3,value= g_TensionName
//	SetVariable setvar4,pos={38,177},size={128,18},title="Status"
//	SetVariable setvar4,value= g_StatusName
//	SetVariable setvar5,pos={8,287},size={161,18},title="AverageDist"
//	SetVariable setvar5,value= g_averagedistName
//	SetVariable setvar7,pos={11,71},size={220,18},title="File Path"
//	SetVariable setvar7,value= g_filePath
//	SetVariable setvar8,pos={5,94},size={226,18},title="FileName",value= g_fileName
//EndMacro

//Window InsertingAritificialPoints() : Panel
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /W=(286,294,528,377)
//	SetVariable highspeedVar,pos={12,20},size={100,18},title="highspeed",value=root:g_highspeed
//	SetVariable lowspeedVar,pos={127,20},size={100,18},title="lowspeed",value=root:g_lowspeed
//	CheckBox InsertPointChkBox,pos={53,52},size={130,18},title="insert artificial points",value=root:g_insertFlag,proc=ifInsertArtificial
////	Button InsertPointButton,pos={53,52},size={130,18},proc=insertArtificial,title="Start inserting"
//EndMacro

Function invokeLoadingPanel()
	variable left,right,top,bottom
	if(!ifExisted("Loading"))
		checkIfInit()
		NVAR iflag=root:g_insertFlag
		getscreensize(left,right,top,bottom)
		Display /W=(left+50,top,right-50,300)/N=Loading/K=1
		NewPanel /W=(0,0,520,65) /N=P0 /HOST=#
		Button l_init,pos={8,7},size={53,55},proc=InitPara,title="Init Paras"
		Button l_selectFile,pos={95,57},size={65,18},proc=chooseFile,title="Select File"
		Button l_loadwithskips,pos={175,57},size={65,18},proc=LoadLTFiles1,title="Load(with#)"
		Button l_loadwithoutskips,pos={255,57},size={65,18},proc=LoadLTFiles2,title="Load(no#)"
		SetVariable l_filePath,pos={101,11},size={220,18},title="File Path",value= g_filePath
		SetVariable l_fileName,pos={95,32},size={226,18},title="FileName",value= g_fileName
		SetVariable highspeedVar,pos={340,12},size={100,18},title="highspeed",value=root:g_highspeed
		SetVariable lowspeedVar,pos={341,34},size={100,18},title="lowspeed",value=root:g_lowspeed
		CheckBox InsertPointChkBox,pos={343,59},size={100,18},title="insert points",value=iflag,proc=ifInsertArtificial
		Button l_stiffness,pos={450,10},size={65,18},proc=findstiffness,title="stiffness"
		SetVariable l_complianceA,pos={450,34},size={70,18},title="com_A",value= root:g_complianceA
		SetVariable l_complianceB,pos={450,59},size={70,18},title="com_B",value= root:g_complianceB
		Button l_calibrate,pos={530,10},size={65,18},title="calibrate",proc=calibrateTension
		Button l_autosplit,pos={600,10},size={65,18},proc=modespliter,title="Auto-Split"
		Button cursorMove_dualleft,pos={530,34},size={20,18},title="<<",proc=cursorMove
		Button cursorMove_left,pos={555,34},size={20,18},title="<",proc=cursorMove
		Button cursorMove_twoway,pos={580,34},size={20,18},title="<>",proc=cursorMove
		Button cursorMove_right,pos={605,34},size={20,18},title=">",proc=cursorMove
		Button cursorMove_dualright,pos={630,34},size={20,18},title=">>",proc=cursorMove
		Button l_saveother,pos={530,59},size={65,18},title="save",proc=saveother
		SetActiveSubwindow ##
	endif
	displayLoadedData()
end

Function checkIfInit()
	if(!exists("g_drawingStatusPara"))
		InitPara("")
	endif
end

Function InitPara(ctrlname):buttoncontrol
	string ctrlname
	//it is better to add a alert here
	String/G g_cyclecountName="CycleCount"
	String/G g_AdistName="A_dist_Y"
	String/G g_BdistName="B_dist_Y"
	String/G g_StatusName="Status"
	String/G g_TensionName="Tension"
	String/G g_filePath="E:\\"
	String/G g_fileName="hp2A"
	String/G g_averagedistName="averageDist"
	Variable/G g_numConstSpeed=0
	Variable/G g_numConstForce=0
	Variable/G g_numOther=0
	Variable/G g_highspeed=1
	Variable/G g_lowspeed=100
	Variable/G g_ncolumn=0
	Variable/G g_insertFlag=0
//	Variable/G g_initTime=0
	Variable/G g_cycleToTime=1000
	Variable/G g_peakInfoDimension=9
//	Variable/G g_jumpInfoDimension=3
	NewDataFolder/O root:constSpeed 
	NewDataFolder/O root:constForce
	NewDataFolder/O root:display
	NewDataFolder/O root:other
	initConstSpeedPara()
end

Function loadLTFiles1(ctrlname):buttoncontrol
	string ctrlname
	loadLTFiles(0)
end

Function loadLTFiles2(ctrlname):buttoncontrol
	string ctrlname
	loadLTFiles(1)
end

Function ifInsertArtificial(name,value):checkboxcontrol
	string name
	variable value
	NVAR insertFlag=root:g_insertFlag
	insertFlag=value
end

Function insertArtificial(cyclecountWave,distanceWave,tensionWave)
	//*****here is for inserting aritificial points, however I dont want to make too much artificial
	//***** points, 3 would be high enough
	wave cyclecountWave,distanceWave,tensionwave
//	NVAR isInserted=root:g_isInserted
	Variable ii=0
	Variable gap
	NVAR highspeed=root:g_highspeed
	NVAR lowspeed=root:g_lowspeed
	if(highspeed<0)
//		isInserted=1
		Note/NOCR cyclecountWave,"isInserted=1;"
		Note/NOCR distanceWave,"isInserted=1;"
		Note/NOCR tensionWave,"isInserted=1;"
		return 0
	endif
	do 
		gap=(cyclecountWave[ii+1]-cyclecountWave[ii])
		
		if(gap!=lowspeed)
			gap/=highspeed
			if(gap>1&&gap<3)
				insertpoints ii+1,1,cyclecountWave
				cyclecountWave[ii+1]=cyclecountWave[ii]+highspeed
				insertpoints ii+1,1,distanceWave
				distanceWave[ii+1]=(distanceWave[ii+2]-distanceWave[ii])/gap+distanceWave[ii]	
				insertpoints ii+1,1,tensionWave
				tensionWave[ii+1]=(tensionWave[ii+2]-tensionWave[ii])/gap+tensionWave[ii]					
			endif
		endif
		ii+=1
	while(ii<numpnts(cyclecountWave)-1) 
	Note/NOCR cyclecountWave,"isInserted=1;"
	Note/NOCR distanceWave,"isInserted=1;"
	Note/NOCR tensionWave,"isInserted=1;"
//	isInserted=1
	//*****end		
end


//Function insertArtificial(ctrlname):buttoncontrol
	//*****here is for inserting aritificial points, however I dont want to make too much artificial
	//***** points, 3 would be high bound
//	string ctrlname
//	NVAR n_column=root:g_ncolumn
//	NVAR isInserted=root:g_isInserted
//	SVAR cyclecountName=root:g_cyclecountName
//	variable ii,jj
//	wave cyclecountWave=$"root:"+cyclecountName
//	ii=0
//	Variable gap
//	NVAR highspeed=root:g_highspeed
//	NVAR lowspeed=root:g_lowspeed
//	if(highspeed<0)
//		isInserted=1
//		return 0
//	endif
//	do 
//		gap=(cyclecountWave[ii+1]-cyclecountWave[ii])
//		
//		if(gap!=lowspeed)
//			gap/=highspeed
//			if(gap>1&&gap<3)
//				for(jj=-1;jj<n_column;jj+=1)
//					wave tempwave=$RemoveEnding(cyclecountName)+num2str(jj)
//					insertpoints ii+1,1,tempwave
//					switch(jj)
//						case 0:
//							tempwave[ii+1]=tempwave[ii]+highspeed
//							break
//						default:
//							if(ii==0)
//								tempwave[1]=tempwave[0]
//							else
//								tempwave[ii+1]=(tempwave[ii+2]-tempwave[ii])/gap+tempwave[ii]
//							endif
//					endswitch
//				endfor
//			endif
//		endif
//		ii+=1
//	while(ii<numpnts(cyclecountWave)-1) 
//	isInserted=1
	//*****end		
//end

Function loadLTFiles(ismodified)
	variable ismodified
	SVAR filePath=root:g_filePath
	SVAR fileName=root:g_fileName
	NVAR n_column=root:g_ncolumn
	SVAR cyclecountName=root:g_cyclecountName
	SVAR AdistName=root:g_AdistName
	SVAR BdistName=root:g_BdistName
	SVAR StatusName=root:g_StatusName
	SVAR TensionName=root:g_TensionName
	SVAR averagedistName=root:g_averagedistName
	
	String fileNameNoExtent=fileName
	string fileNameExtent
	variable ii,jj,kk
	Variable refNum
	if(stringmatch(fileName,"*.*"))
		splitstring /E="([^.]*).([^.]*)" fileName,fileNameNoExtent,fileNameExtent
	endif
	fileNameNoExtent=RemoveEnding(fileNameNoExtent)	
	print filePath,fileNameNoExtent,fileNameExtent
	
	for(ii=0;ii<6;ii+=1)
		filename= fileNameNoExtent+num2char(65+ii)+"."+fileNameExtent
		movefile/Z filepath+fileNameNoExtent+num2char(65+ii)+"."+fileNameExtent filepath+"moved.txt"
		if(V_flag==0)
			movefile/Z filepath+"moved.txt"  filepath+fileNameNoExtent+num2char(65+ii)+"."+fileNameExtent
		else
			break
		endif
		if(ismodified)
			LoadWave /G /N=$fileNameNoExtent+num2char(65+ii) filePath+fileName
		else
			grep /E="^[^#]"  filePath+fileName as filePath+"m_"+fileName
			LoadWave /G /N=$fileNameNoExtent+num2char(65+ii) filePath+"m_"+fileName
		endif
		if(ii==0)
			n_column=V_flag
		endif
	endfor
	make/O root:mergetemp
	wave mergetemp=root:mergetemp
	for(jj=0;jj<n_column;jj+=1)
		make/O/N=0 $"root:"+fileNameNoExtent+num2str(jj)
		wave targetwave=$"root:"+fileNameNoExtent+num2str(jj)
		for(kk=0;kk<ii;kk+=1)
			concatenate/O/NP {targetwave,$fileNameNoExtent+num2char(65+kk)+num2str(jj)}, mergeTemp
			duplicate/O mergetemp, targetwave
			killwaves/Z $fileNameNoExtent+num2char(65+kk)+num2str(jj)
		endfor
	endfor	
	killwaves/Z  root:mergetemp
	
	if(ismodified)
		Open /R refNum as filePath+fileNameNoExtent+"A."+fileNameExtent
	else
		Open /R refNum as filePath+"m_"+fileNameNoExtent+"A."+fileNameExtent
	endif
	if (refNum == 0)
		return -1 
	endif
	String buffer,tags
	FReadLine refNum, buffer
	Close refNum
	ii=0
	do		
		tags=StringFromList(ii, buffer, "\t")
		tags=RemoveEnding(tags,"\r")
		strswitch(tags)
			case   "CycleCount/n":
				duplicate/O $fileNameNoExtent+num2str(ii),CycleCount
				KillWaves /Z $fileNameNoExtent+num2str(ii)
			break
			case "":
			break
			case "A_dist-Y":
				duplicate/O $fileNameNoExtent+num2str(ii),A_dist_Y
				KillWaves /Z $fileNameNoExtent+num2str(ii)
			break
			case "B_dist-Y":
				duplicate/O $fileNameNoExtent+num2str(ii),B_dist_Y
				KillWaves /Z $fileNameNoExtent+num2str(ii)
			break
			default:
				duplicate/O $fileNameNoExtent+num2str(ii),$tags
				KillWaves /Z $fileNameNoExtent+num2str(ii)
			break
		endswitch
		ii+=1
	while(strlen(tags)>0)	
	
	KillDataFolder/Z root:constSpeed
	NewDataFolder/O root:constSpeed //clear folder for holding new data
	KillDataFolder/Z root:constForce
	NewDataFolder/O root:constforce//clear folder for holding new data
	KillDataFolder/Z root:other
	NewDataFolder/O root:other //clear folder for holding new data
	
	displayLoadedData()
//	if(V_flag>0)  //it is better to reset something here, such as Num of force extension curve
//		
//	endif	
end

Function displayLoadedData()
	try
	//	NVAR n_column=root:g_ncolumn
		SVAR averagedistName=root:g_averagedistName
		SVAR AdistName=root:g_AdistName
		SVAR BdistName=root:g_BdistName
		SVAR StatusName=root:g_StatusName
		SVAR TensionName=root:g_TensionName
		SVAR cyclecountName=root:g_cyclecountName
		if(ifExisted("Loading"))
			//Edit/N=Loaded_Data
			//AppendToTable/W=Loaded_Data $averdistName,
			Make/O 	$AveragedistName
			duplicate/O $AdistName $AveragedistName
			avgDistChg("",0,"","");
			clearAll("Loading")
			appendToGraph /W=Loading $"root:"+TensionName vs $"root:"+cyclecountName
			appendToGraph /W=Loading /R $"root:"+averagedistName vs $"root:"+cyclecountName
			modifygraph RGB(averageDist)=(0,0,65535)
			Make/O/N=0 root:trackPosY
			Make/O/N=0 root:trackPosX
			appendtograph/W=Loading root:trackPosY vs root:trackPosX
		endif
	catch
	endtry
end

Function avgDistChg(ctrlName,varNum,varStr,varName):SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SVAR AdistName=root:g_AdistName
	SVAR BdistName=root:g_BdistName
	SVAR averagedistName=root:g_averagedistName
	
	Wave Adistwave=$AdistName
	Wave Bdistwave=$BdistName
	Wave averagedistwave=$averagedistName
	variable nA,nB,nave
	nA=numpnts(Adistwave)
	nB=numpnts(Bdistwave)
	nave=numpnts(averagedistwave)
	if(nA==nB)
		if(nA<nave)
			deletepoints 0,nave-nA,averagedistwave
		endif
		if(nA>nave)
			insertpoints 0,nA-nave,averagedistwave
		endif
		averagedistwave=(Adistwave +  Bdistwave) /2
	endif
end

Function chooseFile(ctrlname):ButtonControl
	String ctrlname
	
	SVAR filePath=root:g_filePath
	SVAR fileName=root:g_fileName
	
	LoadWave /G /N=Non /L={1,1,1,1,1}  filePath
	filePath=S_path
	fileName=S_filename
end

Function modeSpliter(ctrlname):buttoncontrol
	string ctrlname
	SVAR averagedistName=root:g_averagedistName
	SVAR StatusName=root:g_StatusName
	SVAR TensionName=root:g_TensionName
	SVAR cyclecountName=root:g_cyclecountName
	Wave averagedistWave=$averagedistName
	Wave StatusWave=$StatusName
	Wave TensionWave=$TensionName
	Wave cyclecountWave=$cyclecountName
	NVAR numConstSpeed=g_numConstSpeed
	NVAR numConstForce=g_numConstForce
	
	Variable directionFlag,oldDirectionFlag
	Variable beginFlag
	Variable constSpeedFlag=0,constForceFlag=0,preForce=-1
	Variable statusFlag
	
	numConstSpeed=0 //reset number of curves to zero
	numConstForce=0
	KillDataFolder/Z root:constSpeed
	NewDataFolder/O root:constSpeed //clear folder for holding new data
	KillDataFolder/Z root:constForce
	NewDataFolder/O root:constForce
	Variable i,n
	i=0
	n=numpnts(StatusWave)
	oldDirectionFlag=-1	
	for(;i<n;)
		switch(floor(StatusWave[i]/1000))
			case 1:
				preForce=-1
				constSpeedFlag=1
				directionFlag=StatusWave[i]&1
				beginFlag=i
				statusFlag=StatusWave[i]
				do
					if(directionFlag!=(StatusWave[i]&1))    //if preflag not equal curflag
						if(i-100>beginFlag)    //i will only record curves with more than 99 points
							constPullSpeedRecorder(beginFlag,i-1,directionFlag)
						endif
						if(!directionFlag || (oldDirectionFlag==directionFlag))
								numConstSpeed+=1
						endif						
						oldDirectionFlag=directionFlag
						directionFlag=StatusWave[i]&1
						statusFlag=StatusWave[i]
						beginFlag=i
					endif
					i+=1
				while(i<n&&floor(StatusWave[i]/1000)==1)
				if((i-100)>beginflag)
					constPullSpeedRecorder(beginFlag,i-1,directionFlag)
					numConstSpeed+=1
				endif
				break
			case 7:
			case 8:
				constForceFlag=1
				beginFlag=i
				directionFlag=floor(StatusWave[i]/1000)
				do
					i+=1
				while(i<n&&directionFlag==floor(StatusWave[i]/1000))
				if((i-1)>beginFlag)
					preForce=constForceRecorder(beginFlag,i-1,preForce)
					numconstForce+=1
				endif
				break
			default: 
				preForce=-1
				i+=1
		endswitch
	endfor
	if(constSpeedFlag)
		
		execute "ConstSpeedAnalysis()"
		refreshWaves("")
	endif
end

Function saveother(ctrlname):buttoncontrol
	string ctrlname
	variable count=0
	string tempstr=CsrInfo(A,"Loading")
	string tracea=StringByKey("TNAME",tempstr,":",";")
	variable pointa = -1
	variable left
	if(cmpstr(tracea,""))
		pointa= NumberByKey("POINT",tempstr,":",";")
		count+=1
	endif
	tempstr=CsrInfo(B,"Loading")
	string traceb=StringByKey("TNAME",tempstr,":",";")
	variable pointb = -1
	if(cmpstr(traceb,""))
		pointb= NumberByKey("POINT",tempstr,":",";")
		count+=2
	endif
	if(count==3)
		otherRecorder(min(pointa,pointb),max(pointa,pointb))
	endif	
end

Function otherRecorder(startFlag,endFlag)
	Variable startFlag,endFlag
	SVAR averagedistName=root:g_averagedistName
	SVAR StatusName=root:g_StatusName
	SVAR TensionName=root:g_TensionName
	SVAR cyclecountName=root:g_cyclecountName
	Wave averagedistWave=$averagedistName
	Wave StatusWave=$StatusName
	Wave TensionWave=$TensionName
	Wave cyclecountWave=$cyclecountName
	NVAR numother=root:g_numOther
	NVAR insertFlag=root:g_insertFlag
	NVAR cycleToTime=root:g_cycleToTime
	NVAR infodimension=root:g_peakInfoDimension
	variable st,starttime
	duplicate/O/R=[startFlag,endFlag] averagedistWave $"root:other:Distance_"+num2str(numother)
	duplicate/O/R=[startFlag,endFlag] TensionWave $"root:other:Tension_"+num2str(numother)
	duplicate/O/R=[startFlag,endFlag] cyclecountWave $"root:other:Time_"+num2str(numother)
	Wave temptime=$"root:other:Time_"+num2str(numother)
	Wave tempdistance=$"root:other:Distance_"+num2str(numother)
	Wave temptension=$"root:other:Tension_"+num2str(numother)
	st=temptime[0]
	if(insertFlag)
		insertArtificial(temptime,tempdistance,temptension)
	endif
	tempTime/=cycleToTime
	startTime=temptime[0]
	tempTime-=startTime
	Note/NOCR temptime, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((st)/cycleToTime)+";"
	Note/NOCR temptension, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((st)/cycleToTime)+";"
	Note/NOCR tempdistance, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((st)/cycleToTime)+";"
	Note/NOCR tempdistance,"startpos="+num2str(startFlag)+";"
	if(insertFlag)//if(isInserted)
		SetScale/P x,0,temptime[numpnts(temptime)-1]/(numpnts(temptime)-1),temptension,tempdistance
//		isForceSetScale=1
	endif
	Make/O/N=(0,infodimension) $"root:other:Peak_Info_"+num2str(numother)
end

Function constForceRecorder(startFlag,endFlag,preForce)
	Variable startFlag,endFlag,preForce
	SVAR averagedistName=root:g_averagedistName
	SVAR StatusName=root:g_StatusName
	SVAR TensionName=root:g_TensionName
	SVAR cyclecountName=root:g_cyclecountName
	Wave averagedistWave=$averagedistName
	Wave StatusWave=$StatusName
	Wave TensionWave=$TensionName
	Wave cyclecountWave=$cyclecountName
	NVAR numConstForce=g_numConstForce
//	NVAR isInserted=root:g_isInserted
//	NVAR isForceSetScale=root:g_isForceSetScale
	NVAR insertFlag=root:g_insertFlag
//	NVAR initTime=root:g_initTime
	NVAR cycleToTime=root:g_cycleToTime
	NVAR jumpInfoDimension=root:g_peakInfoDimension
	
	Variable aveForce=0
	Variable startDist=0
	Variable startTime=0
	Variable st=0
	Variable ii,n
	duplicate/O/R=[startFlag,endFlag] averagedistWave $"root:constForce:Distance_"+num2str(numConstForce)
	duplicate/O/R=[startFlag,endFlag] TensionWave $"root:constForce:Tension_"+num2str(numConstForce)
	duplicate/O/R=[startFlag,endFlag] cyclecountWave $"root:constForce:Time_"+num2str(numConstForce)
	Wave temptime=$"root:constForce:Time_"+num2str(numConstForce)
	Wave tempdistance=$"root:constForce:Distance_"+num2str(numConstForce)
	Wave temptension=$"root:constForce:Tension_"+num2str(numConstForce)
	st=temptime[0]
	if(insertFlag)
		insertArtificial(temptime,tempdistance,temptension)
	endif
	n=numpnts(temptension)
	for(ii=30;ii<n;ii+=1)     //don't want to count the beginning 30 points
		aveForce+=temptension[ii]/n
	endfor
	startDist=tempdistance[0]
	tempdistance-=startDist
	tempTime/=cycleToTime
	startTime=temptime[0]
	tempTime-=startTime
	Note/NOCR temptime, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((st)/cycleToTime)+";"+"force="+num2str(aveForce)+";"+"previous_force="+num2str(preForce)+";"
	Note/NOCR temptension, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((st)/cycleToTime)+";"+"force="+num2str(aveForce)+";"+"previous_force="+num2str(preForce)+";"
	Note/NOCR tempdistance, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((st)/cycleToTime)+";"+"force="+num2str(aveForce)+";"+"previous_force="+num2str(preForce)+";"
	Note/NOCR tempdistance,"startpos="+num2str(startFlag)+";"
	if(insertFlag)//if(isInserted)
		SetScale/P x,0,temptime[numpnts(temptime)-1]/(numpnts(temptime)-1),temptension,tempdistance
//		isForceSetScale=1
	endif
	Make/O/N=(0,jumpInfoDimension) $"root:constForce:Peak_Info_"+num2str(numConstForce)
	return aveForce
end

Function linearFitting(ywave,xwave,startFlag,endFlag,parawave)//end one is not included
	wave ywave,xwave,parawave
	variable startFlag,endFlag
	Variable ii,n=endFlag-startFlag
	Variable xsum=0,ysum=0,xysum=0,x2sum=0
	for(ii=startFlag;ii<endFlag;ii+=1)
		xsum+=xwave[ii]
		ysum+=ywave[ii]
		xysum+=xwave[ii]*ywave[ii]
		x2sum+=xwave[ii]*xwave[ii]
	endfor
	parawave[1]=(xysum-xsum*ysum/n)/(x2sum-xsum*xsum/n)
	parawave[0]=(ysum-xsum*parawave[1])/n
end

Function cmpSlope(s1,s2,standard)//s1 is main one
	Variable s1,s2,standard
	if (abs(s1-s2)/abs(s1)>standard)
		return 0
	else
		return 1
	endif
end

Function constPullSpeedRecorder(startFlag,endFlag,directionFlag)
	Variable startFlag,endFlag,directionFlag
	SVAR averagedistName=root:g_averagedistName
	SVAR StatusName=root:g_StatusName
	SVAR TensionName=root:g_TensionName
	SVAR cyclecountName=root:g_cyclecountName
	Wave averagedistWave=$averagedistName
	Wave StatusWave=$StatusName
	Wave TensionWave=$TensionName
	Wave cyclecountWave=$cyclecountName
	NVAR numConstSpeed=g_numConstSpeed
	Variable temptimestart,PullingSpeed,tempdiststart
//	NVAR isInserted=root:g_isInserted
//	NVAR isSpeedSetScale=root:g_isSpeedSetScale
	NVAR insertFlag=root:g_insertFlag
//	NVAR initTime=root:g_initTime
	NVAR cycleToTime=root:g_cycleToTime
	NVAR peakInfoDimension=root:g_peakInfoDimension
	
	Variable st=0
	
	String directionStr
	if(directionFlag)
		directionStr="Unf"
	else
		directionStr="Ref"
	endif
	
	duplicate/O/R=[startFlag,endFlag] averagedistWave $"root:constSpeed:Distance_"+directionStr+num2str(numConstSpeed)
	duplicate/O/R=[startFlag,endFlag] TensionWave $"root:constSpeed:Tension_"+directionStr+num2str(numConstSpeed)
	duplicate/O/R=[startFlag,endFlag] cyclecountWave $"root:constSpeed:Time_"+directionStr+num2str(numConstSpeed)
	Wave temptime=$"root:constSpeed:Time_"+directionStr+num2str(numConstSpeed)
	Wave tempdistance=$"root:constSpeed:Distance_"+directionStr+num2str(numConstSpeed)
	Wave temptension=$"root:constSpeed:Tension_"+directionStr+num2str(numConstSpeed)
	if(insertFlag)
		insertArtificial(temptime,tempdistance,temptension)
	endif
	
	Make/O/N=2 root:ConstSpeed:rightPara
	Make/O/N=2 root:ConstSpeed:leftPara
	Make/O/N=2 root:ConstSpeed:tempPara
	wave rP=root:ConstSpeed:rightPara
	wave lP=root:ConstSpeed:leftPara
	wave tP=root:ConstSpeed:tempPara
	Variable rightend=numpnts(tempdistance),ii,temptag,divfactor
	variable rightstart=rightend-round(rightend/4),leftend=round(rightend/4)
	linearFitting(tempdistance,temptime,rightstart,rightend,rP)
	linearFitting(tempdistance,temptime,rightend-round(rightend/6),rightend,tP)
	linearFitting(tempdistance,temptime,0,leftend,lP)
	if(!cmpSlope(rp[1],lp[1],0.2))
		if(cmpSlope(rp[1],tp[1],0.1))
			leftend=0
		else
			divfactor=5
			do
				rightstart=rightend-round(rightend/divfactor)
				linearFitting(tempdistance,temptime,rightstart,rightend,rP)
				linearFitting(tempdistance,temptime,rightend-round(rightend/(divfactor+1)),rightend,tP)
				if(cmpSlope(rp[1],tp[1],0.1))
					break
				endif
				divfactor+=1
			while(divfactor<10)
			leftend=0
		endif
			do
				rightstart=floor((rightstart+leftend)/2)
				linearFitting(tempdistance,temptime,rightstart,rightend,tP)		
				if(!cmpSlope(rp[1],tp[1],0.1))
					break
				else
					rightstart=floor((rightstart+leftend)/2)
				endif
			while(leftend<rightstart)
			leftend=rightstart
			linearFitting(tempdistance,temptime,0,leftend,lP)
			temptag=(lP[0]-rP[0])/(rP[1]-lP[1])
			for(ii=0;ii<rightend;ii+=1)
				if(temptime[ii]>temptag)
					break
				endif
			endfor
			rightstart=ii
			linearFitting(tempdistance,temptime,rightstart,rightend,rP)
			temptag=(lP[0]-rP[0])/(rP[1]-lP[1])
			for(ii=0;ii<rightend;ii+=1)
				if(temptime[ii]>temptag)
					break
				endif
			endfor
			deletepoints 0,ii,temptime
			deletepoints 0,ii,tempdistance
			deletepoints 0,ii,tempTension		
	endif	
	if(numpnts(temptime)<10)
		killwaves/Z  temptime
		killwaves/Z  tempdistance
		killwaves/Z  tempTension
	else	
		temptimestart=temptime[0]
		temptime=(temptime-temptimestart)/cycleToTime
		if(directionFlag)
			tempdiststart=tempdistance[0]
		else
			tempdiststart=tempdistance[numpnts(tempdistance)-1]
		endif
//		tempdistance-=tempdiststart
//		tempdistance=abs(tempdistance)
//		PullingSpeed=abs((tempdistance[numpnts(tempdistance)-1]-tempdistance[0])/temptime[numpnts(temptime)-1])
		linearFitting(tempdistance,temptime,0,numpnts(tempdistance),rP)
		PullingSpeed=abs(rp[1])
		Note/NOCR temptime, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((temptimestart)/cycleToTime)+";"+"pulling_speed="+num2str(PullingSpeed)+";A=0;B=0;"
		Note/NOCR temptension, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((temptimestart)/cycleToTime)+";"+"pulling_speed="+num2str(PullingSpeed)+";A=0;B=0;"
		Note/NOCR tempdistance, "begin_at="+num2str_precise(startFlag)+";"+"end_at="+num2str_precise(endFlag)+";"+"start_time="+num2str((temptimestart )/cycleToTime)+";"+"pulling_speed="+num2str(PullingSpeed)+";A=0;B=0;"
		Make/O/N=(0,peakInfoDimension) $"root:constSpeed:Peak_Info_"+directionStr+num2str(numConstSpeed)
		if(insertFlag)//if(isInserted)
			SetScale/P x,0,temptime[numpnts(temptime)-1]/(numpnts(temptime)-1),temptension,tempdistance
//			isSpeedSetScale=1
		endif
	endif
end

Function square(s)
	variable s
	return s*s
end

Function calibrateTension(ctrlname):buttoncontrol
	string ctrlname
	string tempstr=CsrInfo(A,"Loading")
	string tracename=StringByKey("TNAME",tempstr,":",";")
	tempstr=CsrInfo(B,"Loading")
	if(!cmpstr(tracename,StringByKey("TNAME",tempstr,":",";")))
		if(exists("X_Force"))
			calibrateForces2("X_Force","Y_Force","Z_Force")
		else
			calibrateForces("Y_Force")
		endif
	endif
end

Function calibrateForces(yforceName)
	string yforcename
	SVAR TensionName=root:g_TensionName
	wave tensionwave = $TensionName
	wave yforcewave = $yforceName
	duplicate/O yforcewave root:g_xzforcewave
	wave xzforcewave=root:g_xzforcewave
	variable i,n,xzblankforce,yblankforce
	n = numpnts(Tensionwave)
	xzblankforce = 0
	yblankforce = 0
	
	for(i =pcsr(A); i<pcsr(B);i+=1)
		yblankforce += yforcewave[i]
		xzblankforce += sqrt(square(tensionwave[i])- square(yforcewave[i]))
	endfor
	yblankforce /= (pcsr(B)-pcsr(A))
	xzblankforce /= (pcsr(B)-pcsr(A))
	for(i=0;i <n;i+=1)
		tensionwave[i] = sqrt(square(yforcewave[i]-yblankforce)+square(sqrt(square(tensionwave[i])- square(yforcewave[i]))-xzblankforce))
	endfor
end

Function calibrateForces2(xforceName,yforceName,zforceName)
	string yforcename,xforceName,zforceName
	SVAR TensionName=root:g_TensionName
	wave tensionwave = $TensionName
	wave yforcewave = $yforceName
	wave xforcewave = $xforceName
	wave zforcewave = $zforceName
	variable i,n,xblankforce,yblankforce, zblankforce
	n = numpnts(Tensionwave)
	xblankforce = 0
	yblankforce = 0
	zblankforce = 0
	for(i =pcsr(A); i<pcsr(B);i+=1)
		yblankforce += yforcewave[i]
		xblankforce += xforcewave[i]
		zblankforce += zforcewave[i]
	endfor
	yblankforce /= (pcsr(B)-pcsr(A))
	xblankforce /= (pcsr(B)-pcsr(A))
	zblankforce /= (pcsr(B)-pcsr(A))
	print "blank(x, y, z):"+num2str(xblankforce)+","+num2str(yblankforce)+","+num2str(zblankforce)
	for(i=0;i <n;i+=1)
		tensionwave[i] = sqrt(square(yforcewave[i]-yblankforce)+square(xforcewave[i]-xblankforce)+square(zforcewave[i]-zblankforce))
	endfor
end

Function calibrateForces3(xforceName,xblankforce,yforceName,yblankforce,zforceName,zblankforce)
	string yforcename,xforceName,zforceName
	variable xblankforce,yblankforce,zblankforce
	SVAR TensionName=root:g_TensionName
	wave tensionwave = $TensionName
	wave yforcewave = $yforceName
	wave xforcewave = $xforceName
	wave zforcewave = $zforceName
	variable i,n
	n = numpnts(Tensionwave)	
	for(i=0;i <n;i+=1)
		tensionwave[i] = sqrt(square(yforcewave[i]-yblankforce)+square(xforcewave[i]-xblankforce)+square(zforcewave[i]-zblankforce))
	endfor
end

Function findstiffness(ctrlname):buttoncontrol
	string ctrlname
	extractStiffnessParameters("Y_Force")
end

Function extractStiffnessParameters(yforcename)
	string yforcename
	SVAR cyclecntname=root:g_cyclecountname
	SVAR adistname=root:g_AdistName
	SVAR bdistname=root:g_BdistName
	SVAR statusname=root:g_StatusName
	Nvar com_a=root:g_complianceA
	Nvar com_b=root:g_complianceB
	wave yforcewave=$yforcename
	wave cyclecntwave=$cyclecntname
	wave adistwave=$adistname
	wave bdistwave=$bdistname
	wave statuswave=$statusname
	make/O/N=(101,6) root:pulseAvg
	wave pulseAvg=root:pulseAvg
	variable i,n,temp,j,yforcesum,adistsum,bdistsum,pulsenum
	variable loforcesum,hiforcesum,loadistsum,hiadistsum,lobdistsum,hibdistsum,cyclecntsum,pcnt,nlo,nhi,hilodigit
	variable risetime=5
	make/O/N=(0,6) root:stf
	wave stf=root:stf
	variable fcnt
	n=numpnts(cyclecntwave)
	i=0
	pulsenum=0
	variable flag=0
	print "CycleCount   yForce(pN)   distA(nm)  distB(nm)   HiPulses   LoPulses"
	do
		temp=statuswave[i]-4000
		if(temp>-1e-5 && temp<=1000 && pulsenum<101)
			flag=1
			if(statuswave[i]==statuswave[i-risetime+1] )
				
				j=0
				yforcesum=0
				adistsum=0
				bdistsum=0
				do
					yforcesum+=yforcewave[i+j]
					adistsum+=adistwave[i+j]
					bdistsum+=bdistwave[i+j]
					j+=1
				while((i+j)<n && statuswave[i+j]==statuswave[i+j-1])
				pulseAvg[pulsenum][0]=cyclecntwave[i+j]
				pulseAvg[pulsenum][1]=-yforcesum/j
				pulseAvg[pulsenum][2]=adistsum/j
				pulseAvg[pulsenum][3]=bdistsum/j
				pulseAvg[pulsenum][4]=statuswave[i+j-1]
				pulseAvg[pulsenum][5]=j
				pulsenum+=1
				i+=j-1
			endif
		else
			if(pulsenum>1)
				loforcesum=0
				hiforcesum=0
				loadistsum=0
				hiadistsum=0
				lobdistsum=0
				hibdistsum=0
				nlo=0
				nhi=0
				cyclecntsum=0
				pcnt=0
				for(j=0;j<(pulsenum-1);j+=1)
					if(pulseAvg[j][5]>20)
						hilodigit=floor((pulseAvg[j][4]-4*floor(pulseAvg[j][4]/4))/2)
						if(hilodigit==0)
							loforcesum+=pulseAvg[j][1]
							loadistsum+=pulseAvg[j][2]
							lobdistsum+=pulseAvg[j][3]
							nlo+=1
						else
							if(hilodigit==1)
								hiforcesum+=pulseAvg[j][1]
								hiadistsum+=pulseAvg[j][2]
								hibdistsum+=pulseAvg[j][3]
								nhi+=1
							endif
						endif
						cyclecntsum+=pulseAvg[j][0]
						pcnt+=1
					endif
				endfor
				if(pcnt>0 && nlo>0 && nhi >0)
					temp=numpnts(stf)/6
					insertpoints temp,1,stf
					stf[temp][0]=cyclecntsum/pcnt
					stf[temp][1]=(hiforcesum/nhi+loforcesum/nlo)/2
					stf[temp][2]=abs(hiadistsum/nhi-loadistsum/nlo)
					stf[temp][3]=abs(lobdistsum/nlo-hibdistsum/nhi)
					stf[temp][4]=nhi
					stf[temp][5]=nlo
					print cyclecntsum/pcnt, (hiforcesum/nhi+loforcesum/nlo)/2,hiadistsum/nhi-loadistsum/nlo,lobdistsum/nhi-hibdistsum/nlo,nhi,nlo
				endif
				pulsenum=0
			endif
		endif
		i+=1
	while(i<n)
	if(flag)
		make/O/N=(numpnts(stf)/6) root:stiffnessx
		make/O/N=(numpnts(stf)/6) root:stiffnessy
		wave stfx=root:stiffnessx
		wave stfy=root:stiffnessy
		for(i=0;i<numpnts(stf)/6;i+=1)
			stfx[i]=stf[i][1]
			stfy[i]=1/(2/stf[i][2]+2/stf[i][3])
		endfor
		display/N=stf stiffnessy vs stiffnessx
		ModifyGraph mode=3
		CurveFit/NTHR=0 line  stiffnessy /X=stiffnessx /D 
		wave coef=root:W_coef
		com_a=coef[0]
		com_b=coef[1]
	else
		print "None"
	endif
end

Function/S num2str_precise(num)////only for integer
	variable num
	string str
	variable temp
	num=floor(num)
	str=""
	if(num==0)
		return "0"
	endif
	for(;num>0;)
		temp=num-floor(num/10)*10
		str=num2str(temp)+str
		num=(num-temp)/10
	endfor
	return str
end

Function cursorMove(ctrlname):buttoncontrol
	string ctrlname
	variable count=0
	string tempstr=CsrInfo(A,"Loading")
	string tracea=StringByKey("TNAME",tempstr,":",";")
	variable pointa = -1
	variable left
	if(cmpstr(tracea,""))
		pointa= NumberByKey("POINT",tempstr,":",";")
		count+=1
	endif
	tempstr=CsrInfo(B,"Loading")
	string traceb=StringByKey("TNAME",tempstr,":",";")
	variable pointb = -1
	if(cmpstr(traceb,""))
		pointb= NumberByKey("POINT",tempstr,":",";")
		count+=2
	endif
	if(count==3)
		if(!cmpstr(tracea,traceb))
			strswitch(ctrlname)
				case "cursorMove_dualleft":
					pointa=slidecursor("root:status",pointa,-1)
					pointb=slidecursor("root:status",pointb,-1)
					break
				case "cursorMove_dualright":
					pointa=slidecursor("root:status",pointa,1)
					pointb=slidecursor("root:status",pointb,1)
					break
				case "cursorMove_left":
					if(pointb>pointa)
						pointa=slidecursor("root:status",pointa,-1)
					else
						pointb=slidecursor("root:status",pointb,-1)
					endif
					break
				case "cursorMove_right":
					if(pointb<pointa)
						pointa=slidecursor("root:status",pointa,1)
					else
						pointb=slidecursor("root:status",pointb,1)
					endif
					break
				case "cursorMove_twoway":
					if(pointb>pointa)
						pointa=slidecursor("root:status",pointa,-1)
						pointb=slidecursor("root:status",pointb,1)
					else
						pointb=slidecursor("root:status",pointb,-1)
						pointa=slidecursor("root:status",pointa,1)
					endif
					break
			endswitch
			cursor/W=Loading A,$tracea,pointa
			cursor/W=Loading B,$traceb,pointb
		endif
	elseif(count!=0)
		strswitch(ctrlname)
			case "cursorMove_left":
			case "cursorMove_dualleft":
				if(count==1) 
					cursor/W=Loading A,$tracea,slidecursor("root:status",pointa,-1)
				else
					cursor/W=Loading B,$traceb,slidecursor("root:status",pointb,-1)
				endif
				break
			case "cursorMove_right":
			case "cursorMove_dualright":
				if(count==1) 
					cursor/W=Loading A,$tracea,slidecursor("root:status",pointa,1)
				else
					cursor/W=Loading B,$traceb,slidecursor("root:status",pointb,1)
				endif
				break
		endswitch
		
	endif
	doupdate
end

Function slidecursor(followtrace,location,direction)
	variable location,direction
	string followtrace
	wave status=$followtrace
	variable speedup=1*direction
	location+=speedup
	if(location<0)
		location=0
	endif
	if(location>=numpnts(status))
		location=numpnts(status)-1
	endif
	variable i = location
	string tracename
	for(;floor(status[i]/1000)==floor(status[location]/1000) && (status[i]&1)==(status[location]&1) ;i+=speedup)
		if(i<-speedup || i>=numpnts(status)-speedup)
			break
		endif
	endfor
	
	return i
end