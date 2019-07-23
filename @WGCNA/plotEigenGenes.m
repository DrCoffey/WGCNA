function plotEigenGenes(o)
% Plot the eigengenes for each sample.

[~, rgb] = colornames('R',categories(o.eigenGenes.moduleColor));

figure
g = gramm('x',o.eigenGenes.Sample, 'y',o.eigenGenes.eigenGene, 'color',o.eigenGenes.moduleColor);
g.facet_wrap(o.eigenGenes.moduleColor,'ncols',4);
g.geom_bar;
g.set_layout_options('redraw',0,'margin_height',[.05,.05],'margin_width',[.05,.05]);
g.set_color_options('map',rgb);
g.set_names('x','','y','log2(eigenTMP)');
g.no_legend;
g.set_order_options('x',1);
g.set_text_options('base_size',6)
g.draw;

for i = g.facet_axes_handles
    xtickangle(i,45)
end