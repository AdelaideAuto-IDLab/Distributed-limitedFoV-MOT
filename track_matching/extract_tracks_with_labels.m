function [Y_track,l_list,k_birth,k_death]= extract_tracks_with_labels(est,cur_j,cur_k)
    %     cur_j = 20;
    %     cur_k = 50;
    try
        sel_idx = cur_j : cur_k;
        l_list = unique([cell2mat(est.L(sel_idx)')]','rows','stable')';
        if isempty(l_list)
           l_list = zeros(2,0); 
        end
        labelcount= size(l_list,2);
        l_idx = 1 : labelcount;
        
        est.total_tracks= labelcount;
        est.track_list= cell(length(sel_idx),1);
        idx = 0;
        for k=cur_j:cur_k
            if ~isempty(l_idx)
                idx = idx + 1;
                n_l = size(est.L{k},2);
                for j = 1 : n_l
                    cur_l = est.L{k}(:,j);
                    cur_l_idx = l_idx(ismember(l_list',cur_l','rows')');
                    est.track_list{idx} = [est.track_list{idx},cur_l_idx];
                end
            end
        end
        if labelcount == 0
            Y_track = zeros(4,1,0);
            k_birth = [];
            k_death = [];
        else
            [Y_track,k_birth,k_death]= extract_tracks(est.X(sel_idx),est.track_list,est.total_tracks);
        end
    catch err
        error(err.message);
    end
end
