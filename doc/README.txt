File: README.txt 
Date Created: June 24, 2013


Jiwan Rana(jiwan.rana@colorado.edu)  == gpoisoned

// HOW TO IMPORT NCL MODULE IN JANUS //
// Note:
Janus is a sumpercomputer at University of Colorado-Boulder. For more info, visit: https://www.rc.colorado.edu/node/212

- It is important that ncl module is imported to run theses scripts on Janus. 
	The way to do this on Janus is :	
		module load viz/ncl-6.1.2

	You can put this line in .my.bash_profile or .my.cshrc depending on the shell you are on.

//-------------------------------------------------------------- 
// NCL scripts description follows : 
//-------------------------------------------------------------- 

      1.  FileName: plotWindSpeedContours.ncl
      		        // WHAT THIS DOES ? //
      			//-----------------------------------------------------------
      			 - This file plots the WRF GAD data in terms of x and y in meters. 
      			    It also labels the plot in terms of Rotor diameters(D). The contours
      			    are of Wind Speed whose units are in meters per sec.

      			// HOW TO RUN //
      			  - ncl plotWindSpeedContours.ncl runs the script 

      			// HOW TO RUN DIFFERENT FILE //
      				- Line number 9 in the script is where the
      			input file is selected. Modify accordingly to a differnt file location.

      				Note: variable "file_name_attr" is what sets the string in the main string title of the
      				plot. 
      				Correct use of this is : If the file name has surface flux = 20Wm^-2, then set it to 
      				"20 wm~S~-2 ~E~".
      				Change "20" -> "100" if the file you are using has surface flux = 100Wm^-2.   	

      			// WHAT ARE THE OUTPUT IN THE TERMINAL //
      				- Variable "level" -> is the model level selected that was closest to 80m height.

      				- Variable "temp" -> gives the actual height which is float. Note that this variable 
      				is rounded to nearest integer and is used in the main title string of the plot.

      			// HOW TO DETERMINE THAT THE SCRIPT RAN SUCCESSFULLY
      				- The script outputs "PLOT COMPLETE" to the terminal once it has completed without
      				  errors.


      	2. FileName: plotXZ_windContours.ncl
      			// WHAT THIS DOES ? //
      			//-----------------------------------------------------------	
      			- This file plots the WRF GAD data in terms of x and z where z is the height. The plot is 
      			plotted at the value of "y = 1070" which corresponds to the y co-ordinate of the turbine whose
      			co-ordinate in XY plane is (2070,1070).

      			// HOW TO RUN //
      			  - ncl plotXZ_windContours.ncl runs the script 

      			// HOW TO RUN DIFFERENT FILE //
      				- Line number 15 in the script is where the input file is selected. Modify accordingly
      				to a differnt file location.

      				Note: variable "file_name_attr" is what sets the string in the main string title of the
      				plot. 
      				Correct use of this is : If the file name has surface flux = 20Wm^-2, then set it to
      				"20 wm~S~-2 ~E~". Chage "20" -> "100" if the file you are using has surface 
      				flux = 100Wm^-2   	

      			// WHAT IS THE OUTPUT IN THE TERMINAL//
      				- The printed variable is the maximum height rounded to an integer value that will be
      				used for the maximum value of X-axis tickmarks.

      				Note: THE x axis = z (height in m) is irregular and the resource
      				"gsnYAxisIrregular2Linear = True" is used to convert it to linear.


      			// HOW TO DETERMINE THAT THE SCRIPT RAN SUCCESSFULLY
      				- The script outputs "PLOT COMPLETE" to the terminal once it has completed without 
      				errors.

      	
      	3. 	FileName: plotXZ_subsection.ncl
      			// WHAT THIS DOES ? //
      			//-----------------------------------------------------------			
      			- This file is very similar to the above file "plotXZ_windContours.ncl" but it differs slightly
      			in that this allows to select a section in x direction from where to plot till the end. 
      			
      			Note: At the moment, this doesn't support selecting the end point in X axis and the end
      			point is the default end point in the WRF output. To select the left starting point of x-axis,
      			change the value of the variable "x_val" in line 26 to a desired value.
      			
      			Hint: Range for all data files is (0:414)

      			- The script goes to the height of ~500m which corresponds to number of model levels = 31.
      			To change this, setting a different value for lev_val = 31 will work. Increasing the lev_val 
      			will increase the maximum height and vice-versa.

//-------------------------------------------------------------- 
                      HOW THE ANIMATIONS ARE CREATED 								
//-------------------------------------------------------------- 
Software Application used : ffmpeg
	 	     	  http://ffmpeg.org/

Short description of use:
		Lets say we have our image sequences range -
		"Image00001.png  to Image00099.png" at "~/jira3216" 
		
		ffmpeg -r 3 -i ~/test/Image%05d.png -vb 3M -r 30 output_file.mpeg
		
		This command will create output_file.mpeg file from the
		images sequences in the path "~/test" with bitrate of
		3 Megabits per second, input frame rate of 3 frames per
		second  and forced output frame rate of 30 frames per
		second.

                Note: 
                        For more information on ffmpeg please visit http://www.ffmpeg.org/documentation.html

		It is also possible to use ffmpeg to create "gif" file
		format but from my expeience it is almost always better to use mpeg format
		than gif as gifs are inefficient in terms of disk usage. 
	
			 
