function h = boxutilC(x,notch,lb,lf,sym,vert,whis,whissw,c,fillit,LineWidth,koutline,lessoverlap,meansym)
%BOXUTILC Produces a single box plot.
%   BOXUTILC(X) is a utility function for BOXPLOT, which calls
%   BOXUTILC once for each column of its first argument. Use
%   BOXPLOTC or BOXPLOTCSUB rather than BOXUTILC. 

%   BFGK 26-mars-2002
%       c           Color option, uses standard color string
%       fillit      Fill option [0 default, 1 produces filled boxes]
%       LineWidth   Specify LineWidth of box lines (deafult = 0.5)
%   BFGK 23-mai-2003
%       corrected color allocation for outlier SYM
%   BFGK 21-aout-03
%       koutline    if = 1 uses 'k-' for the line color while c option us still 
%                   used for the fill. This allows for the outline of the box and 
%                   the mean line to remain black and visible. = 0 by default
%   BFGK 17-oct-03
%       h           graphics handle output, outputs matrix of graphics
%                   handles, each column represents a data set. Rows
%                   correspond to 
%                       1: upper whisker line
%                       2: lower whisker line
%                       3: lower extent endline
%                       4: upper extent endline
%                       5: box
%                       6: median line
%                       7: outlier marker
%                       8: fill patch polygon
%   BFGK 6-mai-2004
%       corrected treatment of empty SYM
%   BFGK 1-mai-2008
%       added an outlier counter using 'UserData' of the gca
%       not yet compatible with boxplotCsub
%   BFGK 22-jun-2008
%       added handle to filled polygon
%   BFGK 10-jun-2010
%       lessoverlap reduce width of boxes to reduce overlap, in units. Default = 0
%   BFGK 1-oct-2010
%       meansym  added plot symbol for plotting mean value 
%                h(9,:)
%   BFGK 31-aug-2012
%       corrected errors produced when using [rgb] color def in certain instances

%   Copyright 1993-2000 The MathWorks, Inc. 
% $Revision: 2.14 $  $Date: 2000/05/26 17:28:25 $

% Make sure X is a vector.
if min(size(x)) ~= 1, 
    error('First argument has to be a vector.'); 
end

nargs = nargin  ;
if nargs < 8
    error('Requires at least eight input arguments.');
end

if (nargs < 9 | isempty(c)), 
    nargs = 8; 
    c = 'b';
end
if (nargs < 10 | isempty(fillit)), fillit = 0; end
if (nargs < 11 | isempty(LineWidth)), LineWidth = 0.5; end
if (nargs < 12 | isempty(koutline)), koutline = 0; end
if (nargs < 13 | isempty(lessoverlap)), lessoverlap = 0; end
% if (nargs < 14 | isempty(meansym)), meansym = 'k+'; end
if (nargs < 14 ), meansym = 'k+'; end

% define the median and the quantiles
med = prctile(x,50);
q1 = prctile(x,25);
q3 = prctile(x,75);

avg = mean(x); % add mean point

% find the extreme values (to determine where whiskers appear)
vhi = q3+whis*(q3-q1);
upadj = max(x(x<=vhi));
if (isempty(upadj)), upadj = q3; end

vlo = q1-whis*(q3-q1);
loadj = min(x(x>=vlo));
if (isempty(loadj)), loadj = q1; end

x1 = lb*ones(1,2);
x2 = x1+[-0.25*lf,0.25*lf];
yy = x(x<loadj | x > upadj);

%sym1 = [c sym]

if isempty(yy)
   yy = loadj;
   if ~isempty(sym),
       [a1 a2 a3 a4] = colstyle(sym);
       sym = [a2 '.'];
   else
       sym = '';
   end
end

xx = lb*ones(1,length(yy));
    lbp = lb + 0.5*lf -lessoverlap ;
    lbm = lb - 0.5*lf +lessoverlap ;

if whissw == 0
   upadj = max(upadj,q3);
   loadj = min(loadj,q1);
end

% Set up (X,Y) data for notches if desired.
if ~notch
    xx2 = [lbm lbp lbp lbm lbm];
    yy2 = [q3 q3 q1 q1 q3];
    xx3 = [lbm lbp];
