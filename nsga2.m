
% clear all workspace variables
clear all;

addpath(genpath('./input_data'));   % this is where all the algorithm parameters are
addpath(genpath('./problemdef'));   % this is where all the problems are defined
addpath(genpath('./rand'));         % this is where all the legacy rng related stuffs are.
                                    % NOT VECTORIZED, DO NOT USE, SLOW !!!

% global variables that may be used here
global popsize ;
global nreal ;
global nobj ;
global ncon ;
global ngen ;

% load algorithm parameters
load_input_data('input_data/zdt4.in');
pprint('\nInput data successfully entered, now performing initialization\n\n');

% for debugging puproses 
% global min_realvar ;
% global max_realvar ;
% popsize = 12 ;
% nreal = 3 ;
% min_realvar = min_realvar(1:nreal);
% max_realvar = max_realvar(1:nreal);

obj_col = nreal + 1 : nreal + nobj ;

% this is the objective function that we are going to optimize
obj_func = @zdt4 ;
child_pop = zeros(popsize, nreal + nobj + ncon + 3);
mixed_pop = zeros(2 * popsize, nreal + nobj + ncon + 3);

% switch to save file, if true, the code becomes slow
save_file = false ;

tic;
% initialize population
parent_pop = initialize_pop(0.12345);
pprint('Initialization done, now performing first generation\n\n');
parent_pop = evaluate_pop(parent_pop, obj_func);
parent_pop = assign_rank_and_crowding_distance(parent_pop);

% save into file
if(save_file)
    rank_col = nreal + nobj + ncon + 2 ;
    dlmwrite('all_pop.out', sortrows(parent_pop, rank_col));
end

% plot the pareto front
show_plot(1, parent_pop, false, [2 3 4]);

for i = 2:ngen
    fprintf('gen = %d\n', i)
    child_pop = selection(parent_pop, child_pop);
    child_pop = mutation_pop(child_pop);
    child_pop(:,obj_col) = 0;
    child_pop = evaluate_pop(child_pop, obj_func);
    mixed_pop = merge_pop(parent_pop, child_pop);
    parent_pop = fill_nondominated_sort(mixed_pop);
    
    % plot the current pareto front
    show_plot(i, parent_pop, false, [2 3 4]);    
    
    % save the parent_pop into file
    if(save_file)       
        dlmwrite('all_pop.out', sortrows(parent_pop, rank_col), '-append');
    end
end
fprintf('Generations finished, now reporting solutions\n');
fprintf('Routine successfully exited\n');
toc;

if(save_file)    
    dlmwrite('best_pop.out', parent_pop(parent_pop(:,rank_col) == 1,:));
    dlmwrite('final_pop.out', sortrows(parent_pop, nreal+nobj+ncon+2));
end