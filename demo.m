clearvars; 
close all; 
restoredefaultpath; matlabrc;
add_paths;
rng(0);                                                                                                         % default seed (0)

% --- initialisation
settings =  gen_settings('case_id',1,'sel_pd',0.98);                                                            % generate settings for a scenario
model = gen_model(settings,'meas_sigma',10,'lambda_c',10,'track_threshold',0.001,'metric_type','ospa_union');   % generate model parameters
truth = gen_truth(model,settings);                                                                              % generate ground truths
[~,colorarray] = plot_truth(settings.source_info, model, truth);                                                % plot the current truths
meas = gen_all_meas(settings,model,truth);                                                                      % generate measurements

% --- main fusion program
fused_agents = run_fused_filter(settings,model,truth,meas);

% --- report results
sel_agent = 2;
report_single_result(sel_agent,fused_agents); 

% --- plot results
[h_ospa,h_ospa2,h_card,h_proc] =  plot_fused_results(model,truth,fused_agents,'sel_agent',sel_agent);
plot_est_vs_truth(model, settings, truth, fused_agents,'sel_agent',sel_agent,'colorarray',colorarray);
pause(2);
xlim(model.limit(1,:)); ylim(model.limit(2,:));
set(gcf,'Position',[-948,255,795,561]); set(gca,'FontSize',16);

