function colornames_search(palette,name) %#ok<*TRYNC,*ISMAT,*TNOW1>
% View COLORNAMES colorname-matching in an interactive figure.
%
% (c) 2024 Stephen Cobeldick
%
%%% Syntax:
%  colornames_search
%  colornames_search(palette)
%  colornames_search(palette,name)
%
% Dependencies:  Requires the function COLORNAMES(FEX 48155
%
% Note0: Requires MATLAB R2023b or later.
%
%% Input and Output Arguments %%
%
%%% Inputs (all inputs are optional):
%  palette = CharRowVector, the name of a palette supported by COLORNAMES.
%  name    = CharRowVector, the text to be matched to palette color names.
%
%%% Outputs:
% none
%
% See also COLORNAMES COLORNAMES_CUBE COLORNAMES_DELTAE COLORNAMES_VIEW MAXDISTCOLOR

%% Input Wrangling %%
%
persistent uif uip uie uim uit ulz idp cnm
%
isc = @(s) ischar(s) && ndims(s)==2 && size(s,1)==1;
pnc = colornames();
%
if isempty(uif)||~ishghandle(uif)
	cnm = 'ie';
	idp = 1+rem(round(now*1e7),numel(pnc));
	[uif,uip,uie,uim,uit,ulz] = cnsNewFig(@cnsEditClBk,@cnsPallClBk,cnm,idp);
end
%
if nargin>0 && ~isequal(palette,[])
	palette = cns1s2c(palette);
	assert(isc(palette),...
		'SC:colornames_search:palette:NotText',...
		'The 1st input <palette> must be a string scalar or a char row vector.')
	idp = find(strcmpi(palette,pnc));
	assert(isscalar(idp),...
		'SC:colornames_search:palette:UnknownPalette',...
		'Palette "%s" is not supported. Call COLORNAMES() to list all palettes.',palette)
	uip.ValueIndex = idp;
end
%
if nargin>1 && ~isequal(name,[])
	cnm = cns1s2c(name);
	assert(isc(cnm),...
		'SC:colornames_search:name:NotText',...
		'The 2nd input <name> must be a string scalar or a char row vector.')
	uie.Value = cnm;
end
%
%% Callback Functions %%
%
	function cnsEditClBk(~,vcd) % Edit Change CallBack
		cnm = vcd.Value;
		cnsUpdateTxt()
	end
%
	function cnsPallClBk(~,evt) % Palette Menu CallBack
		idp = evt.ValueIndex;
		cnsUpdateTxt()
	end
%
	function cnsUpdateTxt() % Update Displayed Text
		try
			[one,~,dbg] = colornames(pnc{idp},cnm);
		catch
			one = [];
		end
		if numel(one)
			idx = dbg(idp).match{1};
			vec = dbg(idp).names(abs(idx));
			tmp = ["(exact)","(closest)"];
			uit.Value = vec(:);
			uim.Value = one{1};
			ulz.Text  = tmp{1+all(idx>0)};
		else
			uit.Value = '';
			uim.Value = '';
			ulz.Text  = '';
		end
	end
%
%% Initialize the Figure %%
%
cnsUpdateTxt()
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%colornames_search
function arr = cns1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cns1s2c
function [uif,uip,uie,uim,uit,ulz] = cnsNewFig(etf,ddm,cnm,idp)
%
uif = uifigure();
uif.Name = 'Interactive Color Name Matching Tool';
uif.Tag          = mfilename;
uif.Visible          =  'on';
uif.NumberTitle      = 'off';
uif.HandleVisibility = 'off';
uif.IntegerHandle    = 'off';
%
uig = uigridlayout(uif, [6,2]);
uig.ColumnWidth = {'1x','1x'};
uig.RowHeight = {'fit','fit','fit','fit','fit','1x'};
uig.ColumnSpacing = 3;
uig.RowSpacing    = 3;
%
ulp = uilabel(uig);
ulp.Visible = 'on';
ulp.Text = 'Select Palette';
ulp.FontWeight = 'bold';
ulp.HorizontalAlignment = 'center';
ulp.Layout.Row = 1;
ulp.Layout.Column = 1;

uip = uidropdown(uig);
uip.Visible = 'on';
uip.Tag = 'Palette';
uip.Tooltip = 'Select the pallete to search';
uip.Items = colornames();
uip.ValueIndex = idp;
uip.ValueChangedFcn = ddm;
uip.Layout.Row = 2;
uip.Layout.Column = 1;
%
ule = uilabel(uig);
ule.Visible = 'on';
ule.Text = 'Input Text';
ule.FontWeight = 'bold';
ule.HorizontalAlignment = 'center';
ule.Layout.Row = 1;
ule.Layout.Column = 2;
%
uie = uieditfield(uig, 'text');
uie.Visible = 'on';
uie.Tag = 'ColorName';
uie.Placeholder = 'Enter text to match here';
uie.Tooltip = 'Enter the color name (partial or full), index, or initial to match';
uie.HorizontalAlignment = 'center';
uie.Value = cnm;
uie.ValueChangedFcn  = etf;
uie.ValueChangingFcn = etf;
uie.Layout.Row = 2;
uie.Layout.Column = 2;
%
ulm = uilabel(uig);
ulm.Visible = 'on';
ulm.Text = 'Best Color Name Match';
ulm.FontWeight = 'bold';
ulm.HorizontalAlignment = 'center';
ulm.Layout.Row = 3;
ulm.Layout.Column = [1,2];
%
ulz = uilabel(uig);
ulz.Visible = 'on';
ulz.Text = '';
ulz.FontWeight = 'normal';
ulz.HorizontalAlignment = 'right';
ulz.Layout.Row = 3;
ulz.Layout.Column = 2;
%
uim = uieditfield(uig, 'text');
uim.Visible  = 'on';
uim.Enable   = 'on';
uim.Editable = 'off';
uim.Tag = 'Best Color Name Match';
uim.Placeholder = 'No color names matched the input text!';
uim.Tooltip = 'The filtered color name with the smallest Levenshtein distance to the input text. This is the output returned by COLORNAMES().';
uim.HorizontalAlignment = 'center';
uim.Layout.Row = 4;
uim.Layout.Column = [1,2];
%
ult = uilabel(uig);
ult.Visible = 'on';
ult.Text = 'Filtered Palette Color Names';
ult.FontWeight = 'bold';
ult.HorizontalAlignment = 'center';
ult.Layout.Row = 5;
ult.Layout.Column = [1,2];
%
uit = uitextarea(uig, 'WordWrap','off');
uit.Visible  = 'on';
uit.Enable   = 'on';
uit.Editable = 'off';
uit.Tag = 'Filtered Palette Color Names';
uit.Placeholder = 'No color names matched the input text!';
uit.Tooltip = 'Either 1) one palette color name/index/initial which exactly matches the input text or 2) all palette color names that contain the same characters in the same order as the input text (the characters do not need to be consecutive). The best match is selected from this list.';
uit.HorizontalAlignment = 'center';
uit.Layout.Row = 6;
uit.Layout.Column = [1,2];
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnsNewFig