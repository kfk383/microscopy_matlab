function varargout = help_screen(varargin)
% HELP_SCREEN MATLAB code for help_screen.fig
%      HELP_SCREEN, by itself, creates a new HELP_SCREEN or raises the existing
%      singleton*.
%
%      H = HELP_SCREEN returns the handle to a new HELP_SCREEN or the handle to
%      the existing singleton*.
%
%      HELP_SCREEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELP_SCREEN.M with the given input arguments.
%
%      HELP_SCREEN('Property','Value',...) creates a new HELP_SCREEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before help_screen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to help_screen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help help_screen

% Last Modified by GUIDE v2.5 20-Jan-2020 18:30:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @help_screen_OpeningFcn, ...
                   'gui_OutputFcn',  @help_screen_OutputFcn, ...
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


% --- Executes just before help_screen is made visible.
function help_screen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to help_screen (see VARARGIN)

% Choose default command line output for help_screen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes help_screen wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = help_screen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
