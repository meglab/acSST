function [ voxelIDs, viMNICoordAndLabels ] = GetVoxelList(strProjectRoot)

    voxelIDs = [];             

    viMNICoordAndLabels = { 
             50,  20,  20, 'rIFG',   'rIFG';    % 1            
              0,  20,  60, 'preSMA', 'preSMA';  % 2
            -50,  10,  20, 'lIFG',   'l-IFG';   % 3                          
            -20, -10,  60, 'lPMC',   'lPMC';    % 4 
             10, -10,  50, 'rPMC',   'rPMC';    % 5                       
            -40,   0,  50, 'lMFG',   'lMFG';    % 6
            -40,  30,   0, 'lAI',    'lAI';     % 7
           };
    
    for iCoord = 1:size(viMNICoordAndLabels,1)

        iVoxel = ConvertMNItoVoxelID( viMNICoordAndLabels{iCoord,1}, viMNICoordAndLabels{iCoord,2}, viMNICoordAndLabels{iCoord,3}, strProjectRoot);

        voxelIDs = [ voxelIDs iVoxel ];
        
    end

end
