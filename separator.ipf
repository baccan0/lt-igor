#pragma rtGlobals=1		// Use modern global access method.

Function initSeparator()
	variable/G root:g_separatorFlag=0
end

Function analyseSeparatorPanel()
	setDataFolder $getCurrentDataFolder()
	string tracenames=wavelist("Separa*",";","")
	string tracename
	variable i,n
	string tracenote
	n=itemsinlist(tracenames,";")
	setDataFolder root:
	NewDataFolder/O root:results
	switch(getDrawingMode())
		case 0:
			make/O/T/N=0 root:results:validSeparator
			wave/T vs=root:results:validSeparator
			for(i=0;i<n;i+=1)
				tracename=StringFromList(i,tracenames)
				wave tempwave=$getCurrentDataFolder()+tracename
				if(numpnts(tempwave)/2>2)
					tracenote=note($getCurrentDataFolder()+"Tension_"+getSuffix(tracename))
					insertpoints numpnts(vs),1,vs
					vs[numpnts(vs)-1]=StringFromList(i,tracenames)+"_"+stringbykey("pulling_speed",tracenote,"=")
				endif
			endfor
			n=numpnts(vs)
			make/O/N=(n) root:results:vsSelect
			wave vssele=root:results:vsSelect
			vssele=48
			if(ifExisted("analyzeSeparator"))
				Dowindow/K analyzeSeparator
				delayupdate
			endif
			make/O root:results:oberPara={5,15,5}
			wave oberpara=root:results:oberPara
			NewPanel /W=(210,193,500,500) /N=analyzeSeparator /FLT /K=1
			listbox separatorbox,pos={20,10},size={260,200},listWave=vs,selWave=vssele
			Button findPeakBySeparator,pos={15,250},size={80,20},title="findpeaks",proc=startFindPeakBySeparator
			Button analyzeOberbarnscheidt,pos={100,250},size={100,20},title="Oberbarnscheidt",proc= startAlloberAnalysis
			setvariable OberbarnscheidtPara_0,pos={15,220},size={80,20},title="lo_force",value=oberpara[0]
			setvariable OberbarnscheidtPara_1,pos={100,220},size={80,20},title="hi_force",value=oberpara[1]
			setvariable OberbarnscheidtPara_2,pos={185,220},size={80,20},title="num_bin",value=oberpara[2]
			//Button 
		break
		case 1:
		break
	endswitch
end

//Function autoFindPeakBySeparator(wavey,wavex,separator)
//	wave wavey,wavex,separator
//end

Function invokeanalyseSeparatorPanel(ctrlname):buttoncontrol
	string ctrlname
	analyseSeparatorPanel()
end

Function invokedrawseparator(ctrlname):buttoncontrol
	string ctrlname
	drawSeparator()
end

Function invokenewseparator(ctrlname):buttoncontrol
	string ctrlname
	newSeparator()
end

Function startFindPeakBySeparator(ctrlname):buttoncontrol
	string ctrlname
	wave/T vs=root:results:validSeparator
	wave selected=root:results:vsSelect
	variable i,j,k
	string destwavename
	variable oldstate,state
	for(i=0;i<numpnts(selected);i+=1)
		if(selected[i]&16)
			destwavename=getsuffix(removesuffix(vs[i]))
			make/O root:results:tempdistance
			smoothTraces($"root:constSpeed:Distance_"+destwavename, root:results:tempdistance,0)
			make/O root:results:tempTension
			smoothTraces($"root:constSpeed:Tension_"+destwavename, root:results:tempTension,1)
			duplicate/O $"root:constSpeed:Separator_"+destwavename,root:results:tempSeparator
			wave distwave=root:results:tempdistance
			wave tenswave=root:results:tempTension
			wave sepawave=root:results:tempSeparator
			if(numpnts(sepawave)/2>1)
				make/O/N=0 $"root:constSpeed:Peak_Info_"+destwavename
				oldstate=(distwave[0]<separator_y2x(sepawave,tenswave[0]))
				for(j=1;j<numpnts(distwave);j+=1)
					state=(distwave[j]<separator_y2x(sepawave,tenswave[j]))
					if(stringmatch(destwavename,"Unf*"))
						if(oldstate==1 &&state==0)
							for(k=j-1;k>=0;k-=1)
								if(tenswave[k]<tenswave[k+1])
									break
								endif
							endfor						
							addItembypointAndName($"root:constSpeed:Tension_"+destwavename,distwave,removeSuffix(vs[i]),k+1,1)
						endif
					else
						if(oldstate==0 && state==1)
							for(k=j-1;k>=0;k-=1)
								if(tenswave[k]>tenswave[k+1])
									break
								endif
							endfor
						
							addItembypointAndName($"root:constSpeed:Tension_"+destwavename,distwave,removeSuffix(vs[i]),k+1,1)
						endif
					endif
					oldstate=state
				endfor		
			endif
		endif
	endfor
