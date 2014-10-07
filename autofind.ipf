#pragma rtGlobals=1		// Use modern global access method.
constant AFCANDIDATE=100///for method 2
////method 1 examines and keeps all the data pionts in the range of interest, though I don't thind that is necessary
////method 2 also examines all the data points but only keeps top number of AFCANDATE points, then procedure is accelerated

/////////////////////////////////////////////////////global variables
Function initAutoFindPara()
	Variable/G g_AFPnum=0
	Variable/G g_loForce=-1
	Variable/G g_hiForce=-1
	Variable/G g_fromSmoothed=0
end

/////////////////////////////////////////////////////Panel
Function buildAFPPanel()
	NVAR num=root:g_AFPnum
	NVAR lo=root:g_loForce
	NVAR hi=root:g_hiForce
	NVAR fs=root:g_fromSmoothed
	if(!ifExisted("AutoFindSetup"))
		NewPanel/W=(210,193,400,350) /N=AutoFindSetup /K=1
		setvariable AFPNumSetvar, pos={10,10},size={50,15},title="#-",limits={-inf,inf,1},value=num,win=AutoFindSetup
		setvariable AFPLoLimSetvar, pos={10,40},size={120,15},title="low-limit-",value=lo,win=AutoFindSetup
		setvariable AFPHiLimSetvar, pos={10,60},size={120,15},title="high-limit-",value=hi,win=AutoFindSetup
		CheckBox AFPFromSmooth,pos={10,80},size={120,15},title="from_smooth",value=fs,win=AutoFindSetup,proc=switchifFromSmooth
	endif
end

//////////////////////////////////////////////////////checkbox
Function switchifFromSmooth(name,value):checkboxcontrol
	string name
	variable value
	NVAR fromSmoothed=root:g_fromSmoothed
	fromSmoothed=value
end
/////////////////////////////////////////////////////button
Function invokeAFPPanel(ctrlname):buttoncontrol
	string ctrlname
	buildAFPPanel()
end

Function autoFinditem(ctrlname):buttoncontrol
	string ctrlname
	wave/T drawinglist=root:g_panelDrawingList
	variable type
	NVAR num=root:g_AFPnum
	string tracename
	variable traceid
	variable left
	variable right
	NVAR fromsmooth=root:g_fromSmoothed
	string tempstrA=CsrInfo(A,"constspeedAnalysis#G0")
	string tempnameA=StringByKey("TNAME",tempstrA,":",";")
	if(cmpstr(tempnameA,"")!=0)
		wave wavey=$"root:display:"+tempnameA
		wave wavex=XWaveReffromtrace("constspeedAnalysis#G0",tempnameA)
		traceid=str2num(getSuffix(tempnameA))
		tracename=drawinglist[traceid]
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
			traceid=0
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
			
			additembypoint(wavey,wavex,traceid,aftemp[0][0],fromsmooth)
			deletepoints 0,1,aftemp
		catch
			print "not ready yet"	
		endtry		
	else
		//print left,right
		switch(getDrawingMode())
			case 0:
				autoFindCS(wavey,wavex,traceid,left,right,num)
				if(!num)
					num-=1
				endif
			break	
			case 1:
			break
		endswitch
	endif
end

