function output = testbed_single(aut_handle, problem_fname, options)
%TESTBED_SINGLE PDOL Optimization Testbed Algorithm Benchmarking System
%
% output = TESTBED_SINGLE( aut_handle, problem_fname, options)
%
% TESTBED_SINGLE tries to benchmark a single optimization algorithm of the
% following form:
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
%   aut_handle - handle of the (a)lgorithm function (u)nder (t)est
%   problem_fname - the name of the test problem in a string see also PMAN
%   options:
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
%   path to the output folder
%
% examples:
%   Please check CALLTEST for a more detailed demo
%   Benchmark Matlab GA with problem Beale with limit on number of function
%   evaluations
%   First set argument format
%   >> options.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, ...
%     [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound};
%   Then tell testbed that GA assume row points
%   >> options.use_row_point = 1;
%   Then set number of runs
%   >> options.n_runs = 30;
%   Then set maximum number of function evaluations
%   >> options.max_n_samples = 500;
%   Then call testbed with modified options, a few plots will show with
%   results printed out as well
%   >> testbed( @ga, 'beale', options);
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
    'arg_list', [], ... % initialized below
    'use_row_point', 0, ...
    'use_row_bound', 0, ...
    'quiet', 0, ...
    'n_runs', 1, ...
    'max_n_samples', 1000, ...
    'min_obj_value', -Inf, ...
    'max_n_cons', 1000, ...
    'suppress_cons', [], ... % initialized below
    'no_pproc', 1, ...
    'save_path', 'testbed_output', ...
    'name_prefix', '', ...
    'date_format', '_mmdd_hhMMss', ...
    'obj_fname', 'objfun.m', ...
    'con_fname', 'confun.m' ...
);
defaultopt.arg_list = {ctg.arg_n_variables, ctg.arg_lower_bound, ctg.arg_upper_bound};
defaultopt.suppress_cons = ctg.suppress_keep_nothing;

% if just 'defaults' passed in, return the default options in x
if nargin == 1 && (isequal(aut_handle,'defaults') || isequal(aut_handle,ctg.option_defaults))
    output = defaultopt;
    return;
end

% assign default options to options
if nargin < 3
    options = defaultopt;
end
fields = fieldnames(defaultopt);
for ii = 1:numel(fields)
    if ~isfield( options, (fields{ii}))
        options.(fields{ii}) = defaultopt.(fields{ii});
    end
end

% if no prefix specified use function name
if isempty( options.name_prefix)
    options.name_prefix = strcat(func2str( aut_handle),'_');
end

%% add path
my_path = fileparts(mfilename('fullpath'));
addpath( my_path);
% add the immediate parent dir so aut can see objfun
addpath( '..');

%% cd to output folder
% save current path
orig_path = pwd();

% get current time and produce output path
time = now;
output_folder = strcat( options.save_path, '/', options.name_prefix, ...
    problem_fname, datestr( time, options.date_format));

% check for existing folder to avoid data overwrite
while exist(output_folder,'dir')
    output_folder = strcat( output_folder, '.another');
end

mkdir( output_folder);
cd( output_folder);

%% retrive problem
if ~options.quiet
    fprintf('problem selected: %s\n', problem_fname);
end
pstruct = pman( ctg.option_get, problem_fname, options);

%% parse arg_list
function out = get_real_arg( in)
    if     isequal( in, ctg.arg_n_variables);
        out = pstruct.problem.n_variables;
    elseif isequal( in, ctg.arg_n_objectives);
        out = pstruct.problem.n_objectives;
    elseif isequal( in, ctg.arg_lower_bound);
        out = pstruct.problem.lower_bound(:);
        if options.use_row_bound
            out = out';
        end
    elseif isequal( in, ctg.arg_upper_bound);
        out = pstruct.problem.upper_bound(:);
        if options.use_row_bound
            out = out';
        end
    elseif isequal( in, ctg.arg_bound_matrix);
        out = [pstruct.problem.lower_bound(:) pstruct.problem.upper_bound(:)];
        if options.use_row_bound
            out = out';
        end
    elseif isequal( in, ctg.arg_objfun_handle);
        out = pstruct.objfun_handle;
    elseif isequal( in, ctg.arg_confun_handle);
        out = pstruct.confun_handle;
    elseif isstruct( in)
        out = in;
        field_list = fieldnames(out);
        for iii = 1:numel(field_list)
            out.(field_list{iii}) = get_real_arg( out.(field_list{iii}));
        end
    else
        % keep the item is options if not matching enum
        out = in;
    end