end

Function startAlloberAnalysis(ctrlname):buttoncontrol
	string ctrlname
	wave/T vs=root:results:validSeparator
	wave oberpara=root:results:oberPara
	wave selected=root:results:vsSelect
	string destwavename
	make/O/T/N=(oberpara[2]) root:results:unfoldingTraces
	make/O/T/N=(oberpara[2]) root:results:refoldingTraces
	wave/T untrace=root:results:unfoldingTraces
	wave/T retrace=root:results:refoldingTraces
	variable i,j,usedtime,events
	if(oberpara[0]>=oberpara[1])
		return 0
	endif
	for(i=0;i<oberpara[2];i+=1)
		destwavename="root:results:oberAnalysis_unf_"+num2str(i)
		make/O/N=(1,3) $destwavename
		wave tempwave=$destwavename
		tempwave[i][0]=i*(oberpara[1]-oberpara[0])/oberpara[2]+oberpara[0]
		tempwave[i][1]=(i+1)*(oberpara[1]-oberpara[0])/oberpara[2]+oberpara[0]
		untrace[i]=destwavename
		destwavename="root:results:oberAnalysis_ref_"+num2str(i)
		make/O/N=(1,3) $destwavename
		wave tempwave=$destwavename
		tempwave[i][0]=(i+1)*(oberpara[1]-oberpara[0])/oberpara[2]+oberpara[0]
		tempwave[i][1]=i*(oberpara[1]-oberpara[0])/oberpara[2]+oberpara[0]
		retrace[i]=destwavename
	endfor
	for(i=0;i<numpnts(selected);i+=1)
		if(selected[i]&16)
			destwavename=getsuffix(removesuffix(vs[i]))
			make/O root:results:tempdistance
			smoothTraces($"root:constSpeed:Distance_"+destwavename, root:results:tempdistance,0)
			make/O root:results:tempTension
			smoothTraces($"root:constSpeed:Tension_"+destwavename, root:results:tempTension,1)
			duplicate/O $"root:constSpeed:Time_"+destwavename,root:results:tempTime
			duplicate/O $"root:constSpeed:Separator_"+destwavename,root:results:tempSeparator
			if(stringmatch(destwavename,"Unf*"))
				oberAnalysis(root:results:tempTension,root:results:tempdistance,root:results:tempTime,root:results:tempSeparator,untrace)
			else
				oberAnalysis(root:results:tempTension,root:results:tempdistance,root:results:tempTime,root:results:tempSeparator,retrace)
			endif
		endif
	endfor
	make/O/N=(oberpara[2],10) root:results:oberResults//0,1:force range,2:time,3:event#,4,5 refoldingevent,
	wave oberrslt=root:results:oberResults
	for(i=0;i<oberpara[2];i+=1)
		wave tempwave=$"root:results:oberAnalysis_unf_"+num2str(i)
		oberrslt[i][0]=tempwave[0][0]
		oberrslt[i][1]=tempwave[0][1]
		for(j=2;j<10;j+=1)
			oberrslt[i][j]=0
		endfor
		for(j=1;j<numpnts(tempwave)/3;j+=1)
			if(tempwave[j][2])
				oberrslt[i][2]+=tempwave[j][0]
				oberrslt[i][3]+=tempwave[j][1]
			else
				oberrslt[i][6]+=tempwave[j][0]
				oberrslt[i][7]+=tempwave[j][1]
			endif
		endfor
		wave tempwave=$"root:results:oberAnalysis_ref_"+num2str(i)
		usedtime=0
		events=0
		for(j=1;j<numpnts(tempwave)/3;j+=1)
			if(!tempwave[j][2])
				oberrslt[i][4]+=tempwave[j][0]
				oberrslt[i][5]+=tempwave[j][1]
			else
				oberrslt[i][8]+=tempwave[j][0]
				oberrslt[i][9]+=tempwave[j][1]
			endif
		endfor
		
	endfor
	make/O/N=(oberpara[2]) root:results:DataView_force
	make/O/N=(oberpara[2]) root:results:DataView_unf
	make/O/N=(oberpara[2]) root:results:DataView_unf_err
	make/O/N=(oberpara[2]) root:results:DataView_ref
	make/O/N=(oberpara[2]) root:results:DataView_ref_err
	wave dv_unf= root:results:DataView_unf
	wave dv_force=root:results:DataView_force
	wave dv_unf_err= root:results:DataView_unf_err
	wave dv_ref=root:results:DataView_ref
	wave dv_ref_err=root:results:DataView_ref_err
	for(i=0;i<oberpara[2];i+=1)
		dv_force[i]=(oberrslt[i][0]+oberrslt[i][1])/2
		dv_unf[i]=oberrslt[i][3]/oberrslt[i][2]
		dv_unf_err[i]=dv_unf[i]/(oberrslt[i][3]^0.5)
		dv_ref[i]=oberrslt[i][5]/oberrslt[i][4]
		dv_ref_err[i]=dv_ref[i]/(oberrslt[i][5]^0.5)
	endfor
	Display/K=1 dv_unf vs dv_force
       ModifyGraph log(left)=1
       ModifyGraph mode=3,marker=19;DelayUpdate
       ErrorBars DataView_unf Y,wave=(dv_unf_err,dv_unf_err)
       Display/K=1 dv_ref vs dv_force
       ModifyGraph log(left)=1
       ModifyGraph mode=3,marker=19;DelayUpdate
       ErrorBars DataView_ref Y,wave=(dv_ref_err,dv_ref_err)
