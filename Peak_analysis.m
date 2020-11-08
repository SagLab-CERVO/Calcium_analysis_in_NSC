
%% ajust the contrast of the image
figure(4)
imshow(max(I_Green,[],3),[])
text(10,10,'Gcamp Cells Maximum Projection', 'color','w')
% %
% Rescale image
himc=imcontrast(4);
waitfor(msgbox(sprintf('Ajust contrast of the image and when it is done, exit the ''Adjust contrast'' window.')));
waitfor(himc)
I_Max2= getimage(4);
close(figure(4))
I_Max_Green = I_Max2.* 255;
I_Max_Green2 =I_Max2/mean(mean(I_Max2));
I_Max_Green3 = gray2ind(I_Max_Green);
imwrite(I_Max2,[FileName(1:end-4) '_Green_MaxProjection.tif'],'tif','Compression','none')

 
%%  Select the ROI where only one green cell is visible         

choice = 'No';
while strcmp(choice,'No')
    f=figure(5);
    set(5,'Name','Define Green Cells')
    set(5, 'menubar', 'figure' )
    hh = uicontrol('String','Done','Position',[20 20 100 30],...
        'Callback', 'set(gcbf, ''Name'',''.'')'); %Done button 
    I_toplot = round(I_Max_Green);
    [Gmap] = makecolormaps(I_toplot, 'Green');
    I_toplot_RGB= ind2rgb(I_toplot, Gmap);
    IRGB= I_toplot_RGB;
    BW_Green = zeros(size(IRGB,1),size(IRGB,2));

    imshow(IRGB);
    text(10,15,'Select Green Cells','color', 'w')
    h = imfreehand(gca); %Draw
    api = iptgetapi(h);
    position= api.getPosition(); %get position of the drawing 
    BW = poly2mask(position(:,1), position(:,2), size(IRGB,1), size(IRGB,2));
    BW_Green = im2bw(BW_Green + BW,0); 
    BWRGB = ind2rgb(BW,[0 0 0 ; 0.5 0.5 0.5]);
    IRGB = IRGB + BWRGB; %add the drawing to the image of the cell
    data = get(hh, 'Value'); %look of 'Done' was pressed
    waitfor(f, 'Name'); %wait for 'Done' to be push
    choice = questdlg('Is this correct ?', ...
    '', ...
    'Yes','No','Yes');
end
close(f)   
imwrite(uint8(BW_Green),[FileName(1:end-4) '_BW_Green.tif'],'tif','Compression','none') %save


%% choose the background (possible to choose more than one ROI, but only one at a time)

 choice = 'Trace this ROI again';
 b=1;
 waitfor(msgbox(sprintf('Select a ROI for the background. If you want to draw an other ROI, press "Done" and then, press "Trace another ROI". ' )));
while true 
    if strcmp(choice,'Trace another ROI')
        if b == 1
            section1 = BW_Bckg; 
        end
    b=b+1; %counting how many background there is, excluding the ones that were traced again 
    
    end
    
    f=figure(5);
    set(5,'Name','Define Background')
    hh = uicontrol('String','Done/Trace another ROI','Position',[20 20 150 30],...
        'Callback', 'set(gcbf, ''Name'',''.'')'); %Done press button 
    if b == 1
    BW_Bckg = zeros(size(IRGB,1),size(IRGB,2));
    end
    imshow(IRGB);
    text(10,15,'Select Background','color', 'w')
    h = imfreehand(gca); %draw the ROI
    api = iptgetapi(h); 
    position = api.getPosition(); % get the position of the ROI
    BW = poly2mask(position(:,1), position(:,2), size(IRGB,1), size(IRGB,2)); 
    BW_Bckg = im2bw(BW_Bckg + BW,0); %add the drawing to the image of the cell
    BWRGB = ind2rgb(BW,[0 0 0 ; 0.5 0.5 0.5]);

    %mean the value
    BW11 = bwlabel(BW_Bckg);
    all_meanBCKG_Green=[];
    for i=1:frames
        stats = regionprops(BW11,I_Green(:,:,i),'MeanIntensity'); %mean intensity of the ROI
        meanBCKG=[];
        for j=1:numel(stats)
            meanBCKG(j)  = stats(j).MeanIntensity; %get value of mean intensity for every stack
        end
        all_meanBCKG_Green(i,:) = [i,mean(meanBCKG)];
    end 
    
    data = get(hh, 'Value');
    waitfor(f, 'Name');
    choice = questdlg('Do you want to ?', ...
        '', ...
        'Trace another ROI','Trace this ROI again','Finish','Finish');
    close(5)
    if strcmp(choice,'Finish')
        IRGB = IRGB + BWRGB;
        break
    elseif strcmp(choice,'Trace this ROI again')
        position=[];
    else
        IRGB = IRGB + BWRGB;
        continue
    end
