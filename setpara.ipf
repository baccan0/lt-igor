#pragma rtGlobals=1		// Use modern global access method.

/////////////////////////////////////////////////////////////////////init
Function initPanelDispPara()
	NVAR pid=root:g_peakInfoDimension
	Variable/G g_statusParaNum= 11
	Make/O g_drawingStatusPara={{0,1,0,0,0,0,0,0,0,0,0,0},{0,3,3,3,3,3,3,3,3,3,3,3},{0,0,0,1,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}
	MatrixTranspose g_drawingStatusPara
	make/O/T g_drawingStatusParaNames={"tens_vs_dist","tens_vs_dist_smth","tens_vs_exte","tens_vs_exte_smth","dist_vs_time","dist_vs_time_smth","tens_vs_time","tens_vs_time_smth","mWLCFit","ItemY","ItemX"}
	make/O/N=2 g_infoShowPara={7,7,7}
	Make/O/T g_itemInfoLabels={"tracename","Y","X","is_unfold","cL","time_stamp","dist_gap","dist_gap_stdev"}
	Variable/G g_mergePara=2^(pid+2)-1
end

////////////////////////////////////////////////////////////////////panels
Window DrawingStatusSetup():Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(210,193,560,750)
	DSSetupFunc()
	drawtext,20,540,"Be careful not to have conflicts!"
EndMacro

Window InfoItemSetup():Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(210,193,1030,350)
	drawtext 5,30,"Items in infobox"
	drawtext 5,90,"Items to be merged"
	IISetupFunc()
EndMacro

////////////////////////////////////////////////////////////////////////build_func
Function IISetupFunc()
	NVAR pid=root:g_peakInfoDimension
	wave/T iiLabels=root:g_itemInfoLabels
	wave status=g_drawingStatusPara
	wave isp=g_infoShowPara
	NVAR mp=root:g_mergePara
	variable i
	
	for(i=0;i<pid;i+=1)
		CheckBox $"IISChkBox_"+num2str(i),pos={5+100*i,40},size={65,15},title=iiLabels[i+1],value=isp[status[0][0]]&(2^i), win=InfoItemSetup,proc=setInfoItem
	endfor
	for(i=0;i<pid+1;i+=1)
		CheckBox $"IISMergeChkBox_"+num2str(i),pos={5+100*i,110},size={65,15},title=iiLabels[i],value=mp&(2^i), win=InfoItemSetup,proc=setInfoItemMerge
	endfor
	updateInfoBox()
end

Function DSSetupFunc()
	variable i
	NVAR spn=root:g_statusParaNum
	wave/T dspn=root:g_drawingStatusParaNames
	wave status=g_drawingStatusPara
	for(i=0;i<spn;i+=1)
		CheckBox $"DSSChkBox_"+num2str(i+1),pos={5,20+20*i},size={65,15},title=dspn[i],value=status[0][i+1], win=DrawingStatusSetup,proc=setDrawingGraph
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4),pos={150,20+20*i},size={50,15},title="left",value=status[1][i+1]&1,win=DrawingStatusSetup,proc=setDrawingGraphLoc
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4+1),pos={200,20+20*i},size={50,15},title="right",value=!(status[1][i+1]&1),win=DrawingStatusSetup,proc=setDrawingGraphLoc
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4+2),pos={250,20+20*i},size={50,15},title="bottom",value=status[1][i+1]&2,win=DrawingStatusSetup,proc=setDrawingGraphLoc
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4+3),pos={300,20+20*i},size={50,15},title="top",value=!(status[1][i+1]&2),win=DrawingStatusSetup,proc=setDrawingGraphLoc
	endfor
	CheckBox $"DSSChkBox_"+num2str(2^8),pos={5,260},size={65,15},title="BotView",value=status[2][1],win=DrawingStatusSetup,proc=setBotView
	for(i=0;i<spn;i+=1)
		CheckBox $"DSSChkBox_"+num2str(2^8+i+1),pos={5,280+20*i},size={65,15},title=dspn[i],value=status[2][i+1], win=DrawingStatusSetup,proc=setDrawingGraph
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4),pos={150,280+20*i},size={50,15},title="left",value=status[3][i+1]&1,win=DrawingStatusSetup,proc=setDrawingGraphLoc
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4+1),pos={200,280+20*i},size={50,15},title="right",value=!(status[3][i+1]&1),win=DrawingStatusSetup,proc=setDrawingGraphLoc
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4+2),pos={250,280+20*i},size={50,15},title="bottom",value=status[3][i+1]&2,win=DrawingStatusSetup,proc=setDrawingGraphLoc
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4+3),pos={300,280+20*i},size={50,15},title="top",value=!(status[3][i+1]&2),win=DrawingStatusSetup,proc=setDrawingGraphLoc
	endfor
