function autoXFOIL(bufferLocal,settings)
% INPUTS
%   - bufferLocal : (struct) airfoil data for analysis
%   - settings    : (struct) settings for analysis
% OUTPUTS (PROGRAMMATIC)
%   - < none >
% FILES
%   - < creates report files in \reports >


    % GET CURRENT DATE AND TIME AT FUNCTION CALL - HHMM for filenames
    dt = datestr(datetime('now'));
    
    % PATH TO XFOIL
    xPath = 'bin\xfoil\xfoil.exe';
    
    % GET SETTINGS FROM STRUCT FOR BREVITY
    alphaUp  = settings.AOA_up;
    alphaDn  = settings.AOA_dn;
    alphaMax = settings.AOA_max;
    alphaMin = settings.AOA_min;
    


end