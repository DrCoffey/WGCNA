function o = calculateEigenGenes(o)
calcType = 'unweighted';
%calcType = 'weighted';
o.eigenGenes = [];

% Get the columns that contain the TPMs
numericVars = varfun(@isnumeric,o.geneTable,'output','uniform');
sampleNames = o.geneTable.Properties.VariableNames(numericVars)';
modules = unique(o.geneTable.moduleColor);

for module = modules'
    
    switch calcType
        case 'weighted'
            % Extract the subgraph
            g = o.getGraphOfModule(module);
            g = o.removeDisconnectedNodes(g);
            TPM = o.geneTable{ismember(o.geneTable.Probes,g.Nodes.Name), numericVars};
            % Do weighted PCA
            if height(g.Nodes) < 2000
                weights = centrality(g,'closeness','Cost',g.Edges.Weight);
                %[~,score] = pca(log2(TPM'+1),'NumComponents',1,'VariableWeights',weights);
                [~,score] = pca(TPM','NumComponents',1,'VariableWeights',weights);
            else
                %[~,score] = pca(log2(TPM'+1),'NumComponents',1);
                [~,score] = pca(TPM','NumComponents',1);
            end
            
        case 'unweighted'
            TPM = o.geneTable{o.geneTable.moduleColor == module, numericVars};
                [~,score] = pca(TPM','NumComponents',1);
                %[~,score] = pca(log2(TPM'+1),'NumComponents',1);
    end
    if isempty(score)
        score = zeros(length(sampleNames),1);
    end
    if isempty(o.key)
    o.eigenGenes = [o.eigenGenes;
        table(repmat(module,length(sampleNames),1),sampleNames,zscore(score),'VariableNames',{'moduleColor','Sample','eigenGene'})
        ];
    else
    o.eigenGenes = [o.eigenGenes;
        table(repmat(module,length(sampleNames),1),'VariableNames',{'moduleColor'}),...
        table(sampleNames,'VariableNames',{'Sample'}),...
        table(zscore(score),'VariableNames',{'eigenGene'}),...
        o.key];
    end
end
