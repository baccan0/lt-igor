#pragma rtGlobals=1		// Use modern global access method.

constant NUMWLCFITPARA=4
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////global variable
Function initConstSpeedPara()
	Make/O/T/N=0 g_waveBox
	Make/O/N=0 g_waveBoxSelect
	make/O/N=0 g_waveBoxSelect_dup
	Make/O/W/U g_waveBoxColor={{0,0,0},{65535,0,0},{0,65535,0},{0,0,65535},{0,65535,65535}}
	MatrixTranspose g_waveBoxColor
	Make/O/T/N=(0,3) g_infoBox
	Make/O/N=0 g_infoBoxSelect

	Make/O/T/N=0 g_panelDrawingList
	Make/O/N=0 g_panelDrawingItemInfoNum

	Variable/G g_complianceA=4
	Variable/G g_complianceB=0
//	Variable/G g_insertFlag=0
//	Variable/G g_isSpeedSetScale=0
//	Variable/G g_showExtFlag=0
	
	Variable/G g_multiSelec=0
	Variable/G g_saveGraphCounter=0

	String/G g_currentFittingTrace=""
	Variable/G g_saveFittingFlag=0
	 initAutoFindPara()
	 initPanelDispPara()
	 initSeparator()
	 initMySmooth()
//	Variable/G g_isFiltered=0
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Panel
Window ConstSpeedAnalysis():Panel
	PauseUpdate; Silent 1		// building window...
	buildAnalysisPanel()
//	g_showExtFlag=2
EndMacro

Function buildAnalysisPanel()
	wave status=g_drawingStatusPara
	variable left,right,bottom,top
	if(!ifExisted("ConstSpeedAnalysis"))
		getscreensize(left,right,top,bottom)
		print left,right,top,bottom
		NewPanel /W=(left,top,right,bottom-100)/N=ConstSpeedAnalysis
