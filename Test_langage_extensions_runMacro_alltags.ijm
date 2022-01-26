/* Test macro for analysis on a dataset Omero
 *  Input : 3D TIF image
 *  Thresholding and 3D object detection and labeling 
 *  Transformation of labels into ROI groups : 3D ROIs
 *  Output : Image of labels (depending on choice), Results tab, Log window and ROIs
 *  F. Brau for Fiji/ImageJ 1.53f November 2021
*/


// Initialisation parameters--------------------------------------------------------------------------------------------
run("Set Measurements...", "area limit redirect=None decimal=2");
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 count=1 edm=Overwrite");

// Login and choose the correct dataset---------------------------------------------------------------------------------
Dialog.create("Login on your Omero database");
Dialog.addString("Login:", "user");
Dialog.addString("Password :", "password");
Dialog.addString("Give a signature tag to the images processed by ImageJ :", "IJ_Processed");
Dialog.show();
login=Dialog.getString();
password=Dialog.getString();
tagName_IJ_Processed=Dialog.getString();

run("OMERO Extensions");
Ext.connectToOMERO("bioimage.france-bioinformatique.fr", 4064, login,password);

// Get all the tags from your default account-----------------------------------------------------------------------------
tags = Ext.list("tags");
print(tags);
tagIds = split(tags,",");
tagName_ID=newArray(tagIds.length);
tagName=newArray(tagIds.length);
tag_exists=false;
for (i = 0; i <tagIds.length; i++) {
	tagName_ID[i] = Ext.getName("tag", tagIds[i]) + " (" + tagIds[i] + ")";
	tagName[i] = Ext.getName("tag", tagIds[i]);
	print(tagName_ID[i]);
// If the TagNmane tagging the "analysis done" already exists get its TagID-----------------------------------------------	
	if (tagName[i]==tagName_IJ_Processed) {
		tag_exists=true;
		tagId_IJ_Processed=tagIds[i];
		print("Tag signature exists : "+tagId_IJ_Processed);
	}
}
print("Tag_exists="+tag_exists);

// If the TagName tagging the "analysis done" is not available creation of the TagName given in the dialogbox-------------
if (tag_exists!=true) {
	New_tagId_Processed=Ext.createTag(tagName_IJ_Processed, "Image Processed by IJ macro");
	print("TagID cree:"+New_tagId_Processed);
}

// Select the images to analyse according to a chosen tag------------------------------------------------------------------
Dialog.create("Choose a tag to Process images associated with that tag");
Dialog.addChoice("Tags", tagName_ID);
Dialog.show();
chosen_tag=replace(Dialog.getChoice(), ".+ \\(([0-9]+)\\)$", "$1");
print("Tag choisi pour le traitement: "+chosen_tag);

images = Ext.list("images");
image_ids = split(images,",");
for (i=0; i <image_ids.length; i++) {
	tags= Ext.list("tags", "image", image_ids[i]);
	tagIds = split(tags,",");
	
// Open the images having the chosen tag------------------------------------------------------------------------------------
	for (j = 0; j <tagIds.length; j++){
		if (tagIds[j]==chosen_tag){
		    imageplus_id = Ext.getImage(image_ids[i]);
		    nom_image=getTitle();
		    chosen_image_ID=image_ids[i];
		    tags_chosen_image= Ext.list("tags", "image", chosen_image_ID);
			tagIds_chosen_image= split(tags_chosen_image,",");
			print("Image "+nom_image+", "+chosen_image_ID);
			already_tagged = false;
			
// When the tag already exists is it linked to the image ?------------------------------------------------------------------	
			if (tag_exists==true){
				for (k = 0; k <tagIds_chosen_image.length; k++) {
					if (tagIds_chosen_image[k]==tagId_IJ_Processed) {
						already_tagged = true;
					}
					if (tagIds_chosen_image[k]!=tagId_IJ_Processed){
					}
				}
				
// If it is already linked : no process--------------------------------------------------------------------------------------
				if(already_tagged==true) {
					print("Image "+nom_image+" ("+chosen_image_ID+") already processed");
					close(nom_image);
				} 
				
// If it exists unlinked : process & link------------------------------------------------------------------------------------
				else {
					print("The signature Tag of the processing exists but unlinked from "+nom_image+", "+chosen_image_ID);
					runMacro("Macro_to_Batch_onOmero_3D");
					nROIS = Ext.saveROIs(image_ids[i],"ROIs");	
					Tag_linked=Ext.link("image", chosen_image_ID, "tag", tagId_IJ_Processed);
					print("Signature Tag linked");
				}
			}
			
// If the tag doesn't exits : process and link the new signature tag from the dialg box--------------------------------------
			else {
				runMacro("Macro_to_Batch_onOmero_3D");
				nROIS = Ext.saveROIs(image_ids[i],"ROIs");
				Tag_linked=Ext.link("image", chosen_image_ID, "tag", New_tagId_Processed);
				print("image "+nom_image+", "+chosen_image_ID+" Linked to new signature Tag of the processing "+New_tagId_Processed);
			}
		}
	}
}
Ext.disconnect();
