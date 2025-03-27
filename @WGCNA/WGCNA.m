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
        colorMap = 'Crayola';
        geneTablePath
        key

    end
    
    methods
        function o = WGCNA()
        end
        
        copyGenes(o,GraphOrModuleName)
                
        o = loadGeneTable(o,geneTablePath,varargin)
        o = loadDissTOM(o,dissTOMPath,varargin)
        o = loadDESEQ(o,deseqPath)
        o = mergeEigenGenes(o,varargin);

        

        
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
            numEdgesToRemove = round(max(numEdgesToRemove,0))
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
            
            
            
            try
            if sum(daObj.Layout=='tree')==4;
            g = minspantree(g);
            g = w.removeDisconnectedNodes(g);
            end
            catch
            end
            
            figure('Position',[0 0 1180 1080])
            % h = plot(g,'EdgeCData',rescale(g.Edges.Weight,0,1), 'NodeLabelMode', 'auto');
            h = plot(g,'EdgeCData',1-g.Edges.Weight, 'NodeLabelMode', 'auto');
            if daObj.SigNode==1;
                g.Nodes.Wald_Stats(isnan(g.Nodes.Wald_Stats))=0;
                h.MarkerSize = rescale(abs(g.Nodes.Wald_Stats),2,12)
                h.NodeColor = [.90,.60,0];
            else
                h.MarkerSize = 5;
                h.NodeColor = [.90,.60,0];;
            end
            h.LineWidth = daObj.LineWidth;
            h.EdgeAlpha = daObj.EdgeAlpha;
            h.NodeFontSize = daObj.NodeFontSize;
            
            try
            if sum(daObj.Layout=='circle')==6;
            layout(h,'circle');
            end
            catch
            end
            
            try
            if sum(daObj.Layout=='force')==5;
            center=centrality(g,'degree');
            g.Nodes.Connections=center;
            [B I] = maxk(g.Nodes.Connections,5);
            tmp=repmat({''},1,length(h.NodeLabel));
            tmp(I)=h.NodeLabel(I);
            h.NodeLabel=tmp;
            %layout(h,daObj.Layout,'WeightEffect','direct','UseGravity','on');
            layout(h,'force','WeightEffect','inverse','UseGravity','on');
            %layout(h,'subspace3','Dimension',100);
            end
            catch
            end
            
            try
            if sum(daObj.Layout=='subspace')==8;
            center=centrality(g,'degree');
            g.Nodes.Connections=center;
            [B I] = maxk(g.Nodes.Connections,5);
            tmp=repmat({''},1,length(h.NodeLabel));
            tmp(I)=h.NodeLabel(I);
            h.NodeLabel=tmp;
            layout(h,'subspace3','Dimension',150);
            end
            catch
            end
            
            try
            if sum(daObj.Layout=='subspace')==8;
            center=centrality(g,'degree');
            g.Nodes.Connections=center;
            [B I] = maxk(g.Nodes.Connections,5);
            tmp=repmat({''},1,length(h.NodeLabel));
            tmp(I)=h.NodeLabel(I);
            h.NodeLabel=tmp;
            layout(h,'subspace3','Dimension',150);
            end
            catch
            end
            
            try
            if sum(daObj.Layout=='tree')==4;
            layout(h,'force','Iterations',30,'WeightEffect','inverse','UseGravity','on');
            center=centrality(g,'degree');
            g.Nodes.Connections=center;
            [B I] = maxk(g.Nodes.Connections,4);
            tmp=repmat({''},1,length(h.NodeLabel));
            tmp(I)=h.NodeLabel(I);
            h.NodeLabel=tmp;
            end
            catch
            end
            
            set(gcf,'Colormap',(plasma),'Color','k');
            h.NodeLabelColor = 'w';
            h.NodeFontWeight = 'bold'
            box off
            axis off
            c=colorbar('Color','w');
%             c.Limits = [min(h.EdgeCData) max(h.EdgeCData)]
            c.Label.String="Similarty";
            
%             set(gca,'position',[0,0,1,1])
        end
    end
end

