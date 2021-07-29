function l_temp_u = update_l_report_from_asso_hist(fused_agents,s,k)
    % Algorithm B.3 UpdateLabels
    [G,l_space] = create_a_graph_from_asso_hist(fused_agents); 
    birth_unique = fused_agents{s}.model.ospa.unique_multiplier^2;    
    l_temp = fused_agents{s}.est_fused.L{k};    
    nl_temp = size(l_temp,2);
    l_temp_u = l_temp;
    for i = 1 : nl_temp
        cur_l_temp = l_temp(:,i);
        if any(ismember(l_space',cur_l_temp','rows'))
            l_idx = 1 : size(l_space,2);
            temp_idx = l_idx(ismember(l_space',cur_l_temp','rows'));
            nearest_nodes = [temp_idx,nearest(G,temp_idx,inf)'];
            max_loop = length(nearest_nodes);
            while max_loop > 0
                max_loop = max_loop - 1;
                cur_l_space = l_space(:,nearest_nodes);
                cur_l_space_flat = cur_l_space(1,:) * birth_unique + cur_l_space(2,:);
                [~,min_idx] = min(cur_l_space_flat);
                if min_idx == 1
                    break;
                end
                cur_l_temp = cur_l_space(:,min_idx);
                if  ~any(ismember(l_temp',cur_l_temp','rows')) && ~any(ismember(l_temp_u',cur_l_temp','rows')) % 
                    l_temp_u(:,i) = cur_l_temp;
                    break;
                end
                nearest_nodes(min_idx) = [];
            end
        end
    end
end
