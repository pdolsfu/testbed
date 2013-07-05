classdef ctg < double
%CTG        Category Enumerator for the PDOL Optimization Testbed System
%
% This enumeration class includes categories and support for the operation
% of functions in testbed system. The purpose is to cut down string compare
% usage and explicit numerical values in the implementation of funcions.
% ctg stands for (c)a(t)e(g)ory.
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

    enumeration
        % variable
        continuous (1)
        discrete (2)
        mixed (3)

        % linearity
        linear (4)
        nonlinear (5)

        % symmetry
        symmetric (6)
        nonsymmetric (7)

        % number of mode
        singlemodal (8)
        multimodal (9)

        % constrain
        constrained (10)
        unconstrained (11)

        % scale
        smallscale (12)
        largescale (13)

        % number of objective
        go (14)
        moo (15)

        % null and number of categories
        null (0)
        n_ctg (15)

        % configs for problem manager
        option_find (33)
        option_get (34)
        option_list (35)
        option_defaults (36)

        % for problem manager accessories
        option_must (49)
        option_fill (50)
        option_cell (51)
        option_eval (52)

        % for objective, constraint function and data manager
        option_clear (65)
        option_harvest (66)
        option_create (67)
        option_log (68)
        option_activate (69)
        option_deactivate (70)

        % predifined data ids for data manager
        id_obj_x (1)
        id_obj_f (2)
        id_obj_t (3)
        id_obj_tic (4)
        id_con_x (5)
        id_con_c (6)
        id_con_ceq (7)
        id_con_t (8)
        id_con_tic (9)

        % suppression levels used in data manager
        suppress_keep_all (0)
        suppress_keep_only_count (80)
        suppress_keep_nothing (81)

        % argument items for arg_list, use bezaire values to avoid clushing
        arg_n_variables (-10.01)
        arg_n_objectives (-10.02)
        arg_lower_bound (-10.03)
        arg_upper_bound (-10.04)
        arg_bound_matrix (-10.045)
        arg_objfun_handle (-10.05)
        arg_confun_handle (-10.06)

        % return items for ret_list
        ret_point (-11.01)
        ret_value (-11.02)
    end
end
