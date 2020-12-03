function main
    ver = 'v 0.1 (alpha)';

    % CREATE MAIN FIGURE GUI WINDOW
    f = figure('Name','ATS (alpha v 0.1)','NumberTitle','off','units','normalized');
    font = 'Comic Sans MS';

    % PRE-ALLOCATE STRUCTURES
    uiElem = struct();          % STRUCTURE OF BUTTONS ON MAIN GUI
    bufferAirfoils = struct();  % STRUCTURE OF AIRFOILS THAT HAVE BEEN LOADED IN BY USER
    bufferAirfoils.new = true;  % PROPERTY INITIALIZATION USED FOR ASSIGNING INDICES TO AIRFOILS LOADED IN

%% MAIN UI LAYOUT - STATIC ELEMENTS
    % TITLES
    % PANELS
    % PANEL LABELS
    
    % PANEL AROUND LEFT SIDE UI ELEMENTS
    uiElem.panel_left  = uipanel(f,'Position',[0.10 0.10 0.35 0.60]);
    
    % PANEL AROUND RIGHT SIDE UI ELEMENTS
    uiElem.panel_right = uipanel(f,'Position',[0.55 0.10 0.35 0.60]);
    
    % TITLE LINE - AIRFOIL TOOL SUITE
    uiElem.text_title = uicontrol(f,'Style','text','String','Welcome to Airfoil Tool Suite',...
        'Units','normalized','Position',[0.1 0.8 0.8 0.1],...
        'Fontweight','bold','FontSize',14,'FontName',font);
    
    % AUTHOR LINE - DEVELOPED BY ANDREW MISTELE
    uiElem.text_author = uicontrol(f,'Style','text','String','Developed by Andrew Mistele (2020)',...
        'Units','normalized','Position',[0.1 0.75 0.8 0.1],...
        'Fontweight','bold','FontSize',10,'FontName',font);
    
    % VERSION LINE - CURRENT TOOL VERSION
    uiElem.text_version = uicontrol(f,'Style','text','String',ver,...
        'Units','normalized','Position',[0.1 0.7125 0.8 0.1],...
        'Fontweight','bold','FontSize',10,'FontName',font);

    % LEFT PANEL LABEL - TOOLS
    ui.Elem.text_left = uicontrol(f,'Style','text','String','Tools',...
        'Units','normalized','Position',[0.125 0.575 0.3 0.1],...
        'FontWeight','bold','FontSize',12,'FontName',font);

    % RIGHT PANEL LABEL - AIRFOILS (BUFFER)
    ui.Elem.text_right = uicontrol(f,'Style','text','String','Airfoils',...
        'Units','normalized','Position',[0.575 0.575 0.3 0.1],...
        'FontWeight','bold','FontSize',12,'FontName',font);

    