end

imwrite(uint8(BW_Bckg),[FileName(1:end-4) '_Mask_BCKG.tif'],'tif','Compression','none')

%give one mean value per stack, witch means that the mean value for every ROI is calculated

%% Calculate de biggest peak of the background

 BW_section1 = bwlabel(section1);

    for i = 1 : frames
    stats_section1 = regionprops(BW_section1,I_Green(:,:,i),'MeanIntensity');
        if i == 1
            intensity_section1  = stats_section1.MeanIntensity;
        else
            intensity_section1 = [intensity_section1 ; stats_section1.MeanIntensity];
        end
    intensity_section1(i,1) = ( intensity_section1(i,1) - all_meanBCKG_Green(i,2) ) ./ all_meanBCKG_Green(i,2) .*100 ; 
    end
[pks_section1,locs_section1] = findpeaks(intensity_section1);

threshold = max(pks_section1);

%% Soma Calcium
global cst

    cst = 2; 
    BW_Green_Only = im2bw(imread([FileName(1:end-4) '_BW_Green.tif']),0);
    BW1 = bwlabel(BW_Green_Only);
    all_mean_Green=[];
    for i=1:size(I_Green,3)
        stats = regionprops(BW1,I_Green(:,:,i),'MeanIntensity','Centroid'); %mean intensity of the ROI
        meanGreen=[];
        for j=1:numel(stats)
            %centroid of the ROI, 1 line, 1 to 81, mean intensity of the ROI and 0 line.
            meanGreen(j,:)  = [stats(j).Centroid(1) stats(j).Centroid(2) i j stats(j).MeanIntensity 0 ]; 
        end
        all_mean_Green=[all_mean_Green ; meanGreen]; %vector with the value for all the stacks
    end
    Calcium_Green = sortrows(all_mean_Green,4); 
    % Remove BCKG
    for i=1:size(I_Green,3) %mean_intensity-mean_background for each acquisition
        Calcium_Green(Calcium_Green(:,3)==i,6) = Calcium_Green(Calcium_Green(:,3)==i,5) - all_meanBCKG_Green(i,2);
    end
    save([FileName(1:end-4) '_Calcium_Green.txt'],'Calcium_Green','-ascii')


%% Display and Decision
I_toplot = round(I_Max_Green);
[Gmap] = makecolormaps(I_toplot, 'Green');
I_toplot_RGB= ind2rgb(I_toplot, Gmap);

%create a gui where you have the possibility to add/delete peak
%from the data and you can choose to save or discart the data. 

f=figure(5);
set(findobj(5),'Position',[ 10    57   379   413]);
pnl1 = uipanel('Position',[.05 .2 .9 .2]);
pnl2 = uipanel('Position',[.05 .64 .9 .2]);
DeletePeaksh = uicontrol('Style', 'togglebutton','String', 'Delete Peaks','Position', [250 282 70 50]);
addPeaksh = uicontrol('Style', 'togglebutton','String', 'Add Peaks','Position', [50 282 70 50]);
keeph = uicontrol('Style', 'togglebutton','String', 'Save data','Position', [250 104 70 50]);
discardh = uicontrol('Style', 'togglebutton','String', 'Discard data','Position', [50 104 70 50]);
uicontrol('Style', 'text','String', 'Keep ''n'' std over the mean','Position', [100 30 150 20]);
uicontrol('Style', 'text','String', 'Please select the action you want to do on this interface first. After, select the peak on the Figure(7).','Position', [10 350 350 50]);
uicontrol('Style', 'text','String', 'What do you want to do with the data ?','Position', [10 180 350 20]);
uicontrol('Style', 'text','String','n= ','Position', [130 10 50 20]);
%Here to change std over the mean; change the string value.
nvalueh = uicontrol('Style', 'edit','String',cst,'Position', [170 12 20 20]);


