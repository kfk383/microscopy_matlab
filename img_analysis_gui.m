function varargout = img_analyis_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_analyis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @img_analyis_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%----------------------------------GLOBAL SET/GET----------------------------

function clear_vars
global objects scale_box scale_line scale position filename bw files index
clear objects scale_box scale_line scale position filename bw files index;

function clear_next_img
global objects scale_box scale_line scale position filename bw
clear objects scale_box scale_line scale position filename bw;

function set_files(val)
global files
files = val;

function r = get_files
global files
r = files;

function r = get_index
global index
r = index;

function set_index(val)
global index
index = val;

function r = get_image
global image
r = image;

function set_filename(val)
global filename
filename = val;

function r = get_filename 
global filename
r = filename;

function set_image(img)
global image
image = img;

function set_bw(img)
global bw
bw = img;

function r = get_bw
global bw
r = bw;

function add_object(obj)
global objects
objects = [objects, obj];

function undo_object
global objects
if not(isempty(objects))
    objects(end) = [];
end

function set_scale_box(val)
global scale_box
scale_box = val;

function r = get_scale_box
global scale_box;
r = scale_box;

function r = get_objects
global objects
r = objects;

function r = get_scale_line
global scale_line
r = scale_line;

function set_scale_line(val)
global scale_line
scale_line = val;

function set_scale(val)
global scale
scale = val;

function r = get_scale
global scale
r = scale;

function set_mode(val)
global mode
mode = val;

function r = get_mode
global mode
r = mode;

function set_position(val)
global position
position = val;

function r = get_position
global position
r = position;

% This is used to update the table element in the GUI. This will be called
% on demand in the program to display a size distribution summary of the 
% objects within the most recently free drawn shape in step 3 of the
% program. 
function update_summary(handles)
object = get_objects;
if (size(object) > 0)
    BW2 = get_bw;
    shape = object(end);
    bin0 = imcomplement(createMask(shape,BW2));
    BW2 = BW2 - bin0;
    cc = bwconncomp(get_bw);
    L = bwlabel(get_bw);
    NL = cc.NumObjects;
    for i=1:NL
        Obj = (L==i);
        Area(i) = regionprops(Obj,'Area') ;
    end
    Area_um = struct2array(Area);
    position = get_position;
    distx = (position(1,1) - position(2,1))^2;
    disty = (position(1,2) - position(2,2))^2;
    distance = (distx + disty)^(1/2);
    pixel_to_um = distance / get_scale;
    
    for i=1:max(size(Area_um))
        conv_area = Area_um(i) / (pixel_to_um)^2;
        Area_um(i) = conv_area;
    end
    set(handles.summary, 'data', transpose(Area_um));
end

% These are the guts of mode 2. It prompts the users to drag draw a line
% and a rectangle, after inputting the scale. These are stored in global 
% variables, and the position of the line is saved for area conversions
% from units of pixels to the desired um scale that the user set. 
function mode2(handles)
set(handles.currstep, 'String', 'Proceed with step 2.');
axes(handles.axes1);
imshow(get_image);
if (not(isempty(get_scale)))
    line = drawline();
    box = drawrectangle();
    set_scale_box(box.Position());
    set_scale_line(line);
    set_position(line.Position())
end

% These are the guts of mode 3. It converts the image to a pure black and
% white image, and displays this on the axes. The callback functions for
% the Draw Rectangle and Free Draw buttons handle the drawing functions of 
% this mode.
function mode3(handles)
set(handles.currstep, 'String', 'Proceed with step 3.');
rgb = rgb2gray(get_image);
I = medfilt2(rgb);
BW = imbinarize(I,'adaptive','ForegroundPolarity','dark','Sensitivity',0.3);
BW2 = imcomplement(BW);
set_bw(BW2);
axes(handles.axes1);
imshow(BW2);

% These are the guts of mode 4. It takes into account the freedrawn objects
% of the previous mode, and excludes the convex hulls of these freedrawn 
% objects from the size distribution analysis. Then, the areas of each
% shape were taken, converted to the desired scale, and printed into a CSV 
% file in the current directory. 
function mode4(handles)
set(handles.currstep, 'String', 'Proceed with step 4.');
BW2 = get_bw;
objects = get_objects;
scale_box = get_scale_box;
x = [scale_box(1) scale_box(3)];
y = [scale_box(2) scale_box(4)];
b = poly2mask(x,y,size(BW2,1), size(BW2,2));
BW2 = BW2-b;
for i=1:size(objects)
    try
        bin0 = createMask(objects(i),BW2);
        BW2=BW2-bin0;
    catch
    end
end
set_bw(BW2);

cc = bwconncomp(get_bw);
L = bwlabel(get_bw);
NL = cc.NumObjects;
for i=1:NL
    Obj = (L==i);
    Area(i) = regionprops(Obj,'Area') ;
end
Area_um = struct2array(Area);
position = get_position;
distx = (position(1,1) - position(2,1))^2;
disty = (position(1,2) - position(2,2))^2;
distance = (distx + disty)^(1/2);
pixel_to_um = distance / get_scale;
fname = get_filename;
pd_index = strfind(fname, '.');
r = extractAfter(fname,pd_index);
fname = replace(fname,r,'csv');
fid = fopen(fname,'w');
for i=1:max(size(Area_um))
    conv_area = Area_um(i) / (pixel_to_um)^2;
    Area_um(i) = conv_area;
