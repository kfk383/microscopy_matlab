function varargout = img_analyis_gui(varargin)
% IMG_ANALYIS_GUI MATLAB code for img_analyis_gui.fig
%      IMG_ANALYIS_GUI, by itself, creates a new IMG_ANALYIS_GUI or raises the existing
%      singleton*.
%
%      H = IMG_ANALYIS_GUI returns the handle to a new IMG_ANALYIS_GUI or the handle to
%      the existing singleton*.
%
%      IMG_ANALYIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_ANALYIS_GUI.M with the given input arguments.
%
%      IMG_ANALYIS_GUI('Property','Value',...) creates a new IMG_ANALYIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before img_analyis_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to img_analyis_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help img_analyis_gui

% Last Modified by GUIDE v2.5 09-Apr-2019 11:06:07

% Begin initialization code - DO NOT EDIT
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
% End initialization code - DO NOT EDIT

%----------------------------------GLOBAL SET/GET----------------------------

function clear_vars
global objects scale_box scale_line scale position filename bw
clear objects scale_box scale_line scale position filename bw;

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
        bin0 = createMask(objects(i));
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
function img_analyis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_analyis_gui (see VARARGIN)

% Choose default command line output for img_analyis_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes img_analyis_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = img_analyis_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%----------------------------------BUTTON PRESS CALLBACKS-----------------------

% --- Executes on button press in prevstep.
function prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
m = get_mode;
if (isnan(m))
    set_mode(1)
    set(handles.currstep, 'String', 'Proceed with step 1.');
    fprintf('Step 1. \n')
    fprintf(' Please enter the name of the file you want to analyze, including the file extension. \n')
elseif (m == 3)
    set_mode(2)
    mode2(handles);
    set(handles.currstep, 'String', 'Proceed with step 2.');
    fprintf('Went back to step 2. \n')
    fprintf(' Drag draw a line along the scale bar in the image. \n')
elseif (m == 4)
    set_mode(3)
    mode3(handles);
    set(handles.currstep, 'String', 'Proceed with step 3.');
    fprintf('Went back to step 3. \n')
    fprintf(' Use the drawing tools to outline portions you wish to exclude. \n')
else
    set_mode(1)
    set(handles.currstep, 'String', 'Proceed with step 1.');
    fprintf('Went back to step 1. \n')
    fprintf(' Please enter the name of the file you want to analyze, including the file extension. \n')
end

% --- Executes on button press in nextstep.
function nextstep_Callback(hObject, eventdata, handles)
% hObject    handle to nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
m = get_mode;
if (isnan(m))
    set_mode(1)
    set(handles.currstep, 'String', 'Proceed with step 1.');
    fprintf('Step 1. \n')
    fprintf(' Please enter the name of the file you want to analyze, including the file extension. \n')
elseif (m == 1)
    set_mode(2)
    mode2(handles);
    set(handles.currstep, 'String', 'Proceed with step 2.');
    fprintf('Progressed to step 2. \n')
    fprintf(' Enter the scale, then drag draw a line along the scale bar, and a rectangle on the scale box in the image. \n')
elseif (m == 2)
    set_mode(3)
    mode3(handles);
    set(handles.currstep, 'String', 'Proceed with step 3.');
    fprintf('Progressed to step 3. \n')
    fprintf(' Use the drawing tools to outline portions you wish to exclude. \n')
else
    set_mode(4)
    mode4(handles);
    set(handles.currstep, 'String', 'Proceed with step 4.');
    fprintf('Progressed to step 4. \n')
    fprintf(' Image analysis complete. A CSV with obtained areas has been saved in your directory. The generated figure must be manually saved. \n')
end

% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get_mode == 3)
    obs = get_objects;
    if not(isempty(obs))
        del = obs(end);
        delete(del);
    end
    undo_object();
end

%----------------------------------DRAWING CALLBACKS-----------------------------

% --- Executes on button press in drawrect.
function drawrect_Callback(hObject, eventdata, handles)
% hObject    handle to drawrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get_mode == 3)
    h = drawrectangle();
    add_object(h);
end

% --- Executes on button press in freedraw.
function freedraw_Callback(hObject, eventdata, handles)
% hObject    handle to freedraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get_mode == 3)
    h = drawfreehand();
    add_object(h);
end

%----------------------------------TEXT BOX CALLBACKS-----------------------------

function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double
str = get(hObject,'String');
set_filename(str);
try
    clear_vars;
    img = imread(str);
    axes(handles.axes1);
    imshow(img);
    set_image(img);
    set_mode(2);
    set(handles.currstep, 'String', 'Proceed with step 2.');
    fprintf('Opened image file ');
    fprintf(str);
    fprintf('\n');
    fprintf('Progressed to step 2. \n')
    fprintf(' Enter the scale, then drag draw a line along the scale bar, and a rectangle on the scale box in the image. \n')
catch
    warning('File not found. Please enter a valid file name.')
    set_mode(1);
end

% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scale_bar_Callback(hObject, eventdata, handles)
% hObject    handle to scale_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_bar as text
%        str2double(get(hObject,'String')) returns contents of scale_bar as a double
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
function scale_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function save_fig_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = get_filename;
fig = figure;
copyobj(handles.axes1, fig);
