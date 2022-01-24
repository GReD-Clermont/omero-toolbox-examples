/* Test macro for analysis on a dataset Omero
 *  Input : 3D TIF image
 *  Thresholding and 3D object detection and labeling 
 *  Transformation of labels into ROI groups : 3D ROIs
 *  Output : Image of labels (depending on choice), Results tab, Log window and ROIs
 *  F. Brau for Fiji/ImageJ 1.53f November 2021
*/


// Initialisation parameters-------------------------------------------------------------------------------------
run("Set Measurements...", "area limit redirect=None decimal=2");
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 count=1 edm=Overwrite");

// Login and choose the correct dataset--------------------------------------------------------------------------
Dialog.create("Login on your Omero database");
Dialog.addString("Login:", "frederic.brau");
Dialog.addString("Password :", "password");
Dialog.addString("Give a tag the images processed by ImageJ :", "IJ_Processed");
Dialog.show();
login=Dialog.getString();
password=Dialog.getString();
tagName_IJ_Processed=Dialog.getString();

run("OMERO Extensions");
Ext.connectToOMERO("bioimage.france-bioinformatique.fr", 4064, login,password);

// Get all the tags from your default account---------------------------------------------------------------------
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
// If the TagNmane tagging the "analysis done" already exists get its TagID--------------------------------------	
	if (tagName[i]==tagName_IJ_Processed) {
		tag_exists=true;
		tagId_IJ_Processed=tagIds[i];
		print("Tag signature existe : "+tagId_IJ_Processed);
	}
}
print("Tag_exists="+tag_exists);

// If the TagName tagging the "analysis done" is not available creatian of the TagName given in the dialogbox--------
if (tag_exists!=true) {
	New_tagId_Processed=Ext.createTag(tagName_IJ_Processed, "Image Processed by IJ macro");
	print("TagID cree:"+New_tagId_Processed);
}

// Select the images to analyse according to a chosen tag--------------------------------------------------------
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
// Open the images having the chosen tag-------------------------------------------------------------------------
	for (j = 0; j <tagIds.length; j++){
		if (tagIds[j]==chosen_tag){
		    imageplus_id = Ext.getImage(image_ids[i]);
		    nom_image=getTitle();
		    chosen_image_ID=image_ids[i];
		    tags_chosen_image= Ext.list("tags", "image", chosen_image_ID);
			tagIds_chosen_image= split(tags_chosen_image,",");
			print("Image "+nom_image+", "+chosen_image_ID);
			for (k = 0; k <tagIds_chosen_image.length; k++) {
/*				print(tagIds_chosen_image[k]);
			}
		print("-------------");
		}
	}
}		
			exit;
*/			
				if (tag_exists==true){
						if (tagIds_chosen_image[k]==tagId_IJ_Processed) {
							print("Image "+nom_image+" "(+chosen_image_ID+)" already processed");
							close(nom_image);
						}
						if (tagIds_chosen_image[k]!=tagId_IJ_Processed){
							print("Le tag signature existe mais n'est pas lié à "+nom_image+", "+chosen_image_ID);
							Tag_linked=Ext.link("image", chosen_image_ID, "tag", tagId_IJ_Processed);
							print("le tag a été lié");
						}
				}
				if(tag_exists==false) {
					Tag_linked=Ext.link("image", chosen_image_ID, "tag", New_tagId_Processed);
					print("image "+nom_image+" "(+chosen_image_ID+)" Liee nouveau Tag "+New_tagId_Processed);
				}
			}
		}
	}
}

//			runMacro("Macro_to_Batch_onOmero_3D");
// 			nROIS = Ext.saveROIs(image_ids[i],"ROIs");

run("OMERO Extensions");
Ext.disconnect();