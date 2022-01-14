/* Test macro for analysis on a dataset Omero
 *  Input : 3D TIF image
 *  Thresholding and 3D object detection and labeling 
 *  Transformation of labels into ROI groups : 3D ROIs
 *  Output : Image of labels (depending on choice), Results tab, Log window and ROIs
 *  F. Brau for Fiji/ImageJ 1.53f November 2021
*/

// Initialisation----------------------------------------------------------------------
run("Set Measurements...", "area limit redirect=None decimal=2");
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 count=1 edm=Overwrite");
run("Clear Results");
print("\\Clear");

if (roiManager("count")>0) {
	roiManager("deselect");
	roiManager("delete");
}

// Dialog Box=Get variables ----------------------------------------------------------
/* The dialog box is executed only if the macro is called for the first time by the macro
 In this case values are stored in a temporary file "Parameters_Macro_toBatch.txt" (which is previously deleted)
 in the Fiji\macros directory. The values are read in the file during the following executions.
 */
chemin=getDirectory("macros"); 
execution=getArgument();

if (execution=='0'){
	Dialog.create("3D segmentation Batch Macro on Omero");
	Dialog.addNumber("2D Minimal size :", 20);
	Dialog.addNumber("3D Minimal size :", 20);
	Dialog.addCheckbox("Close all the images at the end", false);
	Dialog.show();
	size_min2D=Dialog.getNumber();
	size_min3D=Dialog.getNumber();
	close_all=Dialog.getChoice();
	File.delete(chemin+"Parameters_Macro_toBatch.txt");
	file_temp = File.open(chemin+"Parameters_Macro_toBatch.txt");
	print(file_temp, size_min2D + "  \t" + size_min3D+ "  \t" + close_all);
	File.close(file_temp);
}
if (execution!='0'){
	str=File.openAsString(chemin+"Parameters_Macro_toBatch.txt"); 
	lines=split(str,"\t");
  	size_min2D=(lines[0]);
  	size_min3D=(lines[1]);
  	close_all=(lines[2]);
}
arguments=size_min2D+" "+size_min3D+" "+close_all;
runMacro("Macro_to_Batch_onOmero_3D", arguments);