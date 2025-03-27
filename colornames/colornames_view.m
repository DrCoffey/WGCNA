function colornames_view(palette,order) %#ok<*TRYNC,*ISMAT,*TNOW1>
% View the COLORNAMES palettes in an interactive figure. Sort colors by name/colorspace.
%
% (c) 2014-2024 Stephen Cobeldick
%
%%% Syntax:
%  colornames_view
%  colornames_view(palette)
%  colornames_view(palette,order)
%
% Create a figure displaying all of the colors from any palette supported
% by the function COLORNAMES. The palette and sort order can be selected
% by drop-down menu or by optional inputs. The colors may be sorted:
% * alphanumerically (names includ any leading indices), or
% * alphabetically (names exclude any leading indices), or
% * by colorspace: Lab, LCh, XYZ, YUV, HSV, or RGB.
%
% Unfortunately for R2014b and later (i.e. HG2) getting the colorname
% extents is slow for larger color palettes. For HG1 it is much faster.
%
% Dependencies:  Requires the function COLORNAMES(FEX 48155).
%
%% Input and Output Arguments %%
%
%%% Inputs (all inputs are optional):
%  palette   = CharRowVector, the name of a palette supported by COLORNAMES.
%  sortorder = CharRowVector, either 'Alphabetic' OR 'AlphaNumeric' OR
%              the colorspace dimensions in the desired order, e.g.:
%              'Lab', 'abL', 'bLa', ... 'XYZ', ... 'RGB','RBG',... etc. 
%
%%% Outputs:
% none
%
% See also COLORNAMES COLORNAMES_CUBE COLORNAMES_DELTAE COLORNAMES_SEARCH MAXDISTCOLOR

%% Figure Parameters %%
%
persistent fgh axh slh txh pmh smh edh txs cnc rgb prv txd
%
isChRo = @(s) ischar(s) && ndims(s)==2 && size(s,1)==1;
%
% Text lightness threshold:
thr = 0.54;
%
% Text margin, uicontrol and axes gap (pixels):
mrg = 5;
gap = 4;
sid = 20;
%
% Slider position:
yid = 0;
ymx = 0;
%
% Handle of outlined text:
prv = [];
%
pmt = 'Enter a color name or RGB here, or click on a tile...';
ift = 'Initializing the figure... please wait.';
%
% Get palette names and colorspace functions:
[pnc,csf,dbg] = colornames();
%
if nargin<1
	idp = 1+rem(round(now*1e7),numel(pnc));
else
	palette = cnv1s2c(palette);
	assert(isChRo(palette),...
		'SC:colornames_view:palette:NotText',...
		'The first input <palette> must be a string scalar or a char row vector.')
	idp = find(strcmpi(palette,pnc));
	assert(isscalar(idp),...
		'SC:colornames_view:palette:UnknownPalette',...
		'Palette "%s" is not supported. Call COLORNAMES() to list all palettes.',palette)
end
%
%% Color Sorting List %%
%
% For sorting:
ncs = {'AlphaNumeric';'Alphabetic'};
ucs = {'Lab';'XYZ';'LCh';'YUV';'HSV';'RGB'};
% Get every permutation of the colorspaces:
cso = cellfun(@(s)perms(s(end:-1:1)),ucs,'UniformOutput',false);
cso = [ncs;cellstr(vertcat(cso{:}))];
acs = [ncs;ucs];
[lst,idl] = cellfun(@sort,acs,'UniformOutput',false);
%
if nargin<2
	ido = 1;
else
	order = cnv1s2c(order);
	assert(isChRo(order),...
		'SC:colornames_view:order:NotText',...
		'The second input <order> must be a string scalar or a char row vector.')
	ido = strcmpi(order,cso);
	assert(any(ido),...
		'SC:colornames_view:order:UnknownOption',...
		'The second input <order> must be one of:%s\b.',sprintf(' %s,',cso{:}))
	ido = find(ido);
