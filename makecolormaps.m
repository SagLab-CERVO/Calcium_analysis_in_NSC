%makecolormap : est une fonction autoscale qui creer une map commencant
%a l'intensite minimum de l'image jusqu'au maximum. On peut choisir la 
%couleur avec 'Green' ou 'Red' ou 'Trans' pour une image en lumiere transmise 
%en grayscale.
%S. Labrecque 2007-07-24.

function [map] = makecolormaps(I, mapcolor)

if isequal(mapcolor,'Green') == 1 
        mapGreen=[];
        maxImage=double(max(max(I)));        
        mapGreen=zeros(maxImage+1,3);
        mapGreen(:,2)=[0:(1/maxImage):1];
        map= mapGreen;
end

if isequal(mapcolor,'Trans') == 1 
        mapTrans=[];
        maxImage=double(max(max(I)));        
        mapTrans=zeros(maxImage+1,3);
        mapTrans(:,1)=[0:(1/maxImage):1];
        mapTrans(:,2)=[0:(1/maxImage):1]; 
        mapTrans(:,3)=[0:(1/maxImage):1]; 
        map = mapTrans;
end

if isequal(mapcolor,'Red') == 1
        mapRed=[];
        maxImage=double(max(max(I)));        
        mapRed=zeros(maxImage+1,3);
        mapRed(:,1)=[0:(1/maxImage):1];
        map = mapRed;
end    

if isequal(mapcolor,'Blue') == 1
        mapBlue=[];
        maxImage=double(max(max(I)));        
        mapBlue=zeros(maxImage+1,3);
        mapBlue(:,3)=[0:(1/maxImage):1]; 
        map = mapBlue;
end    

if isequal(mapcolor,'Yellow') == 1
        mapYellow=[];
        maxImage=double(max(max(I)));        
        mapYellow=zeros(maxImage+1,3);
        mapYellow(:,1)=[0:(1/maxImage):1]; 
        mapYellow(:,2)=[0:(1/maxImage):1];
        map =  mapYellow;
end

if isequal(mapcolor,'Cyan') == 1
        mapCyan=[];
        maxImage=double(max(max(I)));        
        mapCyan=zeros(maxImage+1,3);
        mapCyan(:,2)=[0:(1/maxImage):1]; 
        mapCyan(:,3)=[0:(1/maxImage):1];
        map =  mapCyan;
end





end