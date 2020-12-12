function ui_autoXFOIL(bufferLocal,listString,fParent)
% INPUTS
%   - bufferLocal : structure of local 
%   - listString  : cell array of airfoil list names from buffer window
%   - fParents    : object of parent figure
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
    uiLocal = struct();     % UI ELEMENTS ON LOCAL FIGURE
    settings = struct();    % SETTINGS TO FEED INTO AUTOXFOIL
    
    % DEFINE DEFAULT SETTINGS
    settings.mode = 1;      % SET DEFAULT MODE
    settings.invisc = false;
    settings.incomp = false;
    
    settings.RN = [];       % VECTOR FOR RN VALUES  
    settings.M  = [];       % VECTOR FOR M  VALUES
    
    settings.AOA_max  = 10;
    settings.AOA_min  = -10;
    settings.AOA_up   = 0.25;
    settings.AOA_down = -0.1;
    
    settings.cmref    = 0.25;
    settings.Ncrit    = 9;

    % CREATE AUTOXFOIL GUI WINDOW
    pos = fParent.Position + [ 0.05 -0.05 fParent.Position(3) 0];
    f = figure('Name','autoXFOIL','NumberTitle','off','units','normalized','Position',pos);
    
    
%% MAIN UI LAYOUT - STATIC ELEMENTS
    % TITLES
    % PANELS
    % PANEL LABELS
    
    % TITLE LINE - AUTOXFOIL
    uiLocal.text_title = uicontrol(f,'Style','text','String','autoXFOIL: XFOIL Automation Tool',...
        'Units','normalized','Position',[0.1 0.85 0.8,0.1],...
        'Fontweight','bold','FontSize',14,'FontName',font);
    
    % SOME PANEL SETTINGS
    eOff   = 0.01;          % EDGE OFFSET
    width  = 0.333 - 2*eOff; % PANEL WIDTH
    height = 0.80;          % PANEL HEIGHT
    
    % LEFT PANEL
    uiLocal.panel_left   = uipanel(f,'Position',[eOff 3*eOff width height]);
    
    % CENTER PANEL
    uiLocal.panel_center = uipanel(f,'Position',[eOff+0.333 3*eOff width height]);
    
    % RIGHT PANEL
    uiLocal.panel_right  = uipanel(f,'Position',[eOff+0.666 3*eOff width height]); 
    
    
    
    % SELECT MODE LABEL
    uiLocal.text_center = uicontrol(f,'Style','text','String','Select Mode',...
        'Units','normalized','Position',[eOff*2 0.7 0.333-4*eOff 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % REYNOLDS NUMBER LABEL
    uiLocal.text_sub_left = uicontrol(f,'Style','text','String','Reynolds #',...
        'Units','normalized','Position',[0.35-0.333 0.4 0.125 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % MACH NUMBER LABEL
    uiLocal.text_sub_right = uicontrol(f,'Style','text','String','Mach #',...
        'Units','normalized','Position',[0.525-0.333 0.4 0.125 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % AIRFOILS LABEL
    uiLocal.text_left = uicontrol(f,'Style','text','String','Airfoils',...
        'Units','normalized','Position',[0.333+eOff*2 0.7 0.333-4*eOff 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % ANGLE OF ATTACK LABEL
    uiLocal.text_right_up = uicontrol(f,'Style','text','String','Angle of Attack',...
        'Units','normalized','Position',[0.666+eOff*2 0.7 0.333-4*eOff 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);

    % MOMENT COEFFICIENT REFERENCE LABEL
    uiLocal.text_right_lw = uicontrol(f,'Style','text','String','Moment Coefficient Reference',...
        'Units','normalized','Position',[0.666+eOff*2 0.4-0.025 0.333-4*eOff 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);

    % CMREF SLIDER LABEL - MIN, LE
    uiLocal.text_slider_min = uicontrol(f,'Style','text','String','LE',...
        'Units','normalized','Position',[2*eOff+0.666 0.325-0.025 (width-2*eOff)/4 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font,...
        'HorizontalAlignment','left');
    
    % CMREF SLIDER LABEL - MAX, TE
    uiLocal.text_slider_max = uicontrol(f,'Style','text','String','TE',...
        'Units','normalized','Position',[2*eOff+0.666+(width-2*eOff)/4 0.325-0.025 (width-2*eOff)/4 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font,...
        'HorizontalAlignment','right');
    
    % CMREF SLIDER LABEL - MID, C/2
    uiLocal.text_slider_mid = uicontrol(f,'Style','text','String','c/2',...
        'Units','normalized','Position',[2*eOff+0.666+(width-2*eOff)/8 0.325-0.025 (width-2*eOff)/4 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % NCRIT LABEL
    uiLocal.text_right_dn = uicontrol(f,'Style','text','String','Ncrit (Advanced)',...
        'Units','normalized','Position',[0.666+eOff*2 0.2-0.05 0.333-4*eOff 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % NCRIT SLIDER LABEL - MIN, 4
    uiLocal.text_slider_min = uicontrol(f,'Style','text','String','4',...
        'Units','normalized','Position',[2*eOff+0.666 0.125-0.05 (width-2*eOff)/4 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font,...
        'HorizontalAlignment','left');
    
    % NCRIT SLIDER LABEL - MAX, 14
    uiLocal.text_slider_max = uicontrol(f,'Style','text','String','14',...
        'Units','normalized','Position',[2*eOff+0.666+(width-2*eOff)/4 0.125-0.05 (width-2*eOff)/4 0.05],...
        'Fontweight','bold','FontSize',10,'FontName',font,...
        'HorizontalAlignment','right');
    
    % NCRIT SLIDER LABEL - MID, 9
    uiLocal.text_slider_mid = uicontrol(f,'Style','text','String','9',...
        'Units','normalized','Position',[2*eOff+0.666+(width-2*eOff)/8 0.125-0.05 (width-2*eOff)/4 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    
%% MAIN MENU BUTTONS - GENERAL
    % DEBUG
    % BUTTON - DEBUG
    uiLocal.button_DEBUG = uicontrol(f,'Style','pushbutton','String','Debug',...
        'Units','normalized','Position',[0.4, 0.0125 0.2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);


    
%% MAIN MENU BUTTONS - LEFT PANEL
    % SELECT MODE:
    %   BUTTON GROUP
    %   MODE 1
    %   MODE 2
    %   MODE 3
    % CHECK - INVISCID
    % CHECK - INCOMPRESSIBLE
    % RN LISTBOX
    % M  LISTBOX
    
    % BUTTON GROUP FOR RADIO BUTTONS
    uiLocal.modeGroup = uibuttongroup('Visible','off','Position',[2*eOff 0.525 width-2*eOff 0.2125],...
        'SelectionChangeFcn',@modeSelection);
    
    % RADIO BUTTON 1 - COMPARE AIRFOILS
    uiLocal.radio_MODE1 = uicontrol(uiLocal.modeGroup,'Style','radiobutton',...
        'String','Mode 1: Compare Airfoils at RN and M','Units','normalized',...
        'Position',[2*eOff 0.67 1-1*eOff 0.3],...
        'FontSize',10,'FontName',font);
    
    % RADIO BUTTON 2 - COMPARE RN SWEEPS
    uiLocal.radio_MODE2 = uicontrol(uiLocal.modeGroup,'Style','radiobutton',...
        'String','Mode 2: RN Sweep for an Airfoil at M',...
        'Units','normalized','Position',[2*eOff 0.35 1-1*eOff 0.3],...
        'FontSize',10,'FontName',font);
    
    % RADIO BUTTON 3 - COMPARE M SWEEPS
    uiLocal.radio_MODE3 = uicontrol(uiLocal.modeGroup,'Style','radiobutton',...
        'String','Mode 3: M Sweep for an Airfoil at RN',...
        'Units','normalized','Position',[2*eOff 0.05 1-1*eOff 0.3],...
        'FontSize',10,'FontName',font);
    
    % ACTIVATE BUTTON GROUP
    uiLocal.modeGroup.Visible = 'on';
    
    % CHECKBOX FOR INVISCID
    uiLocal.check_invisc = uicontrol(f,'Style','checkbox',...
        'Units','normalized','Position',[0.35-0.333 0.4 0.125 0.05],...
        'String','Inviscid','FontSize',10,'FontName',font);
    
    % CHECKBOX FOR INCOMPRESSIBLE
    uiLocal.check_incomp = uicontrol(f,'Style','checkbox',...
        'Units','normalized','Position',[0.525-0.333 0.4 0.125 0.05],...
        'String','Incompressible','FontSize',10,'FontName',font);
    
    % LISTBOX FOR RN VALUES
    uiLocal.list_RN = uicontrol(f,'Style','list',...
        'Units','normalized','Position',[0.35-0.333 0.2 0.125 0.2],...
        'String',{},'FontSize',10,'FontName',font);
    
    % LISTBOX FOR M  VALUES
    uiLocal.list_M = uicontrol(f,'Style','list',...
        'Units','normalized','Position',[0.525-0.333 0.2 0.125 0.2],...
        'String',{},'FontSize',10,'FontName',font);
    
    % EDIT BOX FOR RN VALUES
    uiLocal.edit_RN = uicontrol(f,'Style','edit',...
        'Units','normalized','Position',[0.35-0.333 0.15 0.125 0.05],...
        'String','(Enter RN)','FontSize',10,'FontName',font);
    
    % EDIT BOX FOR M  VALUES
    uiLocal.edit_M  = uicontrol(f,'Style','edit',...
        'Units','normalized','Position',[0.525-0.333 0.15 0.125 0.05],...
        'String','(Enter M)','FontSize',10,'FontName',font);
    
    % BUTTON - ADD FOR RN VALUES
    uiLocal.add_RN = uicontrol(f,'Style','pushbutton','String','Add',...
        'Units','normalized','Position',[0.35-0.333 0.1 0.125/2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - ADD FOR M VALUES
    uiLocal.add_M = uicontrol(f,'Style','pushbutton','String','Add',...
        'Units','normalized','Position',[0.525-0.333 0.1 0.125/2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - DELETE RN VALUES
    uiLocal.del_RN = uicontrol(f,'Style','pushbutton','String','Delete',...
        'Units','normalized','Position',[0.35-0.333+0.125/2 0.1 0.125/2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - DELETE M VALUES
    uiLocal.del_M  = uicontrol(f,'Style','pushbutton','String','Delete',...
        'Units','normalized','Position',[0.525-0.333+0.125/2 0.1 0.125/2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    
%% MAIN MANU BUTTONS - CENTER PANEL
        % AIRFOIL BUFFER DISPLAY
    % RENAME
    % RUN ANALYSIS
    % XFOIL DOCS
    
    % LIST - BUFFER AIRFOILS
    uiLocal.list_AIRFOILS = uicontrol(f,'Style','list',...
        'Units','normalized','Position',[3*eOff+0.333 0.35 width-4*eOff 0.385],...
        'Max',length(listString),'String',listString,'FontSize',10,'FontName',font);
    
    % BUTTON - RENAME
    uiLocal.button_RENAME  = uicontrol(f,'Style','pushbutton','String','Rename',...
        'Units','normalized','Position', [0.333/2-0.1+0.333 0.26 0.2 0.075],...
        'Fontweight','bold','FontSize',10,'FontName',font);
    
    % CALL AUTOXFOIL
    uiLocal.RUN_ANALYSIS = uicontrol(f','Style','pushbutton','String','Run Analysis',...
        'Units','normalized','Position',[eOff*2+0.333 0.15 0.333-4*eOff 0.075],...
        'FontSize',14,'Fontweight','bold','FontName',font);

    % DOCS - XFOIL
    uiLocal.docs_XFOIL = uicontrol(f,'Style','pushbutton','String','XFOIL Docs',...
        'Units','normalized','Position',[eOff*2+0.333 0.075 0.333-4*eOff 0.075],...
        'FontSize',12,'Fontweight','bold','FontName',font);
    
    
%% MAIN MENU BUTTONS - RIGHT PANEL
    % AOA SETTING DISPLAY
    % AOA SETTING EDIT
    % AOA UPDATE
    % NCRIT SLIDER
    % NCRIT HELP
    % NCRIT DOCS
    
    % LIST - AOA SETTINGS
    uiLocal.list_AOA = uicontrol(f,'Style','list','String',...
        {'AOA max = 10','AOA min = -10','AOA step+ = 0.25','AOA step- = -0.1'},...
        'Units','normalized','Position',[2*eOff+0.666 0.525 (width-2*eOff)/2 0.2125],...
        'FontSize',10,'FontName',font);
    
    % EDIT - AOA SETTINGS
    uiLocal.edit_AOA = uicontrol(f,'Style','edit','String','10',...
        'Units','Normalized','Position',[eOff+0.833 0.6875 (width-4*eOff)/2 0.05],...
        'FontSize',10,'FontName',font);
    
    % BUTTON - UPDATE AOA
    uiLocal.update_AOA = uicontrol(f,'Style','pushbutton','String','Update',...
        'Units','normalized','Position',[eOff+0.833 0.625 (width-4*eOff)/2 0.05],...
        'FontSize',10,'FontWeight','bold','FontName',font);
    
    % BUTTON - AOA HELP
    uiLocal.help_AOA = uicontrol(f,'Style','pushbutton','String','Help',...
        'Units','normalized','Position',[eOff+0.833 0.525 (width-4*eOff)/2 0.05],...
        'FontSize',10,'FontWeight','bold','FontName',font);
    
    % SLIDER - CMREF
    uiLocal.slider_CMREF = uicontrol(f,'Style','slider','Min',0,'Max',1,'Value',0.25,...
        'Units','normalized','Position',[2*eOff+0.666 0.375-0.025 (width-2*eOff)/2 0.05],...
        'BackgroundColor',[1 1 1]);
    
    % EDIT - CMREF
    uiLocal.edit_CMREF = uicontrol(f,'Style','edit','String','0.25','enable','inactive',...
        'Units','normalized','Position',[eOff+0.833 0.375-0.025 (width-4*eOff)/2 0.05],...
        'FontSize',10,'FontName',font);
    
    % HELP - CMREF
    uiLocal.help_CMREF = uicontrol(f,'Style','pushbutton','String','Help',...
        'Units','normalized','Position',[eOff+0.833 0.325-0.025 (width-4*eOff)/2 0.05],...
        'FontSize',10','Fontweight','bold','FontName',font);
    
    % SLIDER - NCRIT
    uiLocal.slider_NCRIT = uicontrol(f,'Style','slider','Min',4,'Max',14,'Value',9,...
        'Units','normalized','Position',[2*eOff+0.666 0.175-0.05 (width-2*eOff)/2 0.05],...
        'BackgroundColor',[1 1 1]);
    
    % EDIT - NCRIT
    uiLocal.edit_NCRIT   = uicontrol(f,'Style','edit','String','9','enable','inactive',...
        'Units','normalized','Position',[eOff+0.833 0.175-0.05 (width-4*eOff)/2 0.05],...
        'FontSize',10,'FontName',font);
    
    % HELP - NCRIT
    uiLocal.help_NCRIT   = uicontrol(f,'Style','pushbutton','String','Help',...
        'Units','normalized','Position',[eOff+0.833 0.125-0.05 (width-4*eOff)/4 0.05],...
        'FontSize',10,'Fontweight','bold','FontName',font);

    % DOCS - NCRIT
    uiLocal.docs_NCRIT   = uicontrol(f,'Style','pushbutton','String','Docs',...
        'Units','normalized','Position',[eOff+0.833+(width-4*eOff)/4 0.125-0.05 (width-4*eOff)/4 0.05],...
        'FontSize',10,'Fontweight','bold','FontName',font);
        

%% CALLBACK FUNCTION ASSIGNMENTS
    % DEBUG - debugTool()
    
    % CALLBACKS DEFINED LOCALLY
    uiLocal.button_DEBUG.Callback  = @debugTool;
    uiLocal.button_RENAME.Callback = @renameAirfoil;
    uiLocal.radio_MODE1.Callback   = @setMode1;
    uiLocal.radio_MODE2.Callback   = @setMode2;
    uiLocal.radio_MODE3.Callback   = @setMode3;
    
    uiLocal.check_invisc.Callback  = @setInvisc;
    uiLocal.check_incomp.Callback  = @setIncomp;
    uiLocal.add_RN.Callback        = @addReynolds;
    uiLocal.add_M.Callback         = @addMach;
    uiLocal.del_RN.Callback        = @deleteReynolds;
    uiLocal.del_M.Callback         = @deleteMach;
    
    uiLocal.list_AOA.Callback      = @updateEditAOA;
    uiLocal.update_AOA.Callback    = @updateListAOA;
    uiLocal.help_AOA.Callback      = @helpAOA;
    
    uiLocal.slider_CMREF.Callback  = @updateEditCMREF;
    uiLocal.help_CMREF.Callback    = @helpCMREF;
    
    uiLocal.slider_NCRIT.Callback  = @updateEditNCRIT;
    uiLocal.help_NCRIT.Callback    = @helpNCRIT;
    uiLocal.docs_NCRIT.Callback    = @docsNCRIT;
    
    uiLocal.docs_XFOIL.Callback    = @docsXFOIL;
    uiLocal.RUN_ANALYSIS.Callback  = @runAnalysis;
    
%% CALLBACK FUNCTION DEFINITIONS

    % DEBUG BUTTON - ON CLICK, PAUSE TO ALLOW VIEWING DATA STRUCTURES
    %   FILES - < NONE >
    function debugTool(src,event)
        bufferLocal;
        uiLocal;
    end


    % RENAME BUTTON - ON CLICK, PROMPT TO RENAME FOIL IF ONLY ONE IS CHOSEN
    %   FILES - < NONE >
    function renameAirfoil(src,event)
        if length(uiLocal.list_AIRFOILS.Value) > 1
            % DISPLAY AN ERROR IF THE BUTTON IS CLICK W/ > 1 FOIL SELECTED
            msgbox('Only one airfoil may be renamed at a time!','Error','error');
        else
            % PROMPT FOR NEW NAME FOR AIRFOIL
            newName = inputdlg('Enter new name for airfoil:','Rename Airfoil',[1 60]);
            
            % CHANGE STRING NAME IF A NAME IS ENTERED IN DIALOG BOX
            if ~isempty(newName)
                id = uiLocal.list_AIRFOILS.Value;
                uiLocal.list_AIRFOILS.String(id) = newName;
                bufferLocal(id).name = newName;
            end
                
        end
    end
       

    % MODE SELECTION BUTTONS - CHANGE
    %   FILES - < NONE >
    function modeSelection(src,event)
        % DO NOTHING - BUTTON CLICKS ARE MANAGED BY EACH BUTTON'S CALLBACK
    end


    % RADIO - SET MODE 1 (AIRFOIL SWEEP)
    %   FILES - < NONE >
    function setMode1(src,event)
        % UPDATE AIRFOIL LISTBOX SETTINGS
        uiLocal.list_AIRFOILS.Max = length(uiLocal.list_AIRFOILS.String);
        
        % UPDATE AUTOXFOIL SETTINGS
        settings.mode = 1;
        
        % UPDATE RN AND M LISTBOX SETTINGS
        uiLocal.list_RN.Value = 1;
        uiLocal.list_M.Value  = 1;
        uiLocal.list_RN.Max   = 1;
        uiLocal.Lost_M.Max    = 1;
    end

    % RADIO - SET MODE 2 (RN SWEEP)
    %   FILES - < NONE >
    function setMode2(src,event)
        % UPDATE AIRFOIL LISTBOX SETTINGS
        uiLocal.list_AIRFOILS.Value = 1;
        uiLocal.list_AIRFOILS.Max   = 1;
        
        % UPDATE AUTOXFOIL SETTINGS
        settings.mode = 2;
        
        % UPDATE RN AND M LISTBOX SETTINGS
        if length(uiLocal.list_RN.String) == 0
            uiLocal.list_RN.Max = 1;
        else
            uiLocal.list_RN.Max = length(uiLocal.list_RN.String);
        end
        uiLocal.list_M.Value = 1;
        uiLocal.list_M.Max   = 1;
        
    end


    % RADIO - SET MODE 3 (M SWEEP)
    %   FILES - < NONE >
    function setMode3(src,event)
        % UPDATE AIRFOIL LISTBOX SETTINGS
        uiLocal.list_AIRFOILS.Value = 1;
        uiLocal.list_AIRFOILS.Max   = 1;
        
        % UPDATE AUTOXFOIL SETTINGS
        settings.mode = 3;
        
        % UPDATE RN AND M LISTBOX SETTINGS
        if length(uiLocal.list_M.String) == 0
            uiLocal.list_M.Max = 1;
        else
            uiLocal.list_M.Max = length(uiLocal.list_M.String);
        end
        uiLocal.list_RN.Value = 1;
        uiLocal.lsit_RN.Max   = 1;
        
    end

    % CHECK - SET INVISCID
    %   FILES - < NONE >
    function setInvisc(src,event)
        % UPDATE AIRFOIL LISTBOX SETTINGS
        uiLocal.list_RN.Value  = 1;
        uiLocal.list_RN.Max    = 1;
        uiLocal.list_RN.String = {};
        
        % UPDATE AUTOXFOIL SETTINGS
        settings.M = [];
        settings.invisc = int8(uiLocal.check_invisc.Value);
    end

    % CHECK - SET INCOMPRESSIBLE
    % FILES - < NONE >
    function setIncomp(src,event)
        % UPDATE AIRFOIL LISTBOX SETTINGS
        uiLocal.list_M.Value  = 1;
        uiLocal.list_M.Max    = 1;
        uiLocal.list_M.String = {};
        
        % UPDATE AUTOXFOIL SETTINGS
        settings.RN = [];
        settings.incomp = int8(uiLocal.check_incomp.Value);
    end

    % BUTTON - ADD RN
    %   FILES - < NONE >
    function addReynolds(src,event)
        % CHECK IF INVISCID IS FLAGGED - IF IT IS, RETURN
        if uiLocal.check_invisc.Value == 1
            msgbox('Deselect ''Inviscid'' to Enter Reynolds Numbers','Notice','warn');
            return
        end
        
        % CATCH TYPECASTING FAILURES
        try
            % CHECK IF VALID ENTRY - IF IT ISN'T, RETURN
            text = uiLocal.edit_RN.String;
            num = str2num(text);
            if num < 0 || isempty(num)
                msgbox('Invalid Reynolds Number!','Error','error');
                return
            end
            
            % UPDATE LISTBOX
            uiLocal.list_RN.String{end+1} = text;
            if settings.mode == 2
                uiLocal.list_RN.Max = length(uiLocal.list_RN.String);
            else
                uiLocal.list_RN.Max = 1;
            end
            
            % UPDATE SETTINGS
            settings.RN(end+1) = num;
            
            % CLEAR LISTBOX
            uiLocal.edit_RN.String = '';
        catch
            msgbox('Invalid Reynolds Number!','Error','error');
            return
        end
    end
    

    % BUTTON - ADD M
    %   FILES - < NONE >
    function addMach(src,event)
        % CHECK IF ICOMPRESSIBLE IS FLAGGED - IF IT IS, RETURN
        if uiLocal.check_incomp.Value == 1
            msgbox('Deselect ''Incompressible'' to Enter Mach Numbers','Notice','warn');
            return
        end
        
        % CATCH TYPECASTING FAILURES
        try
            % CHECK IF VALID ENTRY - IF IT ISN'T, RETURN
            text = uiLocal.edit_M.String;
            num = str2num(text);
            if num < 0 || isempty(num)
                msgbox('Invalid Mach Number!','Error','error');
                return
            end
            
            % UPDATE LISTBOX
            uiLocal.list_M.String{end+1} = text;
            if settings.mode == 3
                uiLocal.list_M.Max = length(uiLocal.list_RN.String);
            else
                uiLocal.list_RN.Max = 1;
            end
            
            % UPDATE SETTINGS
            settings.M(end+1) = num;
            
            % CLEAR LISTBOX
            uiLocal.edit_M.String = '';
            
        catch
            msgbox('Invalid Mach Number!','Error','error');
            return
        end
    end

    
    % BUTTON - DELETE RN
    %   FILES - < NONE >
    function deleteReynolds(src,event)
        % IF NOTHING IN LIST, RETURN
        if length(uiLocal.list_RN.String) == 0
            return
        end
        
        % GET INDICES OF ELEMENTS TO BE DELETED
        idx = uiLocal.list_RN.Value;
        
        % UPDATE LIST
        uiLocal.list_RN.String(idx) = [];
        
        % SELECT FIRST VALUE IN LIST
        uiLocal.list_RN.Value       = 1;
        
        % UPDATE NUMBER OF VALUES THAT CAN BE SELECTED IN LIST
        if length(uiLocal.list_RN.String) == 0
            uiLocal.list_RN.Max = 1;
        elseif settings.mode == 2
            uiLocal.list_RN.Max = length(uiLocal.list_RN.String);
        else
            uiLocal.list_RN.Max = 1;
        end
        
        % UPDATE AUTOXFOIL SETTINGS
        settings.RN(idx) = [];
    end


    % BUTTON - DELETE M
    %   FILES - < NONE >
    function deleteMach(src,event)
        % IF NOTHING IN LIST, RETURN
        if length(uiLocal.list_M.String) == 0
            return
        end
        
        % GET INDICES OF ELEMENTS TO BE DELETED
        idx = uiLocal.list_M.Value;
        
        % UPDATE LIST
        uiLocal.list_M.String(idx) = [];
        
        % SELECT FIRST VALUE IN LIST
        uiLocal.list_M.Value       = 1;
        
        % UPDATE NUMBER OF VALUES THAT CAN BE SELECTED IN LIST
        if length(uiLocal.list_M.String) == 0
            uiLocal.list_M.Max = 1;
        elseif settings.mode == 3
            uiLocal.list_M.Max = length(uiLocal.list_M.String);
        else
            uiLocal.list_M.Max = 1;
        end
        
        %UPDATE AUTOXFOIL SETTINGS
        settings.M(idx) = [];
    end


    % UPDATE AOA EDIT FIELD BASED ON LIST SELECTION
    %   FILES - < NONE >
    function updateEditAOA(src,event)
        % GET POSITION AND TEXT OF SELECTED ENTRY
        idx = uiLocal.list_AOA.Value;
        text = uiLocal.list_AOA.String{idx};
        
        % GET INDEX OF EQUALS SIGN
        ids = strfind(text,'=');
        
        % UPDATE AOA EDIT FIELD
        uiLocal.edit_AOA.String = text(ids+2:end);
    end


    % UPDATE AOA LIST ON BUTTON PRESS
    %   FILES - < NONE >
    function updateListAOA(src,event)
        % GET INDEX OF CURRENTLY SELECTED LIST ITEM
        listID = uiLocal.list_AOA.Value;
        
        % GET INDEX OF EQUALS SIGN FROM LISTBOX STRING
        equalID = strfind(uiLocal.list_AOA.String{listID},'=');
        
        % GET TEXT FROM EDIT BOX
        text = uiLocal.edit_AOA.String;
        
        % TRY TO TYPECAST VALUE FROM EDIT BOX
        try
            num = str2num(text);
            if isempty(num)
                msgbox('Invalid Entry!','Error','error');
                return
            end
            
            % CHECK IF ALPHA STEP UP IS GREATER THAN ZERO - IF NOT, RETURN
            if listID == 3
                if num <= 0
                    msgbox({'Invalid Entry!','Entry must be greater than 0.'},'Error','error');
                    return
                end
            end
            
            % CHECK IF ALPHA STEP DOWN IS LESS THAN ZERO - IF NOT, RETURN
            if listID == 4
                if num >= 0
                    msgbox({'Invalid Entry!','Entry must be less than 0.'},'Error','error');
                    return
                end
            end
            
            % CHECK IF ALPHA MAX > ALPHA MIN - IF NOT, WARN BUT ALLOW
            % (ONE HAS TO BE CHANGED FIRST)
            if listID == 1
                if num < settings.AOA_min
                    msgbox('Warning: AOA max should be greater than AOA min.','Warning','warn');
                end
            end
            if listID == 2
                if num > settings.AOA_max
                    msgbox('Warning: AOA min should be less than AOA min.','Warning','warn');
                end
            end
            
            % IF HAVEN'T RETURNED BY THIS POINT, STORE VALID VALUE
            % UPDATE LISTBOX DISPLAY
            switch listID
                case 1
                    settings.AOA_max = num;
                case 2
                    settings.AOA_min = num;
                case 3
                    settings.AOA_up = num;
                case 4
                    settings.AOA_down = num;
            end
            
            % UPDATE LISTBOX STRING
            currentStr = uiLocal.list_AOA.String{listID};
            uiLocal.list_AOA.String{listID} = [currentStr(1:equalID+1) num2str(num)];
            
            % CHECK IF 0 IS INCLUDED IN AOA RANGE - IF NOT, WARN BUT ALLOW
            if (settings.AOA_max < 0 || settings.AOA_min > 0) && (listID == 1 || listID == 2)
                msgbox('Warning: It is highly recommended that the range between AOA min and AOA max incldude zero.','Warning','warn');
            end
            
        catch
            msgbox('Invalid Entry!','Error','error');
            return
        end
    end
    

    % HELP AOA - OPEN HELP WINDOW EXPLAINING AOA SETTINGS
    %   FILES - < NONE >
    function helpAOA(src,event)
        % TEXT FOR MESSAGE BOX
        text = {
            'AOA max   : maximum angle of attack',...
            'AOA min   : minimum angle of attack',...
            'AOA step+ : step size forward (default generally recommended)',...
            'AOA step- : step size backward (default generally recommended)',...
            ' ',...
            'Forward step size is used to increment from 0 up to AOA max (for AOA min < 0, AOA max > 0) or from AOA min to AOA max (for AOA min, AOA max > 0).',...
            ' ',...
            'Backward step size is used to increment from 0 back to AOA min (for AOA min < 0, AOA max > 0) or from AOA max to AOA min (for AOA min, AOA max < 0).',...
            ' ',...
            'For AOA min > 0, AOA step- is unused.',...
            'For AOA max < 0, AOA step+ is unused.'
            };
        
        % CREATE MESSAGE BOX
        msgbox(text,'Angle of Attack Help','help');
    end


    % UPATE EDIT CMREF - PUSH ROUNDED SLIDER VALUE TO EDIT BOX
    %   FILES - < NONE >
    function updateEditCMREF(src,event)
        % GET CURRENT SLIDER VALUE
        val = uiLocal.slider_CMREF.Value;
        
        % ROUND VALUE TO 2 DECIMAL POITNS
        val = round(val,2);
        
        % UPDATE SLIDER VALUE, EDIT BOX, AND SETTINGS
        uiLocal.slider_CMREF.Value = val;
        uiLocal.edit_CMREF.String  = sprintf('%.2f',val);
        settings.cmref             = val;
    end

    
    % HELP CMREF - OPEN MESSAGE
    %   FILES - < NONE >
    function helpCMREF(src,event)
        % TEXT FOR MESSAGE BOX
        text = {
        'The moment reference coefficient is the chordwise location about which the pitching moment is measured.',...
        'The default value is 0.25, corresponding to the quarter-chord location, and this is recommended for general use.',...
        'A value of ''0'' corresponds to the Leading Edge, and ''1'' to the Trailing Edge.'
        };
    
        % CREATE MESSAGE BOX
        msgbox(text,'CMREF Help','help');
    end
    

    % UPDATE EDIT NCRIT - PUSH ROUNDED SLIDER VALUE TO EDIT BOX
    %   FILES - < NONE >
    function updateEditNCRIT(src,event)
        % GET CURRENT SLIDER VALUE
        val = uiLocal.slider_NCRIT.Value;
        
        % ROUND VALUE TO NEAREST DECIMAL POINT
        val = round(val,1);
        
        % UPDATE SLIDER VALUE, EDIT BOX, AND SETTINGS
        uiLocal.slider_NCRIT.Value = val;
        uiLocal.edit_NCRIT.String  = sprintf('%.1f',val);
        settings.Ncrit             = val;
        
    end

    
    % HELP NCRIT - OPEN MESSAGE
    %   FILES - < NONE >
    function helpNCRIT(src,event)
        % TEXT FOR MESSAGE BOX
        text = {
        '''NCrit'' is a parameter used by XFOIL to define the turbulence level.',...
        'The default value is 9, and this is recommended for general use.',...
        'XFOIL documentation on Ncrit and the turbulence level can be found by selecting ''Docs''.'
        };
    
        % CREATE MESSAGE BOX
        msgbox(text,'Ncrit Help','help');
        
    end
    

    % DOCS NCRIT - OPEN DOCS EXCERPT
    %   FILES - < bin\docs_ncrit.txt >
    function docsNCRIT(src,event)
        % OPEN DOCS
        system('start bin\docs_ncrit.txt'); 
    end
        

    % DOCS XFOIL - OPEN XFOIL DOCS
    %   FILES - < bin\docs_xfoil.txt >
    function docsXFOIL(src,event)
        % OPEN DOCS
        system('start bin\docs_xfoil.txt');
    end

    
    % RUN ANALYSIS - CALL AUTOXFOIL
    %   FILES - < bin\autoXFOIL.m >
    function runAnalysis(src,event)
        % GET INDICES OF SELECTED AIRFOILS
        idcs = uiLocal.list_AIRFOILS.Value;
        
        % CHECK TO MAKE SURE INPUTS ARE VALID
        % ALL INPUTS EXCEPT AOAMAX AND AOA MIN ARE PREVIOUSLY CHECKED
        if settings.AOA_max <= settings.AOA_min
            msgbox('Make sure AOA max > AOA min before running!','Warning','warn')
        else
            % CALL AUTOXFOIL
            newBuffer = bufferLocal(idcs);
            autoXFOIL(newBuffer,settings);
        end
    end
    
end