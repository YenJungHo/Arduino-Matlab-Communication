function varargout = main_guide(varargin)
% MAIN_GUIDE MATLAB code for main_guide.fig
%      MAIN_GUIDE, by itself, creates a new MAIN_GUIDE or raises the existing
%      singleton*.
%
%      H = MAIN_GUIDE returns the handle to a new MAIN_GUIDE or the handle to
%      the existing singleton*.
%
%      MAIN_GUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_GUIDE.M with the given input arguments.
%
%      MAIN_GUIDE('Property','Value',...) creates a new MAIN_GUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_guide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_guide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_guide

% Last Modified by GUIDE v2.5 27-Jun-2020 13:01:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_guide_OpeningFcn, ...
                   'gui_OutputFcn',  @main_guide_OutputFcn, ...
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


% --- Executes just before main_guide is made visible.
function main_guide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_guide (see VARARGIN)

% Choose default command line output for main_guide
handles.output = hObject;

handles.serialTimer = timer('Name','serialTimer',               ...
                                'Period',0.1,                    ... 
                                'StartDelay',0.001,                 ... 
                                'TasksToExecute',Inf,           ... 
                                'ExecutionMode','fixedSpacing', ...
                                'TimerFcn',{@serialTimerCallback,hObject}); 
                          
handles.count = 0;
handles.index = [];
handles.resistor = [];

handles.plotFigureTimer = timer('Name','plotFigureTimer',               ...
                                'Period',1,                    ... 
                                'StartDelay',0.001,                 ... 
                                'TasksToExecute',Inf,           ... 
                                'ExecutionMode','fixedSpacing', ...
                                'TimerFcn',{@plotFigureTimerCallback,hObject}); 

handles.frameDataSize = 10000;                           

handles.baudrate = 230400;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes main_guide wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_guide_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_start_timer.
function btn_start_timer_Callback(hObject, eventdata, handles)
% hObject    handle to btn_start_timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.serialTimer.Running, 'off')
    start(handles.serialTimer);
end

if strcmp(handles.plotFigureTimer.Running, 'off')
    start(handles.plotFigureTimer);
end

guidata(hObject, handles);


% --- Executes on button press in btn_stop_timer.
function btn_stop_timer_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop_timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(handles.serialTimer.Running, 'on')
    stop(handles.serialTimer);
end

if strcmp(handles.plotFigureTimer.Running, 'on')
    stop(handles.plotFigureTimer);
end

guidata(hObject, handles);


 function [] = serialTimerCallback(hTimer,~,hObject)
     tic
 if ~isempty(hObject)
      % get the handles
      handles = guidata(hObject);
      
      
      if isfield(handles, 'arduinoSerial')
          s = handles.arduinoSerial;
          n = s.ValuesReceived - handles.count;
          for j = 1:2000
              
              data = fscanf(s, '%d');
              if isempty(data)
                  break;
              end
              handles.count = handles.count + 1;
              i = handles.count;
              handles.index(i) = i;
              handles.resistor(i) = data;
          end
      else
          handles.count = handles.count + 1;
          i = handles.count;
          
          handles.index(i) = i;
          handles.resistor(i) = rand();
      end
      
      
      % get the current task number (1,2,3,...,10)
      tasksExecuted = get(hTimer, 'TasksExecuted');
      tasksToExecute = get(hTimer, 'TasksToExecute');
      
      
      % Update handles structure
      guidata(hObject, handles);
      
      % update the text control with the seconds remaining (note the tasksExecuted counts upwards)
      % close the GUI
      if tasksExecuted == tasksToExecute
          close(hObject);
      end
 end
 toc
 
 function [] = plotFigureTimerCallback(hTimer,~,hObject)
 if ~isempty(hObject)
      % get the handles
      handles = guidata(hObject);
      
      frame = handles.frameDataSize;  
      
      % fix figure and axes
      figure( handles.figure1 );
      axes(handles.axesPlotSerialData)
      
      % 
      if isfield(handles, 'line_dataAcq')
          h = handles.line_dataAcq;
          cnt = handles.count;
          idx_s = floor(cnt/frame) * frame + 1;
          idx_e = idx_s + mod( cnt, frame) - 1;
          
          handles.axesPlotSerialData.XLim = [ idx_s ,idx_s + frame ];
          index = idx_s:idx_e;
      
          set( h, 'xdata',handles.index(index) , 'ydata',handles.resistor(index) )
          drawnow

      else
          handles.line_dataAcq = plot( handles.axesPlotSerialData, handles.index, handles.resistor );
          drawnow
          
      end
      % get the current task number (1,2,3,...,10)
      tasksExecuted = get(hTimer, 'TasksExecuted');
      tasksToExecute = get(hTimer, 'TasksToExecute');
      
      % Update handles structure
      guidata(hObject, handles);
      
      % update the text control with the seconds remaining (note the tasksExecuted counts upwards)
      
      % close the GUI
      if tasksExecuted == tasksToExecute
          close(hObject);
      end
 end



