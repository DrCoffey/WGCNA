function copyGenes(o,GraphOrModuleName)
% copyGenes - Copy a set of genes to the clipboard for pasting into WebGestalt.
%
% copyGenes(g) copies the genes contained in graph g to the clipboard.
%
% copyGenes(module) copies the genes in module to the clipboard, where
% module is a cell or char vector.

switch class(GraphOrModuleName)
    case {'cell','char'}
        chars = string(o.geneTable.Probes(o.geneTable.moduleColor == GraphOrModuleName));
    case 'graph'
        chars = string(GraphOrModuleName.Nodes.Name);
end
clipboard('copy',sprintf('%s\r\n',chars))
end