end
for ii = length(options.arg_list):-1:1
    arg_list{ii} = get_real_arg(options.arg_list{ii});
end

% a list of constraint record entries that is 1 dimentional and long
con_long_id_list = [ctg.id_con_c ctg.id_con_ceq ctg.id_con_t];

%% call aut
for run_cnt = options.n_runs:-1:1
    % make subfolder and cd to it
    run_folder = sprintf( 'run%d', run_cnt);
    mkdir( run_folder);
    cd( run_folder);

    % activate dman and clear existing record
    dman( ctg.option_activate);
    dman( ctg.option_clear, 0);
    options.error_on_overflow = 0;
    options.bound = [-Inf Inf];
    options.error_on_bound = 0;

    % create obj sample record
    options.size = [pstruct.problem.n_variables, options.max_n_samples];
    dman( ctg.option_create, ctg.id_obj_x, [], options);

    % create obj t record
    options.size = [1, options.max_n_samples];
    dman( ctg.option_create, ctg.id_obj_t, [], options);

    % create con and obj tic record and log tic
    options.size = [1 2];
    for ii = [ctg.id_obj_tic ctg.id_con_tic]
        dman( ctg.option_create, ii, [], options);
        dman( ctg.option_log, ii, tic);
    end

    % suppress cons record if instructed so
    if options.suppress_cons
        options.suppress = options.suppress_cons;
    end

    % create other cons records
    options.size = [1, options.max_n_cons];
    for ii = con_long_id_list
        dman( ctg.option_create, ii, [], options);
    end

    % create cons sample record, this record handles overflow
    options.error_on_overflow = 1;
    options.size = [pstruct.problem.n_variables, options.max_n_cons];
    dman( ctg.option_create, ctg.id_con_x, [], options);

    options.suppress = ctg.suppress_keep_all;

    % create objective function value record, this record handles both errs
    options.size = [ pstruct.problem.n_objectives, options.max_n_samples];
    options.error_on_overflow = 1;
    options.bound = [options.min_obj_value Inf];
    options.error_on_bound = 1;
    dman( ctg.option_create, ctg.id_obj_f, [], options);

    % call aut
    % TODO: we assume aut function doesn't return anything useful (e.g. MPS)
    try
        aut_handle(arg_list{:});
    catch err
        if (strcmp(err.identifier,'DMAN:overflow'))
            if ~options.quiet
                fprintf( 'run %d: aut trying to evaluate more than %d sample points or %d constraint points\n', run_cnt, options.max_n_samples, options.max_n_cons);
            end
        elseif (strcmp(err.identifier,'DMAN:bound'))
            if ~options.quiet
                fprintf( 'run %d: aut reached objective function value %g\n', run_cnt, options.min_obj_value);
            end
        else
            cd( orig_path);
            rethrow(err);
        end
    end

    % save objfun log and confun log
    recorder_array(run_cnt).recorder = dman( ctg.option_harvest, 0, []);

    % write objective evaluation into a tsv file as well
    dlmwrite('eval_log.tsv', [ ...
        recorder_array(run_cnt).recorder{ctg.id_obj_x,1}' ...
        recorder_array(run_cnt).recorder{ctg.id_obj_f,1}' ], '\t');

    % cd back to ouput folder
    cd( '..');
end

%% post processing
% save logs, we are now in output folder
log_fname = 'log.mat';
save( log_fname, 'pstruct', 'recorder_array', 'options', ...
    'output_folder', 'time', 'problem_fname', 'aut_handle', 'arg_list');

% do prostprocess on the .mat file
if ~options.no_pproc
    pproc( log_fname, options);
end

% change back to original path
cd( orig_path);

% return output folder
output = output_folder;

end
