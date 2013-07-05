function output = pman( task, arg, options)
%PMAN       Problem Manager for the PDOL Optimization Testbed
%
% output = PMAN( task, arg, options)
%
% PMAN handles finding and retriving test problems from the problem pool.
% User should search for a desired problem using PMAN and call TESTBED with
% the name of problem. The problem pool is a folder with XML files
% (e.g. banana.p.xml), with fields defined as follows:
%   name
%   description - optional
%   n_variables - number of variables (dimensions)
%   n_objectives - number of objectives (assume 1 if left empty)
%   lower_bound
%   upper_bound - bounds of design space
%   min_point - location of point where minimum value is achieved
%   min_value - minimum value of problem
%   category <multiple> - categories the problem is classified into, can be
%     one or more of the following 15:
%     continuous
%     discrete
%     mixed - mixed continuous and discrete
%     linear
%     nonlinear
%     symmetric
%     nonsymmetric
%     singlemodal
%     multimodal
%     constrained
%     unconstrained
%     smallscale
%     largescale
%     go - single objective
%     moo - multi objective
%   constraint <multiple> - the code that performs constraint calculation,
%     input is column vector x, outputs are c (inequality) and ceq
%     (equality)
%   function <multiple> - the code that performs the objective function
%     calculation, input is column vector x, output is column vector f
%
% arguments:
%   task - perform different task based on value:
%     ctg.option_list - list available categories
%     ctg.option_find - search / find problems with specified categories
%     ctg.option_get - retrive selected problem, this task is usually
%       performed by TESTBED function, not the user
%   arg - if task is find, arg should be an arry of desired categories,
%     consisting of one or more of following enumerations, note
%     that the categories listed here is an exact clone of the list above
%     with a "ctg." prefix:
%     ctg.continuous
%     ctg.discrete
%     ctg.mixed
%     ctg.linear
%     ctg.nonlinear
%     ctg.symmetric
%     ctg.nonsymmetric
%     ctg.singlemodal
%     ctg.multimodal
%     ctg.constrained
%     ctg.unconstrained
%     ctg.smallscale
%     ctg.largescale
%     ctg.go
%     ctg.moo
%     if task is get, arg should be a string of name of selected problem,
%     when listing available categories, arg is ignored
%   options:
%     quiet - whether to suppress printouts (value 1) or not (value 0) [0]
%     root_path - the folder that containts the problem pool and template
%       set [this file's folder]
%     problem_path - path of problem pool relative to root_path [problems]
%     template_path - path of template set [templates]
%     obj_fname - name of generated objective function file [objfun.m]
%     con_fname - name of generated constraint function file [confun.m]
%     use_row_point - whether the aut calls the objective function with
%       each point being a row (value 1) or column (value 0) vector [0]
%     suppress_cons - constraint evaluations will be handled based on the
%       value:
%       [ctg.suppress_keep_nothing] - completely ignore
%       ctg.suppress_keep_only_count - keep the number of evaluations and
%         stop the aut from evaluating more than specified points
%       ctg.suppress_keep_all - keep all points and values of evaluations
%         (not fully utilized)
%
% output:
%   if task is list, output is a string of names of enumerations, the
%     string is also printed out
%   if task is find, output is an cell of qualified problem file names,
%     details of the problems are also printed (user don't usually need to
%     use the returned value)
%   if task is get, output is a struct that consists of the problem struct
%     of the selected problem and objfun and confun handles (user don't
%     usually use this task)
%
% examples:
%   Display all available categories
%   >> pman( ctg.option_list);
%   Find problems belong to: go smallscale symmetric multimodal, user can
%   then browse through the returned list and call testbed with one of them
%   >> p = pman( ctg.option_find, [ctg.go ctg.smallscale ctg.symmetric ...
%     ctg.multimodal]);
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
    'root_path', fileparts(mfilename('fullpath')), ...
    'problem_path', 'problems', ...
    'template_path', 'templates', ...
    'obj_fname', 'objfun.m', ...
    'con_fname', 'confun.m', ...
    'use_row_point', 0, ...
    'suppress_cons', [] ... % initialized below
);
defaultopt.suppress_cons = ctg.suppress_keep_nothing;

% if just 'defaults' passed in, return the default options in x
if nargin == 1 && (isequal(task,'defaults') || isequal(task, ctg.option_defaults))
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

% add path of xmltree and CalcMD5
my_path = fileparts(mfilename('fullpath'));
addpath( strcat( my_path, '/xmltree'));
addpath( strcat( my_path, '/CalcMD5'));

