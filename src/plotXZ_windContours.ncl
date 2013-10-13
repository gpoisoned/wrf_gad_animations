;--------------------------------------------------------------------------------
;   Jiwan Rana
;--------------------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin 

      iFile = addfile("/projects/jira3216/FromJeff/hs100_lpdm_d02_0001-01-01_15-59-00","r")

        file_name_attr = "100W m~S~-2~E~"

        size = dimsizes(iFile->uc)
	n_x = size(3) 	
	n_y = size(2) 
        n_lev = 31 ; translates to height ~500m AGL
        n_t = size(0) 
     
        dzc = iFile->dzc
         ;-------------------------------------------------------------------------	 
        ; Compute z_mid 
        ;-------------------------------------------------------------------------	 
       z_interface = new((/n_t,n_lev,n_y,n_x/), float,"No_FillValue")
       z_mid = new((/n_t,n_lev,n_y,n_x/),float,"No_FillValue")

        z_interface(:,1:(n_lev - 1),:,:) = z_interface(:,0:(n_lev - 2),:,:) + dzc(:,0:(n_lev - 2),:,:)                
        z_mid(:,1:(n_lev -  1),:,:) = 0.5 * (z_interface(:,0: n_lev - 2,:,:) + z_interface(:,1:(n_lev - 1),:,:))
       
        avg_z_each_level = new(n_lev,float)

         do it =0,n_lev-1
            avg_z_each_level(it) = avg(z_mid(:,it,:,:))
          end do
          

         ;-------------------------------------------------------------------------	           
         ; Compute height_array to use for sfYarray
         ;-------------------------------------------------------------------------	 
         temp = 0.0
         height_array = new(n_lev,float)
         do it =0,n_lev-1
           do counter = 0, it
                  temp = temp + avg_z_each_level(it)
            end do
            height_array(it) = temp
            temp = 0.0
         end do          
         
         y_array_m = round(height_array,3) 
         x_array_m = ispan(0,4140,10)
         ;-------------------------------------------------------------------------	 
       
         print(max(round(height_array,3)))

      ;-------------------------------------------------------------------------	          
       ;  Since the turbine is located at (2070,1070)m      
      ;-------------------------------------------------------------------------	                  
       y_value = 107
   
       U = iFile->uc(:,0:n_lev-1,y_value,:)
       V = iFile->vc(:,0:n_lev-1,y_value,:)
      
        WS = new((/n_t,n_lev,n_x/),float,"No_FillValue")
  
        do t_it =1,n_t-1
                do lev_it = 0,n_lev-1
                            do x_it = 0,n_x-1
                                        WS(t_it,lev_it,x_it) = sqrt(U(t_it,lev_it,x_it)^2 + V(t_it,lev_it,x_it)^2)
                             end do
                end do
       end do                
        
       ; max_WS = round(max(WS),3)
       ; min_WS = round(min(WS),3)

       
       ;-------------------------------------------------------------------------	                
       ;   For polygon to mark the pos of turbine
       ;-------------------------------------------------------------------------	                  
       poly_xarray = (/2050, 2080, 2080, 2050 ,2050/)
       poly_yarray = (/ 125, 125, 0, 0, 125/)

       spacing = "              "
       ;-------------------------------------------------------------------------	                
       ;    Create a workstation 
       ;-------------------------------------------------------------------------	                  
        wks = gsn_open_wks("png","XZ_"+file_name_attr)

     ;-------------------------------------------------------------------------	                  
     ;    BEGIN TIME LOOP
     ;-------------------------------------------------------------------------	                  
        do time_loop=1,n_t-1
               title = "Wind speed contours at "+file_name_attr + "~C~" + spacing + " at time " + iFile->Times(time_loop,11:18)

               gsn_define_colormap(wks,"gui_default")
                res = True
                res@gsnDraw = False
                res@gsnFrame = False
                res@gsnMaximize = True
                res@gsnSpreadColors = True             

                res@tiMainString = title
                res@tiYAxisString = "z [m]"
                res@tiXAxisString = "x [m]"

                res@cnLevelSelectionMode = "ManualLevels"
                res@cnMaxLevelValF = 16
                res@cnMinLevelValF =  2               
                res@cnLevelSpacingF = 2.0
                res@cnLinesOn = False ; no contour lines	
                res@cnFillOn = True  ; turn on color fill              
                res@cnExplicitLabelBarLabelsOn = True

                res@lgTitleOn = False ;Turn off legend title

                res@lbAutoManage = False
                res@lbOrientation = "Vertical"
                res@lbTitleString = "ms~S~-1~E~"
                res@lbTitlePosition = "Right"
                res@lbTitleDirection = "Across"
                res@lbTitleFontHeightF = 0.08

                res@sfYArray = y_array_m
                res@sfXArray = x_array_m
                
                res@gsnYAxisIrregular2Linear = True ; Make the Y axis regular from irregular
                res@gsnXAxisIrregular2Linear = True
                
                ; Chage the aspect ratio of the plot
                res@vpHeightF = 1.0
                res@vpWidthF = 3.2                               
                
                plot=gsn_csm_contour(wks,WS(time_loop,:,:),res)

                plres = True
                plres@gsFillColor = "black"
                
                poly = gsn_add_polygon(wks, plot, poly_xarray, poly_yarray, plres)
                        
              draw(plot)
               frame(wks)

        end do
        ;-------------------------------------------------------------------------	                
        ;  END OF TIME LOOP
        ;-------------------------------------------------------------------------	                  

        print("PLOT COMPLETE")
end

     
