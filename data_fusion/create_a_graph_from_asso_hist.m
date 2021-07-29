function [G,l_space] = create_a_graph_from_asso_hist(fused_agents)
    % Create a graph from the association history, line 1 in Algorithm B.3
    T = [];
    l_space = [fused_agents{1}.l_space{:}];
    if isempty(l_space)
       G = graph; 
       return;
    end
    L_size = size(l_space,2);
    l_idx = 1 : L_size;
    n_s = length(fused_agents);
    try
        for s = 1 : n_s
            if ~isempty(fused_agents{s}.l_space{s})
                s_l_idx = l_idx(ismember(l_space',fused_agents{s}.l_space{s}','rows'));
                for i = 1 : n_s
                    if i < s && ~isempty(fused_agents{s}.l_space{i})
                        l_asso_hist = fused_agents{s}.l_asso_hist{s,i};
                        l_asso_hist = fix_multiple_asso_indices(l_asso_hist');
                        cur_l_idx = l_idx(ismember(l_space',fused_agents{s}.l_space{i}','rows'));
                        tmp = [s_l_idx;cur_l_idx * (l_asso_hist>0)];
                        tmp = tmp(:,all(tmp>0));
                        T = [T,tmp];
                    elseif i > s && ~isempty(fused_agents{s}.l_space{i})
                        l_asso_hist = fused_agents{s}.l_asso_hist{s,i};
                        l_asso_hist = fix_multiple_asso_indices(l_asso_hist');
                        cur_l_idx = l_idx(ismember(l_space',fused_agents{s}.l_space{i}','rows'));
                        tmp = [s_l_idx;cur_l_idx * (l_asso_hist>0)];
                        tmp = tmp(:,all(tmp>0));
                        T = [T,tmp];
                    end
                end
            end
        end
        
        if isempty(T)
            G = graph;
            G = addnode(G,size(l_space,2));
        else
            G = graph(T(1,:), T(2,:));
            if max(max(T)) < size(l_space,2)
                G = addnode(G, size(l_space,2)-max(max(T)));
            end
        end
    catch err
        disp(err.message);
    end
        
end
