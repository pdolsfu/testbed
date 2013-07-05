% test all problems
options.arg_list = { ctg.arg_objfun_handle, ctg.arg_confun_handle, ctg.arg_lower_bound, ctg.arg_upper_bound};
options.quiet = 1;
p_list = pman( ctg.option_find, [], options);
n = length( p_list);

for ii = 1:n
    fprintf( '%s\n', p_list{ii});
    testbed( @aut_verify, p_list{ii}, options);
end
