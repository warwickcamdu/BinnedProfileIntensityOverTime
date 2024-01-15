%% Open data
loadDir = uigetdir(pwd,'Pick Load Directory');
        DirData              = dir(loadDir);
        DirIndex             = [DirData.isdir];
        subDir               = {DirData(DirIndex).name}';
        ValIndex(DirIndex)   = ~ismember(subDir,{'.','..','.DS_Store'});
        DirList              = {DirData(ValIndex).name}';

        for j = 1:length(DirList)
            DirList(j) = strcat(loadDir,'/',DirList(j));
        end

checkingSample = DirList{1,1};

normalisedResultsFile = dir([checkingSample '/Normalised_results*.csv']);     % Lists the normalised results in the Sample directory in a vector

name = normalisedResultsFile.name;

filename = append(checkingSample, "/", normalisedResultsFile.name);

data=readtable(filename, 'ReadVariableNames', true, 'ReadRowNames', true);

globalTimepoints = size(data,2);

% Results will be stored in a matrix of time x distance (normalised) x line
% Dimensions are space, time, line
finalResultsMatrix = zeros(100,globalTimepoints,length(DirList));

for f = 1:length(DirList)

    % Load the line's data
    
    sample = DirList{f,1};
    
    normalisedResultsFile = dir([sample '/Normalised_results*.csv']);     % Lists the normalised results in the Sample directory in a vector

    name = normalisedResultsFile.name;

    filename = append(sample, "/", normalisedResultsFile.name);

    data=readtable(filename, 'ReadVariableNames', true, 'ReadRowNames', true);

    numTimepoints = size(data,2);

    if (numTimepoints ~= globalTimepoints)
        % throw error

    end


    numPoints = size(data,1);

    reset = true;

    finalValues = zeros(1,numTimepoints);

    min=0;

    if (numPoints >= 100)
        binNumber = 1;

        for i=1:numPoints
            
            if reset
                min = i;
                reset = false;
            end

    
            if ((i + 1) / numPoints) * 100 > binNumber

                valuesList = data{min:i,1:numTimepoints};

                if size(valuesList,1) > 1
                    finalValues = mean(valuesList);
    
                else
                    finalValues = valuesList;
                end
                finalResultsMatrix(binNumber,:,f) = finalValues;
                binNumber = binNumber + 1;
                reset = true;

            end

        end


    elseif (numPoints == 80)
        pointNumber = 1;
        for i=1:100
            if reset
                min = i;
                reset = false;
            end

    
            if ((i + 1) / 100) * numPoints > pointNumber

                finalValues = data{pointNumber,1:numTimepoints};

                for j = min:i
                    finalResultsMatrix(j,:,f) = finalValues;
                end

                pointNumber = pointNumber + 1;
                reset = true;

            end

        end


    else
        min = 1;
        binNumber = 1;

        for i=1:100
            while ((binNumber) / numPoints) * 100 <= i
                binNumber = binNumber + 1;
            end

            % Now set next min to current bin
            nextMin = binNumber;

            %Get values from set, not including current bin value
            valuesList = data{min:binNumber - 1,1:numTimepoints};

            if size(valuesList,1) > 1
                finalValues = mean(valuesList);

            else
                finalValues = valuesList;
            end
            
            finalResultsMatrix(i,:,f) = finalValues;
            min = nextMin;
    
        end

    end
end


%% For *all* cells calculate mean and standard error of intensity for each bin
% Create figure
f2=figure;
hold on;
% preallocate arrays
mb_y=zeros(100,1);
mb_x=zeros(100,1);
ste_y=zeros(100,1); %standard error of binned measurements

legendNames = strings(1,numTimepoints);
for t=1:numTimepoints
    legendNames(t) = string(t);
end

for t=1:numTimepoints
    for i=1:100 % for all cells in each bin...
        mb_y(i)=mean(finalResultsMatrix(i,t,:));
        mb_x(i)= i;
        ste_y(i)=std(finalResultsMatrix(i,t,:))/sqrt(length(finalResultsMatrix(i,1,:)));
    
      
    end

    % plot results
    % linesList(t) = errorbar(mb_x,mb_y,ste_y,'LineStyle',"none",'marker',".");
    % linesList(t) = shadedErrorBar(mb_x,mb_y,ste_y);
    colour = zeros(3,1);
    colour(1) = 1 - (t / numTimepoints);
    colour(2) = t / numTimepoints;
    colour(3) = sin((t/numTimepoints)*pi);
    line = shadedErrorBar(mb_x,mb_y,ste_y);
    line.mainLine.Color = colour;
    line.patch.FaceColor = colour;
    % name=string(t);
    % set (linesList(t), {'DisplayName'},{name});

    % save results to .csv file
    new_array=[mb_x,mb_y,ste_y];
    savename = strcat(sample, '/all_cells.csv');
    writematrix (new_array, savename);
end
hold off;

leg = legend(legendNames);
title(leg,"Time");
title("All Cells")
xlabel('Length along line') 
ylabel('Normalised intensity') 
    saveas(gcf, [sample '/All_Cells_plot.pdf']);