%% MAIN MENU BUTTONS - LEFT SIDE
    % AUTOXFOIL
    % CAMBER UTILS
    % LERFINDER
    
    % BUTTON - AUTOXFOIL
    uiElem.button_autoXFOIL     = uicontrol(f,'Style','pushbutton','String','autoXFOIL',...
        'Units','normalized','Position',[0.125 0.5 0.3 0.1],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - CAMBERUTILS
    uiElem.button_CAMBERUTILS   = uicontrol(f,'Style','pushbutton','String','CamberUtils',...
        'Units','normalized','Position',[0.125 0.375 0.3 0.1],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - LERFINDER
    uiElem.button_LERFINDER     = uicontrol(f,'Style','pushbutton','String','LERfinder',...
        'Units','normalized','Position',[0.125 0.250 0.3 0.1],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - HELP
    uiElem.button_HELP          = uicontrol(f,'Style','pushbutton','String','Help',...
        'Units','normalized','Position',[0.175 0.125 0.2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);


%% MAIN MENU BUTTONS - RIGHT SIDE
    % LOAD
    % AIRFOIL BUFFER DISPLAY
    % REPANEL
    % DELETE
    
    % BUTTON - LOAD NEW
    uiElem.button_LOAD    = uicontrol(f,'Style','pushbutton','String','Load New',...
        'Units','normalized','Position',[0.625 0.550 0.20 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - REPANEL
    uiElem.button_REPANEL = uicontrol(f,'Style','pushbutton','String','Repanel',...
        'Units','normalized','Position',[0.625 0.175 0.20 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % BUTTON - DELETE
    uiElem.button_DELETE  = uicontrol(f,'Style','pushbutton','String','Delete',...
        'Units','normalized','Position',[0.625 0.125 0.20 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    % LIST - BUFFER AIRFOILS
    uiElem.list_AIRFOILS  = uicontrol(f,'Style','list',...
        'Units','normalized','Position',[0.575  0.250 0.30 0.275],...
        'String',{},'FontName',font);

%% MAIN MENU BUTTONS - DEBUG
    % DEBUG
    
    % BUTTON - DEBUG
    uiElem.button_DEBUG = uicontrol(f,'Style','pushbutton','String','Debug',...
        'UNits','normalized','Position',[0.4, 0.025 0.2 0.05],...
        'FontWeight','bold','FontSize',10,'FontName',font);
    
    
%% CALLBACK FUNCTION ASSIGNMENTS
    % HELP    - openHelp()
    % LOAD    - loadAirfoil()
    % DELETE  - deleteAirfoil()
    % REPANEL - repanelAirfoil()
    
    uiElem.button_HELP.Callback    = @openHelp;
    uiElem.button_LOAD.Callback    = @loadAirfoil;
    uiElem.button_DELETE.Callback  = @deleteAirfoil;
    uiElem.button_REPANEL.Callback = @repanelAirfoil;
    uiElem.button_DEBUG.Callback   = @debugTool;


%% CALLBACK FUNCTION DEFINITIONS

    % HELP BUTTON - ON BUTTONCLICK, OPEN HELP FILE
    %   FILES - HELP.TXT
    function openHelp(src,event)
        system('start help.txt');
    end
    

    % LOAD BUTTON - ON BUTTONCLICK, OPEN FILE SELECTION MENU
    %   FILES - < ANY LOADED AIRFOIL >
    %   READS IN RAW AIRFOIL DATA AND STORES TO AIRFOIL BUFFER
    function loadAirfoil(src,event)
        
        % UI LOAD FILE
        [file,path] = uigetfile({'*.dat';'*.txt'},'Select Airfoil Coordinates File');
        
        % GET RELATIVE PATH TO FILE FROM ABSOLUTE PATH
        relpath = relativepath(path);
        
        % IF NO FILE IS SELECTED
        if isequal(file,0)
            % DO NOTHING
            
        % IF A FILE IS SELECTED
        else
            
            % READ IN RAW AIRFOIL DATA FROM THE FILE
            raw = load([path file]);
            
            % DETERMINE NEXT BUFFER INDEX
            if length(bufferAirfoils) == 0 || bufferAirfoils(1).new % determine next buffer index
                
                % IF STRUCT IS NEW OR FOIL HAS BEEN DELETED, INDEX = 1
                i = 1;
            else
                % IF OTHER FOILS HAVE BEEN LOADED, INDEX = end+1
                i = length(bufferAirfoils)+1;
            end
            
            % STORE AIRFOIL DATA FROM "raw" TO BUFFER
            %   .RELPATH is FOR XFOIL CALLS TO PREVENT PATH LENGTH OVERFLOW
            bufferAirfoils(i).x       = raw(:,1);
            bufferAirfoils(i).y       = raw(:,2);
            bufferAirfoils(i).pts     = length(bufferAirfoils(i).x);
            bufferAirfoils(i).name    = file(1:end-4);
            bufferAirfoils(i).path    = [path file];
            bufferAirfoils(i).relpath = [relpath file];
            
            % FLAG STRUCTURE AS NO LONGER NEW
            bufferAirfoils(1).new = false;
            
            % UPDATE LIST WITH FORMATTED AIRFOIL NAME
            uiElem.list_AIRFOILS.String{end+1} = [bufferAirfoils(i).name sprintf(' (%i pts)',bufferAirfoils(i).pts)];
            
            % UPDATE PROPERTY STORING NUMBER OF AIRFOILS IN THE LIST
            uiElem.list_AIRFOILS.Max = length(uiElem.list_AIRFOILS.String);
        end
    end


    % DELETE BUTTON - ON CLICK, REMOVE SELECTED AIRFOIL(S) FROM BUFFER
    %   FILES - < NONE >
    function deleteAirfoil(src,event) % remove airfoil from listbox
        if length(uiElem.list_AIRFOILS.String) > 0
            
            % INDEX(ICES) OF AIRFOILS SELECTED FROM LIST
            idx = uiElem.list_AIRFOILS.Value;
            
            % REMOVE AIRFOILS FROM UI LIST
            uiElem.list_AIRFOILS.String(idx) = [];
            
            % REMPVE AIRFOIL FROM BUFFER STRUCTURE
            bufferAirfoils(idx) = [];
            
            % SELECT FIRST AIRFOIL IN LIST
            uiElem.list_AIRFOILS.Value = 1;
            
            % RE-UPDATE NUMBER OF AIRFOILS IN BUFFER
            uiElem.list_AIRFOILS.Max = length(bufferAirfoils);
        end
    end
    
    
    % REPANEL BUTTON - ON CLICK, USE XFOIL TO REPANEL AIRFOIL TO 494 POINTS
    %   FILES - bin\xfoil
    function repanelAirfoil(src,event)
        
        % FOR EACH SELECTED AIRFOIL
        for k = 1:length(uiElem.list_AIRFOILS.Value)
            
            % INDEX OF SELECTED AIRFOIL FOR CURRENT ITERATION
            i = uiElem.list_AIRFOILS.Value(k);
            
            % WRITE XFOIL SCRIPT TO RE-PANEL AIRFOIL
            fhand = fopen('repanel.txt','w');
            fprintf(fhand,'LOAD %s\n\n',bufferAirfoils(i).relpath);
            fprintf(fhand,'ppar\n');
            fprintf(fhand,'n 494\n\n\n');
            
            % DOING FILE PATH MANIPULATION
            idxs = find(bufferAirfoils(i).relpath == '\' | bufferAirfoils(i).relpath == '/');
            idx = idxs(end); % chopping off absolute path to avoid XFOIL filename truncation due to memory overflow
            
            % CONTINUE WRITING XFOIL SCRIPT
            fprintf(fhand,'PSAVE %s\n\n',[bufferAirfoils(i).relpath(idx+1:end-4) '-HiRes',bufferAirfoils(i).relpath(end-3:end)]);
            fprintf(fhand,'quit\n\n');
            fprintf(fhand,'repanel.txt (END)');
            
            % EXECUTE XFOIL SCRIPT
            fclose(fhand);
            system('bin\xfoil\xfoil.exe < repanel.txt');
            delete('repanel.txt');
            
            % READ IN RE-PANELED AIRFOIL DATA FROM XFOIL OUTPUT
            raw = load([bufferAirfoils(i).path(idx+1:end-4) '-HiRes',bufferAirfoils(i).path(end-3:end)]);
            j = length(bufferAirfoils) + 1;
            bufferAirfoils(j).x = raw(:,1); % store airfoil data to buffer
            bufferAirfoils(j).y = raw(:,2);
            bufferAirfoils(j).pts  = length(bufferAirfoils(j).x);
            bufferAirfoils(j).name = [bufferAirfoils(i).relpath(idx+1:end-4) '-HiRes'];
            bufferAirfoils(j).path = [pwd '\' bufferAirfoils(j).name bufferAirfoils(i).path(end-3:end)];
            
            % CREATE LIST NAME FOR NEWLY READ-IN AIRFOIL
            uiElem.list_AIRFOILS.String{end+1} = [bufferAirfoils(j).name sprintf(' (%i pts)',bufferAirfoils(j).pts)]; % update listbox
     
        end
        
        % UPDATE NUMBER OF AIRFOILS IN BUFFER LIST
        uiElem.list_AIRFOILS.Max = length(uiElem.list_AIRFOILS.String); % increasing number of airfoils that can be selected by number of new airfoils
    end
            
    
    % DEBUG BUTTON - ON CLICK, PAUSE TO ALLOW VIEWING DATA STRUCTURES
    %   FILES - < NONE >
    function debugTool(src,event)
        bufferAirfoils;
        uiElem;
    end
            
            
            



end