function testbed( aut_handle_list, problem_fname, options_list)
%TESTBED    PDOL Optimization Testbed Algorithm Benchmarking System
%
% output = TESTBED( {aut_handle_1, ...}, problem_fname, {options_1, ...})
%                   '--------v--------'                 '-------v------'
%                     aut_handle_list                     options_list
%
% TESTBED tries to benchmark and compare performances of optimization
% algorithms of the following form:
%   [min_x, min_f] = algorithm( objective, constraint, bound, ..., options)
% where:
%   objective - objective function f = objective( x) with a desired minima
%   constraint - constraint function [c ceq] = constraint( x)
%   bound - design space specified either as vectors of upper and lower
%     bound or a matrix that contains the two bounds
%   other arguments - number of variables, number of objectives
%   options - options that are private to the algorithm
% and the algorithm must comply to the following restrictions:
%   the algorithm must be packaged in a function that can be called with
%     the above parameters, as oppose to a script where the script itself
%     has to be modified in any way
%   the algorithm must NOT issue "clear all" command at any time, because
%     the data collected by the testbed is stored in persistent memory
% the performance of the algorithm will be judged based on the number of
% function evaluations and minimum value achieved
%
% arguments:
%   aut_handle_list - cell array of handles of the (a)lgorithms function
%     (u)nder (t)est
%   problem_fname - the name of the test problem in a string see also PMAN
%   options_list - cell array of options for each aut, for each options:
%    interfacing options:
%     arg_list - the way the aut should be called ordered in an cell array
%       with a combination of following elements:
%       ctg.arg_n_variables - number of variables
%       ctg.arg_n_objectives - number of objectives
%       ctg.arg_upper_bound
%       ctg.arg_lower_bound
%       ctg.arg_bound_matrix
%       ctg.arg_objfun_handle - handle of the objective function
%       ctg.arg_confun_handle - handle of the constraint function
%       structures - any of above element appearing a structure passed in
%         as part of the arg_list will also be treated the same
%       other - anything that doesn't match the above elements will be kept
%         unchanged when calling the aut
%     use_row_point - whether the aut calls the objective function with
%       each point being a row (value 1) or column (value 0) vector [0]
%     use_row_bound - whether the aut accepts bounds as row (value 1) or
%       column (value 0) vectors or matrices [0]
%     quiet - whether to suppress printouts (value 1) or not (value 0) [0]
%     save_path - the path results should be saved [testbed_output]
%     name_prefix - custom string as prefix of output folder names [empty]
%     date_format - the way date should be appear in output folder names
%       [_mmdd_hhMMss] see also DATE
%     obj_fname - the name of the objective function [objfun.m]
%     con_fname - the name of the constraint function [confun.m]
%    control options:
%     n_runs - how many times to run the aut [1]
%     max_n_samples - maximum number of points the aut is allowed to
%       evaluate the objective function [1000]
%     min_obj_value - the desired value of objective function to stop aut
%       from looking any further [-Inf]
%     max_n_cons - maximum number of points the aut is allowd to evaluate
%       the constraint function [1000]
%     suppress_cons - constraint evaluations will be handled based on the
%       value:
%       [ctg.suppress_keep_nothing] - completely ignore
%       ctg.suppress_keep_only_count - keep the number of evaluations and
%         stop the aut from evaluating more than specified points
%       ctg.suppress_keep_all - keep all points and values of evaluations
%         (not fully utilized)
%     no_pproc - do not call post processing [1]
%
% output:
%   not utilized
%
% examples:
%   % Set options for GA
%   ga_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound}
%   ga_opt.use_row_point = 1
%   ga_opt.n_runs = 30
%   ga_opt.max_n_samples = 100
%
%   % Set options for SA
%   sa_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_lower_bound, ctg.arg_lower_bound, ctg.arg_upper_bound}
%   sa_opt.use_row_point = 0
%   sa_opt.n_runs = 30
%   sa_opt.max_n_samples = 100
%
%   % Call testbed
%   testbed( {@ga @simulannealbnd}, 'hump', {ga_opt sa_opt})
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

%% add my path
addpath( fileparts(mfilename('fullpath')));

%% make sure input lists are cells
if ~iscell(aut_handle_list)
    aut_handle_list = {aut_handle_list};
end
if ~iscell(options_list)
    options_list = {options_list};
end

%% cd to output folder
% TODO: this section partially duplicates testbed_single, getting a perfect
% folder name is a hairball

% save current path
orig_path = pwd();

% output folder name creation
output_folder = '';

% get defaults from single
defopt = testbed_single( ctg.option_defaults);

% get save path
if isfield( options_list{1}, 'save_path');
    output_folder = strcat( output_folder, options_list{1}.save_path);
else
    output_folder = strcat( output_folder, defopt.save_path);
end
output_folder = strcat( output_folder, '/');

% get prefix and clear save path
for ii = 1:length(aut_handle_list)
    if isfield( options_list{ii}, 'name_prefix')
        output_folder = strcat( output_folder, options_list{ii}.name_prefix);
    else
        output_folder = strcat( output_folder, func2str( aut_handle_list{ii}),'_');
    end
    if ii ~= length(aut_handle_list)
        output_folder = strcat( output_folder, 'vs_');
    end
    options_list{ii}.save_path = '.';
end

% get current time and produce output path
if isfield( options_list{1}, 'date_format')
    output_folder = strcat( output_folder, problem_fname, datestr( now, options_list{1}.date_format));
else
    output_folder = strcat( output_folder, problem_fname, datestr( now, defopt.date_format));
end

% check for existing folder to avoid data overwrite
while exist(output_folder,'dir')
    output_folder = strcat( output_folder, '.another');
end

mkdir( output_folder);
cd( output_folder);

%% run each AUT
for ii = length(aut_handle_list):-1:1
    % make sure all termination criteria are same
    if isfield(options_list{1},'max_n_samples')
        options_list{ii}.max_n_samples = options_list{1}.max_n_samples;
    end
    if isfield(options_list{1},'min_obj_value')
        options_list{ii}.min_obj_value = options_list{1}.min_obj_value;
    end

    output_folders{ii} = testbed_single( aut_handle_list{ii}, problem_fname, options_list{ii});
end

%% post processing
pproc( strcat(output_folders, '/log.mat'), options_list{1});

cd( orig_path);
