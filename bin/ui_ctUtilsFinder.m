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
    uiLocal = struct();     % UI ELEMENTS ON LOCAL FIGURE
    settings = struct();    % SETTINGS TO FEED INTO MATH STUFF
    
    % DEFINE DEFAULT SETTINGS
    
    
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
    height = 0.5  - 2*eOff;    % PANEL HEIGHT

    % LEFT PANEL
    uiLocal.panel_left   = uipanel(f1,'Position',[eOff 0.875-height+0.025 width height]);
    
    % CENTER PANEL
    uiLocal.panel_center = uipanel(f1,'Position',[eOff+0.333 0.875-height+0.025 width height]);
    
    % RIGHT PANEL
    uiLocal.panel_right  = uipanel(f1,'Position',[eOff+0.666 0.875-height+0.025 width height]);
    
    
    % INPUT AIRFOILS LABEL
    uiLocal.text_left    = uicontrol(uiLocal.panel_left,'Style','text','String','Input Airfoils',...
        'Units','normalized','Position',[0.1 0.9 0.8 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % FIND LE LABEL
    uiLocal.text_canter  = uicontrol(uiLocal.panel_center,'Style','text','String','LE Finder',...
        'Units','normalized','Position',[0.3 0.9 0.4 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    % UPDATED AIRFOILS LABEL
    uiLocal.text_right   = uicontrol(uiLocal.panel_right,'Style','text','String','Updated Airfoils',...
        'Units','normalized','Position',[0.1 0.9 0.8 0.1],...
        'Fontweight','bold','FontSize',12,'FontName',font);
    
    
%% MAIN MENU BUTTONS - LEFT PANEL
    % AIRFOIL BUFFER DISPLAY
    % BUTTON - PASS AIRFOIL OVER
    
    % LIST - BUFFER AIRFOILS
    uiLocal.list_AIRFOILS = uicontrol(uiLocal.panel_left,'Style','list',...
        'Units','normalized','Position',[2*eOff 0.25 1-4*eOff 0.6],...
        'Max',1,'String',listString,'FontSize',10,'FontName',font);
    
    % BUTTON - SEND TO LE FINDER
    uiLocal.button_SENDLE = uicontrol(uiLocal.panel_left,'Style','pushbutton',...
        'String','Send to LE Finder >>','Units','normalized','Position',[2*eOff 0.15 1-4*eOff 0.1],...
        'Fontweight','bold','FontSize',10,'FontName',font);

    
%% MAIN MENU BUTTONS - CENTER PANEL
    % AXES FOR PLOTTING
    
    % AXES - PLOT LE
    uiLocal.plot_LE = axes(uiLocal.panel_center,'Position',[8*eOff 0.475 1-16*eOff 0.4],...
        'Box','on','XGrid','on','YGrid','on');

    
%% CALLBACK FUNCTION ASSIGNMENTS
    
    % CALLBACKS DEFINED LOCALLY
    uiLocal.button_SENDLE.Callback      = @sendLE;


%% CALLBACK FUNCTION DEFINITIONS

    % SEND LE BUTTON - ON CLICK, PLOT SELECTED AIRFOILS AND CALCULATE LE PARAMETERS
    %   FILES - < NONE >
    function sendLE(src,event)
        uiLocal; bufferLocal; settings;
        
        % GET LIST INDEX OF AIRFOIL TO SEND
        idx = uiLocal.list_AIRFOILS.Value;
        
        % SET CURRENT AXES IN CASE OTHER WINDOWS / PLOTS ARE OPEN
        axes(uiLocal.plot_LE);
        cla(uiLocal.plot_LE);
        
        % GET AIRFOIL CALCULATED LE LOCATIONS
        [idGeom, idThetaMin] = calcLE(bufferLocal(idx).x,bufferLocal(idx).y);
        
        % CREATE ARRAY FOR PLOT OBJECTS
        pObjs = [];
        hold on
        
        % PLOT AIRFOIL
        pObjs(1) = plot(bufferLocal(idx).x,bufferLocal(idx).y,'k.-');
        
        % PLOT LE POINTS
        pObjs(2) = plot(bufferLocal(idx).x(idGeom),bufferLocal(idx).y(idGeom),'bo','markersize',12);
        pObjs(3) = plot(bufferLocal(idx).x(idThetaMin),bufferLocal(idx).y(idThetaMin),'r*','markersize',12);
        
        % SETTING PLOT LIMITS TO INCLUDE ALL POINTS ( AND THE ORIGIN )
        xVals = [-0.001 0 0.01 bufferLocal(idx).x(idGeom) bufferLocal(idx).x(idThetaMin)];
        yVals = [-0.01 0 0.01  bufferLocal(idx).y(idGeom) bufferLocal(idx).y(idThetaMin)];
        
        %xLimits = [min(xVals) max(xVals)];
        %yLimits = [min(yVals) max(yVals)];
        %xlim(xLimits)
        %ylim(yLimits)
        axis equal
        
        legend(pObjs(2:3),'Nearest to Origin','Minimum Curvature','location','north')
        
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
    %[xTE, yTE, isBlunt] = 
end