function o = loadDESEQ(o,deseqPath)
% loadDESEQ load the output of deseq2
%
% loadDESEQ('DeseqFile.xlsx') loads the values in 'DeseqFile.xlsx'. If the
% dissTOM file is already loaded or the graph is created, loadDESEQ will
% append that stats to the graph.

[~, o.deseqFileName] = fileparts(deseqPath);
o.deseqTable = readtable(deseqPath, 'TreatAsEmpty', 'NA');
[o.deseqTable, ~, idx] = innerjoin(o.deseqTable,o.geneTable,'LeftKeys',1,'RightKeys','Probes');
% Convert P-Values to Z scores for Normalizaiotn & Plotting
o.deseqTable.z_score = -sqrt(2) * erfcinv(o.deseqTable.P_adj*2);

if ~isempty(o.dissTOM)
    o.geneTable = o.geneTable(idx,:);
    o.dissTOM = o.dissTOM(:,idx);
    o.dissTOM = o.dissTOM(idx,:);
end

if ~isempty(o.graphTOM)
    o.graphTOM.Nodes.Wald_Stats = o.deseqTable.Wald_Stats;
    o.graphTOM.Nodes.P_adj = o.deseqTable.P_adj;
    o.graphTOM.Nodes.module = o.deseqTable.moduleColor;
    o.graphTOM.Nodes.P_value = o.deseqTable.P_value;
end
            
end