//	Button refreshwaves,pos={7,4},size={83,20},proc=refreshWaves,title="refresh waves"
		ListBox waveBox,pos={78,14},size={123,342},proc=waveBoxController,colorWave=g_waveBoxColor,win=ConstSpeedAnalysis
		ListBox waveBox,listWave=root:g_waveBox,selWave=root:g_waveBoxSelect,mode= 3
		ListBox peakBox,pos={9,371},size={195,90},listWave=root:g_infoBox,selwave=root:g_infoBoxSelect,mode=3,proc=infoBoxController,win=ConstSpeedAnalysis
		Button addbutton,pos={55,480},size={50,15},title="+Info",proc=addInfoItem,win=ConstSpeedAnalysis
		Button minusbutton,pos={105,480},size={50,15},title="-Info",proc=delInfoItem,win=ConstSpeedAnalysis
		Button autobutton,pos={155,480},size={50,15},title="Auto",proc=autoFinditem,win=ConstSpeedAnalysis
		Button fitandcalibutton,pos={105,510},size={50,15},title="FitCali",proc=fitAndCalibrate,win=ConstSpeedAnalysis
		Button fitbutton,pos={155,510},size={50,15},title="Fit",proc=fitOnly,win=ConstSpeedAnalysis
		Button savefitbutton,pos={105,525},size={50,15},title="+Fit",proc=savefit,win=ConstSpeedAnalysis
		Button delfitbutton,pos={155,525},size={50,15},title="-Fit",win=ConstSpeedAnalysis
		Button mergedatabutton,pos={155,555},size={50,15},title=">>Table",proc=mergeData,win=ConstSpeedAnalysis
		Button outputgraphbutton,pos={105,555},size={50,15},title=">>Graph",proc=saveGraph,win=ConstSpeedAnalysis
		Button setupinfoboxbutton,pos={105,575},size={50,15},title="Info>>",proc=setupInfo,win=ConstSpeedAnalysis
		Button setupparabutton,pos={155,575},size={50,15},title="Graph>>",proc=setupPara,win=ConstSpeedAnalysis
		Button setupautofindbutton,pos={155,595},size={50,15},title="Auto>>",proc=invokeAFPPanel,win=ConstSpeedAnalysis
		Button setupsmoothbutton,pos={155,615},size={50,15},title="Smth>>",proc=invokeMySmoothPanel,win=ConstSpeedAnalysis
		Button drawseparatorbutton,pos={55,635},size={50,15},title="Sepa++",proc=invokedrawseparator,win=ConstSpeedAnalysis
		Button newseparatorbutton,pos={105,635},size={50,15},title="Sepa--",proc=invokenewseparator,win=ConstSpeedAnalysis
		Button separatoranalysisbutton,pos={155,635},size={50,15},title="Anal>>",proc=invokeanalyseSeparatorPanel,win=ConstSpeedAnalysis
		Checkbox drawingstatuscheckbox0,pos={5,20},size={65,15},title="CSpeed",value=(status[0][0]==0),proc=drawingStatusSwitch,win=ConstSpeedAnalysis
		Checkbox drawingstatuscheckbox1,pos={5,40},size={65,15},title="CForce",value=(status[0][0]==1),proc=drawingStatusSwitch,win=ConstSpeedAnalysis
		Checkbox drawingstatuscheckbox2,pos={5,60},size={65,15},title="Other",value=(status[0][0]==2),proc=drawingStatusSwitch,win=ConstSpeedAnalysis
		Button deleteTraces,pos={5,100},size={50,15},title="-traces",proc=deletetrace,win=ConstSpeedAnalysis
		Display/W=(215,12,right-20,bottom-150)/HOST=ConstSpeedAnalysis
		RenameWindow #,G0
		SetActiveSubwindow ##
		setwindow # hook(mine)=myhook
	endif
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////hook func
Function myhook(s)
	Struct WMWinHookStruct &s
	wave status=root:g_drawingStatusPara
	NVAR sflag=root:g_separatorFlag
	if(!ifExisted("analyzeSeparator"))
		switch(s.eventCode)
			case 3:
				if(sflag)
				//print s.MouseLoc.v
				//print s.MouseLoc.h

					getwindow ConstSpeedAnalysis#G0,psize
				//print "left",V_left
					if((s.MouseLoc.h-V_left)*(s.MouseLoc.h-V_right)<0 && (s.MouseLoc.v-V_top)*(s.MouseLoc.v-V_bottom)<0)
						variable graph_x=(s.MouseLoc.h-V_left)/(V_right-V_left)
						variable graph_y=(s.MouseLoc.v-V_top)/(V_bottom-V_top)
						if(status[1][12]&1)
							GetAxis /Q/W=ConstSpeedAnalysis#G0 left
						else
							GetAxis /Q/W=ConstSpeedAnalysis#G0 right
						endif
						graph_y=V_max-graph_y*(V_max-V_min)
						if(status[1][12]&2)
							GetAxis /Q/W=ConstSpeedAnalysis#G0 bottom
						else
							GetAxis /Q/W=ConstSpeedAnalysis#G0 top
						endif
					graph_x=V_min+graph_x*(V_max-V_min)
					//print graph_x,graph_y
						addPoint2Separator(graph_x,graph_y)
					endif
				endif
				break
			case 4:
				break
			case 7:
				resetItemNum()
				break
			case 11:
				shortcut(s.keycode)
				break
		endswitch
				
	endif
end

Function shortcut(code)
	variable code
	NVAR ms=root:g_multiSelec
	switch(code)
		case 97://a
			addInfoItem("")
			break
		case 100://d
			delInfoItem("")
			break
		case 114://r
			deletetrace("")
			break
		case 117://u
			autoFinditem("")
			break
		case 65://F
			fitOnly("")
			break
		case 68://D
			break
		case 83://S
			saveFit("")
			break
		case 67://C
			fitAndCalibrate("")
			break
		case 109://m
			ms=!ms
			break
		endswitch
		
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////ListBox
Function waveBoxController(LB_Struct):listboxcontrol
	STRUCT WMListboxAction &LB_Struct
	wave/T waveBox= root:g_waveBox
	wave waveBoxSelect=root:g_waveBoxSelect
	wave/T drawinglist=root:g_panelDrawingList
	NVAR ms=root:g_multiSelec
	
	Variable ii,n,j
	n=numpnts(waveBox)
	switch(LB_Struct.eventcode)
		case 4:
		case 5:	
			wave wbsd=root:g_waveBoxSelect_dup
			if(ms)
				for(ii=0;ii<n;ii+=1)
					waveBoxSelect[ii][0][0]=waveBoxSelect[ii][0][0]%^(wbsd[ii]&1)
				endfor
			endif
			deletepoints 0,numpnts(drawinglist),drawinglist
			for(ii=0;ii<n;ii+=1)
				if(waveBoxSelect[ii][0][0]&1)
					j=numpnts(drawinglist)
					insertpoints j,1,drawinglist
					drawinglist[j]=waveBox[ii]
				endif
			endfor	
			updateInfoBox(0,0)	
			drawPanelGraph()
			make/O/N=(n) root:g_waveBoxSelect_dup
			wave wbsd=root:g_waveBoxSelect_dup
			for(ii=0;ii<n;ii+=1)
				wbsd[ii]=waveBoxSelect[ii][0][0]
			endfor
			break
		case 12:
			shortcut(LB_Struct.row)
			break			
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
			updatepjonly()
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
			wave chginfo=$getCurrentDatafolder()+"Peak_info_"+getSuffix(drawinglist[m])
			chginfo[k][i]=changedvalue
		break
	endswitch
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Checkbox

