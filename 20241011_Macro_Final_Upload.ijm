//Please Note: This is a draft format of an ImageJ macro
//Developed by Dr George Merces, Newcastle University, 11.10.2024
//In a Project with Caroline Dalgliesh and David Elliott, Newcastle University
//This macro aims to automate the segmentation of nuclei and identify 
//fluorescence Intensity in Two Channels of Interest

//This option setting allows for arrays to be generated later in the macro for
//removing unsuitable nuclei from the analysis
setOption("ExpandableArrays", true);

//Establishes the File Chooser so Lif Files can be Converted into Tif Files
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use use_file copy_row save_column save_row");
run("Bio-Formats Macro Extensions");

//Sets the Measurements Necessary for Full Data Analysis Later
run("Set Measurements...", "area mean standard modal min centroid perimeter bounding fit shape feret's median area_fraction display redirect=None decimal=3");

//Defines the folder locations necessary for the analysis:
//Home folder containing all the folders and files necessary for this macro to run
homeFolder = getDirectory("Choose The Home Folder (Where All Your Other Folders for this Macro Are)");
//Raw Folder containing all raw, unprocessed images for this macro to analyse
rawFolder = getDirectory("Choose The Image Folder (Where All Your Raw Images Are)");


//Creates folders necessary for saving output images
tifFolder = homeFolder + "Raw_Tifs/";
if (File.isDirectory(tifFolder) < 1) {
	File.makeDirectory(tifFolder); 
}
Ch3 = homeFolder + "Ch3/";
if (File.isDirectory(Ch3) < 1) {
	File.makeDirectory(Ch3); 
}
Ch2 = homeFolder + "Ch2/";
if (File.isDirectory(Ch2) < 1) {
	File.makeDirectory(Ch2); 
}
Ch1 = homeFolder + "Ch1/";
if (File.isDirectory(Ch1) < 1) {
	File.makeDirectory(Ch1); 
}
nucleusFolder = homeFolder + "Nuclear_Combined/";
if (File.isDirectory(nucleusFolder) < 1) {
	File.makeDirectory(nucleusFolder); 
}
nuclearSegFolder = homeFolder + "Nuclear_Segmented/";
if (File.isDirectory(nuclearSegFolder) < 1) {
	File.makeDirectory(nuclearSegFolder); 
}
nuclearROIFolder = homeFolder + "Nuclear_ROI/";
if (File.isDirectory(nuclearROIFolder) < 1) {
	File.makeDirectory(nuclearROIFolder); 
}