end
%
% Intial color sorting index:
idx = 1:numel(colornames(pnc{idp}));
%
%% Create a New Figure %%
%
if isempty(fgh)||~ishghandle(fgh)
	txd = cell(size(pnc));
	% Figure with zoom and pan functions:
	fgh = figure('HandleVisibility','callback', 'IntegerHandle','off',...
		'NumberTitle','off', 'Name','ColorNames View', 'Color','white',...
		'Toolbar','figure', 'Units','pixels', 'Tag',mfilename, 'Visible','on');
	%
	fgp = get(fgh,'Position');
	inh = uicontrol(fgh, 'Units','pixels', 'Style','text', 'HitTest','off',...
		'Visible','on',	'String',ift);
	inx = get(inh,'Extent');
	set(inh,'Position',[fgp(3:4)/2-inx(3:4)/2,inx(3:4)])
	%
	% Axes and scrolling slider:
	slh = uicontrol('Parent',fgh, 'Style','slider', 'Visible','off',...
		'Enable','on', 'Value',1, 'Min',0, 'Max',1,...
		'FontUnits','pixels', 'Units','pixels', 'Callback',@cnvSldClBk);
	axh = axes('Parent',fgh, 'Visible','off', 'Units','pixels',...
		'YDir','reverse', 'XTick',[], 'YTick',[], 'XLim',[0,1], 'YLim',[0,1]);
	% Palette and color sorting method drop-down menus:
	pmh = uicontrol('Parent',fgh, 'Style','popupmenu', 'String',pnc,...
		'ToolTip','Color Scheme', 'Units','pixels',...
		'Visible','off', 'Callback',@cnvPalClBk);
	smh = uicontrol('Parent',fgh, 'Style','popupmenu', 'String',cso,...
		'ToolTip','Sort Colors', 'Units','pixels',...
		'Visible','off', 'Callback',@cnvSrtClBk);
	edh = uicontrol('Parent',fgh, 'Style','edit', 'String',ift,...
		'ToolTip','RGB Value',   'Units', 'pixels', 'Visible','off',...
		'HorizontalAlignment','left', 'Callback',@cnvEditClBk);
else
	set(edh,'String',pmt)
end
set(pmh,'Value',idp);
set(smh,'Value',ido);
%
fgo = get(fgh, 'Pointer');
set(fgh, 'Pointer','watch')
drawnow()
%
%% Helper Functions %%
%
	function cnvNoEdge(h)
		% Note: setting one object is much faster than setting all objects.
		try
			set(h, 'EdgeColor','none')
		end
	end
%
	function cnvRecenter(h)
		pos = [];
		try
			pos = get(h,'Position');
		end
		if numel(pos)
			yld = diff(get(axh,'Ylim'));
			tmp = max(0,min(ymx-yld,pos(2)-yld/2));
			set(axh, 'Ylim',[0,yld]+tmp)
			set(slh, 'Value',1-tmp/(ymx-yld))
		end
	end
%
%% Callback Functions %%
%
	function cnvEditClBk(h,~) % Text Change CallBack
		two = get(h,'String');
		[hxv,~,~,ide] = sscanf(two,'#%2x%2x%2x');
		fpv = sscanf(regexprep(two(ide:end),'[^.0-9]+',' '),'%f');
		fpv = reshape([hxv/255;fpv],1,[]);
		if numel(fpv)==3
			two = fpv;
		end
		fnd = [];
		try
			fnd = colornames(pnc{idp},two);
		end
		if isempty(fnd)
			cnvNoEdge(prv)
			set(edh, 'String',pmt)
			prv = [];
		else
			idc = strcmp(cnc,fnd);
			tmp = txh(idc);
			cnvTextBuDn(tmp)
			cnvRecenter(tmp)
		end
	end
%
	function cnvTextBuDn(h,~)
		cnvNoEdge(prv)
		uistack(h,'top')
		prv = h;
		str = get(h,'String');
		bgd = get(h,'BackgroundColor');
		%
		[R,G,B] = ndgrid(0:1);
		cnr = [R(:),G(:),B(:)];
		[~,idc] = max(sum(bsxfun(@minus,cnr,bgd).^2,2));
		hxs = sprintf('%02X',round(bgd*255));
		dcs = sprintf(',%.5f',bgd);
		set(edh, 'String',sprintf('#%s [%s] %s',hxs,dcs(2:end),str));
		set(h, 'EdgeColor',cnr(idc,:))
	end
