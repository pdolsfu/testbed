function output = pproc( log_fname, opt)
%PPROC Post Pocessing Script for the PDOL Optimization Testbed System
%
% output = PPROC( log_fname, opt)
%
% PPROC handles the post-processing of the testbed results, please read
% through the code for details
%
% arguments:
%   log_fname - the log file TESTBED produced
%   opt:
%     quiet - whether to suppress printouts (value 1) or not (value 0) [0]
%     plot_hist - whether to plot histogram [1]
%     plot_conv - whether to plot convergence plots [1]
%     plot_stat - whether to print statistics table [1]
%
%   plots:
%    convergence:
%     box plot - for selected numbers of evaluations, box plot will show
%       how the "lowest value so far" (convergence value) is distributed
%       over all the runs
%     percentile plot - shows the 100th (max), 75th (Q3), 50th (median), 
%       25th (Q1), and 0th (min) values over all the runs
%
% output:
%   not utilized
%
% examples:
%   please see usage in TESTBED
%
% the suite of files includes
%   TESTBED        - main function and interface
%   TESTBED_SINGLE - benchmark a single algorithm
%   PMAN           - problem manager for problem browsing and selection
%   DMAN           - data manager for keep record during benchmarking
%   PPROC          - post processing
%   CTG            - enumeration class that helps define constants
%   CALLTEST       - an demostration script that shows multiple examples
%   problems       - an folder of xml files define the problem pool
%   templates      - an folder of xml templates for internal use
%   misc           - miscellaneous scripts used during development
%
% feedback is welcome via gary_wang@sfu.ca
%
% see also TESTBED, TESTBED_SINGLE, PMAN, DMAN, PPROC, CTG
%
% license for this software can be found in LICENSE in the same folder
%
% Copyright (c) 2013
% Product Design and Optimization Laboratory (PDOL) Simon Fraser University
% All rights reserved
%

%% argument parsing
% default options
defaultopt = struct( ...
    'quiet', 0, ...
    'plot_show', 1, ... % not utilized yet
    'plot_save', 1, ... % only saving stats table for now
    'plot_format', 'jpg', ...   % not utilized yet
    'plot_hist', 1, ...
    'plot_conv', 1, ...
    'plot_stat', 1, ...
    'plot_tsv_fname_prefix', 'tabular_results_' ...
);

% if just 'defaults' passed in, return the default options in x
if nargin == 1 && (isequal(log_fname,'defaults') || isequal(log_fname,ctg.option_defaults))
    output = defaultopt;
    return;
end

% assign default options to opt, we use name opt to avoid clashing with
% testbed variable name
if nargin < 2
    opt = defaultopt;
end
fields = fieldnames(defaultopt);
for ii = 1:numel(fields)
    if ~isfield( opt, (fields{ii}))
        opt.(fields{ii}) = defaultopt.(fields{ii});
    end
end

% addpath for accessory
my_path = fileparts(mfilename('fullpath'));
addpath( strcat( my_path, '/histNorm'));
addpath( strcat( my_path, '/displaytable'));
addpath( strcat( my_path, '/xticklabel_rotate'));
addpath( strcat( my_path, '/boxplotCsub'));

%% call appropriate plotting functions
% make sure log_fname is an cell
if ~iscell( log_fname)
    log_fname = {log_fname};
end
for ii = length(log_fname):-1:1
    log_struct(ii) = load( log_fname{ii}, ...
        'recorder_array', 'aut_handle', 'options', 'pstruct');
end

% print banner
fprintf( '----------------\n');
fprintf( 'post processing\n');
fprintf( '----------------\n');

if opt.plot_stat
    gm_multi_stat_n_eval( log_struct);
end

if opt.plot_hist
    gm_multi_hist_n_eval( log_struct);
end

% if single objective
if log_struct(1).pstruct.problem.n_objectives == 1
    if opt.plot_stat
        go_multi_stat_obj_val( log_struct);
    end

    if opt.plot_hist
        go_multi_hist_obj_val( log_struct);
    end

    if opt.plot_conv
        go_multi_conv( log_struct);
    end
% multi objective
else
    % nothing yet
end

%% plotting helper functions
function gm_multi_stat_n_eval( log_struct)
    fprintf( 'number of function evaluations\n');
    s = multi_stat( log_struct, @get_n_eval);
    displaytable( ...
        num2cell([s.min s.max s.mean s.std s.n_runs]), ...
        {'min','max','mean','std','n_runs'}, ...
        10 , {'g', 'g', 'g', 'g', 'g'}, s.aut_label, 1);
    fprintf( '----------------\n');
    if opt.plot_save
        dlmwrite(strcat(opt.plot_tsv_fname_prefix,'n_eval','.tsv'), ...
            [s.min s.max s.mean s.std s.n_runs]);
    end
end

function gm_multi_hist_n_eval( log_struct)
    s = multi_stat( log_struct, @get_n_eval);
    figure;
    histNorm(s.data,'LegendStats',[-1; s.aut_label]);
    title('histogram: number of evals for all runs');
    xlabel('number of evals');
end

function go_multi_stat_obj_val( log_struct)
    fmt = '.4g';
    fprintf( 'minimum objective values\n');
    s = multi_stat( log_struct, @get_obj_val);
    displaytable( ...
        num2cell([s.min s.max s.mean s.std s.n_runs]), ...
        {'min','max','mean','std','n_runs'}, ...
        10 , {fmt, fmt, fmt, fmt, 'g'}, s.aut_label, 1);
    fprintf( '----------------\n');
    if opt.plot_save
        dlmwrite(strcat(opt.plot_tsv_fname_prefix,'obj_val','.tsv'), ...
            [s.min s.max s.mean s.std s.n_runs]);
    end
end

