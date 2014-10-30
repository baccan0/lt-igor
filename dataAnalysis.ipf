#pragma rtGlobals=1		// Use modern global access method.

Function initDataAnal()
end

Function buildDataAnal()
	if(ifExisted("DataAnal"))
		Dowindow/K "DataAnal"
	endif
	newDataFolder/O root:results
	Switch(getDrawingMode())
		case 0:
			Make/O/N=12 root:results:pullingspeeds={2,5,10,20,50,100,200,0,0,0,0,0}
			Make/O/T/N=12 root:results:pullingspeedsinbox
			Make/O/N=12 root:results:pullingspeedsselect
			num2str_wave(root:results:pullingspeeds,root:results:pullingspeedsinbox,12)
			wave psinbox=root:results:pullingspeedsinbox
			wave psselect=root:results:pullingspeedsselect
			psselect=2
			NewPanel /W=(100,100,400,300)/N=DataAnal,win=DataAnal
			ListBox pullingspeedAnalysisBox,pos={20,10},size={260,200},listWave=psinbox,selWave=psselect,win=DataAnal 
			Button pullingspeedAnalysisButton,pos={15,250},size={80,20},title="Go"
		break
		case 1:
		break
	endswitch
end

Function startPullingSpeedAnalysis(ctrlname):buttoncontrol
	string ctrlname
	wave ps=root:results:pullingspeeds
	try
		NVAR pid=root:g_peakInfoDimension
		"root:"+q	+"_Info"
	variable i
	for(i=0;i<numpnts(ps);i+=1)
		if(ps[i]>0)
			make/O/N=0 $"root:results:forcesAt_"+num2str(ps[i])
		endif
	endfor
	
end

Function psAnalysisBoxController(s):listboxcontrol
	STRUCT WMListboxAction &s
	switch(s.eventcode)
		case 7:
			str2num_wave(root:results:pullingspeedsinbox,root:results:pullingspeeds,12)
		break
	end
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