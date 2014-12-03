#pragma rtGlobals=1		// Use modern global access method.

Function initDataAnal()
	Make/O/N=12 root:results:pullingspeeds={2,5,10,20,50,100,200,0,0,0,0,0}
	Make/O/T/N=12 root:results:pullingspeedsinbox
	Make/O/N=12 root:results:pullingspeedsselect
end

Function buildDataAnal()
	if(ifExisted("DataAnal"))
		Dowindow/K DataAnal
	endif
	newDataFolder/O root:results
	Switch(getDrawingMode())
		case 0:
			num2str_wave(root:results:pullingspeeds,root:results:pullingspeedsinbox,12)
			wave psinbox=root:results:pullingspeedsinbox
			wave psselect=root:results:pullingspeedsselect
			psselect=6
			NewPanel /W=(100,100,285,350)/N=DataAnal
			ListBox pullingspeedAnalysisBox,pos={20,10},size={80,200},listWave=psinbox,selWave=psselect,win=DataAnal,proc=psAnalysisBoxController
			Button pullingspeedAnalysisButton,pos={122,194},size={50,20},title="Go",proc= startPullingSpeedAnalysis
		break
		case 1:
		break
	endswitch
end

Function startPullingSpeedAnalysis(ctrlname):buttoncontrol
	string ctrlname
	wave ps=root:results:pullingspeeds
	NVAR pid=root:g_peakInfoDimension
	string tracestoread
	variable num,i,j,n,k
	try
		NVAR pid=root:g_peakInfoDimension
	catch
	endtry
	for(i=0;i<numpnts(ps);i+=1)
		if(ps[i]>0)
			make/O/N=0 $"root:results:UnfforcesAt_"+num2str(ps[i])
			make/O/N=0 $"root:results:RefforcesAt_"+num2str(ps[i])
		endif
	endfor
	setdatafolder root:constSpeed:
	tracestoread=wavelist("Peak_Info_*",";","")
	num=ItemsInlist(tracestoread)
	setdatafolder root:
	for(i=0;i<num;i+=1)
		wave temppeakinfo=$"root:constSpeed:"+StringFromList(i, tracestoread, ";")
		if(numpnts(temppeakinfo)>0)
			for(j=0;j<numpnts(ps);j+=1)
				if(temppeakinfo[0][7]>0.8*ps[j]&&temppeakinfo[0][7]<1.0*ps[j])
					break
				endif
			endfor
			if(j<numpnts(ps))			
				for(k=0;k<numpnts(temppeakinfo)/pid;k+=1)
					//print StringFromList(i, tracestoread, ";")
					if(temppeakinfo[k][2])
						wave targetplace=$"root:results:UnfforcesAt_"+num2str(ps[j])
					else
						wave targetplace=$"root:results:RefforcesAt_"+num2str(ps[j])
					endif
					insertpoints numpnts(targetplace),1,targetplace
					targetplace[numpnts(targetplace)-1]=temppeakinfo[k][0]
				endfor
			endif
		endif
	endfor
	for(i=0;i<numpnts(ps);i+=1)
		if(ps[i]>0)
			if(numpnts($"root:results:UnfforcesAt_"+num2str(ps[i]))>0)
				wave targetplace=$"root:results:UnfforcesAt_"+num2str(ps[i])
				Make/N=50/O $"root:results:Hist_UnfforcesAt_"+num2str(ps[i]);DelayUpdate
				Histogram/B={0,1,50} targetplace,$"root:results:Hist_UnfforcesAt_"+num2str(ps[i])
				display/K=1/N=$"UnfoldingForceAt"+num2str(ps[i]) $"root:results:Hist_UnfforcesAt_"+num2str(ps[i])
			endif
			if(numpnts($"root:results:RefforcesAt_"+num2str(ps[i]))>0)
				wave targetplace=$"root:results:RefforcesAt_"+num2str(ps[i])
				Make/N=50/O $"root:results:Hist_RefforcesAt_"+num2str(ps[i]);DelayUpdate
				Histogram/B={0,1,50} targetplace,$"root:results:Hist_RefforcesAt_"+num2str(ps[i])
				display/K=1/N=$"RefoldingForceAt"+num2str(ps[i]) $"root:results:Hist_RefforcesAt_"+num2str(ps[i])
			endif
			
		endif
	endfor
end

Function psAnalysisBoxController(s):listboxcontrol
	STRUCT WMListboxAction &s
	switch(s.eventcode)
		case 7:
			str2num_wave(root:results:pullingspeedsinbox,root:results:pullingspeeds,12)
		break
	endswitch
end

Function num2str_wave(sourwave,destwave,num)
	wave sourwave
	wave/T destwave
	variable num
	variable i
	for(i=0;i<num;i+=1)
		destwave[i]=num2str(sourwave[i])
	endfor
end

Function str2num_wave(sourwave,destwave,num)
	wave/T sourwave
	wave destwave
	variable num
	variable i
	for(i=0;i<num;i+=1)
		destwave[i]=str2num(sourwave[i])
	endfor
end