end

Function oberAnalysis(wavey,wavex,wavetime,separator,destwaves)
	wave wavey,wavex,separator,wavetime
	wave/T destwaves
	variable i,j
	variable left,right
	variable state,tempstate,startat,temp
	for(i=0;i<numpnts(destwaves);i+=1)
		wave tempwave=$destwaves[i]
		Findlevel /P/Q wavey, tempwave[0][0]
		if(!V_Flag)
			left=floor(V_levelX)
			for(;!V_flag;)
				right=ceil(V_levelX)
				findlevel /P/Q/R=[right+1] wavey,tempwave[0][1]
				//print V_levelX
			endfor
			if(left<right)
				j=left
				do
					state=(wavex[j]<separator_y2x(separator,wavey[j]))
					startat=j
					for(j+=1;j<right;j+=1)
						tempstate=(wavex[j]<separator_y2x(separator,wavey[j]))
						if(state!=tempstate)
							break
						endif
					endfor
					temp=numpnts(tempwave)/3
					insertpoints temp,1,tempwave
					tempwave[temp][0]=wavetime[j-1]-wavetime[startat]
					tempwave[temp][1]=(j<right)
					tempwave[temp][2]=state
				while(j<right)
			endif
		else
			continue
		endif
	endfor
	
end

Function drawSeparator()
	NVAR sflag=root:g_separatorFlag
	sflag=!sflag
end