else
    n1 = med + 1.57*(q3-q1)/sqrt(length(x));
    n2 = med - 1.57*(q3-q1)/sqrt(length(x));
    if n1>q3, n1 = q3; end
    if n2<q1, n2 = q1; end
    lnm = lb-0.25*lf;
    lnp = lb+0.25*lf;
    xx2 = [lnm lbm lbm lbp lbp lnp lbp lbp lbm lbm lnm];
    yy2 = [med n1 q3 q3 n1 med n2 q1 q1 n2 med];
    xx3 = [lnm lnp];
end
yy3 = [med med];

if ischar(c),
    linec = [c '-']    ;
    dashc = [c '--']   ;
    rgbcolor = false;
else
    linec = [ '-']    ;
    dashc = [ '--']   ;
    rgbcolor=true;
end

if nargs < 9,
    endline = 'k-'  ;
    meanline = 'r-' ;
elseif koutline == 1,
    endline = 'k-'  ;
    meanline = 'k-' ;
    linec = 'k-';
else
    endline = linec  ;
    meanline = linec ;
end

% [q3 upadj]
% x1
% dashc
% [loadj q1]
% x1
% dashc
% [loadj loadj]
% x2
% endline
% [upadj upadj]
% x2
% endline
% yy2
% xx2
% linec
% yy3
% xx3
% meanline
% yy
% xx
% [c sym]
% 

% Determine if the boxes are vertical or horizontal.
% The difference is the choice of x and y in the plot command.

if fillit
    if vert
        H_fill = fill(xx2,yy2,c)    ;
    else
        H_fill = fill(yy2,xx2,c)    ;
    end
else
    H_fill = [] ;
end

%sym2 = [c sym]

if isempty(sym),
	if vert
        H = plot(x1,[q3 upadj],dashc,x1,[loadj q1],dashc,...
            x2,[loadj loadj],endline,...
            x2,[upadj upadj],endline,xx2,yy2,linec,xx3,yy3,meanline);
	else
        H = plot([q3 upadj],x1,dashc,[loadj q1],x1,dashc,...
            [loadj loadj],x2,endline,...
            [upadj upadj],x2,endline,yy2,xx2,linec,yy3,xx3,meanline);
	end
else
	if vert
        H = plot(x1,[q3 upadj],dashc,x1,[loadj q1],dashc,...
            x2,[loadj loadj],endline,...
            x2,[upadj upadj],endline,xx2,yy2,linec,xx3,yy3,meanline,xx,yy,[sym]);
	else
        H = plot([q3 upadj],x1,dashc,[loadj q1],x1,dashc,...
            [loadj loadj],x2,endline,...
            [upadj upadj],x2,endline,yy2,xx2,linec,yy3,xx3,meanline,yy,xx,[sym]);
    end
    set(H(7),'color',c);
end
if (rgbcolor)&(~koutline),
    set(H(1:6),'color',c)
elseif (rgbcolor)&(koutline),
    set(H(1:2),'color',c)
end

set(H,'LineWidth',LineWidth)

if ~isempty(H_fill),
    H(8,:) = H_fill;
end

if (meansym),
    if vert
        H(9,:) = plot(lb,avg,meansym);
    else
        H(9,:) = plot(avg,lb,meansym);
    end
end

OutlierCnt = get(gca,'UserData')    ;
if isempty(OutlierCnt),
    % can't use xx(1) as index as in boxplotC because for the subplot
    % version the xx coords are not integers. May be more trouble that its
    % worth to get this working for this case.
elseif iscell(OutlierCnt) && strcmp(OutlierCnt{1},'boxplotCsub'),
%    disp('here')
    % can't use xx(1) as index as in boxplotC because for the subplot
    % version the xx coords are not integers. May be more trouble that its
    % worth to get this working for this case.
elseif ~iscell(OutlierCnt) && strcmp(OutlierCnt,'boxplotCsub'),
%    disp('there')
    % can't use xx(1) as index as in boxplotC because for the subplot
    % version the xx coords are not integers. May be more trouble that its
    % worth to get this working for this case.
else
    OutlierCnt{xx(1)+1} = length( x(x<loadj | x > upadj) )      ; 
    set(gca,'UserData',OutlierCnt)      ; 
end

if nargout > 0, h = H   ; end

return
