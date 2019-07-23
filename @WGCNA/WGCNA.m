classdef WGCNA < handle
    % WGCNA
    
    properties
        baseDir = [] % Base Directory, set this to use relative paths
        geneTable
        dissTOM
        graphTOM
        deseqTable
        deseqFileName % Name of the deseq2 file
        eigenGenes
    end
    
    methods
        function o = WGCNA()
        end
        
        copyGenes(o,GraphOrModuleName)
                
        o = loadGeneTable(o,geneTablePath)
        o = loadDissTOM(o,dissTOMPath,varargin)
        o = loadDESEQ(o,deseqPath)

        

        
        function g = getGraphOfModule(o,moduleName)
            g = subgraph(o.graphTOM, o.geneTable.moduleColor == moduleName);
%             g = o.removeDisconnectedNodes(g);
%             g = o.pruneEdges(g, 5)
        end
        
        function g = getGraphOfNeighbors(o,geneName,dist)
            nodeIDs = nearest(o.graphTOM, geneName, 1);
            nodeIDs = nodeIDs(1:dist);
            nodeIDs{end+1} = geneName;
            g = subgraph(o.graphTOM, nodeIDs);
        end
        
        
    end
    
    
    methods(Static)
        function g  = removeDisconnectedNodes(g)
            % Use this function to remove disconnected genes
            g = rmnode(g, find(sum(adjacency(g,'weighted')) == 0));
        end
        
        function g = pruneEdges(g, n)
            % Make it so that each node has an average of n connections
            numEdgesToRemove = g.numedges - (g.numnodes * n);
            numEdgesToRemove = max(numEdgesToRemove,0)
            [~, EdgesToRemove] = maxk(g.Edges.Weight, numEdgesToRemove);
            g = rmedge(g, EdgesToRemove);
        end
        
        function h = plotGraph(g)
            figure
            h = plot(g,'EdgeCData',g.Edges.Weight, 'NodeLabelMode', 'auto');
%             h.MarkerSize = rescale(-g.Nodes.Wald_Stats,2,2)
            h.LineWidth = 1
            h.EdgeAlpha = .7;
            h.NodeFontSize = 8
            % h.NodeColor ='w';
%             h.NodeCData = g.Nodes.Wald_Stats;
            layout(h,'force3','WeightEffect','direct','UseGravity','on');

            set(gcf,'Colormap',flipud(plasma),'Color','k');
            h.NodeLabelColor = 'w';
            h.NodeFontWeight = 'bold'
            box off
            axis off
            set(gca,'position',[0,0,1,1])
        end
    end
end

