;------------------------------------------------------	 
; JIwan Rana
; NCL script to plot wind speed contours at 80 m AGL
;------------------------------------------------------	 	 

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin 

      iFile = addfile("/projects/jira3216/FromJeff/hs100_lpdm_d02_0001-01-01_15-59-00","r")

        file_name_attr = "100 Wm~S~-2 ~E~" 

        size = dimsizes(iFile->uc)
	n_x = size(3) 	
	n_y = size(2) 
        n_lev = size(1) 
        n_t = size(0) 
     
        dzc = iFile->dzc
         ;-------------------------------------------------------------------------	 
        ; Compute z_mid 
        ;-------------------------------------------------------------------------	 
         z_interface = new((/n_t,n_lev,n_y,n_x/), float,"No_FillValue")
        z_mid = new((/n_t,n_lev,n_y,n_x/),float,"No_FillValue")
        
        z_interface(:,1:(n_lev - 1),:,:) = z_interface(:,0:(n_lev - 2),:,:) + dzc(:,0:(n_lev - 2),:,:)                
        z_mid(:,1:(n_lev -  1),:,:) = 0.5 * (z_interface(:,0: n_lev - 2,:,:) + z_interface(:,1:(n_lev - 1),:,:))
       
        
        level = 0; temporary int variable to store the level to use
      ;-------------------------------------------------------------------------	 
      ; Figure out the bottom_top value to be used for 80m AGL 
      ; Tolerance value = 2.0 so limit height = 82.0 m max
     ;--------------------------------------------------------------------------	    
        temp = 0.0
        avg_z_each_level = new(n_lev,float)
        tolerance = 2.0
        limit = 80.0 + tolerance

        do it = 0,n_lev-1
          avg_z_each_level(it) = avg(z_mid(:,it,:,:))          
       end do
 
       do it=0,n_lev-1
                  temp = temp + avg_z_each_level(it)
                  if (temp .gt. limit)
                         level = it -1
                         temp = temp - avg_z_each_level(it)
                         break
                  end if
      end do

      print(level)
      print(temp)
     ;------------------------------------------------------	    

       
     ;------------------------------------------------------	    	
     ; Get the U and V for the appropriate level and
     ; calculate the Wind Speed
     ;------------------------------------------------------	    
	U = iFile->uc(:,level,:,:)
	V = iFile->vc(:,level,:,:)
	
	
	WS = new((/n_t,n_x,n_y/),float,"No_FillValue")
       ; WS@units = U@units ; Set the unit to whatever the original input had

	do t_it = 1,n_t-1
		do y_it = 0,n_y-1
			do x_it =0,n_x-1
					WS(t_it,x_it,y_it) = sqrt(U(t_it,y_it,x_it)^2 + V(t_it,y_it,x_it)^2)
			end do
		end do		
	end do	

	WS!0 = "Time"
	WS!1 = "south_north"
	WS!2 = "west_east"	
	
	new_WS = WS(Time|:,west_east|:,south_north|:)

	max_WS= 18
	min_WS = 2
        units_WS = "WS ms~S~-1"              
        spacing = "           "
        
	;------------------------------------------------------	 
	; 		PLOT WS CONTOUR
	;------------------------------------------------------	 
	
	wks = gsn_open_wks("png", file_name_attr)	
        
        ;------------------------------------------------------	 
        ;  Change X and Y axis to  "m"
        ;------------------------------------------------------	 
        xarray_m = fspan(0,4.14, 414)
        yarray_m = fspan(0,2.13,213)
        ;------------------------------------------------------	 
                   
        ;---------------------------------------------------------
        ;    For polygon to mark the pos of turbine
        ;---------------------------------------------------------
        poly_xarray = (/2.050, 2.085, 2.080, 2.050/)               
        poly_yarray = (/1.105, 1.105, 1.035, 1.035/)
               
