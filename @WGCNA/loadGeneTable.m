function o = loadGeneTable(o,geneTablePath)
%% Load the output table from WGCNA with gene names and modules
% geneTablePath - path to the output table
o.geneTable = readtable(fullfile(o.baseDir,geneTablePath));
% Convert modules to categorical

colorMaps = {'xkcd', 'wikipedia', 'Resene', 'Crayola'};
 
s = RandStream('mt19937ar','seed',sum(uint32(fileparts(geneTablePath))));

colorMap = datasample(s, colorMaps,1);

o.colorMap = colorMap{:};


if ismember('moduleColor',fieldnames(o.geneTable))
    o.geneTable.moduleColor=categorical(o.geneTable.moduleColor);
    o.geneTable.moduleColor = renameColors(o.geneTable.moduleColor, o.colorMap, s);
end

if ismember('mergedColors',fieldnames(o.geneTable))
    o.geneTable.mergedColors=categorical(o.geneTable.mergedColors);
    o.geneTable.mergedColors = renameColors(o.geneTable.mergedColors, o.colorMap, s);
end
% Make the first variable name 'Probes'
o.geneTable.Properties.VariableNames(1) = {'Probes'};


end

function modules = renameColors(modules, colorMap, s)


newColorNames = datasample(s, colornames(colorMap),length(unique(modules)),'Replace',false);

% moduleNames = categories(modules);
% 
% [~, rgb] = colornames('R',moduleNames);
% 
% moduleNames = colornames(colorMap,rgb);

modules = renamecats(modules, newColorNames);



end