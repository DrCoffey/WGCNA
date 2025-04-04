function plotEigenGenes(o)
% Plot the eigengenes for each sample.

%% Make the colors look cool
moduleColor = cellstr(unique(o.eigenGenes.moduleColor));
moduleColor = sort(moduleColor);
[~, rgb] = colornames(o.colorMap,moduleColor);


% [~, rgb] = colornames(o.colorMap,unique(o.eigenGenes.moduleColor,'sorted'));
x=(1:1:height(o.eigenGenes.Sample));
figure('Position',[1,1,1500,1500])
%g = gramm('x',o.eigenGenes.Sample, 'y',o.eigenGenes.eigenGene, 'color',o.eigenGenes.moduleColor);
g = gramm('x',x, 'y',o.eigenGenes.eigenGene, 'color',o.eigenGenes.moduleColor);
g.facet_wrap(o.eigenGenes.moduleColor,'ncols',4,'scale','free_x');
g.geom_point();
g.geom_line();
g.set_layout_options('redraw',0,'margin_height',[.05,.05],'margin_width',[.05,.05]);
g.set_color_options('map',rgb);
g.set_names('x','','y','(eG)');
g.no_legend;
g.set_order_options('x',1);
g.set_text_options('base_size',12)
g.draw;

for i = 1:length(g.facet_axes_handles)
    g.facet_axes_handles(i).XTickLabel={};
end