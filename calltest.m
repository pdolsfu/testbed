%CALLTEST   Category Enumerator for the PDOL Optimization Testbed System
%
% Demonstration of the usage of testbed system
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

clear;
disp( '***************************************')
disp( '*  ____    ____    _____   __         *')
disp( '* /\  _`\ /\  _`\ /\  __`\/\ \        *')
disp( '* \ \ \L\ \ \ \/\ \ \ \/\ \ \ \       *')
disp( '*  \ \ ,__/\ \ \ \ \ \ \ \ \ \ \  __  *')
disp( '*   \ \ \/  \ \ \_\ \ \ \_\ \ \ \L\ \ *')
disp( '*    \ \_\   \ \____/\ \_____\ \____/ *')
disp( '*     \/_/    \/___/  \/_____/\/___/  *')
disp( '*                                     *')
disp( '* DEMO FOR TESTBED SYSTEM: MODULE _1_ *')
disp( '*    Search for a suitable problem    *')
disp( '*                                     *')
disp( '***************************************')
disp( 'Press enter to continue');
disp( ' ');

disp( '1.1 Display all available categories');
disp( '>> pman( ctg.option_list)');
pause;
pman( ctg.option_list);
disp( ' ');
disp( '**************** NEXT *****************');
pause;

disp( '1.2 Find problems belonging to categories: go smallscale symmetric multimodal');
disp( '>> p = pman( ctg.option_find, [ctg.go ctg.smallscale ctg.symmetric ctg.multimodal])');
pause;
p = pman( ctg.option_find, [ctg.go ctg.smallscale ctg.symmetric ctg.multimodal])
disp( ' ');
disp( '**************** NEXT *****************');
pause;

clear;
disp( '***************************************')
disp( '*  ____    ____    _____   __         *')
disp( '* /\  _`\ /\  _`\ /\  __`\/\ \        *')
disp( '* \ \ \L\ \ \ \/\ \ \ \/\ \ \ \       *')
disp( '*  \ \ ,__/\ \ \ \ \ \ \ \ \ \ \  __  *')
disp( '*   \ \ \/  \ \ \_\ \ \ \_\ \ \ \L\ \ *')
disp( '*    \ \_\   \ \____/\ \_____\ \____/ *')
disp( '*     \/_/    \/___/  \/_____/\/___/  *')
disp( '*                                     *')
disp( '* DEMO FOR TESTBED SYSTEM: MODULE _2_ *')
disp( '*  Opportunity controlled comparison  *')
disp( '*                                     *')
disp( '* Limit number of function evaluations*')
disp( '* and compare the optimal result from *')
disp( '* two algorithms:                     *')
disp( '* 1. ga - Genetic Algorithm by Matlab *')
disp( '* 2. simulannealbnd -                 *')
disp( '*      Simmulated Annealing by Matlab *')
disp( '* (it is assumed you have GO toolbox) *')
disp( '* with problems:                      *')
disp( '* 1. hump - (hump.p.xml)              *')
disp( '*                                     *')
disp( '***************************************')
disp( 'Press enter to continue');
disp( ' ');

disp( '2.1 Set argument format for GA');
disp( '>> ga_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound})')
pause;
ga_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound}
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.2 Set that GA assume row points');
disp( '>> ga_opt.use_row_point = 1');
pause;
ga_opt.use_row_point = 1
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.3 Set number of runs to 30');
disp( '>> ga_opt.n_runs = 30');
pause;
ga_opt.n_runs = 30
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.4 Set maximum number of function evaluations to 100');
disp( '>> ga_opt.max_n_samples = 100');
pause;
ga_opt.max_n_samples = 100
disp( ' ');
disp( '**************** NEXT *****************');
pause;

disp( '2.6 Set argument format for SA');
disp( '>> sa_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_lower_bound, ctg.arg_lower_bound, ctg.arg_upper_bound})')
pause;
sa_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_lower_bound, ctg.arg_lower_bound, ctg.arg_upper_bound}
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.7 Set that SA assume row points');
disp( '>> sa_opt.use_row_point = 0');
pause;
sa_opt.use_row_point = 0
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.8 Set number of runs to 30');
disp( '>> sa_opt.n_runs = 30');
pause;
sa_opt.n_runs = 30
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.9 Set maximum number of function evaluations to 100');
disp( '>> sa_opt.max_n_samples = 100');
pause;
sa_opt.max_n_samples = 100
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '2.10 Call testbed to benchmark GA and SA with hump');
disp( '>> testbed( {@ga @simulannealbnd}, ''hump'', {ga_opt sa_opt})');
pause;
testbed( {@ga @simulannealbnd}, 'hump', {ga_opt sa_opt})
disp( 'Results are saved to testbed_output/, a few histograms are produced');
disp( 'and statistical results are printed as well for the comparison');
disp( ' ');
disp( '**************** NEXT *****************');
pause;

