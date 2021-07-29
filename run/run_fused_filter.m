function fused_agents = run_fused_filter(settings,model,truth,meas)
    % Run distributed multi-object tracking via settings, model, truth, meas


    % --- make code look nicer
    
    if strcmp(model.p.Results.metric_type,'ospa_union')
        fused_strategy = 'TC-OSPA2';
    elseif strcmp(model.p.Results.metric_type,'wasserstein')
        fused_strategy = 'TC-WASS';
    else
        fused_strategy = '';
    end
    
    pD_min = model.pD_min;
    n_s = length(settings.source_info);
    
    % --- initialise fused agents
    fused_agents = cell(n_s,1);
    for s = 1 : n_s
        fused_agents{s}.source_info = settings.source_info{s};
        fused_agents{s}.model = model;
        fused_agents{s}.fused_strategy = fused_strategy;
        fused_agents{s}.meas = meas{s};
        fused_agents{s}.lmb_hist = cell(model.K,1);
        fused_agents{s}.lmb_hist_fused = cell(model.K,1);
    end
    
    % --- record processing time performance
    start_time = tic;
    each_proc_time = zeros(model.K,1);
    each_fused_time = zeros(model.K,1);
    
    % --- main loop
    for k = 1 : model.K
        k_start_time = tic;
        fprintf('Running the fused filter using %s at time %d/%d \n',fused_strategy,k,model.K);

        for s = 1 : n_s
            model = update_model_info(model,settings.source_info{s});
            
            % --- initialize at k = 1
            if k == 1                                                                                   
                [fused_agents{s}.est,filter,fused_agents{s}.tt_lmb_update] = setup_filter(model,fused_agents{s}.meas);
                fused_agents{s}.est_fused = fused_agents{s}.est;
                abp_info = [];
                abp_info.source_id = fused_agents{s}.meas.source_id;
                abp_info.abp = model.abp;
                fused_agents{s}.l_asso_hist = cell(n_s,n_s);
                fused_agents{s}.l_space = cell(n_s,1);
            elseif model.abp.enable
                abp_info = fused_agents{s}.abp_info;
                abp_info.source_id = fused_agents{s}.meas.source_id;
            end
            tt_lmb_update = fused_agents{s}.tt_lmb_update;                                              %the previous lmb density 

            % --- joint predict and update, results in GLMB, convert to LMB
            glmb_update= jointlmbpredictupdate(tt_lmb_update,model,filter,fused_agents{s}.meas,k,'abp_info',abp_info,'pD_min',pD_min);
            
            
            % --- pruning, truncation and track cleanup
            tt_lmb_update= glmb2lmb(glmb_update);                                                       %convert GLMB to LMB
            tt_lmb_update= clean_lmb(tt_lmb_update,filter);                                             %clean up LMB tracks
            fused_agents{s}.tt_lmb_to_fuse = tt_lmb_update;                                             %store densities for data fusion
            
            if model.abp.enable                                                                         %prepare data for adaptive birth procedure
                fused_agents{s}.abp_info.abp = model.abp;
                fused_agents{s}.abp_info.glmb_update = glmb_update;
                fused_agents{s}.abp_info.z = fused_agents{s}.meas.Z{k};
                fused_agents{s}.abp_info.source_id = fused_agents{s}.meas.source_id;
            end

            [fused_agents{s}.est.X{k},fused_agents{s}.est.N(k),fused_agents{s}.est.L{k}]= extract_estimates(tt_lmb_update,model); %extract estimates for fusion
            fused_agents{s}.tt_lmb_update = tt_lmb_update;                                              %store the posterior lmb density
            fused_agents{s}.est.source_id = s;
        end

        % --- data fusion (MAIN PROGRAM here) 
        k_fused_start_time = tic;
        fused_agents = fusion_main_tc(model,fused_agents,k);                                            %fusion using track consensus method
        
        % --- update time
        each_fused_time(k) = toc(k_fused_start_time);
        each_proc_time(k) = toc(k_start_time);
        
    end
    proc_time = toc(start_time);
    for  s = 1 : n_s
        fused_agents{s}.proc_time = proc_time/n_s;
        fused_agents{s}.each_proc_time = each_proc_time/n_s;
        fused_agents{s}.each_fused_time = each_fused_time/n_s;
        temp = fused_agents{s}.est;
        fused_agents{s}.est = fused_agents{s}.est_fused;
        fused_agents{s}.est_no_fused = temp;
        [~,fused_agents{s}.ospa,fused_agents{s}.ospa2] = plot_results(model,truth,fused_agents{s}.meas,fused_agents{s}.est,'show_plots',false); %evaluate performance
        fused_agents{s}.lmb_hist = [];                                                                  %delete lmb hist for reducing memory
        fused_agents{s}.lmb_hist_fused = [];                                                            %delete lmb hist for reducing memory
        fused_agents{s}.meas = [];                                                                      %delete meas for reducing memory
        meas{s} = [];                                                                                   %delete meas for reducing memory
    end
end

function model = update_model_info(model,source_info)
    model.P_D = source_info.P_D;
    model.Q_D = 1 - model.P_D;
end

