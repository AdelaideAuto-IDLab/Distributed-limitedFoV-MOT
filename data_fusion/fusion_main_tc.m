function fused_agents = fusion_main_tc(model,fused_agents,k)
    % Algorithm 2: FuseMultiNodes
    % Including two steps:
    % Step 1: Fusing each neighbor node to the selected agent
    % Step 2: Fusing the fused result of each neighbor node toghether. 
    
    n_s = length(fused_agents);
    for s = 1 : n_s
        try
            sel_Agent = fused_agents{s};
            sel_Agent.est.source_id = s;
            neighbor_list = fused_agents{s}.source_info.neighbor_id;
            n_neighbor = length(neighbor_list);

            est_temp = cell(n_neighbor,1);
            l_asso_hist = fused_agents{s}.l_asso_hist;
            l_space = fused_agents{s}.l_space;
            
            % --- Step 1 - Fusing each neighbor node to the selected agent
            for i = n_neighbor: -1 : 1
                cur_neighbor_id = neighbor_list(i);
                cur_Agent = fused_agents{cur_neighbor_id};
                cur_Agent.est.source_id = cur_neighbor_id;
                fused_weight = i/(n_neighbor+1);
                    est_temp{i}.source_id = cur_neighbor_id;
                [est_temp{i}.X{1},est_temp{i}.N(1),est_temp{i}.L{1},l_space,l_asso_hist] = fuse_two_estimated_tracks(sel_Agent.est,cur_Agent.est,l_space,l_asso_hist,model.ospa,k,fused_weight);
            end

            % --- Step 2: Fusing the fused result of each neighbor node toghether.                 
            est_fused = est_temp{n_neighbor};
            ospa_info_temp = model.ospa;
            ospa_info_temp.min_track_len = 1;
            ospa_info_temp.win_len = 1;
            if n_neighbor > 1
               for i = n_neighbor-1:-1 : 1
                   [est_fused.X{1},est_fused.N(1),est_fused.L{1}] = fuse_two_estimated_tracks(est_fused,est_temp{i},cell(n_s,1),cell(n_s,n_s),ospa_info_temp,1,0.5);
               end
            end 
            fused_agents{s}.est_fused.X{k} = est_fused.X{1};
            fused_agents{s}.est_fused.N(k) = est_fused.N(1);
            fused_agents{s}.est_fused.L{k} = est_fused.L{1};               
            fused_agents{s}.l_asso_hist = l_asso_hist;
            fused_agents{s}.l_space = l_space;

            % --- Step 3: Ensure label consensus
            fused_agents{s}.est_fused.L{k} = update_l_report_from_asso_hist(fused_agents,s,k);
        catch err
            err_str = sprintf('fusion_main_tc error  of agent %d with message = %s\n',s,err.message);
            disp(err_str);
            if isfield(model,'folder_path')
                write_to_log(model.folder_path,err_str);
            else
                write_to_log([pwd,'/'],err_str);
            end
        end
    end
end