function edit_baudrate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_baudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_baudrate as text
%        str2double(get(hObject,'String')) returns contents of edit_baudrate as a double
handles = guidata(hObject);

handles.baudrate = str2double(handles.edit_baudrate.String);
handles.edit_baudrate.Value = handles.baudrate;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_baudrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_baudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles = guidata(hObject);

handles.edit_baudrate.Value = 230400;
handles.edit_baudrate.String = num2str(230400);

guidata(hObject, handles);


% --- Executes on button press in btn_build_serial.
function btn_build_serial_Callback(hObject, eventdata, handles)
% hObject    handle to btn_build_serial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

% close serial port
% fclose(instrfind);

try
    arduinoSerial = serial('/dev/cu.usbmodem141201','BaudRate',handles.baudrate);
    fopen(arduinoSerial);
    fscanf(arduinoSerial) %reads "Ready"
    
    handles.arduinoSerial = arduinoSerial;
catch
    disp('fail to build serial commucation with arduino.')
    ls -1 /dev/tty.usb*
    ls -1 /dev/cu.usb*
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles = guidata(hObject);

guidata(hObject, handles);

% --- Executes on button press in btn_close_serial.
function btn_close_serial_Callback(hObject, eventdata, handles)
% hObject    handle to btn_close_serial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

if isfield(handles, 'arduinoSerial')
    fclose(handles.arduinoSerial);
    
    if strcmp(handles.arduinoSerial.Status, 'open')
        disp( 'failed to disconnect.' )
    elseif strcmp(handles.arduinoSerial.Status, 'closed')
        disp( 'success to disconnect.' )
    end
    
elseif ~isempty(instrfind)
    fclose(instrfind)
else
    disp('have not connenct serial port.')
end

guidata(hObject, handles);



function edit_save_path_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_save_path_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_save_path_file as text
%        str2double(get(hObject,'String')) returns contents of edit_save_path_file as a double
handles = guidata(hObject);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_save_path_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_save_path_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles = guidata(hObject);

guidata(hObject, handles);

% --- Executes on button press in btn_saveFile.
function btn_saveFile_Callback(hObject, eventdata, handles)
% hObject    handle to btn_saveFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

if strcmp(handles.serialTimer.Running, 'on') || strcmp(handles.plotFigureTimer.Running, 'on')
    disp( 'Press the button to stop collecting data.' );
    return;
end

[FileName, PathName]=uiputfile({'*.txt','Txt Files(*.txt)';'*.*','All Files(*.*)'},'Save data');
str = [PathName FileName];
handles.edit_save_path_file.String = str;

try
    fid = fopen(char(str), 'w');
    
    n = handles.count;
    for i = 1:n
        fprintf(fid,'%d, %d\n',handles.index(i), handles.resistor(i));
    end
    fclose(fid);
catch
    disp( 'fail to save data.' );
end

guidata(hObject, handles);