Function drawingStatusSwitch(name,value):checkBoxControl
	string name
	variable value
	wave status=root:g_drawingStatusPara
	strswitch(name)
		case "drawingstatuscheckbox0":
			status[0][0]=0
		break
		case "drawingstatuscheckbox1":
			status[0][0]=1
		break
		case "drawingstatuscheckbox2":
			status[0][0]=2
		break
	endswitch
	Checkbox drawingstatuscheckbox0,value=(status[0][0]==0)
	Checkbox drawingstatuscheckbox1,value=(status[0][0]==1)
	Checkbox drawingstatuscheckbox2,value=(status[0][0]==2)
	rewriteCurrentStatus()
	refreshWaves("")
	IIRefreshFunc()
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Button
Function setupInfo(ctrlname):buttoncontrol
	string ctrlname
		IISetupFunc()
end

Function deletetrace(ctrlname):buttoncontrol
	string ctrlname
	wave/T wavebox=root:g_wavebox
	wave waveselect=root:g_waveboxselect
	wave/T drawinglist=root:g_panelDrawingList
	variable i=0
	for(;i<numpnts(wavebox);)
		if(waveselect[i][0][0])
			deleteATrace(getCurrentDataFolder(),wavebox[i])
			deletepoints i,1,wavebox
			deletepoints i,1,waveselect
		else
			i+=1
		endif
	endfor
		deletepoints 0,numpnts(drawinglist),drawinglist
		drawpanelgraph()
	
end

Function setupPara(ctrlname):buttoncontrol
	string ctrlname
		DSSetupFunc()
end

Function addInfoItem(ctrlname):buttoncontrol
	string ctrlname
	SetActivesubwindow constspeedAnalysis#G0
	string tempstr=CsrInfo(A,"constspeedAnalysis#G0")
	string tracename=StringByKey("TNAME",tempstr,":",";")
	if(cmpstr(tracename,"")!=0)
		variable point=str2num(StringByKey("POINT",tempstr,":",";"))
		variable traceid=str2num(getSuffix(tracename))
		wave wavey=$"root:display:"+tracename
		wave wavex=XWaveReffromtrace("constspeedAnalysis#G0",tracename)
		switch(getDrawingMode())
		case 0:
			addItembypoint(wavey,wavex,traceid,point,0)
			break
		case 1:
			autoFindMethod1(wavey,point-20,point+20,1,2)
			wave af=root:g_autoFindLoc
			addItembypoint(wavey,wavex,traceid,af[0][0],0)
			break
		endswitch
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
	updateInfoBox(0,0)
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

Function saveGraph(ctrlname):buttoncontrol
	string ctrlname
	saveGraphByName("constSpeedAnalysis#G0")
end

Function mergeData(ctrlname):buttoncontrol
	string ctrlname
	wave/T labels=root:g_itemInfoLabels
	wave/T waveBox=root:g_waveBox
	NVAR pid=root:g_peakInfoDimension
	NVAR mp=root:g_mergePara
	variable i,j,n,counter,k,rowcounter
	string tablename
	n=numpnts(waveBox)
	variable itemsum=0
	variable mergesum=0
	for(i=0;i<n;i+=1)
		wave tempwave= $getCurrentDataFolder()+"Peak_Info_"+getSuffix(waveBox[i])
		itemsum+=numpnts(tempwave)/pid
	endfor
	for(i=0;i<pid+1;i+=1)
		if(mp&(2^i))
			mergesum+=1
		endif
	endfor
	tablename="root:"+getModeName()+"_Info"
	make/O/T/N=(itemsum+1,mergesum) $tablename
	wave/T infotable=$tablename
	counter=0
	for(j=0;j<pid+1;j+=1)
		if(mp&(2^j))
			infotable[0][counter]=labels[j]
			counter+=1
		endif
	endfor
	rowcounter=1
	for(i=0;i<n;i+=1)
		wave tempwave= $getCurrentDataFolder()+"Peak_Info_"+getSuffix(waveBox[i])
		if(numpnts(tempwave)>0)
			for(k=0;k<numpnts(tempwave)/pid;k+=1)
				if(mp&1)
					infotable[rowcounter][0]=waveBox[i]
					counter=1
				else
					counter=0
				endif
				for(j=1;j<pid+1;j+=1)
					if(mp&(2^j))
						infotable[rowcounter][counter]=num2str(tempwave[k][j-1])
						counter+=1
					endif
				endfor
				rowcounter+=1
			endfor
		endif
	endfor
	edit infotable
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
		case 2:
			SetDataFolder $getCurrentDatafolder()	
			inboxlist= WaveList("Tension_*",";","");
			inboxnum = ItemsInList(inboxlist);
		break
		case 1:
			SetDataFolder $getCurrentDatafolder()
			inboxlist=Wavelist("Distance_*",";","");
			inboxnum=ItemsInlist(inboxlist);
		break
	endswitch