//Finds the names of image files within folder and counts the number of files
list = getFileList(rawFolder);
l = list.length;
//Clears the Results Window and the ROI Manager Prior to Starting Analysis
run("Clear Results");
roiManager("reset");
//For Each Raw Image
for (i=0; i<l; i++) {
	//Open the Image
	fileName = rawFolder + list[i];
	run("Bio-Formats", "check_for_upgrades open=[" + fileName + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	saveName = tifFolder + fileNameRaw + ".tif";
	saveAs("Tiff", saveName); 
	//Split the Image into Constituent Channels
	run("Stack to Images");
	//Save Each Channel to Appropriate Location in Appropriate Folder
	saveName = Ch3 + fileNameRaw + ".tif";
	saveAs("Tiff", saveName);
	close();
	saveName = Ch2 + fileNameRaw + ".tif";
	saveAs("Tiff", saveName);
	close();
	saveName = Ch1 + fileNameRaw + ".tif";
	saveAs("Tiff", saveName);
	//Close Any Open Images
	close("*");
}


//Finds the names of image files within folder and counts the number of files
list = getFileList(tifFolder);
l = list.length;
//Opens each image sequentially
for (i=0; i<l; i++) {
	roiManager("reset");
	//Opens the image
	fileName = tifFolder + list[i];
	open(fileName);
	run("Properties...", "channels=1 slices=3 frames=1 pixel_width=0.3225000 pixel_height=0.3225000 voxel_depth=1.0000000");
	run("Make Substack...", "slices=2,3");
	run("Enhance Contrast...", "saturated=0.1 process_all");
	run("Z Project...", "projection=[Max Intensity]");
	saveName = nucleusFolder + list[i];
	saveAs("Tiff", saveName);
	close("*");
}


// set global variables for Ilastik Project
pixelClassificationProject = homeFolder + "20241017_CD_V2.ilp";
outputType = "Probabilities"; //  or "Segmentation"
inputDataset = "data";
outputDataset = "exported_data";
axisOrder = "tzyxc";
compressionLevel = 0;

foldertoProcess = nucleusFolder;
folderforOutput = homeFolder + "Ilastik_Probability_Output/";
if (File.isDirectory(folderforOutput) < 1) {
	File.makeDirectory(folderforOutput); 
}

//Checks membrane folder (bfFolder Folder) for files and counts the number of them
list = getFileList(Ch1);
//list = Array.sort(list);
l = list.length;
for (i=0; i<l; i++) {
	fileName = foldertoProcess + list[i];
	testName = folderforOutput + list[i];
	if( File.exists(testName) == 0){
		print("Creating New Probability Map");
		open(fileName);
		inputImage = getTitle();
		pixelClassificationArgs = "projectfilename=[" + pixelClassificationProject + "] saveonly=false inputimage=[" + inputImage + "] pixelclassificationtype=" + outputType;
		run("Run Pixel Classification Prediction", pixelClassificationArgs);
		//Saves the probability map to the appropriate folder
		//Split the Image into Constituent Channels
		run("Stack to Images");
		close();
		run("8-bit");
		saveAs("Tiff", folderforOutput + list[i]);
		close("*");
	}
	else{
		print("Probability Map Already Existed");
	}
}

//Finds the names of image files within folder and counts the number of files
list = getFileList(nucleusFolder);
l = list.length;
//Opens each image sequentially, and all series within image, and converts each to individual tif
for (i=0; i<l; i++) {
	roiManager("reset");
	//Opens the nuclear image
	fileName = folderforOutput + list[i];
	open(fileName);
	run("Scale...", "x=0.5 y=0.5 interpolation=Bilinear average create");
	getDimensions(width, height, channels, slices, frames);
	title = getTitle();
	//Applies Guassian Blur
	run("Gaussian Blur...", "sigma=2");
	run("Subtract...", "value=50");
	//Segments the image using StarDist
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'" + title + "', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.05', 'nmsThresh':'0.25', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	//Make a binary image with non-overlapping cells based on the stardist ROIs
	//Counts the number of nuclei found by the ROI manager
	n = roiManager("count");
	if (n == 0) {
		makeOval(1, 1, 1, 1);
		roiManager("Add");
	}
	n = roiManager("count");
	//If some nuclei have been identified...
	if (n > 0) {
		//Create a blank image to draw on the nuclei for to determine cell boundary locations
		newImage("Untitled", "8-bit black", width, height, 1);
		//For each nucleus in the ROI manager
	    for (j=0; j<n; j++) {
	    	//Select the ROI
	    	roiManager("select", j);
	    	run("Enlarge...", "enlarge=2");
	    	roiManager("update");
	    	//Fill the area of the ROI with black to prevent summation of multiple touching nuclei into one super-nucleus
	    	setForegroundColor(0, 0, 0);
			roiManager("Fill");
			//Re-selects the ROI
			roiManager("select", j);
			//Shrinks the ROI down by 3 pixels
			run("Enlarge...", "enlarge=-2");
			//Fills the ROI with white for the particle analyser to find later
			roiManager("update");
			setForegroundColor(255, 255, 255);
			roiManager("Fill");
	    }
	    run("Scale...", "x=2 y=2 interpolation=None average create");
	    saveName = nuclearSegFolder + list[i];
		saveAs("Tiff", saveName);
		roiManager("reset");
		run("Analyze Particles...", "size=0-750 add");
		fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
		saveName = nuclearROIFolder + fileNameRaw + ".zip";
		roiManager("save", saveName);
	}
	close("*");
	roiManager("reset");	
}


//Creates a List of All the Images in your Nuclear Folder
list = getFileList(Ch1);
list = Array.sort(list);
l = list.length;
row = 0;
//For Each Nuclear Channel Image
for (i=0; i<l; i++) {
	roiManager("reset");
	fileName = Ch1 + list[i];
	open(fileName);
	saveFile = list[i];
	saveFileRaw = substring(saveFile, 0, (lengthOf(saveFile)-4));
	roiSaveName = nuclearROIFolder + saveFileRaw + ".zip";
	roiManager("open", roiSaveName);
	n = roiManager("count");
	for (j = 0; j < n; j++) {
		roiManager("select", j);
		run("Measure");
		setResult("Channel", row, "Channel 1");
		setResult("Cell_Number", row, j);
		setResult("Image_Name", row, list[i]);
		row = row + 1;
	}
	close();
	fileName = Ch2 + list[i];
	open(fileName);
		for (j = 0; j < n; j++) {
		roiManager("select", j);
		run("Measure");
		setResult("Channel", row, "Channel 2");
		setResult("Cell_Number", row, j);
		setResult("Image_Name", row, list[i]);
		row = row + 1;
	}
	close();
	fileName = Ch3 + list[i];
	open(fileName);
		for (j = 0; j < n; j++) {
		roiManager("select", j);
		run("Measure");
		setResult("Channel", row, "Channel 3");
		setResult("Cell_Number", row, j);
		setResult("Image_Name", row, list[i]);
		row = row + 1;
	}
	close("*");
	roiManager("reset");
}


csvSave = homeFolder + "Collated_Data.csv";
saveAs("Results", csvSave);


