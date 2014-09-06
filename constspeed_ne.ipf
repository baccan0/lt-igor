#pragma rtGlobals=1		// Use modern global access method.
constant NUMWLCFITPARA=4

Function initConstSpeedPara()
	Make/O/T/N=0 g_waveBox
	Make/O/N=0 g_waveBoxSelect
	Make/O/W/U g_waveBoxColor={{0,0,0},{65535,0,0},{0,65535,0},{0,0,65535},{0,65535,65535}}
	MatrixTranspose g_waveBoxColor
	Make/O/T/N=(0,3) g_infoBox
	Make/O/N=0 g_infoBoxSelect

	Make/O/T/N=0 g_panelDrawingList
	Make/O/N=0 g_panelDrawingItemInfoNum
	Make/O g_drawingStatusPara={{0,1,0,0,0,0,0,0,0,0,0,0},{0,3,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}
	MatrixTranspose g_drawingStatusPara
	make/O/N=2 g_infoShowPara={7,7}
	make/O g_smoothPara={{1,21,0.2,0.3,10},{1,21,0.2,0.3,0}}
	MatrixTranspose g_smoothPara

	Variable/G g_showExtFlag=0
	
	Variable/G g_complianceA=4
	Variable/G g_complianceB=0
	Variable/G g_insertFlag=0
	Variable/G g_isSpeedSetScale=0
	Variable/G g_AFPnum=1
	Variable/G g_AFPLowForce=5
	Variable/G g_AFPHighForce=20
	Variable/G g_AFPStepwise=0.1
	Variable/G g_AFPLevelGap=3
	Variable/G g_AFPForceSmth1=11
	Variable/G g_AFPForceSmth2=3
	String/G g_currentFittingTrace=""
	Variable/G g_saveFittingFlag=0

//	Variable/G g_isFiltered=0
end

Window ConstSpeedAnalysis() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(780,193,1729,773)
//	Button refreshwaves,pos={7,4},size={83,20},proc=refreshWaves,title="refresh waves"
	ListBox waveBox,pos={78,14},size={123,342},proc=waveBoxController,colorWave=g_waveBoxColor
	ListBox waveBox,listWave=root:g_waveBox,selWave=root:g_waveBoxSelect,mode= 3
	ListBox peakBox,pos={9,371},size={195,90},listWave=root:g_infoBox,selwave=root:g_infoBoxSelect,mode=3,proc=infoBoxController
	SetDrawEnv fillpat= 0
	Button addbutton,pos={15,476},size={50,15},title="+",proc=addInfoItem
	Button minusbutton,pos={80,476},size={50,15},title="-",proc=delInfoItem
	Button autobutton,pos={145,476},size={50,15},title="A"
	Button fitandcalibutton,pos={5,508},size={50,15},title="FC",proc=fitAndCalibrate
	Button fitbutton,pos={55,508},size={50,15},title="F",proc=fitOnly
	Button savefitbutton,pos={105,508},size={50,15},title="+F",proc=savefit
	Button delfitbutton,pos={155,508},size={50,15},title="-F"
	Button mergedatabutton,pos={6,560},size={50,15},title=">>Table"
//	Setvariable AFPnumInput,pos={14,468},size={90,18},title="#peaks",value=g_AFPnum
//	Setvariable AFPLowForceInput,pos={14,490},size={90,18},title="Low Force",value=g_AFPLowForce
//	Setvariable AFPHighForceInput,pos={104,490},size={97,18},title="High Force",value=g_AFPHighForce
//	Setvariable AFPStepwiseInput,pos={14,513},size={68,18},title="Step",value=g_AFPStepwise
//	Setvariable AFPGapInput,pos={104,513},size={68,18},title="Gap",value=g_AFPLevelGap
//	Setvariable AFPForceSmth1Input,pos={14,535},size={128,18},title="Level Smoothing",value=g_AFPForceSmth1
//	Setvariable AFPForceSmth2Input,pos={14,556},size={142,18},title="Locating Smoothing",value=g_AFPForceSmth2
//	Button AutoFindPeak,pos={128,444},size={80,25},proc=AutoFindPeak,title="AutoFindPeak"
//	Button mergeData,pos={106,4},size={83,20},proc=mergeAllData,title="Merge data"
	Display/W=(215,12,903,555)/HOST=#  
	RenameWindow #,G0
	SetActiveSubwindow ##
	g_showExtFlag=2
EndMacro

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////hook func
Function myhook(s)
	Struct WMWinHookStruct &s
	switch(s.eventCode)
		case 11:
			switch(s.keyCode)
				case 97://a
					addInfoItem("")
				break
				case 100://d
					delInfoItem("")
				break
				case ://u
				break
				case 65://F
					fitOnly("")
				break
				case 68://D
				break
				case ://S
					saveFit("")
				break
				case ://C
					fitAndCalibrate("")
				break
			endswitch
	endswitch
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////ListBox
Function waveBoxController(LB_Struct):listboxcontrol
	STRUCT WMListboxAction &LB_Struct
	wave/T waveBox= root:g_waveBox
	wave waveBoxSelect=root:g_waveBoxSelect
	wave/T drawinglist=root:g_panelDrawingList

	Variable ii,n,j
	n=numpnts(waveBox)
	switch(LB_Struct.eventcode)
		case 4:
		case 5:	
			deletepoints 0,numpnts(drawinglist),drawinglist
			for(ii=0;ii<n;ii+=1)
				if(waveBoxSelect[ii][0][0]&1)
					j=numpnts(drawinglist)
					insertpoints j,1,drawinglist
					drawinglist[j]=waveBox[ii]
				endif
			endfor	
			updateInfoBox()	
			drawPanelGraph()
	endswitch
end

Function infoBoxController(s):listboxcontrol
	STRUCT WMListboxAction &s
	wave status=root:g_drawingStatusPara
	wave/T drawinglist=root:g_panelDrawingList
	wave/T infoBox=root:g_infoBox
	wave pdiin=root:g_panelDrawingItemInfoNum
	NVAR pid=root:g_peakInfoDimension
	wave isp=root:g_infoShowPara
	switch(s.eventcode)
		case 4:
		case 5:	
			if(status[0][10])
				updatePanelGraph(10,status[1][10]&1,status[1][10]&2)
			endif
			if(status[0][11])
				updatePanelGraph(10,status[1][11]&1,status[1][11]&2)
			endif
			if(status[2][0]&&status[2][10])
				updatePanelGraph(10,status[3][10]&1,status[3][10]&2)
			endif
			if(status[2][0]&&status[2][11])
				updatePanelGraph(11,status[3][11]&1,status[3][11]&2)
			endif
		break
		case 7:
			variable changedvalue=str2num(infoBox[s.row][s.col])
			variable k,m,j,i
			for(k=s.row,m=0;k>=pdiin[m];)
				k-=pdiin[m]
				m+=1
			endfor
			j=0
			for(i=0;j<s.col+1 && i<pid;i+=1)
				if(isp[getDrawingMode()]&(2^i))
					j+=1
				endif
			endfor
			i-=1
			wave chginfo=$getCurrentDatafolder()+"Peak_info_"+getSuffix(drawinglist[k])
			chginfo[m][i]=changedvalue
		break
	endswitch
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Button
Function addInfoItem(ctrlname):buttoncontrol
	string ctrlname
	variable isunfold=0
	NVAR peakInfoDimension= root:g_peakInfoDimension
	wave/T drawinglist=root:g_panelDrawingList
	SetActivesubwindow constspeedAnalysis#G0
	string tempstr=CsrInfo(A,"constspeedAnalysis#G0")
	string tracename=StringByKey("TNAME",tempstr,":",";")
	if(cmpstr(tracename,"")!=0)
		variable point=str2num(StringByKey("POINT",tempstr,":",";"))
		string tracename2=drawinglist[str2num(getSuffix(tracename))]
		string suffixname=getSuffix(tracename2)
		if(stringmatch(suffixname,"Unf*"))
			isunfold=1
		endif
		wave peak_info=$getCurrentDatafolder()+"Peak_Info_"+getSuffix(tracename2)
		wave timeinfo=$getCurrentDatafolder()+"Time_"+getSuffix(tracename2)
		Variable n=numpnts(peak_info)/peakInfoDimension
		if(n==0)
			make/O/N=(1,peakInfoDimension) $getCurrentDatafolder()+"Peak_Info_"+getSuffix(tracename2)
			wave peak_info=$getCurrentDatafolder()+"Peak_Info_"+getSuffix(tracename2)
		else
			Insertpoints n,1,peak_info
		endif
		//wave tempwavey=$"root:display:"+tracename
		addItem(peak_info,vcsr(A,"constspeedAnalysis#G0"),hcsr(A,"constspeedAnalysis#G0"),timeinfo[point],isunfold,0,0,0)
		updateInfoBox()
	endif	
end

Function delInfoItem(ctrlname):buttoncontrol
	string ctrlname
	wave/T drawinglist=root:g_panelDrawingList
	wave pdiin=root:g_panelDrawingItemInfoNum
	wave/T infoBox=root:g_infoBox
	wave infoBoxSel=root:g_infoBoxSelect	
	variable m=getInfoBoxDim()	
	variable n=numpnts(infoBoxSel)/m
	variable i,j,k,l
	if(n>0)
		i=n-1
		do			
			if(isSelected(infoBoxSel,m,i))
				for(k=i,l=0;k>=pdiin[l];)
					k-=pdiin[l]
					l+=1
				endfor
				wave tempwave=$getCurrentDatafolder()+"Peak_Info_"+getSuffix(drawinglist[l])
				delItem(tempwave,k)
			endif
			i-=1
		while(i>=0)
	endif
	infoBoxSel[0][0]=infoBoxSel[0][0]|1
	updateInfoBox()
	doUpdate
end

Function fitAndCalibrate(ctrlname):buttoncontrol
	string ctrlname
	SVAR tracename=root:g_currentFittingTrace
	tracename=curveFittingToCalibrate()
	if(cmpstr(tracename,"")!=0)
		setFitting(1)
	endif
end

Function fitOnly(ctrlname):buttoncontrol
	string ctrlname
	SVAR tracename=root:g_currentFittingTrace
	tracename=curveFittingOnly()
	if(cmpstr(tracename,"")!=0)
		setFitting(1)
	endif
end

Function saveFit(ctrlname):buttonControl
	string ctrlname
	NVAR svf=root:g_saveFittingFlag
	SVAR tracename=root:g_currentFittingTrace
	wave W_coef=root:w_coef
	wave e=root:episilon
	variable i
	if(svf && cmpstr(tracename,"")!=0 && numpnts($getCurrentDatafolder()+tracename)>0)
		
		if(numpnts($getCurrentDatafolder()+"Fit_"+getSuffix(tracename))>0)
			wave tempwave=$getCurrentDatafolder()+"Fit_"+getSuffix(tracename)
			variable n=numpnts(tempwave)/2
			insertpoints n,4, tempwave
			for(i=0;i<4;i+=1)
				tempwave[n+i][0]=W_coef[i]
				tempwave[n+i][1]=e[i]
			endfor
		else
			make/O/N=(4,2) $getCurrentDatafolder()+"Fit_"+getSuffix(tracename)
			wave tempwave=$getCurrentDatafolder()+"Fit_"+getSuffix(tracename)
			for(i=0;i<4;i+=1)
				tempwave[i][0]=W_coef[i]
				tempwave[i][1]=e[i]
			endfor
		endif
		setFitting(0)
	endif
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////display

Function refreshWaves(ctrlname):buttoncontrol
	string ctrlname
	wave/T waveBox= root:g_waveBox
	//wave/T infoBox = root:g_infoBox
	String inboxlist 
	variable inboxnum
	switch(getDrawingMode())
		case 0:
			SetDataFolder $getCurrentDatafolder()	
			inboxlist= WaveList("Tension_*",";","");
			inboxnum = ItemsInList(inboxlist);
		break
		case 1:
			SetDataFolder $getCurrentDatafolder()
			inboxlist=Wavelist("Distance_*",";","");
			inboxnum=ItemsInlist(inboxlist);
		break
		case 2:
		break
	endswitch
	print inboxnum
	Deletepoints 0,numpnts(waveBox),waveBox
	insertpoints 0,inboxnum,waveBox
	
	Make/O/N=(inboxNum,1,2) root:g_waveBoxSelect
	wave waveBoxSelect= root:g_waveBoxSelect
	
	waveBoxSelect[0][0][0]=1
	
	Variable ii=0
	for(;ii<inboxnum;ii+=1)
		waveBox[ii]=StringFromList(ii, inboxlist, ";");
	endfor		
	Make/O/T/N=1 root:g_panelDrawingList
	wave/T drawinglist=root:g_panelDrawingList
	drawinglist[0]=waveBox[0]
	SetDataFolder root:
end

Function dist2Ext(waved,wavef)
	wave waved,wavef
	NVAR a=g_complianceA
	NVAR b=g_complianceB
	variable i,n
	n=numpnts(waved)
	for(i=0;i<n;i+=1)
		waved[i]-=(a*wavef[i]-b*wavef[i]*wavef[i])
	endfor
end

Function clearAll(graphName)
	string graphName
	clearTraces(graphName,"*")
	KillDataFolder/Z root:display
	NewDataFolder root:display
end

Function clearTraces(graphName,recognizer)
	string graphName,recognizer
	variable ii,tracenum
	string tracenames,tracename
	tracenames=tracenamelist(graphName,";",1)
	//clear all traces
	tracenum=ItemsInList(tracenames)
	for(ii=0;ii<tracenum;ii+=1)
		tracename=stringfromList(ii,tracenames)
		if(stringmatch(tracename,recognizer))
			removefromgraph/W=$graphName $tracename
		endif
	endfor
	delayUpdate
end

Function myAppendToGraph2(graphName,wavey,isleft,isbottom)
	string graphName
	wave wavey
	variable isleft,isbottom
	if(isleft)
		if(isbottom)
			appendToGraph/L/B/W=$graphName wavey
		else
			appendToGraph/L/T/W=$graphName wavey 
		endif
	else
		if(isbottom)
			appendToGraph/R/B/W=$graphName wavey 
		else
			appendToGraph/R/T/W=$graphName wavey
		endif
	endif
end

Function myAppendToGraph(graphName,wavey,wavex,isleft,isbottom)
	string graphName
	wave wavey,wavex
	variable isleft,isbottom
	if(isleft)
		if(isbottom)
			appendToGraph/L/B/W=$graphName wavey vs wavex
		else
			appendToGraph/L/T/W=$graphName wavey vs wavex
		endif
	else
		if(isbottom)
			appendToGraph/R/B/W=$graphName wavey vs wavex
		else
			appendToGraph/R/T/W=$graphName wavey vs wavex
		endif
	endif
end

Function drawPanelGraph()
	clearAll("ConstSpeedAnalysis#G0")
	wave/T drawinglist=root:g_panelDrawingList
	wave status=root:g_drawingStatusPara
	variable i,j
	for(i=0;i<numpnts(drawinglist);i+=1)
		make/O $"root:display:distance"+num2str(getDrawingMode())+"_"+num2str(i)
		make/O $"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i)
		make/O $"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i)
		make/O $"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
		wave distancewave=$"root:display:distance"+num2str(getDrawingMode())+"_"+num2str(i)
		wave tensionwave=$"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i)
		wave timewave=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
		wave distancesmthwave=$"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i)
		duplicate/O $getCurrentDatafolder()+"Tension_"+getSuffix(drawinglist[i]),tensionwave
		duplicate/O $getCurrentDatafolder()+"Distance_"+getSuffix(drawinglist[i]),distancewave
		smoothTraces(distancewave,distancesmthwave,0)
		duplicate/O $getCurrentDatafolder()+"Time_"+getSuffix(drawinglist[i]),timewave
		
	endfor
	for(i=1;i<12;i+=1) //use a variable to keep 12
		if(status[0][i])
			updatePanelGraph(i,status[1][i]&1,status[1][i]&2)
		endif
	endfor
	if(status[2][0])
		for(i=1;i<12;i+=1)
			if(status[2][i])
				updatePanelGraph(i,status[3][i]&1,status[3][i]&2)
			endif
		endfor
		doUpdate
		GetAxis /Q/W=$"ConstSpeedAnalysis#G0" left 
		SetAxis/W=$"ConstSpeedAnalysis#G0" left, 2*V_min-V_max,V_max
		delayupdate
		GetAxis /Q/W=$"ConstSpeedAnalysis#G0" right
		SetAxis/W=$"ConstSpeedAnalysis#G0" right, V_min,2*V_max-V_min
		doupdate
	endif
	setFitting(0)
end

Function updatePanelGraph(controller,isleft,isbottom)
	variable controller
	variable isleft,isbottom
	string graphName="ConstSpeedAnalysis#G0"
	wave/T drawinglist=root:g_panelDrawingList
//	wave smoothPara=root:g_smoothPara //need updating
	string tempstr
	NVAR pid=root:g_peakInfoDimension
	variable num,m
	wave infoBoxSel=root:g_infoBoxSelect
	variable i,n,j,count
	n=numpnts(drawinglist)
	switch(controller)
		case 1:
			clearTraces(graphName,"tension")
			for(i=0;i<n;i+=1)
				tempstr="tension"+num2str(getDrawingMode())+"_"+num2str(i)
				myAppendToGraph(graphName,$"root:display:"+tempstr,$"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i),isleft,isbottom)
				//appendtograph/W=$graphName $"root:display:"+tempstr vs $"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i)
				modifygraph/W=$graphName rgb($tempstr)=(65535,0,0) 
				delayupdate
			endfor
			break
		case 2:
			clearTraces(graphName,"distsmth")				
			for(i=0;i<n;i+=1)
				tempstr="tensmth"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i)
				smoothTraces($"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				delayupdate
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0) 
				delayupdate
			endfor
			break
		case 3:
			clearTraces(graphName,"extensiony")
			for(i=0;i<n;i+=1)
				tempstr="extensiony"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				make/O $"root:display:extensionx"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavex=$"root:display:extensionx"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavey=$"root:display:"+tempstr
				duplicate/O $"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i), tempwavex
				duplicate/O $"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i), tempwavey
				dist2Ext(tempwavex,tempwavey)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				delayupdate
				modifygraph/W=$graphName rgb($tempstr)=(0,0,65535)
				delayupdate
			endfor
			break
		case 4:
			clearTraces(graphName,"extensmthy")
			for(i=0;i<n;i+=1)
				tempstr="extensmthy"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				make/O $"root:display:extensmthx"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavex=$"root:display:extensmthx"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavey=$"root:display:"+tempstr
				duplicate/O $"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i), tempwavex
				smoothTraces($"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				dist2Ext(tempwavex,tempwavey)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				delayupdate
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0)
				delayupdate
			endfor
			break
		case 5:
			clearTraces(graphName,"distance")
			for(i=0;i<n;i+=1)
				tempstr="distance"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				modifygraph/W=$graphName rgb($tempstr)=(65535,0,0) 
				delayupdate
			endfor
			break
		case 6:
			clearTraces(graphName,"distsmth")
			for(i=0;i<n;i+=1)
				tempstr="distsmth"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
				smoothTraces($"root:display:distance"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0) 
				delayupdate
			endfor
			break
		case 7:
			clearTraces(graphName,"tensiontime")
			for(i=0;i<n;i+=1)
				tempstr="tensiontime"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
				duplicate/O $"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				modifygraph/W=$graphName rgb($tempstr)=(65535,0,0) 
				delayupdate
			endfor
			break
		case 8:
			clearTraces(graphName,"tensiontimesmth")
			for(i=0;i<n;i+=1)
				tempstr="tensiontimesmth"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
				smoothTraces($"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0) 
				delayupdate
			endfor
			break
		case 9:			
			clearTraces(graphName,"WLCFIT")
			if(isleft)
				GetAxis /Q/W=$graphName left
			else
				GetAxis /Q/W=$graphName right
			endif
			make/O/N=4 root:display:w_fit
			wave w=root:display:w_fit
			for(i=0;i<n;i+=1)
					if(numpnts($getCurrentDatafolder()+"Fit_"+getSuffix(drawinglist[i]))>=(NUMWLCFITPARA*2))
						wave tempwave=$getCurrentDatafolder()+"Fit_"+getSuffix(drawinglist[i])
						count=0
						for(j=0;j<numpnts(tempwave)/2;j+=NUMWLCFITPARA)
							make/O/N=10001 $"root:display:WLCFIT"+num2str(i)+"_"+num2str(count)
							wave tempfit=$"root:display:WLCFIT"+num2str(i)+"_"+num2str(count)
							w[0]={tempwave[j][0],tempwave[j+1][0],tempwave[j+2][0],tempwave[j+3][0]}
							variable xlimit=inv_mod_MuS(w, V_max)
							setScale/I x 0,xlimit,tempfit
							for(m=0;m<10001;m+=1)
								tempfit[m]=mod_Mus(w,m*xlimit/10000)
							endfor
							myAppendToGraph2(graphName,tempfit,isleft,isbottom)
							doupdate
							//appendtograph/W=$graphName tempwave;delayUpdate
							modifygraph/W=$graphName rgb($"WLCFIT"+num2str(i)+"_"+num2str(count))=(32768,0,65535);delayUpdate
							tag /A=RT /L=1 /Z=0 /B=0 $"WLCFIT"+num2str(i)+"_"+num2str(count),100,"p="+num2str(tempfit[j])+";L="+num2str(tempfit[j+2])+";K="+num2str(tempfit[j+3])
							count+=1
						endfor
					endif
			endfor
			//tag /A=LT /L=1 /Z=0 /B=0 stiffness24,100,"haha"
			break
		case 10:
			clearTraces(graphName,"Peak")
			if(isbottom)
				GetAxis /Q/W=$graphName bottom
			else
				GetAxis /Q/W=$graphName top
			endif
			
			m=getInfoBoxDim()
			count=0
			for(i=0;i<n;i+=1)
				wave tempinfo=$getCurrentDatafolder()+"Peak_info_"+getSuffix(drawinglist[i])
				num=numpnts(tempinfo)/pid
				if(num>0)
					for(j=0;j<num;j+=1)
						make/O/N=2 $"root:display:Peak_"+num2str(count)
						wave tempwave=$"root:display:Peak_"+num2str(count)
						setScale/I x V_min,V_max,tempwave
						tempwave=tempinfo[j][0]
						myAppendToGraph2(graphName,tempwave,isleft,isbottom)
						//appendtograph/W=$graphName tempwave;delayUpdate
						modifygraph/W=$graphName lStyle($"Peak_"+num2str(count))=2;delayUpdate
						if(isSelected(infoBoxSel,m,count))
							modifygraph/W=$graphName rgb($"Peak_"+num2str(count))=(0,0,0);delayUpdate
						else
							modifygraph/W=$graphName rgb($"Peak_"+num2str(count))=(32767,32767,32767);delayUpdate
						endif
						count+=1
					endfor
				endif
			endfor
		break
		case 11:
			clearTraces(graphName,"Jump")
			if(isleft)
				GetAxis /Q/W=$graphName left
			else
				GetAxis /Q/W=$graphName right
			endif
			m=getInfoBoxDim()
			count=0
			for(i=0;i<n;i+=1)
				wave tempinfo=$getCurrentDatafolder()+"Peak_info_"+getSuffix(drawinglist[i])
				num=numpnts(tempinfo)/pid
				if(num>0)
					for(j=0;j<num;j+=1)
						make/O/N=2 $"root:display:Jump_"+num2str(count)
						wave tempwave=$"root:display:Jump_"+num2str(count)
						setScale/I x tempinfo[j][1],(tempinfo[j][1]+0.00001),tempwave
						tempwave[0]=V_min
						tempwave[1]=V_max
						myAppendToGraph2(graphName,tempwave,isleft,isbottom)
						//appendtograph/W=$graphName tempwave;delayUpdate
						modifygraph/W=$graphName lStyle($"Jump_"+num2str(count))=2;delayUpdate
						if(isSelected(infoBoxSel,m,count))
							modifygraph/W=$graphName rgb($"Jump_"+num2str(count))=(0,0,0);delayUpdate
						else
							modifygraph/W=$graphName rgb($"Jump_"+num2str(count))=(32767,32767,32767);delayUpdate
						endif
						count+=1
					endfor
				endif
			endfor
		break
	endswitch
	doupdate
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////helper

Function setFitting(flag)
	variable flag
	NVAR svf=root:g_saveFittingFlag
	svf = flag
end

Function/S getCurrentDatafolder()
	string str
	switch(getDrawingMode())
		case 0: 
			str="root:constSpeed:"
			break
		case 1:
			str="root:constForce:"
			break
		case 2:
			str="root:other:"
			break
	endswitch
	return str
end

Function getDrawingMode()
	wave status=root:g_drawingStatusPara
	return status[0][0]
end

Function/S getModeName()
	string str
	switch(getDrawingMode())
		case 0:
			str="CS"
			break
		case 1:
			str="CF"
			break
		case 2:
			str="OT"
			break
	endswitch
end

Function /S getSuffix(sourStr)
	string sourStr
	string temp1,temp2
	if(stringmatch(sourStr,"*_*"))
		splitstring /E="([a-zA-Z0-9_]*)_([^_]*)" sourStr,temp1,temp2
	endif
	return temp2
end

Function addItem(peak_info,a,b,c,d,e,f,g)
	wave peak_info
	variable a,b,c,d,e,f,g
	peak_info[n][0]=a//vcsr(A,"constspeedAnalysis#G0")//[point]
	peak_info[n][1]=b//hcsr(A,"constspeedAnalysis#G0")//[point]
	peak_info[n][4]=c//timeinfo[point]
	peak_info[n][2]=d//isunfold
	peak_info[n][3]=e//0//cLIncrement
	//getProteinDistance(peak_info[n][1],peak_info[n][0], distAve, distStddev)
	peak_info[n][5]=f//0//distAve
	peak_info[n][6]=g//0//distStddev
end

Function getInfoBoxDim()
	variable m,i
	wave infoShowPara=root:g_infoShowPara
	NVAR pid=root:g_peakInfoDimension
	for(i=0;i<pid;i+=1)
		if(infoShowPara[getDrawingMode()]&(2^i))
			m+=1
		endif
	endfor
	return m
end

Function delItem(peak_info,k)
	wave peak_info
	variable k
	deletepoints k,1,peak_info
end

Function isSelected(w,y,index)
	wave w
	variable y,index
	variable j
	variable n=numpnts(w)/y
	for(j=0;j<n;j+=1)
		if(w[index][j]&1)
			break
		endif
	endfor
	if(j<n) 
		return 1
	else 
		return 0
	endif
end

Function updateInfoBox()
	wave/T drawinglist=root:g_panelDrawingList
	NVAR pid=root:g_peakInfoDimension
	wave infoShowPara=root:g_infoShowPara
	variable n=0,i,m=0,j,k,ibx,iby
	make/O/N=(numpnts(drawinglist)) root:g_panelDrawingItemInfoNum
	wave pdiin=root:g_panelDrawingItemInfoNum
	for(i=0;i<numpnts(drawinglist);i+=1)
		pdiin[i]= numpnts($getCurrentDatafolder()+"Peak_Info_"+getSuffix(drawinglist[i]))/pid
		n+=pdiin[i]
	endfor	
	m=getInfoBoxDim()
	if(getDrawingMode()==0)
		Make/O/T/N=(n,m) root:g_infoBox
		Make/O/N=(n,m) root:g_infoBoxSelect	
		wave/T infoBox=root:g_infoBox
		wave infoBoxSel=root:g_infoBoxSelect
		ibx=0
		for(i=0;i<numpnts(pdiin);i+=1)
			if(pdiin[i]>0)
				wave temppeakinfo=$getCurrentDatafolder()+"Peak_Info_"+getSuffix(drawinglist[i])
				for(j=0;j<pdiin[i];j+=1)
					iby=0
					for(k=0;k<pid;k+=1)
						if(infoShowPara[0]&(2^k))
							infoBox[ibx][iby]=num2str(temppeakinfo[j][k])
							infoBoxSel[ibx][iby]=2
							iby+=1
						endif
					endfor
					ibx+=1
					//print ibx,iby
				endfor
			endif
		endfor
		infoBoxSel[0][0]=infoBoxSel[0][0]|1
	elseif(getDrawingMode()==1)
	endif
	doUpdate
end

Function smoothTraces(sourWave,destWave,selector)
/// inprement to smooth the data 
/// para[0],para[1] represent two set of parameter
/// para[0 or 1][0] tells which method to use
///			0: box smoothing	(using para[][1])
///			1: low pass filter (using para[][2] and para[][3])
///			2: polynomial fitting (using para[][4])
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
			make/O/N=0 root:filtered
			wave temp=root:filtered
			Duplicate/O sourWave, temp
			Make/O/D/N=0 root:coefs
			FilterFIR/DIM=0/LO={para[selector][2],para[selector][3],101}/COEF root:coefs, temp //101 may have to be changed
			duplicate/O temp, destWave	
		break
		case 3:	
			make/O/N=0 root:filtered
			wave temp=root:filtered
			Duplicate/O sourWave, temp
			duplicate/O temp,destWave
			CurveFit/NTHR=0 poly para[selector][4],  temp /D=destWave	
		break
	endswitch
end

Function/S curveFittingToCalibrate()
	variable a,b,m
	wave/T drawinglist=root:g_panelDrawingList
	string tempstr=CsrInfo(A,"constspeedAnalysis#G0")
	string tracename=StringByKey("TNAME",tempstr,":",";")
	string tempstrb=CsrInfo(B,"constspeedAnalysis#G0")
	if(cmpstr(tracename,StringByKey("TNAME",tempstrb,":",";"))==0)
		a=str2num(StringByKey("POINT",tempstr,":",";"))
		b=str2num(StringByKey("POINT",tempstrb,":",";"))
		//print a,b
		make/D/O/N=5 root:w_coef
		wave W_coef=root:w_coef
		W_coef[0]={20,298,540,500,-1500}
		make/D/O/N=5 root:episilon
		wave e=root:episilon
		e[0]={1,1,1,1,1}
		print tracename
		wave wavey=$"root:display:"+tracename
		wave wavex=XWaveReffromtrace("constspeedAnalysis#G0",tracename)
		FuncFit/H="01100"/NTHR=0 mod_MuS_offset W_coef  wavey[min(a,b),max(a,b)] /X=wavex  /E=e
		//eWLCFitting_offset(XWaveReffromtrace("constspeedAnalysis#G0",tracename),$"root:display:"+tracename,min(a,b),max(a,b)
		variable index=str2num(getSuffix(tracename))
		wave distwave=$getCurrentDatafolder()+"Distance_"+getSuffix(drawinglist[index])
		distwave-=W_coef[4]
		wavex-=W_coef[4]
		make/O/N=10001 $"root:display:WLCFITEXAMPLE"
		wave tempfit=$"root:display:WLCFITEXAMPLE"
		deletepoints 4,1,W_coef
		variable xlimit=inv_mod_MuS(W_coef, max(wavey[0],wavey[numpnts(wavey)-1]))
		setScale/I x 0,xlimit,tempfit
		for(m=0;m<10001;m+=1)
			tempfit[m]=mod_Mus(W_coef,m*xlimit/10000)
		endfor
		clearTraces("constspeedAnalysis#G0","WLCFITEXAMPLE")
		appendTograph/W=$"constspeedAnalysis#G0" tempfit
		return drawinglist[index]
	endif
	return ""
end

Function/S curveFittingOnly()
	variable a,b,m
	wave/T drawinglist=root:g_panelDrawingList
	string tempstr=CsrInfo(A,"constspeedAnalysis#G0")
	string tracename=StringByKey("TNAME",tempstr,":",";")
	string tempstrb=CsrInfo(B,"constspeedAnalysis#G0")
	if(cmpstr(tracename,StringByKey("TNAME",tempstrb,":",";"))==0)
		a=str2num(StringByKey("POINT",tempstr,":",";"))
		b=str2num(StringByKey("POINT",tempstrb,":",";"))
		//print a,b
		make/D/O/N=4 root:w_coef
		wave W_coef=root:w_coef
		W_coef[0]={20,298,540,500}
		make/D/O/N=4 root:episilon
		wave e=root:episilon
		e[0]={1,1,1,1}
		print tracename
		wave wavey=$"root:display:"+tracename
		wave wavex=XWaveReffromtrace("constspeedAnalysis#G0",tracename)
		FuncFit/H="0100"/NTHR=0 mod_MuS W_coef  wavey[min(a,b),max(a,b)] /X=wavex  /E=e
		//eWLCFitting_offset(XWaveReffromtrace("constspeedAnalysis#G0",tracename),$"root:display:"+tracename,min(a,b),max(a,b))
		make/O/N=10001 $"root:display:WLCFITEXAMPLE"
		wave tempfit=$"root:display:WLCFITEXAMPLE"
		deletepoints 4,1,W_coef
		variable xlimit=inv_mod_MuS(W_coef, max(wavey[0],wavey[numpnts(wavey)-1]))
		setScale/I x 0,xlimit,tempfit
		for(m=0;m<10001;m+=1)
			tempfit[m]=mod_Mus(W_coef,m*xlimit/10000)
		endfor
		clearTraces("constspeedAnalysis#G0","WLCFITEXAMPLE")
		appendTograph/W=$"constspeedAnalysis#G0" tempfit
		variable index=str2num(getSuffix(tracename))
		return drawinglist[index]
	endif
	return ""
end