% field that every problem must have
must_fields = {
    'n_variables'
    'function'
    'signature'
    };

% field that we fill up if problem doesn't have it
fill_fields = {
    'name'
    'description'
    'n_objectives'
    'lower_bound'
    'upper_bound'
    'min_point'
    'min_value'
    'category'
    'constraint'
    };

% field that must be cells
cell_fields = {
    'category'
    'constraint'
    'function'
    };

% field that we need to evaluated into arrays
eval_fields = {
    'n_variables'
    'n_objectives'
    'lower_bound'
    'upper_bound'
    'min_point'
    'min_value'
    };

if task == ctg.option_list
    [dummy list] = enumeration( 'ctg');
    fprintf( 'All enumerated categories:\n');
    output = sprintf( 'ctg.%s\n', list{1:double(ctg.n_ctg)});
    fprintf( '%s', output);
elseif task == ctg.option_find
%% xml parsing
% assemble the database from xmls
ids = cellstr(ls(strcat(options.root_path,'/',options.problem_path,'/*.p.xml')));
% category matrix
cate = false(length(ids), ctg.n_ctg);

for index = 1:length(ids)
    % get problem and struct into applicable format
    xmlhandle = xmltree(strcat(options.root_path,'/',options.problem_path,'/',ids{index}));
    problem = convert( xmlhandle );

    % fix struct format
    fix_messy_issues;
    problem = struct_operation( problem, ctg.option_must, must_fields);
    problem = struct_operation( problem, ctg.option_fill, fill_fields);
    problem = struct_operation( problem, ctg.option_cell, cell_fields);
    problem = struct_operation( problem, ctg.option_eval, eval_fields);

    % assemble category matrix
    for ii = 1:length(problem.category)
        if ~isempty(problem.category{ii})
            cate(index,ctg.(problem.category{ii})) = true;
        end
    end
    if ~any(cate(index,:))
        warning('PMAN:empty_category', 'test problem %s does not have any category', ids{index});
    end

    % save problem structs to an array
    if index == 1
        % preallocate space for array
        problems(length(ids)) = problem;
    else
        % make the format of problem conform to the previous
        tmparray = [problems(index-1) problem];
        problem = tmparray(2);
    end
    problems(index) = problem;
end

%% filter categories
good = true(size(ids,1),1);
for ii = 1:length(arg)
    good = good & cate(:,arg(ii));
end

% assign output to array of problem objects
output = ids(good);

% print description
if ~options.quiet
    fprintf( 'Matching problems:\n');
    for ii = find(good)'    % ii wouldn't iterate with column vector
        fprintf( '%s\n', ids{ii});
        print_problem( problems(ii));
        fprintf( '\n');
    end
end

%% produce function output
else
    % get matching problem
    problem_fname = ls(strcat(options.root_path,'/',options.problem_path,'/',arg,'.p.xml'));
    if size( problem_fname, 1) < 1
        problem_fname = ls(strcat(options.root_path,'/',options.problem_path,'/',arg,'*'));
        if size( problem_fname, 1) > 1
            error( 'multiple matching problems');
        elseif size( problem_fname, 1) < 1
            error( 'no matching problems');
        end
    end
    xmlhandle = xmltree(strcat(options.root_path,'/',options.problem_path,'/',problem_fname));
    problem = convert( xmlhandle);

    % fix struct format
    fix_messy_issues;
    problem = struct_operation( problem, ctg.option_must, must_fields);
    problem = struct_operation( problem, ctg.option_fill, fill_fields);
    problem = struct_operation( problem, ctg.option_cell, cell_fields);
    problem = struct_operation( problem, ctg.option_eval, eval_fields);

    % printf matching problem
    if ~options.quiet
        print_problem( problem);
    end

    % check signature
    check_signature( strcat(options.root_path,'/',options.problem_path,'/',problem_fname));

    % write objfun.m
    if options.use_row_point
        xmlhandle = xmltree(strcat(options.root_path,'/',options.template_path,'/','objfun_row_point.t.xml'));
    else
        xmlhandle = xmltree(strcat(options.root_path,'/',options.template_path,'/','objfun.t.xml'));
    end
    objfun_template = convert( xmlhandle );
    write_from_template( objfun_template.line, 'content', problem.function, options.obj_fname);

    % write confun.m
    if options.use_row_point
        if options.suppress_cons == ctg.suppress_keep_nothing
            xmlhandle = xmltree(strcat(options.root_path,'/',options.template_path,'/','confun_row_point_no_log.t.xml'));
        else
            xmlhandle = xmltree(strcat(options.root_path,'/',options.template_path,'/','confun_row_point.t.xml'));
        end
    else
        if options.suppress_cons == ctg.suppress_keep_nothing
            xmlhandle = xmltree(strcat(options.root_path,'/',options.template_path,'/','confun_no_log.t.xml'));
        else
            xmlhandle = xmltree(strcat(options.root_path,'/',options.template_path,'/','confun.t.xml'));
        end
    end
    confun_template = convert( xmlhandle );
    if isempty(problem.constraint) || length(problem.constraint) == 1 % TODO: if there are multiple empty constraint fields, we will fail
        problem.constraint = {'c=[]; ceq=[];'};
    end
    write_from_template( confun_template.line, 'content', problem.constraint, options.con_fname);

    % get the newly generated file on the search path
    rehash;

    % assign output, we assume obj and con fname end with .m
    output.objfun_handle = str2func(options.obj_fname(1:end-2));
    output.confun_handle = str2func(options.con_fname(1:end-2));
    output.problem = problem;