//	print inboxnum
	Deletepoints 0,numpnts(waveBox),waveBox
	insertpoints 0,inboxnum,waveBox
	
	Make/O/N=(inboxNum,1,2) root:g_waveBoxSelect
	wave waveBoxSelect= root:g_waveBoxSelect
	waveBoxSelect=0
	waveBoxSelect[0][0][0]=1
	Variable ii=0
	for(;ii<inboxnum;ii+=1)
		waveBox[ii]=StringFromList(ii, inboxlist, ";");
	endfor
	if(inboxnum>0)		
		Make/O/T/N=1 root:g_panelDrawingList
		wave/T drawinglist=root:g_panelDrawingList
		drawinglist[0]=waveBox[0]
	else
		cleardrawinglist()
	endif
	SetDataFolder root:
	drawPanelGraph()
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
	NewDataFolder/O root:display
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
Function updatepjonly()
	wave status=root:g_drawingStatusPara
	if(status[0][10])
		updatePanelGraph(10,status[1][10]&1,status[1][10]&2)
	endif
	if(status[0][11])
		updatePanelGraph(11,status[1][11]&1,status[1][11]&2)
	endif
	if(status[2][0]&&status[2][10])
		updatePanelGraph(10,status[3][10]&1,status[3][10]&2)
	endif
	if(status[2][0]&&status[2][11])
		updatePanelGraph(11,status[3][11]&1,status[3][11]&2)
	endif
end