end

/////////////////////////////////////////////////////////////refresh_func

Function IIRefreshFunc()
	NVAR pid=root:g_peakInfoDimension
	wave status=g_drawingStatusPara
	wave isp=g_infoShowPara
	variable i
	
	for(i=0;i<pid;i+=1)
		CheckBox $"IISChkBox_"+num2str(i),value=isp[status[0][0]]&(2^i), win=InfoItemSetup
	endfor
	updateInfoBox()
end

Function IIRefreshMergeFunc()
	NVAR pid=root:g_peakInfoDimension
	NVAR mp=root:g_mergePara
	variable i
	for(i=0;i<pid+1;i+=1)
		CheckBox $"IISMergeChkBox_"+num2str(i),value=mp&(2^i), win=InfoItemSetup
	endfor
end

Function DSRefreshFunc()
	variable i
	NVAR spn=root:g_statusParaNum
	wave status=g_drawingStatusPara
	for(i=0;i<spn;i+=1)
		CheckBox $"DSSChkBox_"+num2str(i+1),value=status[0][i+1], win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4),value=status[1][i+1]&1,win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4+1),value=!(status[1][i+1]&1),win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4+2),value=status[1][i+1]&2,win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str((i+1)*4+3),value=!(status[1][i+1]&2),win=DrawingStatusSetup
	endfor
	CheckBox $"DSSChkBox_"+num2str(2^8),value=status[2][1],win=DrawingStatusSetup
	for(i=0;i<spn;i+=1)
		CheckBox $"DSSChkBox_"+num2str(2^8+i+1),value=status[2][i+1], win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4),value=status[3][i+1]&1,win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4+1),value=!(status[3][i+1]&1),win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4+2),value=status[3][i+1]&2,win=DrawingStatusSetup
		checkBox $"DSSChkBoxLoc_"+num2str(2^8+(i+1)*4+3),value=!(status[3][i+1]&2),win=DrawingStatusSetup
	endfor
end

/////////////////////////////////////////////////////////////////////////checkbox

Function setBotView(name,value):checkBoxcontrol
	string name
	variable value
	wave status=g_drawingStatusPara
	status[2][0]=value
	drawPanelGraph()
end

Function setDrawingGraph(name,value):checkBoxcontrol
	string name
	variable value
	variable chkboxlabel=str2num(getSuffix(name))
	wave status=g_drawingStatusPara
	if(chkboxlabel&(2^8))
		status[2][chkboxlabel-2^8]=value
	else
		status[0][chkboxlabel]=value
	endif
	drawPanelGraph()
end

Function setDrawingGraphLoc(name,value):checkBoxcontrol
	string name
	variable value
	variable chkboxlabel=str2num(getSuffix(name))
	variable isbot,loc,index,temp
	isbot=1
	wave status=g_drawingStatusPara
	temp=chkboxlabel
	if(temp&(2^8))
		isbot=3
		temp-=2^8
	endif
	loc=temp&3
	index=(temp-loc)/4
	switch(loc)
		case 0:
			checkbox $name, value=1
			checkbox $"DSSChkBoxLoc_"+num2str(chkboxlabel+1),value=0
			status[isbot][index]=status[isbot][index]|1
		break
		case 1:
			checkbox $name, value=1
			checkbox $"DSSChkBoxLoc_"+num2str(chkboxlabel-1),value=0
			status[isbot][index]=status[isbot][index]&2
		break
		case 2:
			checkbox $name, value=1
			checkbox $"DSSChkBoxLoc_"+num2str(chkboxlabel+1),value=0
			status[isbot][index]=status[isbot][index]|2
		break
		case 3:
			checkbox $name, value=1
			checkbox $"DSSChkBoxLoc_"+num2str(chkboxlabel-1),value=0
			status[isbot][index]=status[isbot][index]&1
		break
	endswitch
	drawPanelGraph()	
end

Function setInfoItem(name,value):checkboxcontrol
	string name
	variable value
	wave status=g_drawingStatusPara
	wave isp=g_infoShowPara
	NVAR pid=root:g_peakInfoDimension
	variable index=str2num(getSuffix(name))
	if(value)
		isp[status[0][0]]=isp[status[0][0]]|(2^index)
	else
		isp[status[0][0]]=isp[status[0][0]]&(2^(pid+1)-1-2^index)
	endif
	updateInfoBox()
end

Function setInfoItemMerge(name,value):checkboxcontrol
	string name
	variable value
	NVAR mp=root:g_mergePara
	NVAR pid=root:g_peakInfoDimension
	variable index=str2num(getSuffix(name))
	if(value)
		mp=mp|(2^index)
	else
		mp=mp&(2^(pid+2)-1-2^index)
	endif
end