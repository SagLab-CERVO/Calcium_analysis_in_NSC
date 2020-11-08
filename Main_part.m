close all, clear all, warning('off')
%% Load image
[FileName,PathName] = uigetfile('*.tif','Select the Movie file');
cd(PathName)
info = imfinfo(FileName);
II=[];
 for i=1:numel(info)
     II(:,:,i) = imread(FileName,i);
 end

 
I_Green=[];
for i=1:numel(info)
    I_Green(:,:,i) = II(:,:,i);
end
frames = size(I_Green,3);
%-----------------------Main part----------------------------

%% Load existing workspace if one is find
global cst
if exist([FileName(1:end-4) '_workspace.mat'], 'file')
    load([FileName(1:end-4) '_workspace']);
    Choose_section = questdlg('What would you like to modify ?', ...
	'Correct data','Remove/Add peaks','Change background/soma zone','Cancel','Cancel');
    switch Choose_section
        case 'Remove/Add peaks'
            Correction = 0;
        case 'Change background/soma zone'
            Correction = 1;
        case 'Cancel'
            Correction = 2;
    end
    
    if Correction == 2% Cancel case
        return        
    end
    
    if Correction == 0 % Remove/Add peaks case   
        
        run Change_peaks
    end  
    if Correction == 1 % Change soma/background case
        choice = questdlg('Which zone would you like to change ?', ...
        'Change soma/background zone','Soma','Background','Cancel','Cancel');

        switch choice
            case 'Cancel'
                Change_sb = 0;
            case 'Soma'
                Change_sb = 1;
            case 'Background'
                Change_sb = 2;
        end

        if Change_sb == 0 % Cancel case
            return
        end
        if Change_sb == 1 % Soma case
            run Change_soma
            return
        end
        if Change_sb == 2 % Background case
            run Change_background
            return
        end

    end    
       
else
    count_add = 0;
    count_delete = 0;
    run Peak_analysis
end



