function o = createGraphTOM(o)
o.dissTOM(o.dissTOM > 0.95) = 0;
o.graphTOM = graph(o.dissTOM,o.geneTable.Probes,'upper');
o.graphTOM.Nodes.module = o.geneTable.moduleColor;
if ~isempty(o.deseqTable)
    o.graphTOM.Nodes.module = o.deseqTable.moduleColor;
    o.graphTOM.Nodes.Wald_Stats = o.deseqTable.Wald_Stats;
    o.graphTOM.Nodes.P_adj = o.deseqTable.P_adj;
    o.graphTOM.Nodes.P_value = o.deseqTable.P_value;
end
end