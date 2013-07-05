function output = dman( task, id, data, options)
%DMAN       Dataset Manager for the PDOL Optimization Testbed System
%
% output = DMAN( task, id, data, options)
%
% DMAN records data in persistent memory, make them available for harvest,
% and generates error on a overflow or out of bound event
%
% arguments:
%   task - perform different task based on value:
%     ctg.option_create - create record according to specified options
%     ctg.option_clear - clear record
%     ctg.option_log - log data points into a specific record
%     ctg.option_harvest - retrive specific record or all records
%     ctg.option_activate - turn on DMAN for normal function
%     ctg.option_deactivate - turn off DMAN into non-responsive mode
%   id:
%     for tasks of activate and deactivate, id is ignored
%     for tasks of create, clear, log and harvest, id can be a positive
%     integer that represent a specific channel
%     for tasks of clear and harvest, id can also be 0, which results in
%     clearing or harvesting all channels
%   data:
%     for task of log, data should be a column vector or a matrix with 
%     columns data points to be recorded
%     for other tasks, data is ignored
%   options:
%     quiet - whether to suppress printouts (value 1) or not (value 0) [0]
%     error_on_overflow - if nonzero, produce an error when any record
%       channel overflows [0]
%     error_on_bound - if nonzero, produce an error when any record
%       point violates the predefined bounds [0]
%     size - size of record matrix of the channel [1 1]
%     bound - lower and upper limints of the channel [-Inf Inf]
%     suppress - logging is affected based value:
%       [ctg.suppress_keep_all] - keep record data
%       ctg.suppress_keep_only_count - keep record count without data
%       ctg.suppress_keep_nothing - don't log anything
%
% output:
%   if task is create, clear, activate or deactivate, output is 0
%   if task is log, output is the data point count
%   if task is harvest and a valid channel id is given, output is the data
%   matrix of that channel, if task is harvest and 0 is given, output is
%   the whole recorder struct
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

% persistent variable declaration
persistent activated;
persistent recorder;

% activation control, default deactivated, activate it only when testbed
% has set up the recorder channels
if task == ctg.option_activate
    activated = 1;
    output = 0;
    return;
elseif task == ctg.option_deactivate
    activated = 0;
    output = 0;
    return;
elseif ~isequal(activated, 1)
    output = 0;
    return;
% if we are in second order suppression, skip logging
elseif task == ctg.option_log && isvalid(id) && recorder{id,2}.suppress == ctg.suppress_keep_nothing
    output = 0;
    return;
end

% create primary structure
if isempty(recorder)
    recorder = {};
end

%% argument parsing
% default options
defaultopt = struct( ...
    'quiet', 0, ... % TODO: could be used to suppress warnings
    'error_on_overflow', 0, ...
    'error_on_bound', 0, ...
    'size', [1 1], ...
    'bound', [-Inf Inf], ...
    'suppress', 0 ...
);

% if just 'defaults' passed in, return the default options in x
if nargin == 1 && (isequal(task,'defaults') || isequal(task, ctg.option_defaults))
    output = defaultopt;
    return;
end

% assign default options to options
if nargin < 4
    options = defaultopt;
end
fields = fieldnames(defaultopt);
for ii = 1:numel(fields)
    if ~isfield( options, (fields{ii}))
        options.(fields{ii}) = defaultopt.(fields{ii});
    end
end

switch task
% create recorder entry
case ctg.option_create
    if isvalid(id)
        error( 'entry %d has been registered', double(id));
    elseif id == 0
        error( 'entry number starts at 1');
    end
    recorder{id,2}.size = options.size;
    recorder{id,2}.suppress = options.suppress;
    if recorder{id,2}.suppress
        recorder{id,1} = zeros(recorder{id,2}.size(1), 0);
    else
        recorder{id,1} = zeros(recorder{id,2}.size);
    end
    recorder{id,2}.cnt = 0;
    recorder{id,2}.flip = 0;
    recorder{id,2}.bound = options.bound;
    recorder{id,2}.error_on_overflow = options.error_on_overflow;
    recorder{id,2}.error_on_bound = options.error_on_bound;
    output = 0;
case ctg.option_clear
    % here we only clear record array and config associated
    if isvalid(id)
        recorder{id,1} = [];
        recorder{id,2} = [];
    % if id is 0, we clear all records
    elseif id == 0
        recorder = {};
    end
    output = 0;
case ctg.option_log
    if ~isvalid(id)
        error('invalid record id');
    % we ignore logging attempts of empty data
    elseif isempty(data)
        output = recorder{id,2}.cnt;
        return;
    % if the 2nd dimension matches the record dimension, we assume it
    % is still viable data
    % TODO: it will get confusing when the two dimension are the same
    elseif size(data,1) ~= size(recorder{id},1) || recorder{id,2}.flip == 1
        if size(data,2) == size(recorder{id},1)
            data = data';
            recorder{id,2}.flip = 1;
        else
            error('input data size mismatch');
        end
    end

    % check overflow and truncate input data
    if size(data,2) + recorder{id,2}.cnt > recorder{id,2}.size(2)
        if ~options.quiet
            warning('DMAN:overflow', 'record overflow on entry %d, excess data truncated', double(id));
        end
        data = data(:, 1:recorder{id,2}.size(2)-recorder{id,2}.cnt);
    end

    if ~recorder{id,2}.suppress
        recorder{id,1}(:,recorder{id,2}.cnt+1:recorder{id,2}.cnt+size(data,2)) = data;
    end
    recorder{id,2}.cnt = recorder{id,2}.cnt+size(data,2);
    output = recorder{id,2}.cnt;

    % give an error if record overflows (full is considered overflow here)
    if recorder{id,2}.cnt == recorder{id,2}.size(2) && recorder{id,2}.error_on_overflow
        error('DMAN:overflow', 'record overflow on entry %d', double(id));
    end

    % give an error if record exceeds bound, we only check new data here
    if any( data(:) < recorder{id,2}.bound(1)) || any( data(:) > recorder{id,2}.bound(2))
        if recorder{id,2}.error_on_bound
            error('DMAN:bound', 'record out of bound on entry %d', double(id));
        elseif ~options.quiet
            warning('DMAN:bound', 'record out of bound on entry %d', double(id));
        end
    end
case ctg.option_harvest
    if isvalid(id)
        % return count if suppressed, the data array otherwise
        if recorder{id,2}.suppress
            output = recorder{id,2}.cnt;
        else
            output = recorder{id,1}(:,1:min(recorder{id,2}.cnt,size(recorder{id,1},2)));
        end
    elseif id == 0
        output = recorder;
        % shrink all records to exclude empty array
        for ii = 1:size(recorder,1)
            if isvalid( ii)
                output{ii,1} = output{ii,1}(:,1:min(output{ii,2}.cnt,size(output{ii,1},2)));
            end
        end
    else
        error('invalid record id');
    end
otherwise
    error('unrecognized command');
end

function valid = isvalid( id)
    valid = id ~= 0 && size(recorder,1) >= id && ~isempty(recorder{id,2});
end

end