function main
    ver = 'v 0.1 (alpha)';

    f = figure('Name','ATS (alpha v 0.1)','NumberTitle','off','units','normalized');

    uiElem = struct();
    bufferAirfoils = struct();
    bufferAirfoils.new = true;

    %% main UI layout
    uiElem.panel_left  = uipanel(f,'Position',[0.10 0.10 0.35 0.60]); % panel around left side UI elements
    uiElem.panel_right = uipanel(f,'Position',[0.55 0.10 0.35 0.60]); % panel around right side UI elements
    uiElem.text_title = uicontrol(f,'Style','text','String','Welcome to Airfoil Tool Suite',... % title for the UI
        'Units','normalized','Position',[0.1 0.8 0.8 0.1],...
        'Fontweight','bold','FontSize',14,'FontName','Comic Sans MS');
    uiElem.text_author = uicontrol(f,'Style','text','String','Developed by Andrew Mistele (2020)',... % author for the UI
        'Units','normalized','Position',[0.1 0.75 0.8 0.1],...
        'Fontweight','bold','FontSize',10,'FontName','Comic Sans MS');
    uiElem.text_version = uicontrol(f,'Style','text','String',ver,... % current version for the UI
        'Units','normalized','Position',[0.1 0.7125 0.8 0.1],...
        'Fontweight','bold','FontSize',10,'FontName','Comic Sans MS');

    ui.Elem.text_left = uicontrol(f,'Style','text','String','Tools',... % left panel label
        'Units','normalized','Position',[0.125 0.575 0.3 0.1],...
        'FontWeight','bold','FontSize',12,'FontName','Comic Sans MS');

    ui.Elem.text_right = uicontrol(f,'Style','text','String','Airfoils',... % right panel label
        'Units','normalized','Position',[0.575 0.575 0.3 0.1],...
        'FontWeight','bold','FontSize',12,'FontName','Comic Sans MS');

    %% Left Side Main Menu Buttons
    uiElem.button_autoXFOIL     = uicontrol(f,'Style','pushbutton','String','autoXFOIL',... % autoXFOIL button
        'Units','normalized','Position',[0.125 0.5 0.3 0.1],...
        'FontWeight','bold','FontSize',10);
    uiElem.button_CAMBERUTILS   = uicontrol(f,'Style','pushbutton','String','CamberUtils',... % CamberUtils button
        'Units','normalized','Position',[0.125 0.375 0.3 0.1],...
        'FontWeight','bold','FontSize',10);
    uiElem.button_LERFINDER     = uicontrol(f,'Style','pushbutton','String','LERfinder',... % LERfinder button
        'Units','normalized','Position',[0.125 0.250 0.3 0.1],...
        'FontWeight','bold','FontSize',10);
    uiElem.button_HELP          = uicontrol(f,'Style','pushbutton','String','Help',... % help button
        'Units','normalized','Position',[0.175 0.125 0.2 0.05],...
        'FontWeight','bold','FontSize',10);

    %% Right Side Main Menu Buttons
    uiElem.button_LOAD    = uicontrol(f,'Style','pushbutton','String','Load New',...
        'Units','normalized','Position',[0.625 0.550 0.20 0.05],...
        'FontWeight','bold','FontSize',10);
    uiElem.button_REPANEL = uicontrol(f,'Style','pushbutton','String','Repanel',...
        'Units','normalized','Position',[0.625 0.175 0.20 0.05],...
        'FontWeight','bold','FontSize',10);
    uiElem.button_DELETE  = uicontrol(f,'Style','pushbutton','String','Delete',...
        'Units','normalized','Position',[0.625 0.125 0.20 0.05],...
        'FontWeight','bold','FontSize',10);
    uiElem.list_AIRFOILS  = uicontrol(f,'Style','list',...
        'Units','normalized','Position',[0.575  0.250 0.30 0.275],...
        'String',{});

    %% Callback function assignments

    uiElem.button_HELP.Callback    = @openHelp;
    uiElem.button_LOAD.Callback    = @loadAirfoil;
    uiElem.button_DELETE.Callback  = @deleteAirfoil;
    uiElem.button_REPANEL.Callback = @repanelAirfoil;




    %% Callback functions

    function openHelp(src,event) % open help file when help button is pressed
        system('start help.txt');
    end

    function loadAirfoil(src,event) % load airfoil data and display in listbox
        [file,path] = uigetfile({'*.txt';'*.dat'},'Select Airfoil Coordinates File');
        if isequal(file,0)
            % do nothing since no file was selected
        else
            raw = load([path file]); % read in airfoil
            if length(bufferAirfoils) == 0 || bufferAirfoils(1).new % determine next buffer index
                i = 1;
            else
                i = length(bufferAirfoils)+1;
            end
            bufferAirfoils(i).x = raw(:,1); % store airfoil data to buffer
            bufferAirfoils(i).y = raw(:,2);
            bufferAirfoils(i).pts  = length(bufferAirfoils(i).x);
            bufferAirfoils(i).name = file(1:end-4);
            bufferAirfoils(i).path = [path file];
            
            bufferAirfoils(1).new = false;
            
            uiElem.list_AIRFOILS.String{end+1} = [bufferAirfoils(i).name sprintf(' (%i pts)',bufferAirfoils(i).pts)]; % update listbox
            uiElem.list_AIRFOILS.Max = length(uiElem.list_AIRFOILS.String);
        end
    end

    function deleteAirfoil(src,event) % remove airfoil from listbox
        if length(uiElem.list_AIRFOILS.String) > 0
            idx = uiElem.list_AIRFOILS.Value;
            uiElem.list_AIRFOILS.String(idx) = []; % removing airfoils from list
            bufferAirfoils(idx) = []; % removing airfoils from buffer
            
            uiElem.list_AIRFOILS.Value = 1;
            uiElem.list_AIRFOILS.Max = length(bufferAirfoils); % decreasing number of elements that can be selected by number of deleted elements
        end
    end

    function repanelAirfoil(src,event) % repanel airfoils with XFOIL
        for i = 1:length(uiElem.list_AIRFOILS.Value)
            fhand = fopen('repanel.txt','w');
            fprintf(fhand,'LOAD %s\n\n',bufferAirfoils(i).path);
            fprintf(fhand,'ppar\n');
            fprintf(fhand,'n 494\n\n\n');
            
            idxs = find(bufferAirfoils(i).path == '\' | bufferAirfoils(i).path == '/');
            idx = idxs(end); % chopping off absolute path to avoid XFOIL filename truncation due to memory overflow
            
            fprintf(fhand,'PSAVE %s\n\n',[bufferAirfoils(i).path(idx+1:end-4) '-HiRes',bufferAirfoils(i).path(end-3:end)]);
            fprintf(fhand,'quit\n\n');
            fprintf(fhand,'repanel.txt (END)');
            
            fclose(fhand);
            system('bin\xfoil\xfoil.exe < repanel.txt');
            
            raw = load([bufferAirfoils(i).path(idx+1:end-4) '-HiRes',bufferAirfoils(i).path(end-3:end)]);
            i = length(bufferAirfoils) + 1;
            bufferAirfoils(i).x = raw(:,1); % store airfoil data to buffer
            bufferAirfoils(i).y = raw(:,2);
            bufferAirfoils(i).pts  = length(bufferAirfoils(i).x);
            bufferAirfoils(i).name = [bufferAirfoils(i-1).path(idx+1:end-4) '-HiRes'];
            bufferAirfoils(i).path = [pwd bufferAirfoils(i).name];
            
            uiElem.list_AIRFOILS.String{end+1} = [bufferAirfoils(i).name sprintf(' (%i pts)',bufferAirfoils(i).pts)]; % update listbox
            
            delete('repanel.txt');
        end
        uiElem.list_AIRFOILS.Max = length(uiElem.list_AIRFOILS.String); % increasing number of airfoils that can be selected by number of new airfoils
    end
            
            
            
            
            



end