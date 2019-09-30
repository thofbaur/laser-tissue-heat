function [output] = SolveHeatEq(params)
    data = readdata(params);
    if params.pulsefrequency == 0 
        params.pulseperiod = params.stimulationtime;
    else
        params.pulseperiod = 1/params.pulsefrequency;
    end
    params.Tinit = params.Tambient;
    params.stepsbefore = 7;
    params.stepsafter = 7;
    [thermalModelT,tlist] = setup_heatequation(params,data);

    tic
    try
        result = solve(thermalModelT,tlist);
    catch ME
        errorhandler(null,ME);
    end
    solutiontime = toc;
%     if params.verbose
%         disp(['PDE-Solve Time = ',num2str(tfinal),'s'])
%     end
    output.result = result;
    output.data= data;
    output.thermalModelT = thermalModelT;
    output.solutiontime = solutiontime;

    T = result.Temperature-params.Tinit;
    [dTmax,tmax] = max(max(T));
    [~,nodemax] = max(T(:,tmax));
    output.dTmax = dTmax;
    zTmax =  thermalModelT.Mesh.Nodes(2,nodemax); %[m]
    output.zTmax = zTmax;
    
end

function data = readdata(params)
    offsetrow = 33 + 2*(params.nlayer-1) +params.noz + 2+ params.nor + 5 + params.nor+11; 
%     if(strcmp(params.beamtype{1},'d')) 
%         if ~exist( ['Int_',params.fileout])
%             ConvoluteDelta(params);
%         else
%             file1 = dir(params.fileout);
%             file2 = dir(['Int_',params.fileout]);
%             if datetime(file1.date)>datetime(file2.date)
%                 ConvoluteDelta(params);
%             end
%         end 
%         params.beamtype{1} = 'g';
%         params.fileout = ['Int_',params.fileout];
%     end
%         
    data = dlmread([params.fileoutPath,params.fileout],' ',[offsetrow,0,offsetrow+ceil(params.noz*params.nor/5)-1,9]);
    data(:,[1,3,5,7,9])=[];
    data = 10^(6)*reshape(reshape(data',[ 1 params.noz*params.nor]),[params.noz,params.nor]); %[1/m^3]   
end


function [thermalModelT,tlist] = setup_heatequation(params,data)
%% create geometry for model by directly constructing the geometry matrix   
    
    g = double(zeros(7,1+params.nlayer*3));
    r = min(params.nor*params.drm, params.rmax);
    g(:,1) = [2; 0; r;0;0;1;0];
    zbelow = double(0);
    for jj = 1:params.nlayer
       z = min(zbelow+ params.dicke(jj),params.zmax);
       g(:,1+(jj-1)*3+1) = [2,r,r,zbelow,z,double(jj),0];
       g(:,1+(jj-1)*3+2) = [2;r;0;z;z;double(jj);double(mod(jj+1,params.nlayer+1))];
       g(:,1+(jj-1)*3+3) = [2;0;0;z;zbelow;double(jj);0];
       zbelow = z;
       if zbelow==params.zmax
           break;
       end
    end
    
   %% Thermal properties
    
    cFunc1 = @(region,state)  params.cheatmedium(1)*region.x;    
    kFunc1 = @(region,state)  params.lambdamedium(1)*region.x ;
    cFunc2 = @(region,state)  params.cheatmedium(2)*region.x;    
    kFunc2 = @(region,state)  params.lambdamedium(2)*region.x ;
    
    qFuncmedium = @(region,state) region.x .* heat(region,state,params,data);

    thermalModelT = createpde('thermal','transient');
    geometryFromEdges(thermalModelT,g);
%     fh=figure;
%     ax=pdegplot(thermalModelT,'EdgeLabels','on','FaceLabels','on');
    generateMesh(thermalModelT,'Hmax',params.Hmax);
%     if params.verbose
%         disp('Meshgeneration done');
%     end
    thermalProperties(thermalModelT,'ThermalConductivity',kFunc1 ,...
                                    'MassDensity',params.rhomedium(1),...
                                    'SpecificHeat',cFunc1,'Face',1);
	if params.nlayer ==2
        thermalProperties(thermalModelT,'ThermalConductivity',kFunc2 ,...
                                    'MassDensity',params.rhomedium(2),...
                                    'SpecificHeat',cFunc2,'Face',2);
    end
    internalHeatSource(thermalModelT,qFuncmedium,'Face',1:params.nlayer);
    
%% define Boundary conditions
    CCval = @(region,~) params.convectioncoeff*region.x;
    RCval = @(region,~) params.emissivity;
    if params.BC == 1 
        thermalBC(thermalModelT,'Edge',1,...
           'ConvectionCoefficient',CCval,...
           'AmbientTemperature',params.Tambient);
       thermalBC(thermalModelT,'Edge',1-1+params.nlayer*3,...
           'ConvectionCoefficient',CCval,...
           'AmbientTemperature',params.Tambient);
    elseif params.BC == 2
       thermalBC(thermalModelT,'Edge',1,...
           'Emissivity',RCval,...
           'AmbientTemperature',params.Tambient);
       thermalBC(thermalModelT,'Edge',1-1+params.nlayer*3,...
           'Emissivity',params.emissivity,...
           'AmbientTemperature',params.Tambient);
       thermalModelT.StefanBoltzmannConstant = 5.670367E-8;
    else
       thermalBC(thermalModelT,'Edge',1,'HeatFlux',0);   
       thermalBC(thermalModelT,'Edge',1-1+params.nlayer*3,'HeatFlux',0);   
    end
    for jj=1:params.nlayer
        thermalBC(thermalModelT,'Edge',2+(jj-1)*3,'Temperature',params.Tinit);
        thermalBC(thermalModelT,'Edge',4+(jj-1)*3,'HeatFlux',0);
    end
       
    tlist1 = logspace(log10(params.stimulationtime/20),log10(params.stimulationtime),params.stepsbefore);
    tlist2 = logspace(log10(params.stimulationtime+1e-4),log10(params.tfinal),params.stepsafter);
    tlist = unique([0,tlist1,tlist2]);
    
    thermalIC(thermalModelT,params.Tinit);
    thermalModelT.SolverOptions.MaxIterations   = 10000;
    thermalModelT.SolverOptions.ResidualTolerance    = 1e-10;
    thermalModelT.SolverOptions.AbsoluteTolerance  = 1e-10;
    thermalModelT.SolverOptions.MinStep  = 1e-20;

%     findThermalProperties(thermalModelT.Material
    thermalModelT.SolverOptions.ReportStatistics = 'off';
end

function q = heat(region,state,params,data)
    idxr = min(max(ceil( (region.x-params.drm/2)/params.drm),1),params.nor);
    idxz = min(max(ceil( (region.y-params.dzm/2)/params.dzm),1),params.noz);

    q =        heaviside(params.stimulationtime-state.time)*...
               heaviside(params.pulsetime - mod(state.time,params.pulseperiod))*...
    params.beampower*data(sub2ind(size(data),idxz,idxr));
end
