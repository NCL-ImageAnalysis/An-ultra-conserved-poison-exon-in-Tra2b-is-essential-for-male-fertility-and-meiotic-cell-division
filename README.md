# An-ultra-conserved-poison-exon-in-Tra2b-is-essential-for-male-fertility-and-meiotic-cell-division
Image processing and analysis macros for the manuscript titled: "An ultra-conserved poison exon in Tra2b is essential for male fertility and meiotic cell division"

Manuscript Authors: Caroline Dalgliesh, Saad Aldalaqan, Christian Atallah, Andrew Best, Emma Scott, Ingrid Ehrmann, George Merces, Joel Mannion, Barbora Badurova1, Raveen Sandher, Ylva Illing, Brunhilde Wirth, Sara Wells, Gemma Codner, Lydia Tebou, Graham R. Smith, Ann Hedley, Mary Herbert, Dirk G. de Rooij, Colin Miles, Louise N Reynard, and David J. Elliott.

ImageJ Macro Overview
Setup and Configuration:
The macro begins by enabling expandable arrays and setting up file input/output options ensuring compatibility with subsequent processing steps. The key measurement parameters are also defined

Directory Management:
It prompts the user to select the home folder and the directory for raw images, creating necessary output folders for processed images

Image Processing Workflow:
The macro iterates through raw images, converting them to .tif format and splitting them into individual channels (Ch1, Ch2, Ch3), each channel is saved in its respective folder for further analysis.

Nuclear Image Processing:
The macro processes non-DAPI stained images by enhancing contrast and creating maximum intensity projections

Ilastik Integration:
It integrates with Ilastik to generate probability maps for nuclei. The macro checks for existing maps to avoid redundant processing.

Segmentation with StarDist:
The macro employs the StarDist plugin for segmenting nuclei, scaling down the probability maps prior to processing. It applies a slight Gaussian blur and adjusts the image to enhance segmentation accuracy. It manages regions of interest (ROIs) to ensure that overlapping nuclei are correctly identified and counted.

Final Analysis:
After segmentation, the macro analyzes the particles, saving the results and ROIs for further examination. This includes generating binary images for non-overlapping nuclei and saving them in designated folders. The intensity of each channel is measured for each nucleus and exported in csv format

For questions relating to the macros or data analysis presented here, please contact the corresponding author of the manuscript
