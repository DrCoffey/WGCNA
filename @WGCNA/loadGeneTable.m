function o = loadGeneTable(o,geneTablePath)
%% Load the output table from WGCNA with gene names and modules
% geneTablePath - path to the output table
o.geneTable = readtable(fullfile(o.baseDir,geneTablePath));
% Convert modules to categorical

colorMaps = {'xkcd', 'wikipedia', 'Resene', 'Crayola'};
 
%% Use a random seed based on the file name to make things repeatable
s = RandStream('mt19937ar','seed',sum(uint32(fileparts(geneTablePath))));
% Uncomment this line to make it random
% s = RandStream('mt19937ar','seed',randi(1000));

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
modules = renamecats(modules, newColorNames);

end