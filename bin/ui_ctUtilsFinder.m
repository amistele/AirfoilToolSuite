function ui_ctUtilsFinder(bufferLocal,listString,fParent)
% INPUTS
%   - bufferLocal : structure of local airfoils and their data
%   - listString  : cell array of airfoil list names from buffer window
%   - fParent     : object of parent figure
%
% OUTPUTS
%   - < none >
%
% CREATED
%   - < varies with user input >

    % DECLARE GLOBALS
    global font
    addpath('bin')
    
    % PRE-ALLOCATE STRUCTURES
    uiLocal = struct();         % UI ELEMENTS ON LOCAL FIGURE
    settings = struct();        % SETTINGS TO FEED INTO MATH STUFF
    bufferUpdated = struct('x',cell(1,length(bufferLocal)));   % AIRFOILS AFTER LE UPDATES
    
    % DEFINE DEFAULT SETTINGS
    settings.plottedID      = NaN;
    settings.iterateFrom    = 1; % 1 for LE, 0 for TE
    settings.distribute     = 1; % 1 for COSINE, 0 for LINEAR
    settings.mode           = 1; % 1 for AUTOMATIC, 0 for MANUAL
    
    for ind = 1:length(bufferLocal)
        bufferLocal(ind).isBlunt = NaN;
        bufferLocal(ind).xTE = NaN;
        bufferLocal(ind).yTE = NaN;
        bufferLocal(ind).xLE = NaN;
        bufferLocal(ind).yLE = NaN;
    end
    
    % CREATE CTUTILS GUI WINDOW
    pos = fParent.Position + [ 0.05 -0.05-fParent.Position(4)*0.5 fParent.Position(3) fParent.Position(4)*0.5];
    f1 = figure('Name','ctUtils','NumberTitle','off','units','normalized','Position',pos);

    
    %% MAIN UI LAYOUT - STATIC ELEMENTS
    % TITLES
    % PANELS
    % PANEL TITLES
    
    % TITLE LINE - CTUTILS
    uiLocal.text_title = uicontrol(f1,'Style','text','String','ctUtils Util 1: Camber and Thickness Finder Utility',...
        'Units','normalized','Position',[0.1,0.875, 0.8, 0.1],...
        'Fontweight','bold','FontSize',14,'FontName',font);

    % SOME PANEL SETTINGS
    eOff   = 0.01;              % EDGE OFFSET
    width  = 0.333 - 2*eOff;    % PANEL WIDTH
    height1 = 0.2 - 2*eOff;     % PANEL HEIGHT 1
    height2 = 0.5  - 2*eOff;    % PANEL HEIGHT 2

    % TOP LEFT PANEL
    uiLocal.panel_upperLeft     = uipanel(f1,'Position',[eOff 0.2+eOff+height2+2*eOff width height1]);
    
    % CENTER LEFT PANEL
    uiLocal.panel_centerLeft    = uipanel(f1,'Position',[eOff 0.2+eOff width height2]);
    
    % LOWER LEFT PANEL
    uiLocal.panel_lowerLeft     = uipanel(f1,'Position',[eOff eOff width height1]);
    
    % DIVIDER PANEL
    uiLocal.panel_divider       = uipanel(f1,'Position',[eOff+width+eOff 0.05 0.01 0.9-0.1]);
    
    % MAIN RIGHT PANEL
    uiLocal.panel_right         = uipanel(f1,'Position',[2*eOff+width+0.01+eOff eOff 1-eOff-(2*eOff+width+0.01+eOff) 0.9-2*eOff]);
    
    % SETTINGS PANEL
    portion = 0.3;
    uiLocal.panel_settings      = uipanel(uiLocal.panel_right,'Position',[eOff 1-portion+eOff 1-2*eOff portion-2*eOff]);
    
    % SOLVER PANEL
    uiLocal.panel_solver        = uipanel(uiLocal.panel_right,'Position',[eOff eOff 1-2*eOff 1-portion-2*eOff]);
    
    
    % INPUT AIRFOILS LABEL
    uiLocal.text_left       = uicontrol(uiLocal.panel_upperLeft,'Style','text','String','Input Airfoils',...
        'Units','normalized','Position',[0.1 0.8 0.8 0.2],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % FIND LE LABEL
    uiLocal.text_center     = uicontrol(uiLocal.panel_centerLeft,'Style','text','String','LE Finder',...
        'Units','normalized','Position',[0.3 0.9 0.4 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % UPDATED AIRFOILS LABEL
    uiLocal.text_right      = uicontrol(uiLocal.panel_lowerLeft,'Style','text','String','Updated Airfoils',...
        'Units','normalized','Position',[0.1 0.8 0.8 0.2],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % SOLVER SETTINGS LABEL
    uiLocal.text_settings   = uicontrol(uiLocal.panel_settings,'Style','text','String','Solver Settings',...
        'Units','normalized','Position',[0.3 0.8 0.4 0.2],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % SOLVER LABEL
    uiLocal.text_solver     = uicontrol(uiLocal.panel_solver,'Style','text','String','Solver',...
        'Units','normalized','Position',[0.3 0.9 0.4 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    
%% MAIN MENU BUTTONS - UPPER LEFT PANEL
    % AIRFOIL BUFFER DISPLAY
    % BUTTON - PASS AIRFOIL OVER
    
    % LIST - BUFFER AIRFOILS
    uiLocal.list_AIRFOILS = uicontrol(uiLocal.panel_upperLeft,'Style','list',...
        'Units','normalized','Position',[2*eOff 0.2+4*eOff 1-4*eOff 0.6-4*eOff],...
        'Max',1,'String',listString,'FontSize',10,'FontName',font);
    
    % BUTTON - SEND TO LE FINDER
    uiLocal.button_SENDLE = uicontrol(uiLocal.panel_upperLeft,'Style','pushbutton',...
        'String','Send to LE Finder','Units','normalized','Position',[2*eOff eOff 1-4*eOff 0.2],...
        'Fontweight','bold','FontSize',10,'FontName',font);

    
%% MAIN MENU BUTTONS - CENTER LEFT PANEL
    % AXES FOR PLOTTING
    % TITLES FOR PROPERTY LISTBOXES
    % LIST BOXES FOR LE PROPERTIES

    
    % AXES - PLOT LE
    uiLocal.plot_LE = axes(uiLocal.panel_centerLeft,'Position',[8*eOff 0.5 1-16*eOff 0.4],...
        'Box','on','XGrid','on','YGrid','on');
    
    % TITLE - PARAMETERS
    uiLocal.title_PARAMETERS = uicontrol(uiLocal.panel_centerLeft,'Style','text',...
        'String','Parameters','Units','normalized','Position',[eOff 0.385 0.2 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font);
    
    % TITLE - NEAREST VALUES
    uiLocal.title_VALUES_GEOM = uicontrol(uiLocal.panel_centerLeft,'Style','text',...
        'String','"Nearest" LE','Units','normalized','Position',[0.333-eOff-0.09 0.385 0.333+0.025 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font);
    
    % TITLE - CURVATURE VALUES
    uiLocal.title_VALUES_THETA = uicontrol(uiLocal.panel_centerLeft,'Style','text',...
        'String','"Curvature" LE','Units','normalized','Position',[0.666-eOff-0.065 0.385 0.333+0.025 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font);
    
    % LIST BOX - PROPERTY NAMES
    uiLocal.list_PROPERTIES = uicontrol(uiLocal.panel_centerLeft,'Style','list',...
        'Units','normalized','Position',[eOff 0.1+0.03 0.333-eOff-0.05 0.245],...
        'enable','inactive','String',{'index','chord','incidence','(x,y)'},...
        'Value',1,'FontSize',9,'FontName',font);
    
    % LIST BOX - NEAREST VALUES
    uiLocal.list_VALUES_GEOM = uicontrol(uiLocal.panel_centerLeft,'Style','list',...
        'Units','normalized','Position',[0.333-eOff-0.05 0.1+0.03 0.333+0.025 0.245],...
        'enable','inactive','String',{'-','-','-','-'},...
        'Value',1,'FontSize',9,'FontName',font);
    
    % LIST BOX - CURVATURE VALUES
    uiLocal.list_VALUES_THETA = uicontrol(uiLocal.panel_centerLeft,'Style','list',...
        'Units','normalized','Position',[0.666-eOff-0.025 0.1+0.03 0.333+0.025 0.245],...
        'enable','inactive','String',{'-','-','-','-'},...
        'Value',1,'FontSize',9,'FontName',font);
    
    % BUTTON - SET NEAREST AS LE
    uiLocal.button_SET_NEAR = uicontrol(uiLocal.panel_centerLeft,'Style','pushbutton',...
        'String','Set as LE','Units','normalized','Position',[0.333-eOff-0.05 0.015 0.333+0.025 0.1],...
        'Fontweight','bold','Fontsize',10,'FontName',font);
    
    % BUTTON - SET CURVE AS LE
    uiLocal.button_SET_CURVE = uicontrol(uiLocal.panel_centerLeft,'Style','pushbutton',...
        'String','Set as LE','Units','normalized','Position',[0.666-eOff-0.025 0.015 0.333+0.025 0.1],...
        'Fontweight','bold','Fontsize',10,'FontName',font);

    
%% MAIN MENU BUTTONS - LOWER LEFT PANEL

    % LIST - UPDATED AIRFOILS
    uiLocal.list_AIRFOILS_UPDATED = uicontrol(uiLocal.panel_lowerLeft,'Style','list',...
        'Units','normalized','Position',[2*eOff 0.2+4*eOff 1-4*eOff 0.6-4*eOff],...
        'Max',1,'String',{},'FontSize',10,'FontName',font);
    
    % BUTTON - SEND TO LE FINDER
    uiLocal.button_SENDFOIL = uicontrol(uiLocal.panel_lowerLeft,'Style','pushbutton',...
        'String','Send to Cam/Thick Finder','Units','normalized','Position',[2*eOff eOff 1-4*eOff 0.2],...
        'Fontweight','bold','FontSize',10,'FontName',font);

    
%% MAIN MENU BUTTONS - RIGHT PANEL

    % TITLE - 'ITERATE FROM' SETTING
    uiLocal.title_ITERATE   = uicontrol(uiLocal.panel_settings,'Style','text','String','Iterate from:',...
        'Units','normalized','position',[eOff 0.75 0.2-2*eOff 0.125],...
        'HorizontalAlignment','left',...
        'Fontweight','bold','Fontsize',10,'FontName',font);
    
    % TITLE - 'SPACING' SETTING
    uiLocal.title_SPACING   = uicontrol(uiLocal.panel_settings,'Style','text','String','Distribution spacing:',...
        'Units','normalized','position',[eOff 0.325 0.2-2*eOff 0.125],...
        'HorizontalAlignment','left',...
        'Fontweight','bold','Fontsize',10,'FontName',font);
    
    % TITLE - 'STEPPING' SETTING
    uiLocal.title_STEPPING  = uicontrol(uiLocal.panel_settings,'Style','text','String','Stepping mode',...
        'Units','normalized','position',[eOff+0.2 0.75 0.2-2*eOff 0.125],...
        'HorizontalAlignment','left',...
        'Fontweight','bold','Fontsize',10,'FontName',font);
    
    % TITLE - 'MISCELLANEOUS' SETTINGS
    uiLocal.title_MISC      = uicontrol(uiLocal.panel_settings,'Style','text','String','Miscellaneous',...
        'Units','normalized','position',[eOff+0.4 0.75 0.25-2*eOff 0.125],...
        'HorizontalAlignment','center',...
        'Fontweight','bold','Fontsize',10,'FontName',font);
    
    % TITLE - MANUAL SETTINGS
    uiLocal.title_MANUAL    = uicontrol(uiLocal.panel_settings,'Style','text','String','Manual Control: Camber Guessing',...
        'Units','normalized','position',[0.655 0.75 0.345-eOff 0.125],...
        'HorizontalAlignment','center',...
        'Fontweight','bold','Fontsize',10,'FontName',font);
    
    % TITLE - MANUAL SETTINGS DISABLED
    uiLocal.title_DISABLED  = uicontrol(uiLocal.panel_settings,'Style','text','String','(disabled)',...
        'Units','normalized','position',[0.655 0.5 0.345-eOff 0.125],...
        'HorizontalAlignment','center',...
        'Fontsize',10,'FontName',font);
    
    
    % RADIO BUTTON - 'ITERATE FROM LE'
    uiLocal.radio_LE        = uicontrol(uiLocal.panel_settings,'Style','radiobutton',...
        'String','LE (recommended)','Units','normalized','Value',1,...
        'Position',[2*eOff 0.5875+0.025 0.2-4*eOff 0.1625-eOff],...
        'FontSize',10,'FontName',font);
    
    % RADIO BUTTON - 'ITERATE FROM TE'
    uiLocal.radio_TE        = uicontrol(uiLocal.panel_settings,'Style','radiobutton',...
        'String','TE','Units','normalized','Value',0,...
        'Position',[2*eOff 0.425+eOff+0.025 0.2-4*eOff 0.1625-eOff],...
        'FontSize',10,'FontName',font);
    
    
    % RADIO BUTTON - 'COSINE'
    uiLocal.radio_COSINE    = uicontrol(uiLocal.panel_settings,'Style','radiobutton',...
        'String','cosine','Units','normalized','Value',1,...
        'Position',[2*eOff 0.1625+0.025 0.2-4*eOff 0.1625-eOff],...
        'FontSize',10,'FontName',font);
    
    % RADIO BUTTON - 'LINEAR'
    uiLocal.radio_LINEAR    = uicontrol(uiLocal.panel_settings,'Style','radiobutton',...
        'String','linear','Units','normalized','Value',0,...
        'Position',[2*eOff eOff+0.025 0.2-4*eOff 0.1625-eOff],...
        'FontSize',10,'FontName',font);
    
    
    % RADIO BUTTON - 'AUTOMATIC'
    uiLocal.radio_AUTOMATIC = uicontrol(uiLocal.panel_settings','Style','radiobutton',...
        'String','automatic','Units','normalized','Value',1,...
        'Position',[0.2+2*eOff 0.5875+0.025 0.2-4*eOff 0.1625-eOff],...
        'FontSize',10,'FontName',font);
    
    % RADIO BUTTON - 'MANUAL'
    uiLocal.radio_MANUAL    = uicontrol(uiLocal.panel_settings','Style','radiobutton',...
        'String','manual','Units','normalized','Value',0,...
        'Position',[0.2+2*eOff 0.425+0.025+eOff 0.2-4*eOff 0.1625-eOff],...
        'FontSize',10,'FontName',font);
    
    
    % LIST BOX - 'MISCELLANEOUS'
    uiLocal.list_MISC       = uicontrol(uiLocal.panel_settings,'Style','list',...
        'Units','normalized','position',[0.4+eOff 0.325 0.25-2*eOff 0.75-0.325-eOff],...
        'Max',1,'Value',1,'String',{'# points: 50','step force: 1/5','tol: 1e-10'},...
        'FontSize',10,'FontName',font);
    
    % EDIT BOX - EDIT MISCELLANEOUS VALUES
    uiLocal.edit_MISC       = uicontrol(uiLocal.panel_settings,'Style','edit',...
        'Units','normalized','position',[0.4+eOff 0.1625+eOff 0.25-2*eOff 0.1625-eOff],...
        'String','50','FontSize',10,'FontName',font);
    
    % BUTTON - UPDATE MISCELLANEOUS VALUES
    uiLocal.update_MISC     = uicontrol(uiLocal.panel_settings,'Style','pushbutton',...
        'Units','normalized','position',[0.4+eOff eOff 0.25-2*eOff 0.1625-eOff],...
        'String','Update','Fontweight','bold','FontSize',10,'FontName',font);
    
    
%% MANUAL SETTINGS UI ELEMENTS
    
    % PANEL - MANUAL STEPPING
    uiLocal.panel_manual    = uipanel(uiLocal.panel_settings,'Position',[0.655 eOff 1-0.655-eOff/2 0.75-eOff]);
    
    % TEXT - SLIDER LABEL TOP
    uiLocal.text_SLIDER1    = uicontrol(uiLocal.panel_manual,'Style','text',...
        'Units','normalized','position',[0 0.8 0.075 0.2],...
        'String','1','FontSize',10,'Fontweight','bold','FontName',font);
    
    % TEXT - SLIDER LABEL BOTTOM
    uiLocal.text_SLIDER0    = uicontrol(uiLocal.panel_manual,'Style','text',...
        'Units','normalized','position',[0 0 0.075 0.2],...
        'String','0','FontSize',10,'Fontweight','bold','FontName',font);
    
    % SLIDER - GUESS LOCATION
    uiLocal.slider_GUESS    = uicontrol(uiLocal.panel_manual,'Style','slider',...
        'Units','normalized','position',[0.075 eOff 0.1 1-2*eOff],...
        'Min',0,'Max',1,'Value',0.25,'BackgroundColor',[1 1 1]);
    
    
    % TEXT - Height %
    uiLocal.text_HEIGHT     = uicontrol(uiLocal.panel_manual,'Style','text',...
        'Units','normalized','position',[0.175+eOff 0.8 0.4 0.2],...
        'String','Height %','Fontweight','bold','FontSize',10,'FontName',font);
    
    % EDIT - SLIDER VALUE DISPLAY
    uiLocal.edit_HEIGHT     = uicontrol(uiLocal.panel_manual,'Style','edit',...
        'Units','normalized','position',[0.175+eOff 0.65+eOff 0.4 0.2-2*eOff],...
        'String',{'0.50'},'enable','inactive',...
        'Fontsize',10,'FontName',font);
    
    % TEXT - 'rU - rL Error'
    uiLocal.text_ERROR      = uicontrol(uiLocal.panel_manual,'Style','text',...
        'Units','normalized','position',[0.175+eOff 0.4 0.4 0.2],...
        'String','rU-rL Error','Fontweight','bold','FontSize',10,'FontName',font);
    
    % EDIT - ERROR DISPLAY
    uiLocal.edit_ERROR      = uicontrol(uiLocal.panel_manual,'Style','edit',...
        'Units','normalized','position',[0.175+eOff 0.25+eOff 0.4 0.2-2*eOff],...
        'String',{'n/a'},'enable','inactive',...
        'FontSize',10,'FontName',font);
    
    % BUTTON - SEEK
    uiLocal.button_ITERATE  = uicontrol(uiLocal.panel_manual,'Style','pushbutton',...
        'Units','normalized','position',[0.175+eOff eOff 0.4 0.2],...
        'String','Seek','FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - ACCEPT
    uiLocal.button_ACCEPT   = uicontrol(uiLocal.panel_manual,'Style','pushbutton',...
        'Units','normalized','position',[0.575+2*eOff 0.4 0.4 0.4],...
        'String','Accept','FontWeight','bold','FontSize',12,'FontName',font);
    
    % BUTTON - HELP
    uiLocal.button_HELP     = uicontrol(uiLocal.panel_manual,'Style','pushbutton',...
        'Units','normalized','position',[0.575+2*eOff 0.15+eOff 0.4 0.2],...
        'String','Help','FontWeight','bold','FontSize',10,'FontName',font);
    
    % SET SOLVER SETTINGS PANEL INACTIVE B/C NO AIRFOIL LOADED INITIALLY
    %set(uiLocal.panel_settings,'visible','off');
    
    % SET MANUAL CONTROL PANEL INACTIVE B/C AUTO STEPPING DEFAULT
    set(uiLocal.panel_manual,'visible','off');
    
    % SET SOLVER PANEL INACTIVE B/C NO AIRFOIL LOADED INITIALLY
    %set(uiLocal.panel_solver,'visible','off');
    
    
%% CALLBACK FUNCTION ASSIGNMENTS
    
    % CALLBACKS DEFINED LOCALLY - LEFT PANEL
    uiLocal.button_SENDLE.Callback      = @sendLE;
    uiLocal.button_SET_NEAR.Callback    = @setGeomLE;
    uiLocal.button_SET_CURVE.Callback   = @setThetaLE;
    
    % CALLBACKS DEFINED LOCALLY - RIGHT PANEL, RADIO BUTTONS
        % RADIO BUTTON CALLBACKS ARE A BIT CONVOLUTED BECAUSE I DIDN'T USE
        % THE UIBUTTONGROUP FEATURE, WHICH MAKES MANAGING THE BUTTONS
        % EASIER BUT WON'T LET ME POSITION THEM RELATIVELY ON A PANEL
    uiLocal.radio_LE.Callback           = @updateRadioLE;
    uiLocal.radio_TE.Callback           = @updateRadioTE;
    uiLocal.radio_COSINE.Callback       = @updateRadioCosine;
    uiLocal.radio_LINEAR.Callback       = @updateRadioLinear;
    uiLocal.radio_AUTOMATIC.Callback    = @updateRadioAutomatic;
    uiLocal.radio_MANUAL.Callback       = @updateRadioManual;


%% CALLBACK FUNCTION DEFINITIONS

    % SEND LE BUTTON - ON CLICK, PLOT SELECTED AIRFOILS AND CALCULATE LE PARAMETERS
    %   FILES - < NONE >
    function sendLE(src,event)
        uiLocal; bufferLocal; settings; % FOR DEBUGGING
        
        % GET LIST INDEX OF AIRFOIL TO SEND
        idx = uiLocal.list_AIRFOILS.Value;
        settings.plottedID = idx;
        
        % UPDATE PLOT
        updatePlot(bufferLocal(idx).x,bufferLocal(idx).y,idx);
        
    end


    % SET NEAREST LE - SETS AIRFOIL LE AS POINT CLOSEST TO ORIGIN
    %   FILES - < NONE >
    function setGeomLE(src,event)
        % MAKE SURE PLOT IS VALID (NOT NONE, AND NOT UPDATED)
        if isnan(settings.plottedID)
            msgbox('No airfoil has been plotted yet!','Error','error')
            return
        elseif settings.plottedID == -1
            msgbox('This is a plot of an updated airfoil. Its leading edge has already been set.','Error','warn');
            return
        end
        
        
        % SET AIRFOIL PROPERTIES
        idx = settings.plottedID;
        id  = bufferLocal(idx).geomID;
        bufferLocal(idx).xLE   = bufferLocal(idx).x(id);
        bufferLocal(idx).yLE   = bufferLocal(idx).y(id);
        bufferLocal(idx).chord = bufferLocal(idx).chordGeom;
        bufferLocal(idx).incidence = bufferLocal(idx).incidenceGeom;
        
        % CHECK IF INCIDENCE OR CHORD ARE NONSTANDARD
        if bufferLocal(idx).incidence ~= 0 || bufferLocal(idx).chord ~= 1 || bufferLocal(idx).yTE ~= 0
            
            % PROMPT USER TO STANDARDIZE AIRFOIL OR NOT
            question = sprintf('Standard airfoil coordinate format has the leading edge of the airfoil at the origin, an incidence angle of zero degrees, and a chord length of 1.\nFor the chosen LE, at least one of these parameters is non-standard:\nLE (x,y)  = (%.2e,%.2e)\nincidence = %.4f deg\nchord     = %.4e\nWould you like to standardize the airfoil before proceeding?',...
                bufferLocal(idx).xLE,bufferLocal(idx).yLE,bufferLocal(idx).incidence,bufferLocal(idx).chord);
            ans = questdlg(question,'Warning','Yes','No','Yes');
            
            switch ans
                case 'Yes'     
                    % SHIFT AIRFOIL TO LE AT ORIGIN
                    x = bufferLocal(idx).x; x = reshape(x,1,length(x));
                    y = bufferLocal(idx).y; y = reshape(y,1,length(y));
                    x = x - bufferLocal(idx).xLE;
                    y = y - bufferLocal(idx).yLE;

                    % ROTATE AIRFOIL TO ZERO INCIDENCE
                    theta = bufferLocal(idx).incidence;
                    R = [cosd(theta) -sind(theta) ; sind(theta) cosd(theta)];
                    mat = R*[x ; y];
                    xNew = mat(1,:);
                    yNew = mat(2,:);

                    % SCALE AIRFOIL TO CHORD = 1
                    sf = bufferLocal(idx).xTE;
                    xNew = xNew / sf;
                    yNew = yNew / sf;
                    
                    % UPDATE PLOT
                    updatePlot(xNew,yNew,idx);
                    
                    % SET 'SELECTED AIRFOIL' INDEX TO NEGATIVE SO IT CAN'T BE RE-UPDATED
                    settings.plottedID = -1;
                    
                    % MESSAGE BOX THAT THE PLOT HAS BEEN UPDATED
                    msgbox('Plot has been updated!','Notice','help');
                    
                    
                case 'No'
                    % UPDATED COORDINATES ARE THE SAME AS OLD COORDINATES
                    xNew = bufferLocal(idx).x;
                    yNew = bufferLocal(idx).y;
            end
            
            % STORE NEW COORDINATES TO STRUCTURE
            bufferLocal(idx).xNew = xNew;
            bufferLocal(idx).yNew = yNew;
            
            % ADD AIRFOIL TO UPDATED STRUCTURE
            fn = fieldnames(bufferLocal);
            for i = 1:length(fn)
                bufferUpdated(idx).(fn{i}) = bufferLocal(idx).(fn{i});
            end
            bufferUpdated(idx).x = bufferUpdated(end).xNew;
            bufferUpdated(idx).y = bufferUpdated(end).yNew;

            % UPDATE LISTBOX FOR UDPATED AIRFOILS
            uiLocal.list_AIRFOILS_UPDATED.String{end+1} = [uiLocal.list_AIRFOILS.String{idx} ' (nearest LE)'];   
            uiLocal.list_AIRFOILS_UPDATED.Value         = length(uiLocal.list_AIRFOILS_UPDATED.String);
        end
    end


    % SET NEAREST LE - SETS AIRFOIL LE AS POINT WITH LEAST CURVATURE
    %   FILES - < NONE >
    function setThetaLE(src,event)
        % MAKE SURE PLOT IS VALID (NOT NONE, AND NOT UPDATED)
        if isnan(settings.plottedID)
            msgbox('No airfoil has been plotted yet!','Error','error')
            return
        elseif settings.plottedID == -1
            msgbox('This is a plot of an updated airfoil. Its leading edge has already been set.','Error','warn');
            return
        end
        
        
        % SET AIRFOIL PROPERTIES
        idx = settings.plottedID;
        id  = bufferLocal(idx).thetaID;
        bufferLocal(idx).xLE   = bufferLocal(idx).x(id);
        bufferLocal(idx).yLE   = bufferLocal(idx).y(id);
        bufferLocal(idx).chord = bufferLocal(idx).chordTheta;
        bufferLocal(idx).incidence = bufferLocal(idx).incidenceTheta;
        
        % CHECK IF INCIDENCE OR CHORD ARE NONSTANDARD
        if bufferLocal(idx).incidence ~= 0 || bufferLocal(idx).chord ~= 1 || bufferLocal(idx).yTE ~= 0
            
            % PROMPT USER TO STANDARDIZE AIRFOIL OR NOT
            question = sprintf('Standard airfoil coordinate format has the leading edge of the airfoil at the origin, an incidence angle of zero degrees, and a chord length of 1.\nFor the chosen LE, at least one of these parameters is non-standard:\nLE (x,y)  = (%.2e,%.2e)\nincidence = %.4f deg\nchord     = %.4e\nWould you like to standardize the airfoil before proceeding?',...
                bufferLocal(idx).xLE,bufferLocal(idx).yLE,bufferLocal(idx).incidence,bufferLocal(idx).chord);
            ans = questdlg(question,'Warning','Yes','No','Yes');
            
            switch ans
                case 'Yes'     
                    % SHIFT AIRFOIL TO LE AT ORIGIN
                    x = bufferLocal(idx).x; x = reshape(x,1,length(x));
                    y = bufferLocal(idx).y; y = reshape(y,1,length(y));
                    x = x - bufferLocal(idx).xLE;
                    y = y - bufferLocal(idx).yLE;

                    % ROTATE AIRFOIL TO ZERO INCIDENCE
                    theta = bufferLocal(idx).incidence;
                    R = [cosd(theta) -sind(theta) ; sind(theta) cosd(theta)];
                    mat = R*[x ; y];
                    xNew = mat(1,:);
                    yNew = mat(2,:);

                    % SCALE AIRFOIL TO CHORD = 1
                    sf = bufferLocal(idx).xTE;
                    xNew = xNew / sf;
                    yNew = yNew / sf;
                    
                    % UPDATE PLOT
                    updatePlot(xNew,yNew,idx);
                    
                    % SET 'SELECTED AIRFOIL' INDEX TO NEGATIVE SO IT CAN'T BE RE-UPDATED
                    settings.plottedID = -1;
                    
                    % MESSAGE BOX THAT THE PLOT HAS BEEN UPDATED
                    msgbox('Plot has been updated!','Notice','help');
                    
                    
                case 'No'
                    % UPDATED COORDINATES ARE THE SAME AS OLD COORDINATES
                    xNew = bufferLocal(idx).x;
                    yNew = bufferLocal(idx).y;
            end
            
            % STORE NEW COORDINATES TO STRUCTURE
            bufferLocal(idx).xNew = xNew;
            bufferLocal(idx).yNew = yNew;
            
            % ADD AIRFOIL TO UPDATED STRUCTURE
            fn = fieldnames(bufferLocal);
            for i = 1:length(fn)
                bufferUpdated(idx).(fn{i}) = bufferLocal(idx).(fn{i});
            end
            bufferUpdated(end).x = bufferUpdated(end).xNew;
            bufferUpdated(end).y = bufferUpdated(end).yNew;

            % UPDATE LISTBOX FOR UDPATED AIRFOILS
            uiLocal.list_AIRFOILS_UPDATED.String{end+1} = [uiLocal.list_AIRFOILS.String{idx} ' (curvature LE)'];
            uiLocal.list_AIRFOILS_UPDATED.Value         = length(uiLocal.list_AIRFOILS_UPDATED.String);
        end
    end
    

    % UPDATE RADIO BUTTONS - ITERATE FROM - ON LE CLICK
    %   FILES - < NONE >
    function updateRadioLE(src,event)
        % IF RADIO IS ALREADY SET TO LE, KEEP BUTTON ON
        if uiLocal.radio_TE.Value == 0
            uiLocal.radio_LE.Value = 1;
        
        % IF RADIO IS NOT SET TO LE, UPDATE BOTH RADIO BUTTONS
        else 
            % UPDATE BUTTON VALUES
            uiLocal.radio_LE.Value = 1;
            uiLocal.radio_TE.Value = 0;
            
            % UPDATE SOLVER SETTINGS
            settings.iterateFrom = 1;
        end
        
    end
    

    % UPDATE RADIO BUTTONS - ITERATE FROM - ON TE CLICK
    %   FILES - < NONE >
    function updateRadioTE(src,event)
        % IF RADIO IS ALREADY SET TO TE, KEEP BUTTON ON
        if uiLocal.radio_LE.Value == 0
            uiLocal.radio_TE.Value = 1;
        
        % IF RADIO IS NOT SET TO TE, UPDATE BOTH RADIO BUTTONS
        else
            % UPDATE BUTTON VALUES
            uiLocal.radio_LE.Value = 0;
            uiLocal.radio_TE.Value = 1;
            
            % UPDATE SOLVER SETTINGS
            settings.iterateFrom = 0;
        

        end
    end


    % UPDATE RADIO BUTTONS - DISTRIBUTION - ON COSINE CLICK
    %   FILES - < NONE >
    function updateRadioCosine(src,event)
        % IF RADIO IS ALREADY SET TO COSINE, KEEP BUTTON ON
        if uiLocal.radio_LINEAR.Value == 0
            uiLocal.radio_COSINE.Value = 1;
            
        % IF RADIO IS NOT SET TO COSINE, UPDATE BOTH RADIO BUTTONS
        else
            % UPDATE BUTTON VALUES
            uiLocal.radio_COSINE.Value = 1;
            uiLocal.radio_LINEAR.Value = 0;
            
            % UPDATE SOLVER SETTINGS
            settings.distribute = 1;
        end
    end


    % UPDATE RADIO BUTTONS - DISTRIBUTION - ON LINEAR CLICK
    %   FILES - < NONE >
    function updateRadioLinear(src,event)
        % IF RADIO IS ALREADY SET TO LINEAR, KEEP BUTTON ON
        if uiLocal.radio_COSINE.Value == 0
            uiLocal.radio_LINEAR.Value = 1;
        
        % IF RADIO IS NOT SET TO LIENAR, UPDATE BOTH RADIO BUTTONS
        else
            % UPDATE BUTTON VALUES
            uiLocal.radio_COSINE.Value = 0;
            uiLocal.radio_LINEAR.Value = 1;
            
            % UPDATE SOLVER SETTINGS
            settings.distribute = 0;
        end
    end


    % UPDATE RADIO BUTTONS - STEPPING MODE - ON AUTOMATIC CLICK
    %   FILES - < NONE >
    function updateRadioAutomatic(src,event)
        % IF RADIO IS ALREADY SET TO AUTOMATIC, KEEP BUTTON ON
        if uiLocal.radio_MANUAL.Value == 0
            uiLocal.radio_AUTOMATIC.Value = 1;
            
        % IF RADIO IS NOT SET TO AUTOMATIC, UPDATE BOTH RADIO BUTTONS
        else
            % UPDATE BUTTON VALUES
            uiLocal.radio_AUTOMATIC.Value = 1;
            uiLocal.radio_MANUAL.Value = 0;
            
            % UPDATE SOLVER SETTINGS
            settings.mode = 1;
            
            % SET MANUAL CONTROL PANEL TO INVISIBLE
            set(uiLocal.panel_manual,'Visible','off');
        end
    end

    
    % UPDATE RADIO BUTTONS - STEPPING MODE - ON MANUAL CLICK
    %   FILES - < NONE >
    function updateRadioManual(src,event)
        % IF RADIO IS ALREADY SET TO MANUAL, KEEP BUTTON ON
        if uiLocal.radio_AUTOMATIC.Value == 0
            uiLocal.radio_MANUAL.Value = 1;
            
        % IF RADIO IS NOT SET TO MANUAL, UPDATE BOTH RADIO BUTTONS
        else
            % UPDATE BUTTON VALUES
            uiLocal.radio_AUTOMATIC.Value = 0;
            uiLocal.radio_MANUAL.Value = 1;
            
            % UPDATE SOLVER SETTINGS
            settings.mode = 0;
            
            % SET MANUAL CONTROL PANEL TO VISIBLE
            set(uiLocal.panel_manual,'Visible','on');
        end
    end


%% OTHER FUNCTIONS (NOT CALLBACKS) DEFINITIONS
    
    % CALCULATE LE POINTS
    function [idxGeom, idxThetaMin] = calcLE(x,y)
        
        % FIND LE AS MIN THETA BETWEEN POINTS VIA DOT PRODUCT
        theta = nan(length(x),1);
        for i = 2:length(x)-1
            % CALCULATE VECTOR TO PREVIOUS POINT FROM CURRENT POINT
            v1 = [x(i-1) - x(i) ; y(i-1) - y(i) ; 0];
            
            % CALCUALTE VECTOR TO NEXT POINT FROM CURRENT POINT 
            v2 = [x(i+1) - x(i) ; y(i+1) - y(i) ; 0];
            
            % CALCULATE ANGLE BETWEEN THE TWO VECTORS VIA THE DOT PRODUCT
            theta(i) = acosd( dot(v1,v2) / (norm(v1) * norm(v2)) );
        end
        [~,idxThetaMin] = min(theta);
        
        % FIND LE AS CLOSEST POINT TO ORIGIN
        dist = nan(length(x),1);
        for i = 2:length(x)-1
            % CALCUALTE DISTANCE TO ORIGIN VIA PYTHAGOREAN THEOREM
            dist(i) = sqrt(x(i)^2 + y(i)^2);
        end
        [~,idxGeom] = min(dist);
        
    end


    % DETERMINE TE POINT
    function [xTE, yTE, isBlunt] = locateTE(x,y)
        
        % DETERMINE WHETHER TE IS BLUNT
        if x(1) ~= x(end) || y(1) ~= y(end)
            isBlunt = true;
        else
            isBlunt = false;
        end
        
        % DETERMINE TE LOCATION
        if isBlunt
            % TE IS MEAN OF UPPER AND LOWER BLUNT ENDS
            xTE = mean([x(1) x(end)]);
            yTE = mean([y(1) y(end)]);
        else
            % TE IS SHARP TE LOCATION
            xTE = x(1);
            yTE = y(1);
        end
    end


    % UPDATE PLOT WITH NEW POINTS CALCULATED
    function updatePlot(x,y,idx)
        % SET CURRENT AXES IN CASE OTHER WINDOWS / PLOTS ARE OPEN
        axes(uiLocal.plot_LE);
        cla(uiLocal.plot_LE);
        
        % GET AIRFOIL CALCULATED LE LOCATIONS
        [idGeom, idThetaMin] = calcLE(x,y);
        
        % GET AIRFOIL TE LOCATION
        [xTE, yTE, isBlunt] = locateTE(x,y);
        
        % STORE TE PROPERTIES TO BUFFER STRUCTURE
        bufferLocal(idx).isBlunt = isBlunt;
        bufferLocal(idx).xTE = xTE;
        bufferLocal(idx).yTE = yTE;
        
        % CALCULATE CORRESPONDING CHORDS
        xGeomLE  = x(idGeom);
        yGeomLE  = y(idGeom);
        xThetaLE = x(idThetaMin);
        yThetaLE = y(idThetaMin);
        chordGeom  = norm([xGeomLE-xTE yGeomLE-yTE]);
        chordTheta = norm([xThetaLE-xTE yGeomLE-yTE]);
        
        % DETERMINE VECTORS USED FOR CALCULATING INCIDENCE
        vUpperGeom  = [xGeomLE-xTE yGeomLE-yTE 0];
        vUpperTheta = [xThetaLE-xTE yThetaLE-yTE 0];
        vLower = [-xTE -yTE 0];
        
        % CALCULATE INCIDENCE FOR BOTH CHORDS USING DOT PRODUCT
        incidenceGeom  = acosd( dot(vUpperGeom,vLower)  / (norm(vUpperGeom)*norm(vLower))  );
        incidenceTheta = acosd( dot(vUpperTheta,vLower) / (norm(vUpperTheta)*norm(vLower)) );
        
        % STORE POTENTIAL LEs, CHORDs, AND INCIDENCEs TO AIRFOIL BUFFER STRUCTURE
        bufferLocal(idx).geomID             = idGeom;
        bufferLocal(idx).thetaID            = idThetaMin;
        bufferLocal(idx).chordGeom          = chordGeom;
        bufferLocal(idx).chordTheta         = chordTheta;
        bufferLocal(idx).incidenceGeom      = incidenceGeom;
        bufferLocal(idx).incidenceTheta     = incidenceTheta;
        
        % CREATE ARRAY FOR PLOT OBJECTS
        pObjs = [];
        hold on
        
        % PLOT AIRFOIL
        pObjs(1) = plot(x,y,'k.-');
        
        % PLOT LE POINTS
        pObjs(2) = plot(x(idGeom),y(idGeom),'bo','markersize',12);
        pObjs(3) = plot(x(idThetaMin),y(idThetaMin),'r*','markersize',12);
        
        % PLOT CHORDLINES
        pObjs(4) = plot([xTE xGeomLE],[yTE yGeomLE],'--','color',[0.5 0.5 0.5]);
        pObjs(5) = plot([xTE xThetaLE],[yTE yThetaLE],'--','color',[0.5 0.5 0.5]);
        
        % SETTING AXIS SCALING
        axis equal
        
        % PLOT LEGEND
        legend(pObjs(2:3),'Nearest to Origin','Minimum Curvature','location','north');
        
        % PUSH LE DATA TO LIST BOXES:
        % INDICES
        uiLocal.list_VALUES_GEOM.String{1}  = sprintf('%i',idGeom);
        uiLocal.list_VALUES_THETA.String{1} = sprintf('%i',idThetaMin);
        
        % CHORD
        uiLocal.list_VALUES_GEOM.String{2}  = sprintf('%.4f',chordGeom);
        uiLocal.list_VALUES_THETA.String{2} = sprintf('%.4f',chordTheta);
        
        % INCIDENCE
        uiLocal.list_VALUES_GEOM.String{3}  = sprintf('%.4f deg',incidenceGeom);
        uiLocal.list_VALUES_THETA.String{3} = sprintf('%.4f deg',incidenceTheta);
        
        % (X,Y)
        uiLocal.list_VALUES_GEOM.String{4}  = sprintf('(%.1d,%.1e)',xGeomLE,yGeomLE);
        uiLocal.list_VALUES_THETA.String{4} = sprintf('(%.1e,%.1e)',xThetaLE,yThetaLE);
        
    end
end