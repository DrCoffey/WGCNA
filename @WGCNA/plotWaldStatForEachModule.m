function plotWaldStatForEachModule(o, varargin)

p=inputParser;

p.addOptional('column', 'Wald_Stats',  @(x) any(validatestring(x, {'Wald_Stats', 'P_value', 'P-adj', 'z_score'}))); % Column from deseq to plot
p.addOptional('colorOption', 'module', @(x) any(validatestring(x, {'module', 'same'}))); % Color the plots by module color or make them all the same
p.addOptional('title', o.deseqFileName); % Plot title
p.parse(varargin{:})







g = gramm('x',o.deseqTable.moduleColor,'y', o.deseqTable{:,p.Results.column}, 'color',o.deseqTable.moduleColor);
g.stat_violin('normalization','width','dodge',1,'fill','transparent','width',length(unique(o.deseqTable.moduleColor))/2);
g.geom_jitter('width',.1,'dodge',1);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
%g.axe_property('YLim',[-12 12],'tickdir','out');
g.set_names('column',[],'x',[],'y', p.Results.title);
g.set_text_options('base_size',14,'interpreter','none');

%% Make the colors look cool
moduleColor = cellstr(unique(o.deseqTable.moduleColor));
moduleColor = sort(moduleColor);
[~, rgb] = colornames(o.colorMap,moduleColor);


g.set_color_options('map',rgb);

g.geom_hline('yintercept',2.5,'style','--r');
g.geom_hline('yintercept',-2.5,'style','--r');

g.set_point_options('base_size',2);
g.no_legend();
figure('Position',[1 1 1250 500]);
g.draw();
xtickangle(g.facet_axes_handles,45)
set(gcf,'Position',[1 1 1750 800]);
% if o.export
%     g.export('export_path',figfold,'file_name',plotTitle,'file_type','png');
% end