%
	function cnvPalClBk(h,~) % Palette Menu CallBack
		% Select a new palette.
		idp = get(h,'Value');
		set(slh, 'Value',1)
		set(edh, 'String',ift)
		set(fgh, 'Pointer','watch')
		drawnow()    %disp('pal: drawing new text...')
		cnvTxtDraw() %disp('pal: sorting text...')
		cnvSortBy()  %disp('pal: resizing text...')
		cnvResize()  %disp('pal: complete!')
		try
			set(edh, 'String',pmt)
			set(fgh, 'Pointer',fgo)
		end
	end
%
	function cnvSrtClBk(h,~) % Sort-Order Menu CallBack
		% Select the color sorting method.
		ido = get(h,'Value');
		edt = get(edh, 'String');
		set(edh, 'String',ift)
		set(fgh, 'Pointer','watch')
		drawnow()
		cnvSortBy()
		cnvResize()
		try
			cnvRecenter(prv)
			set(edh, 'String',edt)
			set(fgh, 'Pointer',fgo)
		end
	end
%
	function cnvSldClBk(h,~) % Slider CallBack
		% Scroll the axes by changing the axes limits.
		yld = diff(get(axh,'Ylim'));
		set(axh, 'Ylim',[0,yld]+(ymx-yld)*(1-get(h,'Value')));
	end
%
	function cnvZoomClBk(~,~) % Zoom CallBack
		% Change the font and margin sizes.
		yld = diff(get(axh,'Ylim'));
		set(txh, 'FontSize',txs/yld);
		set(txh, 'Margin',mrg/yld);
	end
%
	function cnvPanClBk(~,~) % Pan CallBack
		% Move the scroll-bar to match panning of the axes.
		tmp = get(axh,'Ylim');
		set(slh, 'Value',max(0,min(1,1-tmp(1)/(ymx-diff(tmp)))))
	end
%
%% Color Sorting %%
%
	function cnvSortBy()
		[tmp,ids] = sort(cso{ido});
		idc = strcmp(tmp,lst);
		ids = ids(idl{idc});
		switch acs{idc}
			case ncs{1} % AlphaNum
				idx = csf.cnNatSort(cnc);
				return
			case ncs{2} % Alphabet
				ind = dbg(idp).index;
				if numel(ind)
					rxi = sprintf('^(%s)\\s*',ind);
					[~,idx] = sort(lower(regexprep(cnc(:),rxi,'')));
				else
					[~,idx] = sort(lower(cnc(:)));
				end
				return
			case 'RGB'
				mat = rgb;
			case 'HSV'
				mat = csf.cnRGB2HSV(rgb);
			case 'XYZ'
				mat = csf.cnRGB2XYZ(rgb);
			case 'Lab'
				mat = csf.cnXYZ2Lab(csf.cnRGB2XYZ(rgb));
			case 'LCh'
				mat = csf.cnLab2LCh(csf.cnXYZ2Lab(csf.cnRGB2XYZ(rgb)));
			case 'YUV' % BT.709
				mat = csf.cnGammaInv(rgb) * [...
					+0.2126, -0.19991, +0.61500;...
					+0.7152, -0.33609, -0.55861;...
					+0.0722, +0.43600, -0.05639];
			otherwise
				error('SC:colornames_view:space:UnknownOption',...
					'Colorspace "%s" is not supported.',cso{ido})
		end
		[~,idx] = sortrows(mat,ids);
	end
%
%% Re/Draw Text Strings %%
%
txf = @(s,b,c)text('Parent',axh, 'String',s, 'BackgroundColor',b,...
	'Color',c,'Margin',mrg, 'Units','data', 'Interpreter','none',...
	'VerticalAlignment','bottom', 'HorizontalAlignment','right',...
	'Clipping','on', 'ButtonDownFcn',@cnvTextBuDn,'LineWidth',3);
%
	function cnvTxtDraw()
		% Delete any existing colors:
		try
			cla(axh)
		end
		drawnow()
		% Get new colors:
		[cnc,rgb] = colornames(pnc{idp});
		% Calculate the text color:
		baw = (rgb*[0.298936;0.587043;0.114021])<thr;
		% Draw new colors in the axes:
		txh = cellfun(txf,cnc,num2cell(rgb,2),num2cell(baw(:,[1,1,1]),2),'Uni',0);
		txh = reshape([txh{:}],[],1);
		txs = get(txh(1),'FontSize');
	end