;------------------------------------------------------	 
; Begin time loop
;------------------------------------------------------	 
	do time_loop=1,n_t-1	
                title = "Wind speed contours at height " + round(temp,3)+ "m AGL, ~C~" +spacing+  file_name_attr + "   at time " + iFile->Times(time_loop,11:18)
        
		gsn_define_colormap(wks,"gui_default")	
		res = True;
		res@gsnDraw = False
		res@gsnFrame = False

                 res@gsnMaximize = True	
		 res@gsnSpreadColors =  True ; use full color map
                ; res@gsnPaperOrientation = "landscape"
                 
	     	 res@tiMainString = title	
                 res@tiMainOffsetYF = 0.05
                               
                
		res@tiYAxisString = "y [km]"
		res@tiXAxisString = " x [km]"   
                res@tiYAxisFontHeightF =  0.04
                res@tiXAxisFontHeightF = 0.04
               
                res@cnLevelSelectionMode = "ManualLevels"
                res@cnMaxLevelValF =max_WS
                res@cnMinLevelValF =min_WS
                res@cnLevelSpacingF = 2.0
                res@cnLinesOn = False ; no contour lines	
                res@cnFillOn = True  ; turn on color fill              
                res@cnExplicitLabelBarLabelsOn = True
               
                res@lgTitleOn = False ;Turn off legend title
                
               ;Chage the size of the tickmark labels
                res@tmXBLabelFontHeightF = 0.03
                res@tmYLLabelFontHeightF = 0.03                                   
                
                res@lbAutoManage = False
                res@lbOrientation = "Vertical"
               ; res@lbTitleString = units_WS
                res@lbTitleDirection = "Across"
                res@lbTitlePosition = "Right"
                res@lbLabelFontHeightF = 0.03                           
                
                res@sfXArray = xarray_m
                res@sfYArray = yarray_m

                ; Chage the aspect ratio of the plot
                res@vpWidthF = 1.2
                res@vpHeightF = 0.6                  

                plot = gsn_csm_contour(wks,new_WS(time_loop,:,:),res)	
	
                 plres = True
                plres@gsFillColor = "black"
                
               line = gsn_add_polygon(wks,plot, poly_xarray, poly_yarray, plres)
                
               xarray_d = ispan(-20,20,10)
               yarray_d = ispan(-8,8,4)
               xminor_d = (/-18,-16,-14,-12,-8,-6,-4,-2,2,4,6,8,12,14,16,18/)
               yminor_d = (/-6,-2,2,6/)
               
               
              tmXBValues = (xarray_d +20.7)/10  
              tmYLValues = (yarray_d +10.75 )/10
              tmXBMinorValues = (xminor_d + 20.7)/10
              tmYLMinorValues = (yminor_d + 10.75)/10
          
               setvalues plot
                     "tmYUseLeft" : False
                     "tmYRLabelsOn" : True                     
                     "tmYRMode" : "Explicit"                     
                     "tmYRValues" : tmYLValues
                    "tmYRLabels" : yarray_d
                    "tmYRMinorValues" : tmYLMinorValues

                    "tmXTLabelsOn" : True
                    "tmXUseBottom" : False
                   "tmXTMode" : "Explicit"            
                   "tmXTValues" : tmXBValues
                   "tmXTLabels" : xarray_d
                   "tmXTMinorValues" : tmXBMinorValues
                
               end setvalues                              
               
                draw(plot)

                ;------------------------------------------------------	 
                ; Add text title to second x and y axis 
                ;  and index (workaround for text being outside of viewport problem) 
                ;                 index -> put at the bottom of labelbar
                ;------------------------------------------------------	 
                txres = True 
                txres@txFontHeightF = 0.02
                txres@txAngleF = -90
                gsn_text_ndc(wks, "y [D]",0.88, 0.5, txres)
                
                tyres = True
                tyres@txFontHeightF = 0.02
                gsn_text_ndc(wks,"x [D]", 0.46, 0.73, tyres)
                
                tfix = True
                tfix@txFontHeightF = 0.02
                gsn_text_ndc(wks,units_WS, 0.93, 0.3, tfix )

                frame(wks)
                delete(txres)
                delete(tyres)
		delete(res)
                delete(plres)
	 end do
;------------------------------------------------------	 
; End time loop
;------------------------------------------------------	 
         print ("PLOT COMPLETE")

end