Function drawPanelGraph()
	clearAll("ConstSpeedAnalysis#G0")
	wave/T drawinglist=root:g_panelDrawingList
	wave status=root:g_drawingStatusPara
	variable i,j
	NVAR spn=root:g_statusParaNum
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
	for(i=1;i<spn+1;i+=1) //use a variable to keep 12
		if(status[0][i])
			updatePanelGraph(i,status[1][i]&1,status[1][i]&2)
		endif
	endfor
	if(status[2][0]&&numpnts(drawinglist)>0)
		for(i=1;i<spn+1;i+=1)
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
	resetItemNum()
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
			clearTraces(graphName,"tension*")
			for(i=0;i<n;i+=1)
				tempstr="tension"+num2str(getDrawingMode())+"_"+num2str(i)
				myAppendToGraph(graphName,$"root:display:"+tempstr,$"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i),isleft,isbottom)
				//appendtograph/W=$graphName $"root:display:"+tempstr vs $"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i)
				modifygraph/W=$graphName rgb($tempstr)=(65535,0,0) 
				delayupdate
			endfor
			break
		case 2:
			clearTraces(graphName,"distsmth*")				
			for(i=0;i<n;i+=1)
				tempstr="tensmth"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i)
				setLowPassFilter(getIfInserted(getCurrentDataFolder()+drawinglist[i]))
				smoothTraces($"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				delayupdate
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0) 
				delayupdate
			endfor
			break
		case 3:
			clearTraces(graphName,"extensiony*")
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
			clearTraces(graphName,"extensmthy*")
			for(i=0;i<n;i+=1)
				tempstr="extensmthy"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				make/O $"root:display:extensmthx"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavex=$"root:display:extensmthx"+num2str(getDrawingMode())+"_"+num2str(i)
				wave tempwavey=$"root:display:"+tempstr
				duplicate/O $"root:display:distancesmth"+num2str(getDrawingMode())+"_"+num2str(i), tempwavex
				setLowPassFilter(getIfInserted(getCurrentDataFolder()+drawinglist[i]))
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
			clearTraces(graphName,"distance*")
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
			clearTraces(graphName,"distsmth*")
			for(i=0;i<n;i+=1)
				tempstr="distsmth"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
				setLowPassFilter(getIfInserted(getCurrentDataFolder()+drawinglist[i]))
				smoothTraces($"root:display:distance"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0) 
				delayupdate
			endfor
			break
		case 7:
			clearTraces(graphName,"tensiontime*")
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
			clearTraces(graphName,"tensiontimesmth*")
			for(i=0;i<n;i+=1)
				tempstr="tensiontimesmth"+num2str(getDrawingMode())+"_"+num2str(i)
				make/O $"root:display:"+tempstr
				wave tempwavey=$"root:display:"+tempstr
				wave tempwavex=$"root:display:time"+num2str(getDrawingMode())+"_"+num2str(i)
				setLowPassFilter(getIfInserted(getCurrentDataFolder()+drawinglist[i]))
				smoothTraces($"root:display:tension"+num2str(getDrawingMode())+"_"+num2str(i),tempwavey,1)
				myAppendToGraph(graphName,tempwavey,tempwavex,isleft,isbottom)
				//appendtograph/W=$graphName tempwavey vs tempwavex
				modifygraph/W=$graphName rgb($tempstr)=(0,0,0) 
				delayupdate
			endfor
			break
		case 9:			
			clearTraces(graphName,"WLCFIT*")
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
							make/O/N=10001 $"root:display:WLCFIT"+num2str(count)+"_"+num2str(i)
							wave tempfit=$"root:display:WLCFIT"+num2str(count)+"_"+num2str(i)
							w[0]={tempwave[j][0],tempwave[j+1][0],tempwave[j+2][0],tempwave[j+3][0]}
							variable xlimit=inv_mod_MuS(w, V_max)
							setScale/I x 0,xlimit,tempfit
							for(m=0;m<10001;m+=1)
								tempfit[m]=mod_Mus(w,m*xlimit/10000)
							endfor
							myAppendToGraph2(graphName,tempfit,isleft,isbottom)
							doupdate
							//appendtograph/W=$graphName tempwave;delayUpdate
							modifygraph/W=$graphName rgb($"WLCFIT"+num2str(count)+"_"+num2str(i))=(32768,0,65535);delayUpdate
							tag /W=$graphName /A=RT /L=1 /Z=0 /B=0 $"WLCFIT"+num2str(count)+"_"+num2str(i),100,"p="+num2str(tempfit[j])+";L="+num2str(tempfit[j+2])+";K="+num2str(tempfit[j+3])
							count+=1
						endfor
					endif
			endfor
			//tag /A=LT /L=1 /Z=0 /B=0 stiffness24,100,"haha"
			break
		case 10:
			clearTraces(graphName,"Peak*")
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
						make/O/N=2 $"root:display:Peak_"+num2str(count)+"_"+num2str(i)
						wave tempwave=$"root:display:Peak_"+num2str(count)+"_"+num2str(i)
						setScale/I x V_min,V_max,tempwave
						tempwave=tempinfo[j][0]
						myAppendToGraph2(graphName,tempwave,isleft,isbottom)
						//appendtograph/W=$graphName tempwave;delayUpdate
						modifygraph/W=$graphName lStyle($"Peak_"+num2str(count)+"_"+num2str(i))=2;delayUpdate
						if(isSelected(infoBoxSel,m,count))
							modifygraph/W=$graphName rgb($"Peak_"+num2str(count)+"_"+num2str(i))=(0,0,0);delayUpdate
							modifygraph/W=$graphName lSize($"Peak_"+num2str(count)+"_"+num2str(i))=2;delayUpdate
						else
							modifygraph/W=$graphName rgb($"Peak_"+num2str(count)+"_"+num2str(i))=(32767,32767,32767);delayUpdate
						endif
						count+=1
					endfor
				endif
			endfor
		break
		case 11:
			clearTraces(graphName,"Jump*")
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
						make/O/N=2 $"root:display:Jump_"+num2str(count)+"_"+num2str(i)
						wave tempwave=$"root:display:Jump_"+num2str(count)+"_"+num2str(i)
						setScale/I x tempinfo[j][1],(tempinfo[j][1]+0.00001),tempwave
						tempwave[0]=V_min
						tempwave[1]=V_max
						myAppendToGraph2(graphName,tempwave,isleft,isbottom)
						//appendtograph/W=$graphName tempwave;delayUpdate
						modifygraph/W=$graphName lStyle($"Jump_"+num2str(count)+"_"+num2str(i))=2;delayUpdate
						if(isSelected(infoBoxSel,m,count))
							modifygraph/W=$graphName rgb($"Jump_"+num2str(count)+"_"+num2str(i))=(0,0,0);delayUpdate
							modifygraph/W=$graphName lSize($"Jump_"+num2str(count)+"_"+num2str(i))=2;delayUpdate
						else
							modifygraph/W=$graphName rgb($"Jump_"+num2str(count)+"_"+num2str(i))=(32767,32767,32767);delayUpdate
						endif
						count+=1
					endfor
				endif
			endfor
		break
		case 12:
			clearTraces(graphName,"Separator*")
			variable leftLimit,rightLimit
			for(i=0;i<n;i+=1)
				if(exists(getCurrentDatafolder()+"Separator_"+getSuffix(drawinglist[i])))
					wave tempinfo=$getCurrentDatafolder()+"Separator_"+getSuffix(drawinglist[i])
					num=numpnts(tempinfo)/2
					if(num>=2)
						make/O/N=1001 $"root:display:Separator_"+num2str(i)
						wave tempwave=$"root:display:Separator_"+num2str(i)
						switch(getDrawingmode())
							case 0:
								if(isleft)
									GetAxis /Q/W=$graphName left
								else
									GetAxis /Q/W=$graphName right
								endif
								leftLimit=separator_y2x(tempinfo,V_min)
								rightLimit=separator_y2x(tempinfo,V_max)
								if(leftLimit>rightLimit)
									swapVariable(leftLimit,rightLimit)
								endif
								if(isbottom)
									GetAxis /Q/W=$graphName bottom
								else
									GetAxis /Q/W=$graphName top
								endif
								if(leftLimit<V_min)
									leftLimit=V_min
								endif
								if(rightLimit>V_max)
									rightLimit=V_max
								endif
							break
							case 1:
								if(isbottom)
									GetAxis /Q/W=$graphName bottom
								else
									GetAxis /Q/W=$graphName top
								endif
								leftLimit=V_min
								rightLimit=V_max
							break	
						endswitch
						setScale /I x,leftLimit,rightLimit,tempwave
						for(j=0;j<1001;j+=1)
							tempwave[j]=separator_x2y(tempinfo,leftLimit+j*(rightLimit-leftLimit)/1000)
						endfor
						myAppendToGraph2(graphName,tempwave,isleft,isbottom)
						modifygraph/W=$graphName rgb($"Separator_"+num2str(i))=(0,0,65535);delayUpdate
					endif
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
	return str
