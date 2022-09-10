clc;
close all;
clear all;

global g_debugLvl
g_debugLvl = 1;

demoBuilding = 'thsingle';
Path=pwd;
thermalModelDataDir =   [Path,filesep,'BuildingData',filesep,demoBuilding,filesep,'ThermalModel'];
EHFModelDataDir =       [Path,filesep,'BuildingData',filesep,demoBuilding,filesep,'EHFM'];
buildingIdentifier = demoBuilding;
B = Building(buildingIdentifier);
B.loadThermalModelData(thermalModelDataDir);
EHFModelClassFile = 'BuildingHull.m';                                         % This is the m-file defining this EHF model's class.
EHFModelDataFile = [EHFModelDataDir,filesep,'buildinghull'];                  % This is the spreadsheet containing this EHF model's specification.
EHFModelIdentifier = 'BuildingHull';                                          % This string identifies the EHF model uniquely
B.declareEHFModel(EHFModelClassFile,EHFModelDataFile,EHFModelIdentifier);

% Ventilation
EHFModelClassFile = 'AHU.m'; 
EHFModelDataFile = [EHFModelDataDir,filesep,'ahu']; 
EHFModelIdentifier = 'AHU1';
B.declareEHFModel(EHFModelClassFile,EHFModelDataFile,EHFModelIdentifier);

% InternalGains
EHFModelClassFile = 'InternalGains.m'; 
EHFModelDataFile = [EHFModelDataDir,filesep,'internalgains']; 
EHFModelIdentifier = 'IG';
B.declareEHFModel(EHFModelClassFile,EHFModelDataFile,EHFModelIdentifier);

% TABS
EHFModelClassFile = 'BEHeatfluxes.m'; 
EHFModelDataFile = [EHFModelDataDir,filesep,'BEHeatfluxes']; 
EHFModelIdentifier = 'TABS';
B.declareEHFModel(EHFModelClassFile,EHFModelDataFile,EHFModelIdentifier);

% Radiators
EHFModelClassFile = 'Radiators.m'; 
EHFModelDataFile = [EHFModelDataDir,filesep,'radiators']; 
EHFModelIdentifier = 'Rad';
B.declareEHFModel(EHFModelClassFile,EHFModelDataFile,EHFModelIdentifier);


%B.thermal_model_data.setValue('M0003','density',1000);
%B.writeThermalModelData(pathToModifiedThermalModelData);
%B.drawBuilding();
B.generateBuildingModel();
Ts_hrs = 1/6;
B.building_model.setDiscretizationStep(Ts_hrs);
B.building_model.discretize();
%B.building_model.discretize(discretizationTimestep);
%% RC model
%dist
S=56.9; %area in m2
dis = xlsread('dist.xlsx');
dis=dis(1:289,:);
disNsol=dis(:,5);
disSsol=dis(:,7);
disWsol=dis(:,6);
disEsol=zeros(289,1);
disHsol=zeros(289,1);
disIG=(dis(:,3)./(60*10))./S;
disTam=dis(:,1);
disTgnd=dis(:,2);
disnew=[disIG disTam disTgnd disEsol disHsol disNsol disSsol disWsol];
%% RC
SimExp=SimulationExperiment(B);
numberOfTimesteps=289;
numberOfStates=19;
SimExp.setNumberOfSimulationTimeSteps(numberOfTimesteps);
SimExp.setInitialState(23*ones(numberOfStates,1))
u=[1;1;0;80];
u=repmat(u,1,289);
v=disnew';
SimExp.simulateBuildingModel('inputTrajectory',u,v);
%B.building_model.discrete_time
cell=B.building_model.identifiers.x;
cell=cellstr(cell{1});
plot(SimExp,cell)
xlabel('Time h(2 days)');
ylabel('Room temperature (C)');
title('RC Model');
cost=sum(0.03*((u(4,:)*S)/6000))*16*15;
