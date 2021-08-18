function autoXFOIL(bufferLocal,settings)
% INPUTS
%   - bufferLocal : (struct) airfoil data for analysis
%   - settings    : (struct) settings for analysis
% OUTPUTS (PROGRAMMATIC)
%   - < none >
% FILES
%   - < creates report files in \reports >
%   - < creates temp tiles in \temp and moves to \archive on completion >

    % TRY FOR ERROR CATCHING
    try    


        % GET CURRENT DATE AND TIME AT FUNCTION CALL - HHMM for filenames
        dt = datestr(datetime('now'));
        hhmm = dt([end-7 end-6 end-4 end-3]);

        % PATH TO XFOIL
        xPath = 'bin\xfoil\xfoil.exe';

        % GET SETTINGS FROM STRUCT FOR BREVITY
        mode = settings.mode;
        invisc = settings.invisc;
        incomp = settings.incomp;

        re   = settings.RN;
        mach = settings.M;

        alphaUp  = settings.AOA_up;
        alphaDn  = settings.AOA_down;
        alphaMax = settings.AOA_max;
        alphaMin = settings.AOA_min;

        cmref    = settings.cmref;
        ncrit    = settings.Ncrit;

        % GET NUMBER OF CASES TO ITERATE BASED ON MODE
        switch mode
            case 1
                n = length(bufferLocal);
            case 2
                n = length(re);
            case 3
                n = length(mach);
        end


        %% XFOIL SCRIPT GENERATION

        % STORE FILE NAMES FOR SCRIPCTS, OUTPUTS, AND FILE HANDLES
        scriptFnames = cell(1,n);
        outputFnames = cell(1,n);
        fHands       = zeros(1,n);

        % FORMATTING FILE NAMES AND FILE HANDLES
        for i = 1:n
            scriptFnames{i} = sprintf('temp\\axScript%i.txt',i);
            outputFnames{i} = sprintf('temp\\axOutput%i.txt',i);
            fHands(i) = fopen(scriptFnames{i},'w');
        end

        % WRITE FOIL-LOADING LINES TO EACH SCRIPT
        for i = 1:n
            switch mode
                case 1
                    % IF COMPARING AIRFOILS, ITERATE AIRFOIL BUFFER
                    fprintf(fHands(i),'LOAD %s\n',bufferLocal(i).relpath);
                    fprintf(fHands(i),'%s\n',bufferLocal(i).name);
                otherwise
                    % OTHERWISE, SAME AIRFOIL FOR ALL SCRIPTS
                    fprintf(fHands(i),'LOAD %s\n',bufferLocal.relpath);
                    fprintf(fHands(i),'%s\n',bufferLocal.name);
            end
        end

        % CHANGE MOMENT REFERENCE POINT AND NCRIT
        for i = 1:n
            % CHANGE MOMENT REFERENCE POINT
            fprintf(fHands(i),'XYCM %f 0\n',cmref);

            % CHANGE FREESTREAM TURBULENCE
            fprintf(fHands(i),'oper\n');
            fprintf(fHands(i),'vpar\n');
            fprintf(fHands(i),'n %.2f\n',ncrit);
            fprintf(fHands(i),'\n');
        end

        % WRITE MACH PARAMETERS, IF NOT INCOMPRESSIBLE
        if ~incomp
            for i = 1:n
                switch mode
                    case 3
                        fprintf(fHands(i),'mach %.4f\n',mach(i));
                    otherwise
                        fprintf(fHands(i),'mach %.4f\n',mach);
                end
            end
        end

        % WRITE RN PARAMETERS, IF NOT INVISCID
        if ~invisc
            for i = 1:n
                switch mode
                    case 2
                        fprintf(fHands(i),'visc %.4e\n',re(i));
                    otherwise
                        fprintf(fHands(i),'visc %.4e\n',re);
                end
            end
        end

        % TELL XFOIL TO SAVE DATA TO FILES
        for i = 1:n
            fprintf(fHands(i),'pacc\n');
            fprintf(fHands(i),'%s\n\n',outputFnames{i});
        end

        % DESIGNING ALPHA SEQUENCE SWEEPS
        for i = 1:n
            if alphaMax > 0
                if alphaMin < 0
                    fprintf(fHands(i),sprintf('aseq 0 %.2f %.4f\n',alphaMax,alphaUp));
                    fprintf(fHands(i),'init\n');
                    fprintf(fHands(i),sprintf('aseq 0 %.2f %.4f\n',alphaMin,alphaDn));
                elseif alphaMin == 0
                    fprintf(fHands(i),sprintf('aseq 0 %.2f %.4f\n',alphaMax,alphaUp));
                else
                    fprintf(fHands(i),sprintf('aseq %.2f %.2f %.4f\n',alphaMin,alphaMax,alphaUp));
                end

            elseif alphaMax == 0
                fprintf(fHands(i),sprintf('aseq 0 %.2f %.4f\n',alphaMin,alphaDn));

            else
                fprintf(fHands(i),sprintf('aseq %.2f %.2f %.4f\n',alphaMax,alphaMin,alphaDn));

            end

            % TERMINATE ALPHA SEQUENCE SWEEPS
            fprintf(fHands(i),'pacc\n\n');

        end

        % TERMINATE XFOIL SCRIPTS
        for i = 1:n
            fprintf(fHands(i),'quit\n\n');
            fprintf(fHands(i),'%s (END)',scriptFnames{i});
        end
            
        % CLOSE ALL FILE HANDLES
        fclose('all');

        %% XFOIL SCRIPT EXECUTION
        for i = 1:n
            system(sprintf('%s < %s',xPath,scriptFnames{i}));
        end


        %% IMPORT XFOIL POLARS TO MATLAB

        % FILE HANDLES FOR OUTPUT FILES
        dataFhands = zeros(1,n);

        % READ HEADER LINES OUT OF ALL FILES
        lines = cell(12,n);
        for i = 1:n
            dataFhands(i) = fopen(outputFnames{i});
            for j = 1:12
                lines{j,i} = fgetl(dataFhands(i));
            end
        end

        % CLOSE ALL FILE HANDLES TO RESET LINE INDICES
        fclose('all');

        % GET NUMERICAL DATA OUT OF ALL FILES
        raw = cell(1,n);
        data = struct();
        for i = 1:n
            dataFhands(i) = fopen(outputFnames{i});
            raw{i} = textscan(dataFhands(i),'%f %f %f %f %f %f %f','headerlines',12);
        end

        % SORT DATA INTO STRUCTURE ARRAY FOR EASIER HANDLING
        for i = 1:n
            % STORE RAW DATA
            data(i).alpha = raw{i}{1};
            data(i).cL    = raw{i}{2};
            data(i).cD    = raw{i}{3};
            data(i).cM    = raw{i}{5};

            % SORT BY ALPHA ORDER
            [~,id] = sort(data(i).alpha);
            data(i).alpha = data(i).alpha(id);
            data(i).cL    = data(i).cL(id);
            data(i).cD    = data(i).cD(id);
            data(i).cM    = data(i).cM(id);
        end

        % CLOSE ALL FILES HANDLES
        fclose('all');


        %% GENERATING TITLE FOR FIGURES

        % CREATING FIGURE TITLE BASED ON SCRIPT OPERATION MODE
        switch mode
            case 1
                % AIRFOIL COMPARISON AT REYNOLDS AND MACH
                titleMajor = 'Airfoil Comparison';
                if invisc && incomp
                    titleMinor = 'Inviscid & Incompressible';
                elseif invisc && ~incomp
                    titleMinor = sprintf('Inviscid, M = %.2f',mach);
                elseif incomp && ~invisc
                    titleMinor = sprintf('Incompressible, RN = %.2e',re);
                else
                    titleMinor = sprintf('Rn = %.2e     M = %.2f',re,mach);
                end

            case 2
                % RN SWEEP FOR AIRFOIL AT MACH
                titleMajor = sprintf('Varying Reynolds Number for %s',bufferLocal.name);
                if incomp
                    titleMinor = 'Incompressible';
                else
                    titleMinor = sprintf('M = %.2f',mach);
                end

            case 3
                % MACH SWEEP FOR AIRFOIL AT RN
                titleMajor = sprintf('Varying Mach Number for %s',bufferLocal.name);
                if invisc
                    titleMinor = 'Inviscid';
                else
                    titleMinor = sprintf('RN = %.2e',re);
                end
        end


        %% PORTRAIT REPORT PLOTS

        % STRUCTURE FOR PORTRAIT PLOTS
        pltsP = struct();

        % FIGURE SETUP
        figPortrait = figure();
        set(gcf,'Units','Inches','Position',[1 1 8.5 11]);
        set(gcf,'DefaultAxesFontName','Helvetica');
        set(gcf,'DefaultTextFontName','Helvetica');
        set(gcf,'DefaultAxesFontSize',8);
        set(gcf,'DefaultTextFontSize',8);
        set(gcf,'PaperUnits',get(gcf,'Units'));
        pos = get(gcf,'Position');
        set(gcf,'Paperposition',[0 0 pos(3) pos(4)]);

        % SUBPLOTS SETUP
        %   A LOT OF THIS IS BASED ON LEGACY CODE I'M TOO LAZY TO DOCUMENT

        % FIRST SUBPLOT, CL VS ALPHA
        a = 1:3;
        s1subs_1 = [a 9+a 18+a];
        s1(1) = subplot(6,9,s1subs_1);
        grid on; grid minor; box on; hold on;
        s1(1).GridAlpha = 0.5; s1(1).MinorGridAlpha = 1;
        xlabel('\alpha (deg)','FontWeight','bold')
        ylabel('Lift Coefficient - c_l','FontWeight','bold')
        for i = 1:n
            pltsP(1).p(i) = plot(data(i).alpha, data(i).cL, 'linewidth',2);
        end
        xtickformat('%i')
        ytickformat('%.1f')

        % SECOND SUBPLOT, CL VS CD
        a = 4:6;
        s2subs_1 = [a 9+a 18+a];
        s1(2) = subplot(6,9,s2subs_1);
        title(sprintf('%s\n%s',titleMajor,titleMinor))
        grid on; grid minor; box on; hold on;
        s1(2).GridAlpha = 0.5; s1(2).MinorGridAlpha = 1;
        xlabel('Drag Coefficient - c_d','FontWeight','bold')
        for i = 1:n
            pltsP(2).p(i) = plot(data(i).cD, data(i).cL, 'linewidth',2);
        end
        s1(2).XLim(1) = 0;
        xtickformat('%.3f')
        ytickformat('%.1f')

        % THIRD SUBPLOT, CL VS CM
        a = 7:9;
        s3subs_1 = [a 9+a 18+a];
        s1(3) = subplot(6,9,s3subs_1);
        grid on; grid minor; box on; hold on
        s1(3).GridAlpha = 0.5; s1(3).MinorGridAlpha = 1;
        s1(3).XDir = 'reverse';
        switch cmref
            case 0.25
                refstring = 'c/4';
            case 0
                refstring = 'LE';
            case 1
                refstring = 'TE';
            otherwise
                refstring = sprintf('%.2fc',cmref);
        end
        xlabel(sprintf('Pitching Moment Coefficient - c_{m,%s}',refstring),'FontWeight','bold')
        for i = 1:n
            pltsP(3).p(i) = plot(data(i).cM, data(i).cL, 'linewidth',2);
        end
        xrange3 = xlim();
        if xrange3(2) > 0
            if xrange3(2) > 0
                s1(3).XLim(1) = 0;
            end
        elseif xrange3(2) < 0
            s1(3).XLim(2) = 0;
        end
        xtickformat('%.2f')
        ytickformat('%.1f')

        % PLOTTING AIRFOIL GEOMETRY
        s7subs_1 = 28:45;
        s1(7) = subplot(6,9,s7subs_1);
        grid on; grid minor; box on; hold on
        s1(7).GridAlpha = 0.5; s1(7).MinorGridAlpha = 1;
        title('Airfoil Geometry')
        genstring = sprintf('Generated with autoXFOIL on %s',strrep(dt(1:11),'-',' '));
        xlabel({'x/c',' ',genstring},'FontWeight','bold')
        ylabel('y/c','FontWeight','bold')
        switch mode
            case 1
                for i = 1:n
                    plot(bufferLocal(i).x,bufferLocal(i).y,'.-','linewidth',2,'markersize',4)
                end
            otherwise
                plot(bufferLocal.x,bufferLocal.y,'.-','linewidth',2,'markersize',4)
        end
        s1(7).XLim = s1(7).XLim + [-0.01 0.01];
        s1(7).YLim = s1(7).YLim + [-0.05 0.05];
        daspect(ones(1,3));

        % CREATE LEGEND FOR THE FIGURE
        labels = cell(1,n);
        switch mode
            case 1
                for i = 1:n
                    labels{i} = bufferLocal(i).name;
                end
            case 2
                for i = 1:n
                    labels{i} = sprintf('RN = %.3e',re(i));
                end
            case 3
                for i = 1:n
                    labels{i} = sprintf('M = %.2f',mach(i));
                end
        end
        lgd1 = legend(s1(1),pltsP(1).p,labels,'location','northwest');
        lgd1.FontName = 'Helvetica';
        lgd1.FontSize = 8;
        lgd1.FontWeight = 'bold';
        [v,~] = version;
        if ((str2num(v(end-3:end-2)) >= 18) && n > 4)
            set(lgd1,'NumColumns',2);
        end

        % THICKENING GRID LINES ON x=0 and y=0 FOR ALL POLARS
        for i = 1:3
            line(s1(i), [s1(i).XLim(1) s1(i).XLim(2)],[0 0],'color','k','linewidth',1.2);
            line(s1(i), [0 0],[s1(i).YLim(1) s1(i).YLim(2)],'color','k','linewidth',1.2);
        end

        % ALIGNING ALL VERTICAL AXIS TO THE CL VS ALPHA PLOT
        for i = 2:3
            s1(i).YLim = s1(1).YLim;
        end

        % REMOVING VERTICAL TICKLABELS ON SECOND AND THIRD POLARS
        set(s1(2),'yticklabel',[]);
        set(s1(3),'yticklabel',[]);

        % FORMATTING YTICKS TO AVOID "BASTARDIZED" AXES, TO CONFORM WITH NACA
        % FORMATTING GUIDELINES ON GRID SPACING
        for i = [1:2,7]
            % XTICKS
            delta = s1(i).XRuler.TickValues(2) - s1(i).XRuler.TickValues(1);
            delt = delta / 5;
            MinXTick = sort([s1(i).XRuler.TickValues(1):delt:s1(i).XLim(2), s1(i).XRuler.TickValues(1):-1*delt:s1(i).XLim(1)]); 
            s1(i).XRuler.MinorTickValues = unique(MinXTick);

            % YTICKS
            delta = s1(i).YRuler.TickValues(2) - s1(i).YRuler.TickValues(1);
            delt = delta / 5;
            MinYTick = sort([s1(i).YRuler.TickValues(1):delt:s1(1).YLim(2), s1(i).YRuler.TickValues(1):-1*delt:s1(1).YLim(1)]);
            s1(i).YRuler.MinorTickValues = unique(MinYTick);
        end
        delta = s1(3).XRuler.TickValues(2) - s1(3).XRuler.TickValues(1);
        delt = delta / 5;
        MinXTick = sort([s1(3).XRuler.TickValues(end):-1*delt:s1(3).XLim(1), s1(3).XRuler.TickValues(end):delt:s1(3).XLim(2)+0.1]);
        s1(3).XRuler.MinorTickValues = unique(MinXTick);

        delta = s1(3).YRuler.TickValues(2) - s1(3).YRuler.TickValues(1);
        delt = delta / 5;
        MinYTick = sort([s1(3).YRuler.TickValues(1):delt:s1(1).YLim(2), s1(3).YRuler.TickValues(1):-1*delt:s1(1).YLim(1)]);
        s1(3).YRuler.MinorTickValues = unique(MinYTick);


        %% LANDSCAPE FORMAT REPORTS

        % STRUCTURE FOR PLOTS
        pltsH = struct();

        % FIGURE CREATION AND FORMATTING
        figHoriz = figure();
        set(gcf,'Units','Inches','Position',[1 1 14 6]);
        set(gcf,'DefaultAxesFontName','Helvetica');
        set(gcf,'DefaultTextFontName','Helvetica');
        set(gcf,'DefaultAxesFontSize',8);
        set(gcf,'DefaultTextFontSize',8);
        set(gcf,'PaperUnits',get(gcf,'Units'));
        pos = get(gcf,'Position');
        set(gcf,'Paperposition',[0 0 pos(3) pos(4)]);

        % FIRST SUBPLOT CL VS ALPHA
        a = 1:3;
        s1subs_2 = [a, 9+a, 18+a];
        s2(1) = subplot(6,9,s1subs_2); % same subplot layout as the portrait report figures, just applying to a figure with different dimensions
        grid on; grid minor; box on; hold on
        s2(1).GridAlpha = 0.5; s2(1).MinorGridAlpha = 1;
        xlabel('\alpha (deg)','FontWeight','bold')
        ylabel('Lift Coefficient - c_l','Fontweight','bold')
        for i = 1:n
            pltsH(1).p(i) = plot(data(i).alpha, data(i).cL,'linewidth',2);
        end
        xtickformat('%i')
        ytickformat('%.1f')

        % SECOND SUBPLOT CL VS CD
        a = 4:6;
        s2subs_2 = [a, 9+a, 18+a];
        s2(2) = subplot(6,9,s2subs_2);
        title(sprintf('%s\n%s',titleMajor,titleMinor))
        grid on; grid minor; box on; hold on
        s2(2).GridAlpha = 0.5; s2(2).MinorGridAlpha = 1;
        xlabel('Drag Coefficient - c_d','FontWeight','bold')
        for i = 1:n
            pltsH(2).p(i) = plot(data(i).cD,data(i).cL,'linewidth',2);
        end
        xtickformat('%.3f')
        ytickformat('%.1f')

        % THIRD SUBPLOT CL VS CM
        a = 7:9;
        s3subs_2 = [a, 9+a, 18+a];
        s2(3) = subplot(6,9,s3subs_2);
        grid on; grid minor; box on; hold on
        s2(3).GridAlpha = 0.5; s2(3).MinorGridAlpha = 1;
        s2(3).XDir = 'reverse';
        switch cmref
            case 0.25
                refstring = 'c/4';
            case 0
                refstring = 'LE';
            case 1
                refstring = 'TE';
            otherwise
                refstring = sprintf('%.2fc',cmref);
        end
        xlabel(sprintf('Pitching Moment Coefficient - c_{m,%s}',refstring),'FontWeight','bold')
        for i = 1:n
            pltsH(3).p(i) = plot(data(i).cM,data(i).cL,'linewidth',2);
        end
        xtickformat('%.2f')
        ytickformat('%.1f')

        % PLOTTING AIRFOIL GEOMETRY
        s7subs_2 = 37:54;
        s2(7) = subplot(6,9,s7subs_2);
        grid on; grid minor; box on; hold on
        s2(7).GridAlpha = 0.5; s2(7).MinorGridAlpha = 1;
        title('Airfoil Geometry')
        genstring = sprintf('Generated with autoXFOIL on %s',strrep(dt(1:11),'-',' '));
        xlabel({'x/c',' ',genstring},'FontWeight','bold')
        ylabel('y/c','FontWeight','bold')
        switch mode
            case 1
                for i = 1:n
                    plot(bufferLocal(i).x,bufferLocal(i).y,'.-','linewidth',2,'markersize',4)
                end
            otherwise
                plot(bufferLocal.x,bufferLocal.y,'.-','linewidth',2,'markersize',4)
        end
        s2(7).XLim = s2(7).XLim + [-0.01 0.01];
        s2(7).YLim = s2(7).YLim + [-0.05 0.05];
        daspect(ones(1,3));

        % CREATING LEGEND FOR THE FIGURE
        labels = cell(1,n);
        switch mode
            case 1
                for i = 1:n
                    labels{i} = bufferLocal(i).name;
                end
            case 2
                for i = 1:n
                    labels{i} = sprintf('RN = %.3e',re(i));
                end
            case 3
                for i = 1:n
                    labels{i} = sprintf('M = %.2f',mach(i));
                end
        end
        lgd2 = legend(s2(1),pltsH(1).p,labels,'location','northwest');
        lgd2.FontName = 'Helvetica';
        lgd2.FontSize = 8;
        lgd2.FontWeight = 'bold';
        if str2num(v(end-3:end-2)) >= 18 && n > 4
            set(lgd2,'NumColumns',2)
        end

        % FIXING HORIZONTAL POLAR AXES TO SAME AS PORTRAIT POLAR AXES
        for i = 1:3
            s2(i).XLim = s1(i).XLim;
            s2(i).YLim = s1(i).YLim;
        end

        % THICKENING GRID LINES ON X AND Y AXES
        for i = 1:3
            line(s2(i), [s2(i).XLim(1) s2(i).XLim(2)],[0 0],'color','k','linewidth',1.2);
            line(s2(i), [0 0],[s2(i).YLim(1) s2(i).YLim(2)],'color','k','linewidth',1.2);
        end

        % REMOVING VERTICAL TICKLABELS ON SECOND AND THIRD POLARS
        set(s2(2),'yticklabel',[]);
        set(s2(3),'yticklabel',[]);

        % FORMATTING AXIS TICKS TO AVOID "BASTARDIZED" AXES TO CONFORM TO NACA
        % FORMATTING GUIDELINES
        for i = [1:2, 7]
            % XTICKS
            delta = s2(i).XRuler.TickValues(2) - s2(i).XRuler.TickValues(1);
            delt = delta / 5;
            MinXTick = sort([s2(i).XRuler.TickValues(1):delt:s2(i).XLim(2), s2(i).XRuler.TickValues(1):-1*delt:s2(i).XLim(1)]);
            s2(i).XRuler.MinorTickValues = unique(MinXTick);

            % YTICKS
            delta = s2(i).YRuler.TickValues(2) - s2(i).YRuler.TickValues(1);
            delt = delta / 5;
            MinYTick = sort([s2(i).YRuler.TickValues(1):delt:s2(1).YLim(2), s2(i).YRuler.TickValues(1):-1*delt:s2(1).YLim(1)]);
            s2(i).YRuler.MinorTickValues = unique(MinYTick);
        end
        delta = s2(3).XRuler.TickValues(2) - s2(3).XRuler.TickValues(1);
        delt = delta / 5;
        MinXTick = sort([s2(3).XRuler.TickValues(end):-1*delt:s2(3).XLim(1), s2(3).XRuler.TickValues(end):delt:s2(3).XLim(2)+0.1]);
        s2(3).XRuler.MinorTickValues = unique(MinXTick);

        delta = s2(3).YRuler.TickValues(2) - s2(3).YRuler.TickValues(1);
        delt = delta / 5;
        MinYTick = sort([s2(3).YRuler.TickValues(1):delt:s2(1).YLim(2), s2(3).YRuler.TickValues(1):-1*delt:s2(1).YLim(1)]);
        s2(3).YRuler.MinorTickValues = unique(MinYTick);

        % FIXING LEGENDS
        set(lgd1,'String',lgd2.String(1:n))
        set(lgd2,'String',lgd2.String(1:n))


        %% SAVE FIGURES

        % FILE SAVE NAME STRINGS
        dirname = sprintf('reports\\report-%s',hhmm);
        name = sprintf('axReport-%s',hhmm);

        % CREATE DIRECTORY FOR REPORT STORAGE
        system(sprintf('mkdir %s',dirname));

        % SAVE PDF FROM PORTRAIT REPORT
        saveas(figPortrait,sprintf('%s\\%s_portrait.pdf',dirname,name));

        % SAVE PNG FILES FROM BOTH REPORTS
        saveas(figPortrait,sprintf('%s\\%s_portrait.png',dirname,name));
        saveas(figHoriz   ,sprintf('%s\\%s_landscape.png',dirname,name));

        %% RELOCATING TEMP FILES TO AN ARCHIVE

        % CREATE DIRECTORY
        dirnameA = sprintf('archive\\archive-%s',hhmm);
        system(sprintf('mkdir %s',dirnameA'));
        for i = 1:n
            system(sprintf('move %s %s',scriptFnames{i},dirnameA));
            system(sprintf('move %s %s',outputFnames{i},dirnameA));
        end

        % CLOSE FILES AND NOTIFY OF COMPLETION
        fclose('all');
        text = {
            'autoXFOIL execution complete!',...
            sprintf('Reports save in %s',dirname),...
            sprintf('Scripts archived in %s',dirnameA)
        };
        msgbox(text,'Success!','help');

    catch error
        
        switch mode
            case 1
                n = length(bufferLocal);
            case 2
                n = length(re);
            case 3
                n = length(mach);
        end

        % NOTIFY NOTIFCATION TEXT
        textError = {
            'An unexpected error was encountered during operation.',...
            'This is most likely due to an invalid input or file handle confusion.',...
            'Make sure there are no files in the ''\temp'' directory; delete any that exist there.',...
            '(This is most likely the source of the error if a previous analysis was interrupted and temp files weren''t deleted.)',...
            ' ',...
            'Attempting to clear files from this session from \temp, please verify the directory is empty for future runs.'
            };

        textTrace = {'Error Traceback:'};
        for i = 2:n+1
            textTrace{end+1} = sprintf('\tfile: %s',error.stack(i-1).file);
            textTrace{end+1} = sprintf('\tline: %i',error.stack(i-1).line);
            textTrace{end+1} = ' ';
        end

        % CREATE MESSAGEBOX NOTIFICATIONS
        msgbox(textError,'Error','error')
        pause(0.5)
        msgbox(textTrace,'Error Traceback','error')

        % MOVE FILES TO A CRASH DIRECTORY
        crashDir = sprintf('\\archive\\crash-%s',hhmm);
        system(sprintf('mkdir %s',crashDir));
        for i = 1:n
            system(sprintf('move %s %s',scriptFnames{i},crashDir));
            system(sprintf('move %s %s',outputFnames{i},crashDir));
        end
    end

    
    
end