end
fprintf(fid,'%f\n', Area_um);

%----------------------------------OPENING/PRINT FUNCTIONS-----------------------

% --- Executes just before img_analyis_gui is made visible.
function img_analyis_gui_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = img_analyis_gui_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

%----------------------------------BUTTON PRESS CALLBACKS-----------------------

% --- Executes on button press in prevstep.
function prevstep_Callback(~, ~, handles)
m = get_mode;
if (isnan(m))
    set_mode(1)
    set(handles.currstep, 'String', 'Proceed with step 1.');
    fprintf('Step 1. \n')
    fprintf(' Please enter the name of the file you want to analyze, including the file extension. \n')
elseif (m == 3)
    set_mode(2)
    set(handles.currstep, 'String', 'Proceed with step 2.');
    fprintf('Went back to step 2. \n')
    fprintf(' Drag draw a line along the scale bar in the image. \n')
    mode2(handles);
elseif (m == 4)
    set_mode(3)
    set(handles.currstep, 'String', 'Proceed with step 3.');
    fprintf('Went back to step 3. \n')
    fprintf(' Use the drawing tools to outline portions you wish to exclude. \n')
    mode3(handles);
else
    set_mode(1)
    set(handles.currstep, 'String', 'Proceed with step 1.');
    fprintf('Went back to step 1. \n')
    fprintf(' Please enter the name of the file you want to analyze, including the file extension. \n')
end

% --- Executes on button press in nextstep.
function nextstep_Callback(~, ~, handles)
m = get_mode;
if (isnan(m))
    set_mode(1)
    set(handles.currstep, 'String', 'Proceed with step 1.');
    fprintf('Step 1. \n')
    fprintf(' Please select the file(s) you want to analyze. \n')
elseif (m == 1)
    set_mode(2)
    set(handles.currstep, 'String', 'Proceed with step 2.');
    fprintf('Progressed to step 2. \n')
    fprintf(' Enter the scale, then drag draw a line along the scale bar, and a rectangle on the scale box in the image. \n')
    mode2(handles);
elseif (m == 2)
    set_mode(3)
    set(handles.currstep, 'String', 'Proceed with step 3.');
    fprintf('Progressed to step 3. \n')
    fprintf(' Use the drawing tools to outline portions you wish to exclude. \n')
    mode3(handles);
elseif (m == 3) 
    set_mode(4)
    set(handles.currstep, 'String', 'Proceed with step 4.');
    fprintf('Progressed to step 4. \n')
    fprintf(' Image analysis complete. CSVs with obtained areas have been saved in your directory. The generated figure must be manually saved. \n')
    mode4(handles);
elseif (get_index < length(get_files))
    set_index(get_index + 1)
    set_mode(1)
    clear_next_img;
    file = get_files;
    file = string(file(get_index));
    set_filename(file);
    set_image(imread(get_filename));
    axes(handles.axes1);
    imshow(get_image);
    set_mode(2);
    set(handles.currstep, 'String', 'Proceed with step 2.');
    fprintf('Opened the next image file \n')
    fprintf('Progressed to step 2 on this image. \n')
    fprintf(' Enter the scale, then draw a line along the scale bar. Then, draw a rectangle over the scale box in the image. \n')
end

% --- Executes on button press in undo.
function undo_Callback(~, ~, handles)
if (get_mode == 3)
    obj = get_objects;
    obs = obj(get_index);
    if not(isempty(obs))
        del = obs(end);
        delete(del);
    end
    undo_object();
    update_summary(handles);
end

function openfile_Callback(~, ~, handles)
set_files([{}, uigetfile('*.*','MultiSelect','on')]);
file = get_files;
set_index(1);
file = string(file(get_index));
set_filename(file);
set_image(imread(get_filename));
axes(handles.axes1);
imshow(get_image);
set_mode(2);
set(handles.currstep, 'String', 'Proceed with step 2.');
fprintf('Opened image files \n');
fprintf('Progressed to step 2. \n');
fprintf(' Enter the scale, then draw a line along the scale bar. Then, draw a rectangle over the scale box in the image. \n')

function helpbutton_Callback(~, ~, ~)
help_screen

%----------------------------------DRAWING CALLBACKS-----------------------------

% --- Executes on button press in drawrect.
function drawrect_Callback(~, ~, handles)
if (get_mode == 3)
    h = drawrectangle();
    add_object(h);
    update_summary(handles);
end

% --- Executes on button press in freedraw.
function freedraw_Callback(~, ~, handles)
if (get_mode == 3)
    h = drawfreehand();
    add_object(h);
    update_summary(handles)
end

%----------------------------------TEXT BOX CALLBACKS-----------------------------

function scale_bar_Callback(hObject, ~, handles)
str = get(hObject,'String');
set_scale(str2double(str));
fprintf('Scale set to: ');
fprintf(num2str(get_scale));
fprintf('\n')
set_mode(2);
mode2(handles);
if (isnan(get_scale))
    warning('Invalid scale. Please ensure this is a number. Scale has been set to default value 1.')
    set_scale(1);
end

% --- Executes during object creation, after setting all properties.
function scale_bar_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function save_fig_ClickedCallback(~, ~, handles)
% hObject    handle to save_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = get_filename;
fig = figure;
copyobj(handles.axes1, fig);
