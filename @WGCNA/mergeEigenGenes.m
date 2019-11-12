function o = mergeEigenGenes(o,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

p=inputParser;
p.addParameter('mergeThreshold',1);
p.addParameter('saveTable', false);
p.parse(varargin{:})

U = unstack(o.eigenGenes,'eigenGene','moduleColor');

Y=U{:,2:end};
d = pdist(Y');
Z = linkage(d);

T = cluster(Z,'cutoff',p.Results.mergeThreshold,'Criterion','distance')
dendrogram(Z,0,'colorThreshold',p.Results.mergeThreshold);
export_fig('Merged Eigengene Dendrogra,.png','-m3')

 
oldModules = unique(o.geneTable.moduleColor);
tmp = [];
for i = 1:length(T)
    tmp(o.geneTable.moduleColor == oldModules(i)) = T(i);
end

rng('default');
newColorNames = datasample(colornames(o.colorMap),max(T),'Replace',false);

o.geneTable.moduleColorOld=o.geneTable.moduleColor;
o.geneTable.moduleColor = categorical(tmp', 1:max(T), newColorNames);

if p.Results.saveTable
   writetable(o.geneTable, o.geneTablePath);
end