clear;
disp( '***************************************')
disp( '*  ____    ____    _____   __         *')
disp( '* /\  _`\ /\  _`\ /\  __`\/\ \        *')
disp( '* \ \ \L\ \ \ \/\ \ \ \/\ \ \ \       *')
disp( '*  \ \ ,__/\ \ \ \ \ \ \ \ \ \ \  __  *')
disp( '*   \ \ \/  \ \ \_\ \ \ \_\ \ \ \L\ \ *')
disp( '*    \ \_\   \ \____/\ \_____\ \____/ *')
disp( '*     \/_/    \/___/  \/_____/\/___/  *')
disp( '*                                     *')
disp( '* DEMO FOR TESTBED SYSTEM: MODULE _3_ *')
disp( '*  Objective controlled comparison    *')
disp( '*                                     *')
disp( '* Limit the desired objective function*')
disp( '* value and compare the number of     *')
disp( '* function evaluations from:          *')
disp( '* 1. ga - Genetic Algorithm by Matlab *')
disp( '* 2. simulannealbnd -                 *')
disp( '*      Simmulated Annealing by Matlab *')
disp( '* (it is assumed you have GO toolbox) *')
disp( '* with problems:                      *')
disp( '* 1. hump - (hump.p.xml)              *')
disp( '*                                     *')
disp( '***************************************')
disp( 'Press enter to continue');
disp( ' ');

disp( '3.1 Set argument format for GA');
disp( '>> ga_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound})')
pause;
ga_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound}
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.2 Set that GA assume row points');
disp( '>> ga_opt.use_row_point = 1');
pause;
ga_opt.use_row_point = 1
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.3 Set number of runs to 30');
disp( '>> ga_opt.n_runs = 30');
pause;
ga_opt.n_runs = 30
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.4 Set desired objective function value to -1');
disp( '>> ga_opt.min_obj_value = -1');
pause;
ga_opt.min_obj_value = -1
disp( ' ');
disp( '**************** NEXT *****************');
pause;

disp( '3.6 Set argument format for SA');
disp( '>> sa_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_lower_bound, ctg.arg_lower_bound, ctg.arg_upper_bound})')
pause;
sa_opt.arg_list = {ctg.arg_objfun_handle, ctg.arg_lower_bound, ctg.arg_lower_bound, ctg.arg_upper_bound}
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.7 Set that SA assume row points');
disp( '>> sa_opt.use_row_point = 0');
pause;
sa_opt.use_row_point = 0
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.8 Set number of runs to 30');
disp( '>> sa_opt.n_runs = 30');
pause;
sa_opt.n_runs = 30
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.9 Set desired objective function value to -1');
disp( '>> sa_opt.min_obj_value = -1');
pause;
sa_opt.min_obj_value = -1
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '3.10 Call testbed to benchmark GA and SA with hump');
disp( '>> testbed( {@ga @simulannealbnd}, ''hump'', {ga_opt sa_opt})');
pause;
testbed( {@ga @simulannealbnd}, 'hump', {ga_opt sa_opt})
disp( 'Results are saved to testbed_output/, a few histograms are produced');
disp( 'and statistical results are printed as well for the comparison');
disp( ' ');
disp( '**************** NEXT *****************');
pause;

clear;
disp( '***************************************')
disp( '*  ____    ____    _____   __         *')
disp( '* /\  _`\ /\  _`\ /\  __`\/\ \        *')
disp( '* \ \ \L\ \ \ \/\ \ \ \/\ \ \ \       *')
disp( '*  \ \ ,__/\ \ \ \ \ \ \ \ \ \ \  __  *')
disp( '*   \ \ \/  \ \ \_\ \ \ \_\ \ \ \L\ \ *')
disp( '*    \ \_\   \ \____/\ \_____\ \____/ *')
disp( '*     \/_/    \/___/  \/_____/\/___/  *')
disp( '*                                     *')
disp( '* DEMO FOR TESTBED SYSTEM: MODULE _4_ *')
disp( '*  Constrained GA with custom options *')
disp( '*                                     *')
disp( '***************************************')
disp( 'Press enter to continue');
disp( ' ');

