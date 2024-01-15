//Set output directory
#@ File (label = "Output directory", style = "directory") outDir

//Get the name of the image
name=getTitle;
nameNoExt = split(name, ".");
nameNoExt = nameNoExt[0];

//Get rid of any existing results or ROIs
run("Clear Results");

if (roiManager("Count") > 0)
{
	roiManager("Deselect");
	roiManager("delete");
}


//Save the line as a ROI (user should have set the correct line thickness)
run("ROI Manager...");
roiManager("Add");



//Get current channel, slice and frame
Stack.getPosition(channel, slice, frame);
thisChannel = channel;
thisSlice = slice;

//Get number of frames
getDimensions(width, height, channels, slices, frames);
numFrames = frames;

//Set initial values for normalisation
maximumIntensity = 0;
minimumIntensity = 1000000;

//Create results directory
lineNumber = 1;
resultsDir = outDir + "/" + name + "_line_" + lineNumber + "_results";
while(File.exists(resultsDir))
{
	lineNumber ++;
	resultsDir = outDir + "/" + name + "_line_" + lineNumber + "_results";
}

File.makeDirectory(resultsDir);

//Set CSV name for raw results
outCSVRawName = resultsDir + "/Raw_results.csv";

//Set CSV name for normalised results
outCSVNormName = resultsDir + "/Normalised_results.csv";

//Set ROI name
outROIName = resultsDir + "/ROIs.roi";

//Set CSV name for normalised length
outCSVNormLengthsName = resultsDir + "/Normalised_length.csv";


//Save ROI
roiManager("Save", outROIName);

//Calculate normed lengths
profile = getProfile();

for (i=0; i<profile.length; i++)
{
	setResult("NormalisedLength", i, i/(profile.length-1));
}

updateResults();


//Save normed length results
saveAs("Measurements", outCSVNormLengthsName);

//Clear results table in preparation for writing raw results
run("Clear Results");


for (i = 1; i <= numFrames; i ++)
{
	Stack.setPosition(thisChannel, thisSlice, i);
	columnName = "Frame_" + i;
	profile = getProfile();
	
	for (j=0; j<profile.length; j++)
	{
		setResult(columnName, j, profile[j]);
	
		if (profile[j] > maximumIntensity)
		{
		  	maximumIntensity = profile[j];
		} 
		
		if (profile[j] < minimumIntensity)
		{
		  	minimumIntensity= profile[j];
		}
	}
	
}

updateResults();

//Save raw results
saveAs("Measurements", outCSVRawName);


//Clear results table in preparation for writing normalised results
run("Clear Results");

//Normalise results
for (i = 1; i <= numFrames; i ++)
{
	Stack.setPosition(thisChannel, thisSlice, i);
	columnName = "Frame_" + i;
	profile = getProfile();
	
	for (j=0; j<profile.length; j++)
	{
		normalisedResult = (profile[j] - minimumIntensity) / 
			(maximumIntensity - minimumIntensity);
		setResult(columnName, j, normalisedResult);
	}
	
}

updateResults();

//Save normalised results
saveAs("Measurements", outCSVNormName);

