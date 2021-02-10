function voxelID = ConvertMNItoVoxelID(xMNI, yMNI, zMNI, strProjectRoot)

    
    load(sprintf('%sMRI_T1/%s/template_grid.mat', strProjectRoot, getHeadModelsFolderName())); % loads 'template_grid'
    voxelID = -1;
    
    for iRow = 1:size(template_grid.pos,1)
        
        if template_grid.pos(iRow,1)==xMNI && ...
           template_grid.pos(iRow,2)==yMNI && ...
           template_grid.pos(iRow,3)==zMNI
        
           voxelID = iRow;
           
        end
        
    end

end