end

Function /S getSuffix(sourStr)
	string sourStr
	string temp1,temp2
	if(stringmatch(sourStr,"*_*"))
		splitstring /E="([a-zA-Z0-9_]*)_([^_]*)" sourStr,temp1,temp2
	endif
	return temp2
end

Function /S removeSuffix(sourStr)
	string sourStr
	string temp1,temp2
	if(stringmatch(sourStr,"*_*"))
		splitstring /E="([a-zA-Z0-9_]*)_([^_]*)" sourStr,temp1,temp2
	endif
	return temp1
end

Function addItembypoint(wavey,wavex,traceid,point,fromsmooth)
	wave wavey,wavex		
	variable traceid,point
	variable fromsmooth
	wave/T drawinglist=root:g_panelDrawingList
	variable jumpid=addItembypointAndName(wavey,wavex,drawinglist[traceid],point,fromsmooth)
	updateInfoBox(traceid,jumpid)
end

Function addItembypointAndName(wavey,wavex,tracename2,point,fromsmooth)
		wave wavey,wavex		
		variable point
		variable fromsmooth
		string tracename2
		variable isunfold=0
		NVAR peakInfoDimension= root:g_peakInfoDimension
		string suffixname=getSuffix(tracename2)
		wave peak_info=$getCurrentDatafolder()+"Peak_Info_"+getSuffix(tracename2)
		wave timeinfo=$getCurrentDatafolder()+"Time_"+getSuffix(tracename2)
		//Variable n=numpnts(peak_info)/peakInfoDimension
		string tracenote=note(timeinfo)
		variable timestamp=numberbykey("start_time",tracenote,"=")+timeinfo[point]
		duplicate/O wavey,root:smoothedwavey
		wave wavey_smth=root:smoothedwavey
		smoothtraces(wavey,wavey_smth,1)
		//wave tempwavey=$"root:display:"+tracename
		switch(getDrawingMode())
			case 0:
				if(stringmatch(suffixname,"Unf*"))
					isunfold=1
				endif
				variable dist_gap,gap_dev
				getProteinDistance(wavey_smth,wavex,wavey_smth[point],wavex[point],dist_gap,gap_dev)
				if(fromsmooth)
					return addItem(tracename2,wavey_smth[point],wavex[point],timestamp,isunfold,0,dist_gap,gap_dev,-1,point)
				else
					return addItem(tracename2,wavey[point],wavex[point],timestamp,isunfold,0,dist_gap,gap_dev,-1,point)
				endif
				break
			case 1:
				if(fromsmooth)
					return addItem(tracename2,wavey_smth[point],wavex[point],timestamp,(wavey[point]-wavex[point])>0,0,0,0,0,point)
				else				
					return addItem(tracename2,wavey[point],wavex[point],timestamp,(wavey[point]-wavex[point])>0,0,0,0,0,point)
				endif
				break
		endswitch
