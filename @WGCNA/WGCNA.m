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
        colorMap
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
        
        function h = plotGraph(g,OptionZ)
            % initialize optional argument defaults
            if nargin<2;   OptionZ=struct([]); 
            end
            
            if isfield(OptionZ,'LineWidth')
            daObj.LineWidth=OptionZ.LineWidth;
            else
            daObj.LineWidth=1;
            end
            
            if isfield(OptionZ,'EdgeAlpha')
            daObj.EdgeAlpha=OptionZ.EdgeAlpha;
            else
            daObj.EdgeAlpha=.7;
            end
            
            if isfield(OptionZ,'NodeFontSize')
            daObj.NodeFontSize=OptionZ.NodeFontSize;
            else
            daObj.NodeFontSize=8;
            end
            
            if isfield(OptionZ,'SigNode')
            daObj.SigNode=OptionZ.SigNode;
            else
            daObj.SigNode=0;
            end
            
            if isfield(OptionZ,'Layout')
            daObj.Layout=OptionZ.Layout;
            else
            daObj.Layout='force';
            end
            
            figure%('Position',[0 0 1920 1080])
            h = plot(g,'EdgeCData',rescale(g.Edges.Weight,0,1), 'NodeLabelMode', 'auto');
            if daObj.SigNode==1;
                h.MarkerSize = rescale(-g.Nodes.Wald_Stats,2,2)
                h.NodeCData = g.Nodes.Wald_Stats;
            else
                h.MarkerSize = 5;
            end
            h.LineWidth = daObj.LineWidth;
            h.EdgeAlpha = daObj.EdgeAlpha;
            h.NodeFontSize = daObj.NodeFontSize;
            h.NodeColor ='w';
%             if sum(daObj.Layout=='circle')==6;
%             layout(h,'circle');
%             else
            layout(h,daObj.Layout,'WeightEffect','direct','UseGravity','on');
%             end
            set(gcf,'Colormap',flipud(plasma),'Color','k');
            h.NodeLabelColor = 'w';
            h.NodeFontWeight = 'bold'
            box off
            axis off
%             set(gca,'position',[0,0,1,1])
        end
    end
end

