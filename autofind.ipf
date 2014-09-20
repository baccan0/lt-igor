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

/////////////////////////////////////////////////////button
Function autoFinditem(ctrlname):buttoncontrol
	string ctrlname
	wave/T drawinglist=root:g_panelDrawingList
	variable type
	NVAR num=root:g_AFPnum
	string tracename
	variable left
	variable right
	string tempstrA=CsrInfo(A,"constspeedAnalysis#G0")
		string tempnameA=StringByKey("TNAME",tempstrA,":",";")
		if(cmpstr(tempnameA,"")!=0)
			wave wavey=$"root:display:"+tempnameA
			wave wavex=XWaveReffromtrace("constspeedAnalysis#G0",tempnameA)
			tracename=drawinglist[str2num(getSuffix(tempnameA))]
			string tempstrB=CsrInfo(B,"constspeedAnalysis#G0")
			string tempnameB=StringByKey("TNAME",tempstrB,":",";")
			if(cmpstr(tempnameA,tempnameB)==0)
				left=str2num(StringByKey("POINT",tempstrA,":",";"))
				right=str2num(StringByKey("POINT",tempstrB,":",";"))
				if(left>right)
					left=left+right
					right=left-right
					left=left-right
				endif
			else
				left=0
				right=numpnts(wavey)
			endif
		else
			if(numpnts(drawinglist)>0)
				tracename=drawinglist[0]
				switch(getDrawingMode())
					case 0:
						wave wavey=$"root:constSpeed:"+tracename
						wave wavex=$"root:constSpeed:distance_"+getsuffix(tracename)
						break
					case 1:
						wave wavey=$"root:constForce:"+tracename
						wave wavex=$"root:constForce:time_"+getsuffix(tracename)
						break		
				endswitch
				left=0
				right=numpnts(wavey)			
			endif
		endif	
		
		
	if(num<0)
		try
			wave aftemp=root:g_autoFindLoc
			additembypoint(wavey,wavex,tracename,aftemp[0][0])
			deletepoints 0,1,aftemp
		catch
			print "not ready yet"	
		endtry		
	else
		switch(getDrawingMode())
			case 0:
				autoFindCS(wavey,wavex,tracename,left,right,num)
				if(!num)
					num-=1
				endif
			break	
			case 1:
			break
		endswitch
	endif
end

Function autoFindCS(wavey,wavex,tracename,rangeLeft,rangeRight,num)
	wave wavey,wavex
	string tracename
	variable rangeLeft,rangeRight,num
	variable smth=11
	variable type
	if(stringmatch(getSuffix(tracename),"Unf*"))
		type=1
	else
		type=0
	endif
	duplicate/O wavey, root:aftemp
	wave aftemp=root:aftemp
	smooth/B smth,aftemp
	variable i
	if(num>0)
		autoFindMethod1(aftemp,rangeLeft,rangeRight,num,type)
		duplicate/O root:g_autoFindLoc,root:g_autoFindLoc2
		wave af2=root:g_autoFindLoc2
		for(i=0;i<num;i+=1)
			autoFindMethod1(wavey,af2[i][0],af2[i][1],1,2)
			wave af=root:g_autoFindLoc
			additembypoint(wavey,wavex,tracename,af[0][0])
		endfor
		killWaves/Z af2
	else
		autoFindMethod1(aftemp,rangeLeft,rangeRight,rangeRight-rangeLeft-1,type)
		duplicate/O root:g_autoFindLoc,root:g_autoFindLoc2
		wave af2=root:g_autoFindLoc2
		make/O/N=(numpnts(af2)/2) root:g_autoFindLoc3
		wave af3=root:g_autoFindLoc3
		for(i=0;i<numpnts(af3);i+=1)
			autoFindMethod1(wavey,af2[i][0],af2[i][1],1,2)
			wave af=root:g_autoFindLoc
			af3[i]=af[0][0]
		endfor
		wave af=root:g_autoFindLoc
		duplicate af3,af
		killwaves/Z af2,af3
	endif
	killwaves/Z aftemp
end


Function autoFindMethod1(wavey,rangeLeft,rangeRight,JumpNum,type)
	wave wavey
	variable rangeLeft,rangeRight,JumpNum,type
	variable i,j
	make/O/N=(rangeRight-rangeLeft) root:diff
	make/O/N=(rangeRight-rangeLeft) root:diff_loc
	make/O/N=(rangeRight-rangeLeft) root:diff_loc_end
	wave diff=root:diff
	wave diffl=root:diff_loc
	wave diffle=root:diff_loc_end
	for(i=rangeLeft;i<rangeRight;)
		j=i
		do
			j+=1
			if(type==2)
				if((wavey[j]-wavey[j-1])*(wavey[j+1]-wavey[j])<0)
					break
				endif
			elseif(type==1)//unfold
				if(wavey[j]-wavey[j-1]>0)
					break
				endif
			elseif(type==0)//refold
				if(wavey[j]-wavey[j-1]<0)
					break
				endif
			endif
		while(j<numpnts(wavey))
		if(type==2)
			diff[i-rangeLeft]=abs(wavey[j]-wavey[i])
			diffle[i-rangeLeft]=j
		else
			diff[i-rangeLeft]=abs(wavey[j-1]-wavey[i])
			diffle[i-rangeLeft]=j-1
		endif
		diffl[i-rangeLeft]=i
		
		i=j
	endfor
	quicksort(diff,diffl,diffle,0,numpnts(diff))
	make/O/N=(JumpNum,2) root:g_autoFindLoc
	wave afl=root:g_autoFindLoc
	for(i=0;i<JumpNum;i+=1)
		afl[i][0]=diffl[i]
		afl[i][1]=diffle[i]
	endfor
	killwaves/Z diff,diffl,diffle
end

Function quickSort(wavey,wavex,wavez,left,right)
	wave wavey,wavex,wavez
	variable left,right
	variable i,j
	if(left<right)
		j=left+1
		for(i=left+1;i<right;i+=1)
			if(wavey[i]>wavey[left])
				swap(wavey,j,i)
				swap(wavex,j,i)
				swap(wavez,j,i)
				j+=1
			endif
		endfor
		swap(wavey,j-1,left)
		swap(wavex,j-1,left)
		swap(wavez,j-1,left)
		quickSort(wavey,wavex,wavez,left,j-1)
		quickSort(wavey,wavex,wavez,j,right)
	endif
	
end

Function swap(wavey,i,j)
	wave wavey
	variable i,j
	variable temp
	temp=wavey[i]
	wavey[i]=wavey[j]
	wavey[j]=temp
end

Function resetItemNum()
	NVAR num=root:g_AFPnum
	if(num<0)
		num=0
		try
			wave aftemp=root:g_autoFindLoc
			killwaves/Z aftemp
		catch
		endtry
	endif
end