BW_lbl = bwlabel(BW_Green_Only);
i=1;
y=0;
keepers = [];
analysis_round=1;
while i<=max(Calcium_Green(:,4)) %i<=1
    y=y+1;
    % Display cell in yellow on overlay
    BW_Green_Region = (BW_lbl==i);
    BW_Green_Region_RGB= ind2rgb(BW_Green_Region, [0 0 0 ; 1 1 0]);
    figure(10)
    imshow(I_toplot_RGB+BW_Green_Region_RGB,[]) 
    set(10,'Position',[11   543   672   420])
    text(10,10,'Green Only Cells','color','w')
    text(10,35,['Cells' num2str(i) '/' num2str(max(Calcium_Green(:,4)))],'color','w')

    coordinates = Calcium_Green(Calcium_Green(:,4)==i,1:2);

    %create the stack serie to display with f_StackDisplay_1Channel_3D
       Roi =[];
    for j=1:size(I_Green,3)
        Roi(:,:,j)=II(:,:,j);
    end

    %display the stacks of a gui 
    f_StackDisplay_1Channel_3D('Green and Red Cells',Roi)
    set(findobj('name','Green and Red Cells'),'Position',[987    55   560   418])

    %create a matrix where the intensity is a %
    ided_GCamp = Calcium_Green(Calcium_Green(:,4)==i,[3 5]);
    
    for l = 1 : frames
        ided_GCamp(l,2) = ( Calcium_Green(l,5) - all_meanBCKG_Green(l,2) ) ./ all_meanBCKG_Green(l,2) .*100 ; 
    end

    %plot the intensity for every stack 
    figure(6)
    set(6,'Position',[702   544   560   420])
    hold on
    plot(ided_GCamp(:,2),'k')
    hold off

    % Define Selection parameters  
    ided_GCamp_Values = ided_GCamp(imcomplement(isnan(ided_GCamp(:,2))),:);
    Baseline = ided_GCamp_Values(:,2);
    mean_GCaMP = mean(Baseline);
    std_GCaMP = std(Baseline);
    minthres = mean_GCaMP  + str2double(get(nvalueh,'String'))*std_GCaMP;

    if y == 1 %all the constants won't change if peaks are deleted or added. 
        if minthres > threshold
            [pks,locs] = findpeaks(ided_GCamp(:,2),'MINPEAKHEIGHT',minthres); %find peaks that are bigger than 2 std
        else 
            [pks,locs] = findpeaks(ided_GCamp(:,2),'MINPEAKHEIGHT',threshold);
        end
        ided_GCamp2=ided_GCamp;
    
    
    if isempty(pks)
    figure(7) %make add/delete peaks appear/disappear
    hold on
    %show the mean_intensity of calcium (%) for each stack
    plot(ided_GCamp(:,2),'g')
    A=ones(size(I_Green,3));
    %mean intensity 
    plot(A(1,:).*mean_GCaMP,'k--')
    %first std
    plot(A(1,:)*minthres,'r--')
    %peak of background
    plot(A(1,:)*threshold,'b--')
    legend({'GCamp','Mean GCamp','std'})
    
    keepCell = Calcium_Green(Calcium_Green(:,4)==i,:);
    size(locs,1);
    freq = size(locs,1)./j; % events per frame infocus=> j
    keeper = [keepCell(1,[1:2 4]) freq ];
    keepers = [keepers ; keeper];
    analysis_round=1;
    set(keeph,'Value',0)
    saveas(7,[FileName(1:end-4) '_GreenCell_' num2str(i) '.pdf' ],'pdf')
    break
    end
    
    %delete the peaks that were found just above from the data to calculate an other std. 
    for k = 1 : size(locs,1)
        a(k,1)=locs(k,1); %get the x position of the k peak 
        b(k,1)=locs(k,1); %get the x position of the k peak 
    while true 
        a(k,1)=a(k,1)+1; %look at the next value
        %look the what is the x value when at least the half of the peak value is
        %reach again
        if k == 1
            break
        elseif k == frames
            break 
        end
        if a(k,1) == frames
            break
        elseif  ided_GCamp(a(k,1),2) <= (pks(k,1)-mean_GCaMP)/2+mean_GCaMP; 

            break
        else
            continue
        end    
    end
    while true 
        b(k,1)=b(k,1)-1; %look at the previous value
        %look the what is the x value when at least the half of the peak value is
        %reach again
        
        if k == 1
            break
        elseif k == frames
            break 
        end
        if b(k,1) == 1
            break
        elseif   ided_GCamp(b(k,1),2) <= (pks(k,1)-mean_GCaMP)/2+mean_GCaMP;

            break
        else 
            continue
        end     
    end
    ided_GCamp2(b(k,1):a(k,1),2)=NaN; %empty (NaN) the determined x values
    end 
    ided_GCamp3=ided_GCamp2(:,2); %NaN for the unwanted values
    ided_GCamp3(isnan(ided_GCamp3)) = []; %delete NaN value
    mean_GCaMP2=mean(ided_GCamp3); %mean value without the peaks that were found above
    std_GCaMP2=std(ided_GCamp3); %std without the peaks that were found above
    minthres2=mean_GCaMP2  + str2double(get(nvalueh,'String'))*std_GCaMP2; %new 2 std
    
    if minthres2 > threshold
        %find peaks that are bigger than the new 2 std
        [pks,locs] = findpeaks(ided_GCamp(:,2),'MINPEAKHEIGHT',minthres2); 
    else
        [pks,locs] = findpeaks(ided_GCamp(:,2),'MINPEAKHEIGHT',threshold);
    end
        %delete the peaks that were found just above from the data
    %to calculate an other std.
    ided_GCamp4=ided_GCamp;
    for kk = 1 : size(locs,1)
        aa(kk,1)=locs(kk,1); %get the x position of the k peak 
        bb(kk,1)=locs(kk,1); %get the x position of the k peak 
    while true 
        aa(kk,1)=aa(kk,1)+1; %look at the next value
        %look the what is the x value when at least the half of the peak value is
        %reach again
        if kk == 1
            break
        elseif kk == frames
            break 
        end
        if aa(kk,1) == frames
            break
        elseif  ided_GCamp(aa(kk,1),2) <= (pks(kk,1)-mean_GCaMP)/2+mean_GCaMP;

            break
        else 
            continue
        end    
    end
    while true 
        bb(kk,1)=bb(kk,1)-1; %look at the previous value
        %look the what is the x value when at least the half of the peak value is
        %reach again
        if kk == 1
            break
        elseif kk == frames
            break 
        end
        if bb(kk,1) == 1
            break
        elseif    ided_GCamp(bb(kk,1),2) <= (pks(kk,1)-mean_GCaMP)/2+mean_GCaMP;

            break
        else 
            continue
        end     
    end
    ided_GCamp4(bb(kk,1):aa(kk,1),2)=NaN; %empty (NaN) the determined x values
    end 
    
    ided_GCamp5=ided_GCamp4(:,2); %NaN for the unwanted values
    ided_GCamp5(isnan(ided_GCamp5)) = []; %delete NaN value
    mean_GCaMP4=mean(ided_GCamp5); %mean value without the peaks that were found above
    std_GCaMP4=std(ided_GCamp5); %std without the peaks that were found above
    minthres3=mean_GCaMP4  + str2double(get(nvalueh,'String'))*std_GCaMP4; % new new 2 std
    
    if minthres3 > threshold
    %find peaks that are bigger than the new 2 std
        [pks,locs] = findpeaks(ided_GCamp(:,2),'MINPEAKHEIGHT',minthres3); 
    else 
        [pks,locs] = findpeaks(ided_GCamp(:,2),'MINPEAKHEIGHT',threshold); 
    end
    end
    
    pks2 = [];  
    z=0;
       
    if y ~= 1
    close(figure(7))
    end
    
    figure(7) %make add/delete peaks appear/disappear
    hold on
    %show the mean_intensity of calcium (%) for each stack
    plot(ided_GCamp(:,2),'g')
    x = 1:size(I_Green,3);
    %peaks that were found with the first std and the peaks
    %that were found with the second std
    plot(x(locs),pks,'oc') 
    A=ones(size(I_Green,3));
    %mean intensity 
    plot(A(1,:).*mean_GCaMP,'k--')
    %first std
    plot(A(1,:)*minthres,'r--')
    %background peak 
    plot(A(1,:)*threshold,'b--')
    %show the mean_intensity of calcium (%) for each stack
    %without the first serie of peaks
    plot(ided_GCamp2(:,2),'y')
    %without the first and second serie of peaks
    plot(ided_GCamp4(:,2),'b')
    %second std
    plot(A(1,:)*minthres2,'r--')
    %third std
    plot(A(1,:)*minthres3,'r--')
    %forth std
    legend({'GCamp','peaks','Mean GCamp','std','without peaks'})
  
    % add/delete peak or save/discart data 
    while sum(get(keeph,'Value') |  get(discardh,'Value') | get(DeletePeaksh,'Value') | get(addPeaksh,'Value')) == 0
        i=1; 
        pause(0.2)
    end

   if get(DeletePeaksh,'Value')==1 %delete peak
        
        analysis_round=2;
        figure(7)
        [delete_x,delete_y] = ginput(1);
        
        [d,index] = min(abs(pks-delete_y));
        closestValues = pks(index); 
        delete_pks = closestValues; 
        loc_correspond_to_peak = locs(index,1);
        loc_position = round(delete_x);
        
        if loc_correspond_to_peak == loc_position
           pks(index,1) = 0;
           pks = pks(pks>0);
           locs(index,1) = 0;
           locs = locs(locs>0);
        else
            continue
        end

        set(DeletePeaksh,'Value',0)
        count_delete = count_delete + 1;
        com_delete = [];
        user_com = questdlg ('Do you want to add a comment?','Add comment','Yes','No','No');
        switch user_com
            case 'Yes'
                in = inputdlg('Enter you comment');
                comment_delete{count_delete} = [in delete_x];
            case 'No'
                count_delete = count_delete - 1;
        end
    end

    if get(addPeaksh,'Value')==1 %add peak
        analysis_round=2;
        figure(7)
        [Add_x,Add_y] = ginput(1);
        try
            locs = [locs ;ided_GCamp_Values(ided_GCamp_Values(:,1)==round(Add_x),1)];
            pks = [pks ; ided_GCamp_Values(ided_GCamp_Values(:,1)==round(Add_x),2)];
        catch ME
        end
        set(addPeaksh,'Value',0)
        count_add = count_add + 1;
        com_add = [];
        user_com = questdlg ('Do you want to add a comment?','Add comment','Yes','No','No');
        switch user_com
            case 'Yes'
                in = inputdlg('Enter you comment');
                comment_add{count_add} = [in Add_x];
            case 'No'
                count_add = count_add - 1;
        end
    end


    if get(keeph,'Value')==1 %save data
        keepCell = Calcium_Green(Calcium_Green(:,4)==i,:);
        size(locs,1);
        freq = size(locs,1)./j; % events per frame infocus=> j
        keeper = [keepCell(1,[1:2 4]) freq ];
        keepers = [keepers ; keeper];
        analysis_round=1;
        set(keeph,'Value',0)
        saveas(7,[FileName(1:end-4) '_GreenCell_' num2str(i) '.pdf' ],'pdf')
        i=i+1;
        break
    end
    if get(discardh,'Value')==1 %discard data 
        set(discardh,'Value',0)
        analysis_round=1;
        disp('Trashed')
        i=i+1;
    end 

