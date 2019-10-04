function GeneratePlot(app)
rmax = max(app.vHeatResult.Mesh.Nodes(1,:));
            zmax = max(app.vHeatResult.Mesh.Nodes(2,:));
            switch app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXAxis
                case 'Time t'
                    
                    rlist = 1e-6*app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pSection1;
                    zlist = 1e-6*app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pSection2;
                    Cuintrp = interpolateTemperature(app.vHeatResult,rlist,zlist,1:length(app.vHeatResult.SolutionTimes))-...
                        app.vTinit;
                    legendnames = cell(length(zlist),1);
                    zshift = 0;
                    for ii = 1:length(zlist)
                        legendnames{ii} = ['r = ',num2str((rlist(ii))*1e6),' {\mu}m, ', 'z = ',num2str((zlist(ii)-zshift)*1e6),' {\mu}m'];
                    end
                    indnan =any(isnan(Cuintrp),2) ;
                    if(any(indnan))
                        Cuintrp(indnan,:)= interpolateTemperature(result,rlist(indnan),zlist(indnan)-1e-6,1:length(app.vHeatResult.SolutionTimes))-app.vTinit;
                        indnan =any(isnan(Cuintrp),2) ;
                        if (any(indnan))
                            Cuintrp(indnan,:)= interpolateTemperature(result,rlist(indnan),zlist(indnan)+1e-6,1:length(app.vHeatResult.SolutionTimes))-app.vTinit;
                        end
                    end
                    
                    indnan =any(isnan(Cuintrp),2) ;
                    if any(indnan)
%                         zlist(indnan) = [];
%                         xlist(indnan) = [];
                        legendnames(any(isnan(Cuintrp),2)) = [];  
                    end
                    xval = 1000*app.vHeatResult.SolutionTimes;
                    yval = Cuintrp;
                             
                    labelx = 't [ms]';
                    labely = '{\Delta}T [K]';
                    if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUpAuto 
                        app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp = 1000*app.vtmax;
                        app.xAxisupperLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp;
                    end
                    if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLowAuto 
                        app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow = 0;
                        app.xAxislowerLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow;
                    end
                case 'Radius r'
                    
                    vresolutionr = 1000;
                    
                    if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUpAuto 
                        app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp = rmax;
                        app.xAxisupperLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp;
                    end
                    if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLowAuto 
                        app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow = 0;
                        app.xAxislowerLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow;
                    end   
                    rlist = 1e-6*linspace(app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow,...
                         app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp,...
                         vresolutionr);
                    zlist = 1e-6*app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pSection1;
                    tlist = 1e-3*app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pSection2';
                    [xmesh,zmesh] = meshgrid(rlist,zlist);
                    Cuintrp = interpolateTemperature(app.vHeatResult,xmesh,zmesh,1:length(app.vHeatResult.SolutionTimes))-...
                        app.vTinit;
                    
                    vtempinterp = interp1(app.vHeatResult.SolutionTimes,Cuintrp',tlist,'linear');
                    xval = 1e6* rlist;
                    
                    yval = zeros(app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).vNoSections,vresolutionr);
                    for ii=1:app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).vNoSections
                        vtemp = reshape(vtempinterp(ii,:)',size(zmesh));
                        yval(ii,:) = vtemp(ii,:);  
                    end
                    labelx = 'r [{\mu}m]';
                    labely = '{\Delta}T [K]';
                    
                    legendnames = cell(length(zlist),1);
                    zshift = 0;
                    for ii = 1:length(zlist)
                        legendnames{ii} = ['z = ',num2str((zlist(ii)-zshift)*1e6),...
                            ' {\mu}m, t = ',...
                            num2str((tlist(ii))*1e3),' ms', ];
                    end
                case 'Depth z'
                    
                    vresolutionz = 1000;
                    
                    if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUpAuto 
                        app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp = zmax;
                        app.xAxisupperLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp;
                    end
                    if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLowAuto 
                        app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow = 0;
                        app.xAxislowerLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow;
                    end 
                    zlist = 1e-6*linspace(app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow,...
                         app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp,...
                         vresolutionz);
                    rlist = 1e-6*app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pSection1;
                    tlist = 1e-3*app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pSection2';
                    [xmesh,zmesh] = meshgrid(rlist,zlist);
                    Cuintrp = interpolateTemperature(app.vHeatResult,xmesh,zmesh,1:length(app.vHeatResult.SolutionTimes))-...
                        app.vTinit;
                    
                    vtempinterp = interp1(app.vHeatResult.SolutionTimes,Cuintrp',tlist,'linear');
                    xval = 1e6* zlist;
                    
                    yval = zeros(app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).vNoSections,vresolutionz);
                    for ii=1:app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).vNoSections
                        vtemp = reshape(vtempinterp(ii,:)',size(zmesh));
                        yval(ii,:) = vtemp(:,ii);
                    end
                    labelx = 'z [{\mu}m]';
                    labely = '{\Delta}T [K]';
                    
                    legendnames = cell(length(rlist),1);
                    zshift = 0;
                    for ii = 1:length(rlist)
                        legendnames{ii} = ['r = ',num2str((rlist(ii)-zshift)*1e6),...
                            ' {\mu}m, t = ',...
                            num2str((tlist(ii))*1e3),' ms', ];
                    end
               
            end
            
            plot(app.UIAxes,xval,yval);

            legend(app.UIAxes,legendnames);
            xlabel(app.UIAxes,labelx);
            ylabel(app.UIAxes,labely);
            if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimUpAuto 
                app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimUp = app.vdTmax;
                app.TAxisupperLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimUp;      
            end
            if app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimLowAuto 
                app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimLow = 0;
                app.TAxislowerLimitEditField.Value = app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimLow;                 
            end
         
            ylim(app.UIAxes,[app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimLow,...
                app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pTLimUp]);
            xlim(app.UIAxes,[app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimLow,...
                app.sVisualizationSetting.sPlotProperties(app.vIndCurrPlot).pXLimUp]);
end