%
%% Resize the Axes and UIControls, Move the Colors %%
%
	function cnvResize(~,~)
		%
		%disp('rsz: preprocessing...')
		%
		zoom(fgh,'out');
		%
		if nargin
			txt = get(edh, 'String');
			set(edh, 'String',ift)
			set(fgh, 'Pointer','watch')
			drawnow()
		end
		%
		try
			ecv = get(prv, 'EdgeColor');
			set(prv, 'EdgeColor','none');
		end
		%
		set(axh, 'Ylim',[0,1])
		set(txh, 'Units','pixels', 'FontSize',txs, 'Margin',mrg)
		%disp('rsz: getting extents...')
		if isempty(txd{idp})
			txe = cell2mat(get(txh(:),'Extent')); % slow on HG2 :(
			txd{idp} = txe; %disp('rsz: get new extents...')
		else
			txe = txd{idp}; %disp('rsz: use old extents...')
		end
		%disp('rsz: postprocessing...')
		top = get(slh,'FontSize')*2;
		fgp = get(fgh,'Position'); % [left bottom width height]
		hgt = round(fgp(4)-3*gap-top);
		wid = fgp(3)-3*gap-sid;
		pos = [gap,gap,wid,hgt];
		%
		% Calculate color lengths from text and margins:
		%disp('rsz: calculating text extent...')
		txw = 2*mrg+txe(idx,3);
		txc = cumsum(txw);
		%
		% Preallocate position array:
		txm = mean(txw);
		out = zeros(ceil(1.1*[txc(end)/pos(3),pos(3)/txm]));
		% Split colors into lines that fit the axes width:
		idb = 1;
		idr = 0;
		tmp = 0;
		while idb<=numel(txc)
			idr = idr+1;
			idq = max([idb,find((txc-tmp)<=pos(3),1,'last')]);
			out(idr,1:1+idq-idb) = txc(idb:idq)-tmp;
			tmp = txc(idq);
			idb = idq+1;
		end
		%
		% Calculate X and Y positions for each color:
		%disp('rsz: calulating text X & Y positions...')
		[~,txy,txx] = find(out.');
		txy = txy(:);
		txx = txx(:);
		yid = txy(end);
		txy = txy*(2*mrg+max(txe(idx,4)));
		ymx = txy(end)/pos(4);
		%
		% Resize the scrollbar, adjust scroll steps:
		nwp = [2*gap+wid,gap,sid,hgt];
		if ymx>1
			set(slh, 'Position',nwp, 'Enable','on', 'Value',1,...
				'SliderStep',max(0,min(1,[0.5,2]/(yid*(ymx-1)/ymx))))
		else
			set(slh, 'Position',nwp, 'Enable','off')
		end
		%
		% Resize the axes and drop-down menus:
		%disp('rsz: resizing the axes...')
		set(axh, 'Position',pos)
		uiw = (fgp(3)-gap)/4-gap;
		txw = 2*uiw+gap;
		lhs = gap+(0:2)*(uiw+gap);
		bot = fgp(4)-top-gap;
		set(pmh, 'Position',[lhs(1),bot,uiw,top])
		set(smh, 'Position',[lhs(2),bot,uiw,top])
		set(edh, 'Position',[lhs(3),bot,txw,top])
		% Move text strings to the correct positions:
		%disp('rsz: moving text...')
		arrayfun(@(h,x,y)set(h,'Position',[x,y]),txh(idx),txx-mrg,pos(4)-txy+mrg);
		set(txh, 'Units','data')
		%
		try
			set(prv, 'EdgeColor',ecv);
		end
		%
		if nargin
			set(edh, 'String',txt)
			set(fgh, 'Pointer',fgo)
		end
		drawnow()
		%
		%disp('rsz: complete!')
	end
%
%% Initialize the Figure %%
%
%              disp('ini: drawing new text...')
cnvTxtDraw()  %disp('ini: sorting new text...')
cnvSortBy()   %disp('ini: resizing new text...')
cnvResize()   %disp('ini: complete!')
set([pmh,smh,edh,slh], 'Visible','on')
set(edh, 'String',pmt)
set(fgh, 'Pointer',fgo, 'ResizeFcn',@cnvResize)
set(zoom(fgh), 'ActionPostCallback',@cnvZoomClBk);
set(pan(fgh),  'ActionPostCallback',@cnvPanClBk);
try
	delete(inh)
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%colornames_view
function arr = cnv1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnv1s2c