end

Function addItem(tracename,a,b,c,d,e,f,g,h,x)
	string tracename
	variable a,b,c,d,e,f,g,h,x
	variable n,i,j
	NVAR pid=root:g_peakInfoDimension
	wave peak_info=$getCurrentDataFolder()+"Peak_Info_"+getSuffix(tracename)
	n=numpnts(peak_info)/pid
	if(n==0)
		make/O/N=(1,pid) $getCurrentDatafolder()+"Peak_Info_"+getSuffix(tracename)
		wave peak_info=$getCurrentDatafolder()+"Peak_Info_"+getSuffix(tracename)
	else
		Insertpoints n,1,peak_info
		for(i=n-1;i>=0;i-=1)
			if(peak_info[i][4]>c)
				for(j=0;j<pid;j+=1)
					peak_info[i+1][j]=peak_info[i][j]
				endfor
			else
				break
			endif
		endfor
		n=i+1
	endif
	peak_info[n][0]=a//vcsr(A,"constspeedAnalysis#G0")//[point]
	peak_info[n][1]=b//hcsr(A,"constspeedAnalysis#G0")//[point]
	peak_info[n][4]=c//timeinfo[point]
	peak_info[n][2]=d//isunfold
	peak_info[n][3]=e//0//cLIncrement
	//getProteinDistance(peak_info[n][1],peak_info[n][0], distAve, distStddev)
	peak_info[n][5]=f//0//distAve
	peak_info[n][6]=g//0//distStddev
	string tracenote=note($getCurrentDatafolder()+"Time_"+getSuffix(tracename))
	if(h<0)
		
		peak_info[n][7]=numberbykey("pulling_speed",tracenote,"=")
	else
		peak_info[n][7]=h
	endif
	peak_info[n][8]=x+numberbykey("begin_at",tracenote,"=")
	return n
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

Function updateInfoBox(traceid,jumpid)
	variable traceid,jumpid
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
	for(i=0;i<traceid;i+=1)
		jumpid+=pdiin[i]
	endfor	
	m=getInfoBoxDim()
//	if(getDrawingMode()==0)
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
						if(infoShowPara[getDrawingMode()]&(2^k))
							infoBox[ibx][iby]=num2str(temppeakinfo[j][k])
							infoBoxSel[ibx][iby]=6
							iby+=1
						endif
					endfor
					ibx+=1
					//print ibx,iby
				endfor
			endif
		endfor
		infoBoxSel[jumpid][0]=infoBoxSel[0][0]|1
//	elseif(getDrawingMode()==1)
//	endif
	updatepjonly()
	doUpdate
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

Function getIfInserted(wavename)
	string wavename
	wave tempwave=$wavename
	string wavenote
	wavenote=note(tempwave)
	if(NumberByKey("isInserted",wavenote,"=")==1)
		return 1
	else
		return 0
	endif
end

