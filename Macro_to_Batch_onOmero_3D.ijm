/* Test macro for analysis on a dataset Omero
 * Input : 3D TIF image
 * Thresholding and 3D object detection and labeling 
 * Transformation of labels into ROI groups : 3D ROIs
 * Output : Image of labels, Results tab, Log window and ROIs
 * F. Brau for Fiji/ImageJ 1.53f November 2021
*/

// Initialisation--------------------------------------------------------------------

run("Set Measurements...", "area limit redirect=None decimal=2");
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 count=1 edm=Overwrite");
run("Clear Results");
print("\\Clear");

if (roiManager("count")>0) {
	roiManager("deselect");
	roiManager("delete");
}
// Macro with arguments---------------------------------------------------------------
values = getArgument();
if (lengthOf(values)==0) {return showMessage("Put arguments with the macro");}
a = split(values, "");
size_min2D=parseInt(a[0]);
size_min3D=parseInt(a[1]);    
close_all=a[2];

/*size_min2D=20;
 size_min3D=20;
 close_all=false;
*/

// Get informations from the image-----------------------------------------------------
image=getTitle();
getDimensions(width, height, channels, slices, frames);
Stack.getStatistics(voxelCount, mean, min, n_cells, stdDev);

// 3D filtering and segmentation-------------------------------------------------------
//run("Median 3D...", "x=4 y=4 z=4");
setAutoThreshold("Otsu dark stack");
run("Analyze Particles...", "size="+size_min2D+"-Infinity show=Masks clear stack");
if(is("Inverting LUT")==true) run("Invert LUT");
run("Options...", "iterations=1 count=1 black do=Nothing");
run("Fill Holes", "stack");
getDimensions(width, height, channels, slices, frames);
run("3D OC Options", "volume surface dots_size=5 font_size=10 redirect_to=none");
run("3D Objects Counter", "threshold=1 slice="+slices+" min.="+size_min3D+" max.=5767168 objects statistics summary");

// ROI detection from the same labels in a stack and assignment to a group-------------
for(i=0; i<n_cells; i++) {
	resetThreshold();	
    setThreshold(i+1, i+1);
    for(t=1; t<=frames; t++) {
           Stack.setFrame(t);
            for(z = 1; z <= slices; z++) {
                Stack.setSlice(z);
                run("Create Selection");
                
// if there is no ROI in a plane -------------------------------------------------------        
                if(Roi.size > 0) {
                    Roi.setPosition(0, z, t);
                    Roi.setProperty("ROI", i+1);
                    
// Use ROI groups, but only up to 255 for now-------------------------------------------
                    if(n_cells < 256) Roi.setGroup(i+1);
                    roiManager("Add");
	             }
           	}
      }
}
close("Mask of "+image);
if (close_all==true) close("*");
run("From ROI Manager");