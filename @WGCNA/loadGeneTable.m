function o = loadGeneTable(o,geneTablePath)
%% Load the output table from WGCNA with gene names and modules
% geneTablePath - path to the output table
o.geneTable = readtable(fullfile(o.baseDir,geneTablePath));
% Convert modules to categorical
if ismember('moduleColor',fieldnames(o.geneTable))
    o.geneTable.moduleColor=categorical(o.geneTable.moduleColor);
end
if ismember('mergedColors',fieldnames(o.geneTable))
    o.geneTable.mergedColors=categorical(o.geneTable.mergedColors);
end
% Make the first variable name 'Probes'
o.geneTable.Properties.VariableNames(1) = {'Probes'};
end