end

if exist([FileName(1:end-4) '_Final_Cells.xls']) == 2;
    delete([FileName(1:end-4) '_Final_Cells.xls']);
end

close(figure(2))
close(figure(3))
try close(10); catch ME ; end
try close(1); catch ME ; end
try close(5); catch ME ; end
try close(findobj('name','Green Cells')); catch ME ; end
try close(findobj('Name','Cell Analysis')); catch ME ; end


%% Stats 
xx = inputdlg('Enter the elapsed time per frame(sec)'); %ask frame rate to user 
data2 = str2num(xx{1}); %get frame rate from user 
data3 = data2 * frames ; 
Number_response = size(pks,1); %number of peaks found
% mean intensity of peaks minus mean intensity of signal without the peaks

close(figure(6))
figure(6)
time = 0:1:(frames-1);
time2 = time*data2;
set(6,'Position',[702   544   560   420])
hold on
plot(time2, ided_GCamp(:,2),'k')
hold off
saveas(6,[FileName(1:end-4) '_Black_graph_' num2str(i) '.pdf' ],'pdf')

if isempty(pks)
figure(8) %make add/delete peaks appear/disappear
hold on
%show the mean_intensity of calcium (%) for each stack
plot(time,ided_GCamp(:,2),'k')
A=ones((size(time,2)-1)/2);
%first std
plot(A(1,:)*minthres,'k--')
legend({'GCamp','std'})
saveas(8,[FileName(1:end-4) '_GreenCell_' num2str(i) '.pdf' ],'pdf')
    
else
Mean_intensity_peaks = (mean(pks) - mean_GCaMP4) / abs(mean_GCaMP4) 
Frequency_response_per_sec = Number_response/(data3-data2)
figure(8) %make add/delete peaks appear/disappear
hold on
%show the mean_intensity of calcium (%) for each stack
plot(ided_GCamp(:,2),'k')
x = 1:size(I_Green,3);
%peaks that were found with the first std and the peaks
%that were found with the second std
plot(x(locs),pks,'ok') 
A=ones(size(I_Green,3));
%first std
plot(A(1,:)*minthres,'k--')
%second std
plot(A(1,:)*minthres2,'k--')
%third std
plot(A(1,:)*minthres3,'k--')
legend({'GCamp','peaks','std'})
saveas(8,[FileName(1:end-4) '_GreenCell_' num2str(i) '.pdf' ],'pdf')
%Save the two previous datas in excel file
Mean_and_Freq_values = {'Mean inensity peaks','Frequency';Mean_intensity_peaks,Frequency_response_per_sec};
xlswrite([FileName(1:end-4) '_Datas' '.xls'],Mean_and_Freq_values)
%Save the workspace for other modifications
save([FileName(1:end-4) '_workspace'])
end