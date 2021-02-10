  function SourceLocalization(iFreq, strConditionPrefix, dbAlpha, dbClusterAlpha, bLaTeXOutput, strOutputFolderSuffix)
  
    % Finds all local maxima of the statistics created by ft_sourcestatistics
    % and looks up the corresponding labels in an atlas.
    % .stat and .mask are required as input data.
    %
    % Output .csv file contains a table with following columns:
    % t-value, Voxel index, X index, Y index, Z index, X-MNI [mm], Y-MNI [mm], Z-MNI [mm], Labels found
    %           
    % Note that subfunction TransformCoordinates(i, j, k) is based on a
    % standard MNI template, does not work in subject space!
    %
    % This script requires cell2csv.m (provided by Sylvain Fiedler) for CSV export of
    % resulting cell array.
        
    % save as LaTeX table
    % bLaTeXOutput = true 
    
    % sasve as csv file for Excel
    % bLaTeXOutput = false;
        
    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();
    SetFSLAndLaTeXPaths();
    
    iArrowDirection = 0; % left and right arrow trials
    iStrategy = 0; % all subjects
    iTail = 0; % two-tailed stats
    
    % get actual MEG dataset names
    vsConditions = GetConditionList();

    % input file path for statistics results       
    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);
    
    strBeamformerResultsFolder = GetBeamformerFolder(iArrowDirection, iStrategy);
    
    strFreqRange = sprintf('%d-%dHz', freqRange(1), freqRange(2));
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));
    strDir = sprintf('%s%s/%s/%s/Statistics%s/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval, strFreqRange, strOutputFolderSuffix);
    strReportPath = sprintf('%sFigures/SourceReconstruction/%s/%s/%s/Reports%s/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval,strFreqRange, strOutputFolderSuffix);
    if ~exist(strReportPath)
        mkdir(strReportPath);
    end
    
    strFileName = sprintf('%s-a-%.3f-clusta-%.5f-tail-%d.mat', strConditionPrefix, dbAlpha, dbClusterAlpha, iTail);
    strFilePath = strcat(strDir, strFileName);

    try
        load(strFilePath); % loads variable 'SourceStat'
        disp(strFileName);
    catch
        strMessage = sprintf('Could not load file %s', strFilePath);
        disp(strMessage);
        return;
    end
        
    SourceStat.stat = reshape(SourceStat.stat, SourceStat.dim(1), SourceStat.dim(2), SourceStat.dim(3));
    SourceStat.mask = reshape(SourceStat.mask, SourceStat.dim(1), SourceStat.dim(2), SourceStat.dim(3));
    
    % find local maximal around nearest neighbours (26 around one voxel)
    iNumNeighbourLayers = 1; 
    
    load(sprintf('%sMRI_T1/CompareInwardShifts.mat', strProjectRoot));
    SourceStat.mask = ApplyInwardshiftToMask(SourceStat, template_grid_negInw10);
    
    [ voxelListDist ] = FindLocalMaxima(SourceStat.stat, SourceStat.mask, SourceStat.pos, SourceStat.dim, iNumNeighbourLayers);

    if isempty(voxelListDist)
        strMessage = sprintf('Could not find signficant local extrema in file %s', strFilePath);
        disp(strMessage);

        strItemizedResults = sprintf('\t\t\\item {\\it Could not find signficant local extrema.}\n');
        labelledVoxelList = {};
        labelledVoxelList{1,1} = 0;
        labelledVoxelList{1,2} = 0;
        labelledVoxelList{1,3} = 0;
        labelledVoxelList{1,4} = 0;
        labelledVoxelList{1,5} = 0;
        labelledVoxelList{1,6} = '---';
        labelledVoxelList{1,7} = '---';
        labelledVoxelList{1,8} = '---';
        labelledVoxelList{1,9} = strItemizedResults;              
    else
        sortedVoxelList = sortrows(voxelListDist,-1); % sort descending after t-value
        labelledVoxelList = GetLabels( sortedVoxelList, bLaTeXOutput );

    end   

    if bLaTeXOutput
        strFileNameParameters = sprintf('%s-a-%.3f-clusta-%.5f-tail-%d', strConditionPrefix, dbAlpha, dbClusterAlpha, iTail);
        strFileNameParameters = strrep(strFileNameParameters, '0.', '0p');
        strReportFilePath = sprintf('%sAtlasReport-%s.tex', strReportPath, strFileNameParameters);
        ExportToTeX(labelledVoxelList, strReportFilePath, strConditionPrefix);
    else
        % save as .csv file, which can be opened with Excel etc.
        strReportFilePath = sprintf('%sAtlasReport-%s-a-%.3f-clusta-%.5f-tail-%d.csv', strReportPath, strConditionPrefix, dbAlpha, dbClusterAlpha, iTail);
        cell2csv(strCSVReportFilePath, labelledVoxelList, ';', 2003, ',');
    end

end


function mask = ApplyInwardshiftToMask(SourceStat, templateGrid)

    [ iLength, jLength, kLength ] = size(SourceStat.mask);

    for i = 1:iLength
        for j = 1:jLength
            for k = 1:kLength
                
                if SourceStat.mask(i,j,k) == 1 % do not use values with zero mask
                    
                    iIndex = Coordinates3DToIndex1D(i, j, k, iLength, jLength, kLength);
                    xMNI = SourceStat.pos(iIndex,1);
                    yMNI = SourceStat.pos(iIndex,2);
                    zMNI = SourceStat.pos(iIndex,3);
                    
                    bIsInside = checkIfVoxelIsInsideBrain(xMNI, yMNI, zMNI, templateGrid);
                    
                    if ~bIsInside
                        SourceStat.mask(i,j,k) = 0;
                    end
                    
                end
            end
        end
    end
    
    %length(find(SourceStat.mask==0))
    mask = SourceStat.mask;
end

function [bIsInside] = checkIfVoxelIsInsideBrain(xMNI, yMNI, zMNI, templateGrid)

    bIsInside = true;
    
    if zMNI >= 80 % out of MNI range
        bIsInside = false;
        return;
    end
    
    % allow one centimer tolerance and compensate for negative inward shift
    for x=[xMNI-10,xMNI,xMNI+10]
        for y=[yMNI-10,yMNI,yMNI+10]
            for z=[zMNI-10,zMNI,zMNI+10]
                    
                for iPos = 1:size(templateGrid.pos,1)
        
                    if templateGrid.pos(iPos,1) == x && templateGrid.pos(iPos,2) == y && templateGrid.pos(iPos,3) == z
                        if isempty(find(templateGrid.inside==iPos))
                            bIsInside = false;
                            break;
                        end
                    end
                    
                end
                
            end
        end
    end

end

function strLaTeXTable = ExportToTeX(vList, strFilePath, strConditionPrefix)

    strLaTeXTable = '';
    
    fileID = fopen( strFilePath, 'w' );

    fprintf(fileID, '%% !TEX root = Report-%s.tex \n\n', strConditionPrefix);
    
    % tabular header    
    fprintf(fileID, '\\scriptsize \n');
    fprintf(fileID, '\\tablehead{\n');
    fprintf(fileID, '\\toprule \n');
    fprintf(fileID, '\\multirow{2}{*}{{\\bf t value}} & \\multicolumn{3}{c}{\\quad {\\bf MNI}\\: [mm]} & \\multirow{2}{*}{{\\bf Voxel index, atlas info}} \\\\ \n');
    fprintf(fileID, '& {\\bf X} & {\\bf Y} & {\\bf Z} & \\\\ \n');
    fprintf(fileID, '\\midrule } \n');
    fprintf(fileID, '\\begin{supertabular}{rrrrP{8cm}} \n');

    for i = 1:size(vList,1) % loop through sources in voxel list
        % t-value, mni coordinates (X,Y,Z), voxel index, voxel indices (X,Y,Z)
        
        % format minus sign for TeX
        str_tValue = sprintf('%0.3f', vList{i,1});
        str_tValue = strrep(str_tValue,'-','--'); 
        strX = strrep(vList{i,6},'-','--'); 
        strY = strrep(vList{i,7},'-','--');
        strZ = strrep(vList{i,8},'-','--');
      
        if vList{i,2} > 0 % significant voxel was found
            
            if vList{i,1} >= 0
                fprintf(fileID, '\\textcolor{darkred}{%s}	& %s & %s & %s & \\textcolor{gray}{Voxel %d, matrix indices: %d, %d, %d} \\\\ \n', ...
                        str_tValue, strX, strY, strZ, vList{i,2}, vList{i,3}, vList{i,4}, vList{i,5} );
            else
                fprintf(fileID, '\\textcolor{darkblue}{%s}	& %s & %s & %s & \\textcolor{gray}{Voxel %d, matrix indices: %d, %d, %d} \\\\ \n', ...
                        str_tValue, strX, strY, strZ, vList{i,2}, vList{i,3}, vList{i,4}, vList{i,5} );
            end
        end
        
        fprintf(fileID, '& & & & \\begin{atlasresults} \n');
        
        fprintf(fileID, '%s', vList{i,9});
        
        fprintf(fileID, '\\end{atlasresults} \\\\ \n');
    end
       
    % tabular foot
    fprintf(fileID, '\\bottomrule \\end{supertabular} \\normalsize');
    
    disp(strFilePath);
    
    fclose(fileID);
    
end

function [ vsAtlases ] = SelectAtlases()

    % get complete list using 
    % ! atlasquery --dumpatlases
    vsAtlases = {       
        'Juelich Histological Atlas';
        %'Talairach Daemon Labels';
        'Harvard-Oxford Cortical Structural Atlas';
        %'Harvard-Oxford Cortical Structural Atlas (Lateralized)';
  %      'Harvard-Oxford Subcortical Structural Atlas';
%        'JHU ICBM-DTI-81 White-Matter Labels';
%        'JHU White-Matter Tractography Atlas';
%        'Oxford Thalamic Connectivity Probability Atlas';
%        'Oxford-Imanova Striatal Structural Atlas';
%         'MNI Structural Atlas';  
%        'Subthalamic Nucleus Atlas';
%       'Cerebellar Atlas in MNI152 space after normalization with FLIRT';
       %'Cerebellar Atlas in MNI152 space after normalization with FNIRT';
    }

    % ** slightly different percentage values and output order in comparison to FSlView GUI might occure
    % because atlasquery uses 2mm version, thus leading to different
    % interpolation
 
end


function [ iVoxelIndex ] = Coordinates3DToIndex1D(i, j, k, iLength, jLength, kLength)

    iVoxelIndex = (i-1) + (iLength)*(j-1) + (iLength)*(jLength)*(k-1) + 1; % is not zero-based!

    
end

function [ labelledVoxelList ] = GetLabels( sortedVoxelList, bLaTeXOutput )

    labelledVoxelList = [];
    iNumVoxels = size(sortedVoxelList,1);
    
    vsAtlases = SelectAtlases();
    
    if ~bLaTeXOutput
        labelledVoxelList = AddColumnLabels(labelledVoxelList);
    end

    for i = 1:iNumVoxels
        
       strX = num2str(sortedVoxelList(i,6));
       strY = num2str(sortedVoxelList(i,7));
       strZ = num2str(sortedVoxelList(i,8));
      
       labelledVoxelList{end+1,1} = sortedVoxelList(i,1); % t-value
       labelledVoxelList{end,2} = sortedVoxelList(i,2); % voxel index
       
       % voxel index
       labelledVoxelList{end,3} = sortedVoxelList(i,3);
       labelledVoxelList{end,4} = sortedVoxelList(i,4);
       labelledVoxelList{end,5} = sortedVoxelList(i,5);
       labelledVoxelList{end,6} = strX;
       labelledVoxelList{end,7} = strY;
       labelledVoxelList{end,8} = strZ;
    
       strMessage = sprintf('Lookup coordinates %d / %d [%s,%s,%s] ...', i, iNumVoxels, strX, strY, strZ);

       strItemizedResults = '';
       iNumLabelsFound = 0;
       for iAtlas = 1:size(vsAtlases,1)
            
            strLookupCommand = sprintf('atlasquery -a "%s" -c %s,%s,%s', vsAtlases{iAtlas,1}, strX, strY, strZ);

            disp(strMessage);
            [ iStatus, strResult ] = system(strLookupCommand); 
            
            if iStatus == 0
                
                strResult = CleanQueryOutput(strResult);
                
                iPos1 = strfind(strResult, 'No label found!');
                iPos2 = strfind(strResult, '*.*.*.*.*');
                iPos3 = strfind(strResult, 'Unclassified');
                iPos = [ iPos1, iPos2, iPos3 ];
                
                if isempty(iPos)
                    iNumLabelsFound = iNumLabelsFound + 1;
                else
                    strResult = 'No label found!';
                end
                
                if bLaTeXOutput
                    strResult = strrep(strResult,'%','\%');
                    strResult = strrep(strResult,',',', ');
                    strResult = strrep(strResult,'_','\_');

                    if iNumLabelsFound == 0
                        strItemizedResults = sprintf('\t\t\\item %s\n', strResult);
                    else
                        strItemizedResults = sprintf('%s\t\t\\item %s\n', strItemizedResults, strResult);
                    end
                    labelledVoxelList{end,9} = strItemizedResults;
                else                        
                    labelledVoxelList{end+1,9} = strResult;                       
                end
                
            else                
                strErrorMessage = sprintf('Atlas query error for command <%s>.\n', strLookupCommand);  
                disp(strErrorMessage);
            end
       end
        
       if bLaTeXOutput
            if strcmp(labelledVoxelList{end,9},'') || isempty(labelledVoxelList{end,9})
                strItemizedResults = sprintf('\t\t\\item {\\it No label found.}\n');
                labelledVoxelList{end,9} = strItemizedResults;
            end
       end
    end
    
    if ~bLaTeXOutput
        labelledVoxelList = CleanUpArray(labelledVoxelList);
    end
       
end

function [ cleanedCellArray ] = CleanUpArray(cellArray)

    % remove rows / voxels for which no label could be found in the atlas
    cleanedCellArray = cellArray;
    
    if size(cellArray,1) < 2
       return; 
    end

    iRow = size(cellArray,1);
    
    while iRow > 1
       
        strCurrentXVal = cellArray{iRow,2};
        
        if iRow == 2
            strPrevXVal = strCurrentXVal;
        else
            strPrevXVal = cellArray{iRow-1,2};
        end
                
        if length(strCurrentXVal) > 0 && length(strPrevXVal) > 0 && (iRow-1) > 1
            % remove row, because no label could be found!
            cleanedCellArray(iRow-1,:) = [];
        end
        
        iRow = iRow - 1;
    end

end

function [ labelledVoxelListWithHeaderRow ] = AddColumnLabels( labelledVoxelList )

    labelledVoxelListWithHeaderRow = labelledVoxelList;
    labelledVoxelListWithHeaderRow{1,1} = 't-value';
    labelledVoxelListWithHeaderRow{1,2} = 'Voxel index';
    labelledVoxelListWithHeaderRow{1,3} = 'X index';
    labelledVoxelListWithHeaderRow{1,4} = 'Y index';
    labelledVoxelListWithHeaderRow{1,5} = 'Z index';
    labelledVoxelListWithHeaderRow{1,6} = 'X-MNI [mm]';
    labelledVoxelListWithHeaderRow{1,7} = 'Y-MNI [mm]';
    labelledVoxelListWithHeaderRow{1,8} = 'Z-MNI [mm]';
    labelledVoxelListWithHeaderRow{1,9} = 'Labels found';

end



function [ strNewLabel ] = CleanQueryOutput( strQueryResult )

    % remove first line of query output
    % like '<b>Juelich Histological Atlas</b><br>'
    
    strNewLabel = strQueryResult;
    
    iPosEndHeadline = strfind(strQueryResult, '<br>');
    iLength = length(strQueryResult);
        
    % and remove last char (\n)
    if ~isempty(iPosEndHeadline) && iLength > 5
        strNewLabel = strQueryResult((iPosEndHeadline+4):(iLength-1));
    end
    
    % remove blanks after comma
    strNewLabel = strrep(strNewLabel,', ',',');

end


function [ voxelListDist ] = FindLocalMaxima(SourceStatVoxels, SourceMaskVoxels, pos, dim, iNumNeighbourLayers)

    [ iLength, jLength, kLength ] = size(SourceStatVoxels);

    voxelListDist = [];
         
    for i = 1:iLength
        for j = 1:jLength
            for k = 1:kLength
                
                if SourceMaskVoxels(i,j,k) == 1 % voxel must be significant
                    
                    if IsLocalMaximum(SourceStatVoxels, SourceMaskVoxels, i, j, k, iNumNeighbourLayers, iLength, jLength, kLength)
                        
                        voxelListDist(end+1,1) = SourceStatVoxels(i,j,k);
                        voxelListDist(end,2) = Coordinates3DToIndex1D(i, j, k, iLength, jLength, kLength);
                        [ xMNI yMNI zMNI ] = TransformCoordinates(i, j, k, pos, dim);
                        voxelListDist(end,3) = i;
                        voxelListDist(end,4) = j;
                        voxelListDist(end,5) = k;
                        voxelListDist(end,6) = xMNI;
                        voxelListDist(end,7) = yMNI;
                        voxelListDist(end,8) = zMNI;
                    end
                    
                end
                
            end
        end
    end 
end


function bRet = IsLocalMaximum(SourceStatVoxels, SourceMaskVoxels, i, j, k, iNumNeighbourLayers, iLength, jLength, kLength)

    bRet = false;
    dist = iNumNeighbourLayers;
    
    range_i = (i-dist):(i+dist);
    range_j = (j-dist):(j+dist);
    range_k = (k-dist):(k+dist);
    centerPos_i = dist + 1;
    centerPos_j = dist + 1;
    centerPos_k = dist + 1;
    
    if (i-dist) < 1 
        range_i = i:(i+dist);
        centerPos_i = 1;
    end
    
    if (j-dist) < 1 
        range_j = j:(j+dist);
        centerPos_j = 1;
    end
    
    if (k-dist) < 1 
        range_k = k:(k+dist);
        centerPos_k = 1;
    end
        
    if (i+dist) > iLength 
        range_i = (i-dist):iLength;
    end
    
    if (j+dist) > jLength 
       range_j = (j-dist):jLength;
    end
    
    if (k+dist) > kLength 
        range_k = (k-dist):kLength;
    end
    
    % only take significant neighbours into account
    neighbourVoxels = SourceStatVoxels( range_i, range_j, range_k ) .* SourceMaskVoxels( range_i, range_j, range_k );
    
    % consider negative clusters
    neighbourVoxels = abs(neighbourVoxels);
    
    % get center pos of new, small matrix 'neighbourVoxels'
    centerPos = dist+1;
    
    % save center value
    tempCenter = neighbourVoxels(centerPos_i,centerPos_j,centerPos_k);
        
    % delete center value
    neighbourVoxels(centerPos_i,centerPos_j,centerPos_k) = NaN;
    
    maxNeighbours = max(max(max(neighbourVoxels)));
    
    if tempCenter >= maxNeighbours && tempCenter > 0 % center has to be signficant itself
        bRet = true;
    end
end


function [ xMNI yMNI zMNI ] = TransformCoordinates(i, j, k, pos, dim)

    xgrid = 1:dim(1);
    ygrid = 1:dim(2);
    zgrid = 1:dim(3);
    [x y z] = ndgrid(xgrid, ygrid, zgrid);
    ind = [x(:) y(:) z(:)];    % these are the positions expressed in voxel indices along each of the three axes
    % represent the positions in a manner that is compatible with the homogeneous matrix multiplication,
    % i.e. pos = H * ind
    ind = ind'; ind(4,:) = 1;
    pos = pos'; pos(4,:) = 1;
    % recompute the homogeneous transformation matrix
    transform = pos / ind;

    xMNI = i * transform(1,1) + transform(1,4);
    yMNI = j * transform(2,2) + transform(2,4);
    zMNI = k * transform(3,3) + transform(3,4);
    
    xMNI  = round(xMNI);
    yMNI  = round(yMNI);
    zMNI  = round(zMNI);

end





























