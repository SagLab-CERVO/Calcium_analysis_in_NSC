function f_StackDisplay_1Channel_3D(name,I)
%  % I is 3D I(:,:,:)...
% name = 'grr'
% I= I_Green;
% I2= I_Red;
%  
 %%
if size(findobj('name',name),1) == 1
    close(findobj('name',name))
end
hI = figure('name',name);
uicontrol('Style', 'slider','Value',1,...
    'Position', [35 10 250 20], 'tag', [name 'DisplayStack'],...
    'Min',1,'Max',size(I,3),'SliderStep',[1/size(I,3) 1/size(I,3)],'Callback',@imshowI);
uicontrol('Style', 'text','Position', [10 10 20 20],'tag',[name 'DisplayTxt'],...
    'String',num2str(get(findobj('tag',[name 'DisplayStack']),'Value')))
uicontrol('Style', 'text','Position', [300 10 60 20],...
    'String','AutoScale')
uicontrol('Style', 'checkbox','Position', [365 10 20 20],...
    'tag',[name 'Chkbx'],'Value',0)
%Play button
uicontrol('Style', 'togglebutton','Position', [10 35 50 50],...
    'tag',[name 'Play'],'Value',0, 'String', 'Play','Callback',@imshowI)

axesh = axes('parent',findobj('name',name),'tag',[name 'Axes'],'position',[0.05  .25  .45  .45]);
image = imshow(I(:,:,1),'InitialMagnification', 'fit', 'parent', axesh);
caxis auto
% axesh2 = axes('parent',findobj('name',name),'tag',[name 'Axes'],'position',[.501  .25  .45  .45]);
% image2 = imshow(I2(:,:,1),'InitialMagnification', 'fit', 'parent', axesh2);
% caxis auto

% FPS
uicontrol('Style', 'text','Position', [390 10 60 30],...
    'String','Video Speed')
uicontrol('Style', 'edit','Position', [455 10 30 20],...
    'tag',[name 'VideoSpeed'],'String', '0.1')


%%
    
    function imshowI(hI,evendata)
        
        switch get(findobj('tag',[name 'Play']),'Value')
            case 0
               if  get(findobj('tag',[name 'Chkbx']),'Value') == 1 % doit tester...
                   caxis auto
               else
                   caxis manual
               end
               frame = round(get(findobj('tag',[name 'DisplayStack']),'Value'));
               set(findobj('tag',[name 'DisplayTxt']),'String',num2str(frame))
               set(image,'CData',I(:,:,frame));
               %set(image2,'CData',I2(:,:,frame));
            case 1
               if  get(findobj('tag',[name 'Chkbx']),'Value') == 1 % doit tester...
                   caxis auto
               else
                   caxis manual
               end
               
               frame = round(get(findobj('tag',[name 'DisplayStack']),'Value'));
               while get(findobj('tag',[name 'Play']),'Value') == 1
                   if frame == size(I,3)
                       frame = 1;
                   end
                   set(findobj('tag',[name 'DisplayStack']),'Value',frame)
                   set(findobj('tag',[name 'DisplayTxt']),'String',num2str(frame))
                   set(image,'CData',I(:,:,frame));
%                    set(image2,'CData',I2(:,:,frame));
                   frame = frame +1;
                   pause(str2double(get(findobj('tag',[name 'VideoSpeed']),'String')))
                   drawnow
               end
                
        end
       
       

    end
end