Function addPoint2Separator(x,y)
	variable x,y
	wave/T dl=root:g_paneldrawinglist
	variable num=0
	variable i
	if(exists(getCurrentDatafolder()+"Separator_"+getSuffix(dl[0])))
		wave tempwave=$getCurrentDatafolder()+"Separator_"+getSuffix(dl[0])
		num=numpnts(tempwave)/2
	endif

	if(num<=0)
		make/O/N=(1,2) $getCurrentDatafolder()+"Separator_"+getSuffix(dl[0])
		wave tempwave=$getCurrentDatafolder()+"Separator_"+getSuffix(dl[0])
		tempwave[0][0]=x
		tempwave[0][1]=y
	else
		insertpoints num,1,tempwave
		for(i=num-1;i>=0 && tempwave[i][1]>y;i-=1)
			tempwave[i+1][1]=tempwave[i][1]
			tempwave[i+1][0]=tempwave[i][0]
		endfor
		tempwave[i+1][0]=x
		tempwave[i+1][1]=y
	endif
	chkSeparator(tempwave)
	updateSprtOnly()
end

Function newSeparator()
	wave/T dl=root:g_paneldrawinglist
	make/O/N=0 $getCurrentDatafolder()+"Separator_"+getSuffix(dl[0])
	updateSprtOnly()
end

Function updateSprtOnly()
	wave status=root:g_drawingStatusPara
	if(status[0][12])
		updatePanelGraph(12,status[1][12]&1,status[1][12]&2)
	endif
	if(status[2][0]&&status[2][12])
		updatePanelGraph(12,status[3][12]&1,status[3][12]&2)
	endif
end

Function separator_y2x(wa,v1)
	wave wa
	variable v1
	variable num=numpnts(wa)/2
	variable i
	if(num<2)
		return NaN
	else
		if(v1<=wa[0][1])
			return wa[0][0]-(wa[1][0]-wa[0][0])*(wa[0][1]-v1)/(wa[1][1]-wa[0][1])
		elseif(v1>=wa[num-1][1])
			return wa[num-1][0]+(wa[num-1][0]-wa[num-2][0])*(v1-wa[num-1][1])/(wa[num-1][1]-wa[num-2][1])
		else
			for(i=0;i<num&&wa[i][1]<v1;i+=1)
			endfor 
			return wa[i-1][0]+(wa[i][0]-wa[i-1][0])*(v1-wa[i-1][1])/(wa[i][1]-wa[i-1][1])
		endif
	endif
end

Function separator_x2y(wa,v1)
	wave wa
	variable v1
	variable num=numpnts(wa)/2
	variable i
	if(num<2)
		return NaN
	else
		if((v1-wa[0][0])*(v1-wa[num-1][0])>=0)
			if(abs(v1-wa[0][0])<abs(v1-wa[num-1][0]))
				return wa[0][1]-(wa[1][1]-wa[0][1])*(wa[0][0]-v1)/(wa[1][0]-wa[0][0])
			else
				return wa[num-1][1]+(wa[num-1][1]-wa[num-2][1])*(v1-wa[num-1][0])/(wa[num-1][0]-wa[num-2][0])
			endif
		else
			for(i=0;i<num && (v1-wa[i][0])*(v1-wa[i+1][0])>0;i+=1)
			endfor 
			return wa[i][1]+(wa[i+1][1]-wa[i][1])*(v1-wa[i][0])/(wa[i+1][0]-wa[i][0])
		endif
	endif
end

Function chkSeparator(w)
	wave w
	variable num=numpnts(w)/2
	variable i,temp1,temp2
	if(num>2)
		for(i=2;i<num;i+=1)
			temp1=(w[i-1][1]-w[i-2][1])*(w[i-1][0]-w[i-2][0])
			temp2=(w[i][1]-w[i-1][1])*(w[i][0]-w[i-1][0])
			if(temp1*temp2<0)
				break
			endif
		endfor
		if(i<num)
			deletepoints i,num-i,w
		endif
	endif
end

Function/S getSeparatorName()
	wave/T dl=root:g_paneldrawinglist
	return getCurrentDatafolder()+"Separator_"+getSuffix(dl[0])
end

