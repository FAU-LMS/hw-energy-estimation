%% Evaluate Relative Expected HW Energy Demand for Video Decoding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matthias Kraenzler
% Friedrich-Alexander-Universität Erlangen-Nürnberg, Germany
% matthias.kraenzler@fau.de
% MK 04-2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
%% Settings
% Load pre-trained energy models
load('HEVC_VP9_AV1_optimized_13PE.mat')

% Select model (see pre-trained models)
evalModel = energyModel_13PE_GPR;

% Folders that contain SW profiling with valgrind
% Please specify profilingFolderAnchor and profilingFolderTest
analysisFolder  = 'Import';
profilingFolderAnchor = 'Import/Anchor';
profilingFolderTest   = 'Import/Test';

%% Import your data
profilingFileAnchor = AnalyseCallgrind(profilingFolderAnchor, analysisFolder);
profilingFileTest = AnalyseCallgrind(profilingFolderTest, analysisFolder);

[featureTableAnchor,featureArrayAnchor] = generateFeatureArray(profilingFileAnchor);
[featureTableTest,featureArrayTest]     = generateFeatureArray(profilingFileTest);

%% Evaluate Relavtive Expected HW Energy Demand (REHWED)
% Complexity of Anchor
energyDemandEstimationAnchor = predict(evalModel{1,1},featureArrayAnchor); 
% Complexity of Test
energyDemandEstimationTest = predict(evalModel{1,1},featureArrayTest); 
rehwed = mean(energyDemandEstimationTest ./ energyDemandEstimationAnchor);
disp(['Relative Expected HW Energy Demand: ' num2str(rehwed)]);
