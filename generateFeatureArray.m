% Generate feature arrays (Perf or Callgrind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matthias Kraenzler
% matthias.kraenzler@fau.de
% MK 03-2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [featureTable,featureArray] = generateFeatureArray(matlabAnalysisFile)

load(matlabAnalysisFile);

featureArray = [ic.Ir ic.Dr ic.Dw ic.I1mr ic.D1mr ic.D1mw ic.ILmr ic.DLmr ic.DLmw ic.Bi ic.Bim ic.Bc ic.Bcm ];
featureTable = {'Ir','Dr','Dw','I1mr','D1mr','D1mw','ILmr','DLmr','DLmw','Bi','Bim','Bc','Bcm'};

end