function go_multi_hist_obj_val( log_struct)
    s = multi_stat( log_struct, @get_obj_val);
    figure;
    histNorm(s.data,'LegendStats',[-3; s.aut_label]);
    title('histogram: min objective value for all runs');
    xlabel('min objective value - f*');
end

function go_multi_conv( log_struct)
    s = multi_stat( log_struct, @get_conv);
    % colors = hsv(6);
    colors = [0 0 1; 1 0 0; 1 0 0; 1 0 1; 0 1 1; 1 1 0];

    % assemble convergence value arrays for each aut
    conv_data = cell(length(s.aux),1);
    for aut_index = 1:length(s.aux)
        max_run_n_eval = max(cellfun(@length,s.aux{aut_index}));
        % fill short run with min of the run
        conv_data{aut_index} = repmat( ...
            cellfun(@(x)x(end),s.aux{aut_index})', ...
            [max_run_n_eval 1]);
        % copy struct into a matrix
        for run_index = 1:length(s.aux{aut_index})
            conv_data{aut_index}( ...
                1:length(s.aux{aut_index}{run_index} ...
                ),run_index) = s.aux{aut_index}{run_index};
        end
    end

    % box plot
    n_boxes = 30;
    max_aut_n_eval = max(cellfun(@(x)size(x,1),conv_data));
    all_box_index = ceil(linspace(0,max_aut_n_eval,n_boxes+1));
    all_box_index = all_box_index(2:end);
    box_labels = textscan(num2str(all_box_index),'%s');
    box_handle = cell(length(conv_data),1);
    figure;
    for aut_index = 1:length(conv_data)
        my_box_index = ...
            all_box_index(all_box_index<=size(conv_data{aut_index},1));
        box_handle{aut_index} = boxplotCsub( ...
            conv_data{aut_index}(my_box_index,:)', ...
            1,'x',1,1.5, ... % group, notch, outlier mark, vertical,whisker
            colors(mod(aut_index-1,size(colors,1))+1,:), ... % color
            false,1,false, ... % fill, line width, outline
            [aut_index, length(conv_data)], ... % [current total]
            0.7,0.05,false ... % box width, reduce overlap, show mean
            );
    end
    xticklabel_rotate(1:n_boxes,90,box_labels{1},'interpreter','none');
    legend(cellfun(@(x)x(5,1),box_handle),s.aut_label);
    set(gca,'YScale','log');
    ylim('auto');
    xlabel('number of evals performed');
    ylabel('min objective value - f*');
    title('box plot: distribution of convergence');

    % percentile plot
    median_handle = cell(length(conv_data),1);
    figure;
    hold on;
    for aut_index = 1:length(conv_data)
        my_color = colors(mod(aut_index-1,size(colors,1))+1,:);
        median_handle{aut_index} = ...
        plot(prctile(conv_data{aut_index}',50)', ...
            'Linestyle', '-', 'Color', my_color);
% it's kind of messy to print all the percentiles
%         plot(prctile(conv_data{aut_index}',[25 75])', ...
%             'Linestyle', '--', 'Color', my_color);
%         plot(prctile(conv_data{aut_index}',[0 100])', ...
%             'Linestyle', ':', 'Color', my_color);
    end
    set(gca,'YScale','log');
    ylim('auto');
    legend(cellfun(@(x)x(1),median_handle),s.aut_label);
    xlabel( 'number of evals performed');
    ylabel( 'min objective value - f*');
    title('simple plot: median of convergence');
end

function [data aux] = get_n_eval( recorder, log_struct, aut_index, run_index)
    data = recorder{ctg.id_obj_x,2}.cnt;
    aux = [];
end

% objective value is taken as the differential to f*
function [data aux] = get_obj_val( recorder, log_struct, aut_index, run_index)
    data = min( recorder{ctg.id_obj_f,1}) - ...
        log_struct(aut_index).pstruct.problem.min_value;
    aux = [];
end

% get convergence value differential to f*
function [data aux] = get_conv( recorder, log_struct, aut_index, run_index)
    aux = zeros(recorder{ctg.id_obj_x,2}.cnt,1);
    aux(1) = recorder{ctg.id_obj_f,1}(1) - ...
        log_struct(aut_index).pstruct.problem.min_value;
    for iii = 2:recorder{ctg.id_obj_x,2}.cnt
        aux(iii) = min(aux(iii-1), ...
            recorder{ctg.id_obj_f}(iii) - ...
            log_struct(aut_index).pstruct.problem.min_value);
    end
    data = 0;
end

function output = multi_stat( log_struct, feed_handle)
    n_aut = length(log_struct);
    s.min = zeros(n_aut,1);
    s.max = s.min;
    s.mean = s.min;
    s.std = s.min;
    s.n_runs = s.min;
    s.data = cell(n_aut,1);
    s.aux = s.data;
    s.aut_label = s.data;

    for aut_index = 1:n_aut
        n_runs = log_struct(aut_index).options.n_runs;
        data = zeros(n_runs,1);
        aux = cell(n_runs,1);
        for run_index = 1:n_runs
            [data(run_index) aux{run_index}] = feed_handle( ...
                log_struct(aut_index).recorder_array(run_index).recorder, ...
                log_struct, aut_index, run_index);
        end
        s.min(aut_index) = min(data);
        s.max(aut_index) = max(data);
        s.mean(aut_index) = mean(data);
        s.std(aut_index) = std(data);
        s.n_runs(aut_index) = n_runs;
        s.data{aut_index} = data;
        s.aux{aut_index} = aux;
        s.aut_label{aut_index} = [func2str(log_struct(aut_index).aut_handle) ...
            ' (' num2str(n_runs) ' runs on ' ...
            log_struct(aut_index).pstruct.problem.name ')'];
    end

    output = s;
end

end