disp( '4.1 Set custom argument for GA');
disp( '>> gaopt.PopulationSize = 50; gaopt.CrossoverFraction = 0.9')
pause;
gaopt.PopulationSize = 50; gaopt.CrossoverFraction = 0.9
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '4.2 Set argument format for GA');
disp( '>> options.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound, ctg.arg_confun_handle, gaopt})')
pause;
options.arg_list = {ctg.arg_objfun_handle, ctg.arg_n_variables, [], [], [], [], ctg.arg_lower_bound, ctg.arg_upper_bound, ctg.arg_confun_handle, gaopt}
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '4.3 Set that GA assume row points');
disp( '>> options.use_row_point = 1');
pause;
options.use_row_point = 1
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '4.4 Set number of runs to 3');
disp( '>> options.n_runs = 3');
pause;
options.n_runs = 3
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '4.5 Set maximum number of function evaluations to 500');
disp( '>> options.max_n_samples = 500');
pause;
options.max_n_samples = 500
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '4.6 Find a problem that is: go constrained');
disp( '>> pman( ctg.option_find, [ctg.go ctg.constrained]);');
pause;
p = pman( ctg.option_find, [ctg.go ctg.constrained])
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '4.7 Call testbed to benchmark GA with g1');
disp( '>> testbed( @ga, ''g1'', options)');
pause;
testbed( @ga, 'g1', options)
disp( 'Results are saved to testbed_output/, a few histograms are produced');
disp( 'and statistical results are printed as well');
disp( 'But GA actually evaluates samples that doesnt comply to the constraints');
disp( 'so the minimum value testbed found is no reliable, currently there is');
disp( 'no work around');
disp( ' ');
disp( '**************** NEXT *****************');
pause;

clear;
disp( '***************************************')
disp( '*  ____    ____    _____   __         *')
disp( '* /\  _`\ /\  _`\ /\  __`\/\ \        *')
disp( '* \ \ \L\ \ \ \/\ \ \ \/\ \ \ \       *')
disp( '*  \ \ ,__/\ \ \ \ \ \ \ \ \ \ \  __  *')
disp( '*   \ \ \/  \ \ \_\ \ \ \_\ \ \ \L\ \ *')
disp( '*    \ \_\   \ \____/\ \_____\ \____/ *')
disp( '*     \/_/    \/___/  \/_____/\/___/  *')
disp( '*                                     *')
disp( '* DEMO FOR TESTBED SYSTEM: MODULE _5_ *')
disp( '*  Custom algorithm to be tested      *')
disp( '*  Here we use MPS as am example      *')
disp( '*  MPS can be found on PDOL website   *')
disp( '*                                     *')
disp( '***************************************')
disp( 'Press enter to continue');
disp( ' ');

disp( '5.1 Add MPS to path');
disp( '>> addpath(genpath(strcat(fileparts(mfilename(''fullpath'')),''/MPS'')));');
pause;
addpath(genpath(strcat(fileparts(mfilename('fullpath')),'/MPS')));
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '5.2 Set custom argument for MPS');
disp( '>> options.arg_list = {ctg.arg_n_variables, ctg.arg_lower_bound, ctg.arg_upper_bound}')
pause;
options.arg_list = {ctg.arg_n_variables, ctg.arg_lower_bound, ctg.arg_upper_bound}
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '5.3 Set that MPS assumes row bound');
disp( '>> options.use_row_bound = 1')
pause;
options.use_row_bound = 1
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '5.4 Set name of objective function for MPS');
disp( '>> options.obj_fname = ''objfun.m''')
pause;
options.obj_fname = 'objfun.m'
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '5.5 Set number of runs to 3');
disp( '>> options.n_runs = 3');
pause;
options.n_runs = 3
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '5.6 Set maximum number of function evaluations to 500');
disp( '>> options.max_n_samples = 500');
pause;
options.max_n_samples = 500
disp( ' ');
disp( '**************** NEXT *****************');
pause;
disp( '5.7 Call testbed to benchmark MPS with hump');
disp( '>> testbed( @fminunctent, ''hump'', options)');
pause;
if which( 'fminunctent')
    testbed( @fminunctent, 'hump', options)
    disp( 'Results are saved to testbed_output/, a few histograms are produced');
    disp( 'and statistical results are printed as well');
else
    disp( 'MPS not found, please download at PDOL website, and put in testbed folder');
end
disp( ' ');
disp( '**************** NEXT *****************');
pause;

disp( '***************************************')
disp( '*  ____    ____    _____   __         *')
disp( '* /\  _`\ /\  _`\ /\  __`\/\ \        *')
disp( '* \ \ \L\ \ \ \/\ \ \ \/\ \ \ \       *')
disp( '*  \ \ ,__/\ \ \ \ \ \ \ \ \ \ \  __  *')
disp( '*   \ \ \/  \ \ \_\ \ \ \_\ \ \ \L\ \ *')
disp( '*    \ \_\   \ \____/\ \_____\ \____/ *')
disp( '*     \/_/    \/___/  \/_____/\/___/  *')
disp( '*                                     *')
disp( '* DEMO FOR TESTBED SYSTEM: THE END    *')
disp( '*                                     *')
disp( '***************************************')
disp( 'Press enter to exit');
pause;