end

%% accessories
% simple operations on structs
function s = struct_operation( s, operation, fields)
    for iii = 1:numel(fields)
        switch operation
        case ctg.option_must
            if ~isfield( s, (fields{iii}))
                if isfield( s, 'name')
                    error( 'struct %s does not have field %s', s.name, fields{iii});
                else
                    error( 'struct does not have field %s', fields{iii});
                end
            end
        case ctg.option_fill
            if ~isfield( s, (fields{iii}))
                s.(fields{iii}) = {''};
            end
        case ctg.option_cell
            if ~iscell( s.(fields{iii}))
                s.(fields{iii}) = {s.(fields{iii})};
            end
        case ctg.option_eval
            if iscell( s.(fields{iii}))
                error( 'cannot evaluate multiple lines');
            else
                s.(fields{iii}) = eval(strcat('[',s.(fields{iii}),']'));
            end
        end
    end
end

% fix a few messy non-systematical issues, called before struct_operations
% TODO: we eventually would like to eliminate this function
function fix_messy_issues
    % force some fields to a default value if empty
    if ~isfield( problem, 'min_point')
        problem.min_point = '';
    end
    if ~isfield( problem, 'min_value')
        problem.min_value = '';
    end
    if isequal( problem.n_objectives, '')
        problem.n_objectives = '1';
    end
end

% write to file with templates
function write_from_template( template, token, fill, fname)
    % open output file
    fh = fopen( fname, 'w+');

    % get single strings into cells
    if ~iscell( template)
        template = {template};
    end
    if ~iscell( fill)
        fill = {fill};
    end

    % substitute the line of template with the field content
    for iii = 1:length(template)
        if isfield( template{iii}, token)
            for jjj = 1:length(fill)
                fwrite( fh, [fill{jjj} 10]);
            end
        else
            fwrite( fh, [template{iii} 10]);
        end
    end

    % close file
    fclose( fh);
end

% check signature by checking if the first 4B of MD5 checksum is all zero
function check_signature( fname)
    fid = fopen( fname, 'rb');
    data = fread( fid, 'char=>char');
    fclose(fid);
    % we do not include 1. spaces, 2. tabs, 3. carriage returns in checksum
    data = data(data~=32&data~=13&data~=0);
    % call a third party software to calculate MD5 checksum
    c = CalcMD5( data, 'char', 'Dec');
    if c(1) ~= 0
        error( 'problem does not have a valid signature');
    end
end

% print a problem
function print_problem( problem)
    fprintf( '----------------\n');
    fprintf( '%s: %s\n', problem.name, problem.description);
    fprintf( 'sig: %s\n', problem.signature);
    fprintf( 'nvar: %d, nobj: %d\n', problem.n_variables, problem.n_objectives);
    fprintf( 'lb:');
    fprintf( ' %g', problem.lower_bound);
    fprintf( '\nub:');
    fprintf( ' %g', problem.upper_bound);
    fprintf( '\nx*:');
    fprintf( ' %g', problem.min_point);
    fprintf( '\nf*:');
    fprintf( ' %g', problem.min_value);
    fprintf( '\ncategories:\n');
    fprintf( '\t%s\n', problem.category{:});
    fprintf( 'function:\n');
    fprintf( '\t%s\n', problem.function{:});
    fprintf( 'constraint:\n');
    fprintf( '\t%s\n', problem.constraint{:});
    fprintf( '----------------\n');
end

end