Function saveGraphByName(graphName)
	string graphName
	string tracenames=tracenamelist(graphName,";",1)
	wave/T drawinglist=root:g_panelDrawingList
	wave/T waveBox= root:g_waveBox
	string item,tempname,newwavename
	variable i,n,temp
	NVAR sgc=root:g_saveGraphCounter
	n=itemsinlist(tracenames)
	display/N=$"outputgrpah"+num2str(sgc)
	NewDataFolder/O root:graph
	for(i=0;i<n;i+=1)
		item=StringFromList(i,tracenames,";")
		temp=str2num(getSuffix(item))
		tempname=drawinglist[temp]
		temp=str2num(getSuffix(tempname))
		tempname=waveBox[temp]
		newwavename="root:graph:"+item+"_"+getSuffix(tempname)+"_"+num2str(i)+"_y_"+num2str(sgc)
		duplicate /O $"root:display:"+item, $newwavename
		if(numpnts(XWaveReffromtrace("constspeedAnalysis#G0",item)))
			wave tempwave=XWaveReffromtrace("constspeedAnalysis#G0",item)
			newwavename="root:graph:"+item+"_"+getSuffix(tempname)+"_"+num2str(i)+"_x_"+num2str(sgc)
			duplicate /O tempwave,$newwavename
			appendtograph/W=$"outputgrpah"+num2str(sgc) $"root:graph:"+item+"_"+getSuffix(tempname)+"_"+num2str(i)+"_y_"+num2str(sgc) vs $"root:graph:"+item+"_"+getSuffix(tempname)+"_"+num2str(i)+"_x_"+num2str(sgc)
		else
			appendtograph/W=$"outputgrpah"+num2str(sgc) $"root:graph:"+item+"_"+getSuffix(tempname)+"_"+num2str(i)+"_y_"+num2str(sgc)
		endif
	endfor
	sgc+=1
end

Function getProteinDistance(wavey,wavex,level,xpos, distAve, distStddev)
	wave wavey
	wave wavex 
	variable level
	variable &distAve
	Variable &distStddev
	variable xpos
	make/O root:ConstSpeed:FoundLevels
	wave flvls=root:ConstSpeed:FoundLevels
	FindLevels /Q/P/D=flvls wavey, level
	variable i,j,flag,ave1,stdev1,ave2,stdev2,levelx
	for(i=0;i<numpnts(flvls);i+=1)
		j=floor(flvls[i])
		if(abs(wavex[flvls[i]]-xpos)<0.0001)
			flag=i
		endif
		flvls[i]=(j+1-flvls[i])*wavex[j]+(flvls[i]-j)*wavex[j+1]
	endfor
	levelx=flvls[flag]
	flag =0
	do
		flag = splitDistances(flvls,levelx,ave1, stdev1)
	while(flag==0)
	if(flag==-1)
		distAve=0
		distStddev=0
	else
		flag = splitDistances(flvls,levelx,ave2, stdev2)
		if(flag==-1)
			distAve=0
			distStddev=0
		else
			distAve=ave2-ave1
			distStddev=stdev2+stdev1
		endif
	endif
	killwaves/Z flvls
end

function splitDistances(dists,level,distAve, distStddev)
	wave dists
	variable level
	variable &distAve
	Variable &distStddev
	
	variable i,n
	Variable std=1
	variable flag=0
	n=numpnts(dists)
	if(n<=0)
		return -1
	elseif(n==1)		
		distAve=dists[0]
		distStddev=0
		if(abs(dists[0]-level)<0.0001)
			flag=1
		endif
		deletepoints 0,1,dists
		return flag
	else
		if(abs(dists[0]-level)<0.0001)
			flag=1
		endif
		i=1
		do
			if(abs(dists[i]-dists[i-1])<std)
				if(abs(dists[i]-level)<0.0001)
					flag=1
				endif
				i+=1
			else
				break
			endif
		while(i<n)
		wavestats/Q/R=[0,i-1] dists
		distAve=V_avg
		distStddev=V_sdev
		deletepoints 0,i,dists
		return flag
	endif
end

Function swapVariable(a,b)
	Variable &a,&b
	variable temp
	temp = a
	a = b
	b = temp
end

Function getScreenSize(left,right,top,bottom)
	variable &left,&right,&top,&bottom
	NewPanel /N=getscreensizewin
	movewindow 2,2,2,2
	getwindow getscreensizewin,wsizeDC
	left=V_left
	right=V_right
	bottom=V_bottom
	top=V_top
	movewindow 1,1,1,1
	Dowindow/K getscreensizewin
end

Function clearDrawinglist()
	make/O/T/N=0 root:g_panelDrawingList
end

Function ifExisted(name)
	string name
	Dowindow/F $name
	return V_flag
end

Function deleteATrace(folder,tracename)
	string folder
	string tracename
	killWaves/Z $folder+"Tension_"+getSuffix(tracename)
	killWaves/Z $folder+"Time_"+getSuffix(tracename)
	killWaves/Z $folder+"Distance_"+getSuffix(tracename)
	killWaves/Z $folder+"Peak_Info_"+getSuffix(tracename)
	killWaves/Z $folder+"Fit_"+getSuffix(tracename)
end







