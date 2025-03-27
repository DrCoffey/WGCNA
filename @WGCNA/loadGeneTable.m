function o = loadGeneTable(o,geneTablePath,varargin)
%% Load the output table from WGCNA with gene names and modules
p=inputParser;
p.addParameter('coolColors', false);
p.parse(varargin{:});

% geneTablePath - path to the output table
o.geneTable = readtable(fullfile(o.baseDir,geneTablePath));
% Convert modules to categorical
[filepath, filename, ext] = fileparts(geneTablePath);
o.geneTablePath=geneTablePath;

%% Rename All the Colors!
if p.Results.coolColors
    fprintf(1,'Renaming All the Lame Colors')
    % Use a random seed based on the file name to make things repeatable
    s = RandStream('mt19937ar','seed',sum(uint32(char(geneTablePath))));
    % Uncomment this line to make it random
    % s = RandStream('mt19937ar','seed',randi(1000));
    
    if ismember('moduleColor',fieldnames(o.geneTable))
        o.geneTable.moduleColor=categorical(o.geneTable.moduleColor);
        o.geneTable.moduleColor = renameColors(o.geneTable.moduleColor, o.colorMap, s);
    end
    
    if ismember('mergedColors',fieldnames(o.geneTable))
        o.geneTable.mergedColors=categorical(o.geneTable.mergedColors);
        o.geneTable.mergedColors = renameColors(o.geneTable.mergedColors, o.colorMap, s);
    end
    writetable(o.geneTable, fullfile(filepath, strcat(filename,ext)));

else
    if ismember('moduleColor',fieldnames(o.geneTable))
        o.geneTable.moduleColor=categorical(o.geneTable.moduleColor);
    end
    
    if ismember('mergedColors',fieldnames(o.geneTable))
        o.geneTable.mergedColors=categorical(o.geneTable.mergedColors);
    end
    
end

% Make the first variable name 'Probes'
o.geneTable.Properties.VariableNames(1) = {'Probes'};


end

function modules = renameColors(modules, colorMap, s)

newColorNames = datasample(s, colornames(colorMap),length(unique(modules)),'Replace',false);
modules = renamecats(modules, newColorNames);

end