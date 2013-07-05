%HISTNORM       Normalized histogram for multiple data sets.
%   [h, meanD, stdD] = histNorm(dataSets) plots normalized histogram 
%   of each set of data contained in cell dataSets for comparison.  The 
%   xlims are set to 3 times the maximum standard deviation from the mean 
%   of all each set. The default bin sizes are a tenth of the standard 
%   deviation. h is the handle of the bar plot, meanD and stdD are returned
%   mean and std of dataSets.
%   
%   Optional Switches:
%   histNorm(data, 'FracBinSize', val) specifies the fracional size of the
%   max standard deviation of the bin. The default is 10, giving bin sizes
%   of 1/10 of the max std.
%   
%   histNorm(data,'Legend',legendCell) will add a legend to the plot, using
%   the elements in legendCell as labels.
%
%   histNorm(data,'LegendStats',{roundVal,legendCell}) will add a legend
%   with entries from legendCell and add the STD and mean to the plot using
%   the roundVal to specify the decimal points.  roundVal is typically a
%   negative value.
%   
%   Example
%       data = {0+(50*randn(1000,1)),25+30*randn(1000,1), ...
%           -40+70*randn(100000,1)};
%       histNorm(data,'LegendStats',{-2, 'Set1','Set2','Set3'})
%
%   histNorm(data,'LabelMode','Standard') will set the text to bold and
%   size 15.  As of now only 'Standard' mode is set.
%
%   REVISION HISTORY
%   April 2010,     Created,    Travis Kuspche          tkupsche@gmail.com



function [h,dataMean, dataStd] = histNorm(dataSets,varargin)
%% Check for fractional bin size switch. Otherwise set to 10.
binSize     = 10;
offSet      = 0;
for k = 1:2:length(varargin)
    if strcmpi(varargin{k},'FracBinSize')
        binSize     = varargin{k+1};
        varargin(k:k+1) = [];
        offSet = 2;
    end
end

%% Calculate mean and std for entire set.
dataMean        = zeros(1,length(dataSets));
dataStd         = zeros(1,length(dataSets));
dataMin         = zeros(1,length(dataSets));
dataMax         = zeros(1,length(dataSets));

for k = 1:length(dataSets)
    dataMean(k)     = mean(dataSets{k});
    dataStd(k)      = std(dataSets{k});
    dataMax(k)      = max(dataSets{k});
    dataMin(k)      = min(dataSets{k});
end

%% Find max std. Use to set bin sizes and spread size.
binStep         = max(dataStd);
if binStep == 0; binStep = 1; end
minVal          = min(dataMin);
maxVal          = max(dataMax);
binStep         = binStep/binSize;
bins            = [-Inf minVal minVal+binStep:binStep:maxVal Inf];
binSet          = cell(1,length(dataSets));

%% Bin all datasets.
for k = 1:length(dataSets)
    
    dataSet         = dataSets{k};
    
    
    for j = 1:length(bins)-1
        
        binLow      = bins(j);
        
        binHigh     = bins(j+1);
        
        flagCounter     = dataSet>=binLow & dataSet<binHigh;
        if isempty(flagCounter)
            flagCounter = 0;
        end
        binSet{k}(j)    = sum(flagCounter);
    end
    
end


%% Create bar matrix, and plot bin sets.
allBin = zeros(length(binSet{1}),length(dataSets));
for k = 1:length(dataSets)
    curBin = binSet{k};
    allBin(:,k) = curBin';
end

binLocs     = [bins(2:end-1)-binStep/2 bins(end-1)+binStep/2];


h = bar(binLocs,allBin,'histc');
%% Set xlims, xlabels, xticks
minX        = bins(2)-binStep;
maxX        = bins(end-1)+2*binStep;

xlim([minX maxX]);

xTicks      = get(gca,'XTick');
%check to make sure Inf labels aren't too close to next label.
meanDiffXtc = mean(diff(xTicks));
if (xTicks(1)-minX)<meanDiffXtc/4
    xTicks(1) = [];
end
if (maxX - xTicks(end))<meanDiffXtc/4
    xTicks(end) = [];
end

xTicks      = [minX xTicks maxX];
set(gca,'XTick',xTicks)

set(gca,'XTickLabel',[-Inf xTicks(2:end-1) Inf])

%% run through switches.
if (nargin-offSet)>1
    argNum      = length(varargin);
    
    for k = 1:2:argNum
        
        switch varargin{k}
            
            case 'LabelMode'
                switch varargin{k+1}
                    case 'Standard'
                        
                        set(gca,'FontSize',15)
                        set(gca,'FontWeight','bold')
                    otherwise
                        error('Incorrect LabelMode')
                end
            case 'Legend'
                legend(varargin{k+1})
                
            case 'LegendStats'
                legs    = varargin{k+1};
                roundPlace  = legs{1};
                legs = legs(2:end);
                for ki = 1:length(dataSets)
                    if roundPlace<0
                        spcStr      = ['%5.' num2str(abs(roundPlace)) 'f'];
                    else
                        spcStr      = ['%' num2str(roundPlace) '.0f'];
                    end
                    
                    stdStr      = ['STD: ' num2str(dataStd(ki), spcStr)];
                    aveStr      = ['Mean: ' num2str(dataMean(ki), spcStr)];
                    sttStr      = [aveStr '  ' stdStr];
                    
                    legs{ki}    = strvcat(legs{ki},  sttStr); %#ok<VCAT>
                    
                end
                legend(legs);

            otherwise
                warning('histNorm:arg',['Switch ' varargin{k} 'ignored. Possible Misspelling'])
        end
    end
end
%% Set ylims
maxYlim = max( cell2mat(binSet))+.2*std(cell2mat(binSet));
ylim([0 maxYlim])