Function autoFindCS(wavey,wavex,traceid,rangeLeft,rangeRight,num)
	wave wavey,wavex
	variable traceid
	variable rangeLeft,rangeRight,num
	NVAR lo=root:g_loForce
	NVAR hi=root:g_hiForce
	NVAR fromsmooth=root:g_fromSmoothed
	variable temp
	variable type
	wave/T drawinglist=root:g_panelDrawingList
	string tracename=drawinglist[traceid]
	if(stringmatch(getSuffix(tracename),"Unf*"))
		type=1
	else
		type=0
	endif
	if(lo>0&&getDrawingMode()==0)
		temp=binsearch(wavey,lo)
		if(type && temp>rangeleft)
			rangeleft=temp
		endif
		if((!type) && temp<rangeright)
			rangeright=temp
		endif
	endif
	if(hi>0&&getDrawingMode()==0)
		temp=binsearch(wavey,hi)
		if((!type) && temp>rangeleft)
			rangeleft=temp
		endif
		if(type && temp<rangeright)
			rangeright=temp
		endif
	endif
	
	//wave aftemp=root:display:smoothedtarget
	duplicate/O wavey, root:aftemp
	wave aftemp=root:aftemp
	smoothTraces(wavey,aftemp,1)
	//smooth/B smth,aftemp
	
	variable i
	if(num>0)
		autoFindMethod2(aftemp,rangeLeft,rangeRight,num,type)
		if(fromsmooth)
			for(i=0;i<num;i+=1)
				wave af=root:g_autoFindLoc
				additembypoint(wavey,wavex,traceid,af[i][0],fromsmooth)
			endfor
		else
			duplicate/O root:g_autoFindLoc,root:g_autoFindLoc2
			wave af2=root:g_autoFindLoc2
			for(i=0;i<num;i+=1)
				autoFindMethod2(wavey,af2[i][0],af2[i][1],1,2)
				wave af=root:g_autoFindLoc
				additembypoint(wavey,wavex,traceid,af[0][0],fromsmooth)
			endfor
		endif
		killWaves/Z af2
	else
		autoFindMethod2(aftemp,rangeLeft,rangeRight,AFCANDIDATE,type)
		duplicate/O root:g_autoFindLoc,root:g_autoFindLoc2
		wave af2=root:g_autoFindLoc2
		make/O/N=(numpnts(af2)/2) root:g_autoFindLoc3
		wave af3=root:g_autoFindLoc3
		
		if(fromsmooth)
			for(i=0;i<numpnts(af3);i+=1)
				af3[i]=af2[i][0]
			endfor
		else
			
			for(i=0;i<numpnts(af3);i+=1)
				autoFindMethod2(wavey,af2[i][0],af2[i][1],1,type)
				wave af=root:g_autoFindLoc
				af3[i]=af[0][0]
			endfor
		endif
		
		wave af=root:g_autoFindLoc
		duplicate/O af3,af
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
	print "you are doing type "+num2str(type)+" auto-find-peak..."
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
			if(type==0)
				diff[i-rangeLeft]=wavey[j-1]-wavey[i]
			else
				diff[i-rangeLeft]=wavey[i]-wavey[j-1]
			endif
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

Function autoFindMethod2(wavey,rangeLeft,rangeRight,JumpNum,type)
	wave wavey
	variable rangeLeft,rangeRight,JumpNum,type
	variable i,j
	make/O/N=(JumpNum+1) root:diff
	make/O/N=(JumpNum+1) root:diff_loc
	make/O/N=(JumpNum+1) root:diff_loc_end
	wave diff=root:diff
	wave diffl=root:diff_loc
	wave diffle=root:diff_loc_end
	variable temp1,temp2,k
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
			temp1=abs(wavey[j]-wavey[i])
			temp2=j
			//diff[i-rangeLeft]=abs(wavey[j]-wavey[i])
			//diffle[i-rangeLeft]=j
		else
			if(type==1)
				temp1=wavey[i]-wavey[j-1]
			else
				temp1=wavey[j-1]-wavey[i]
			endif
			temp2=j-1
			//diff[i-rangeLeft]=abs(wavey[j-1]-wavey[i])
			//diffle[i-rangeLeft]=j-1
		endif

		for(k=jumpNum-1;k>=0;k-=1)
			if(temp1>diff[k])
				diff[k+1]=diff[k]
				diffl[k+1]=diffl[k]
				diffle[k+1]=diffle[k]
			else
				break
			endif
		endfor
		diff[k+1]=temp1
		diffle[k+1]=temp2
		diffl[k+1]=i
		
		i=j
	endfor
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
	variable rand=floor(left+(right-left)*abs(enoise(0.999)))
	swap(wavey,rand,left)
	swap(wavex,rand,left)
	swap(wavez,rand,left)
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

Function realEqual(a,b)
	variable a,b
	return (abs(a-b)<a*1e-5)
end

Function binSearch(wavey,y)
	wave wavey
	variable y
	variable i,n,temp
	n=numpnts(wavey)-1
	if(realEqual(wavey[0],y))
		return 0
	endif
	if(realEqual(wavey[n],y))
		return n
	endif
	if((wavey[0]-y)*(wavey[n]-y)>0)
		return -1
	endif
	for(i=0;i<n-1;)
		temp=floor((n+i)/2)
		if(realEqual(wavey[temp],y))
			return temp
		endif
		if((wavey[i]-y)*(wavey[temp]-y)<0)
			n=temp
		else
			i=temp
		endif
	endfor
	return i
end