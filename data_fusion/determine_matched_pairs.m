function Q = determine_matched_pairs(X_track1,l_list1,X_track2,l_list2,ospa_info,k)
    % Algorithm B.1 Determine Matched Pairs
    
    
     % --- make code look nicer
    ospa_c = ospa_info.c_lm;
    ospa_p = ospa_info.p;
    win_len = ospa_info.winlen_lm;

    metric_type = ospa_info.metric_type;
    j = max(1,k - win_len+1); %     j = 1;
    time_idx = j:k;

    l1_idx = (1 : size(l_list1,2))';
    l2_idx = (1 : size(l_list2,2))';
    
    % --- Calculate matching cost
    allcostm = zeros(size(l_list1,2),size(l_list2,2));
    for l1 = 1 : size(l_list1,2)
        X1 = X_track1([1 3],:,l1);
        cur_l1 = l_list1(:,l1);
        for l2 = 1 : size(l_list2,2)
            cur_l2 = l_list2(:,l2);
            X2 = X_track2([1 3],:,l2);
            if ~all(cur_l1 == cur_l2)
                allcostm(l1,l2) = compute_base_dist_two_tracks(X1,X2,ospa_c,ospa_p,'metric_type',metric_type,'time_idx',time_idx); 
            elseif any(isnan(X1(:,end))) || any(isnan(X2(:,end)))
                allcostm(l1,l2) = ospa_c;
            else
                allcostm(l1,l2) = -1;
            end
        end
    end
    
    % --- list of matched and unmatched tracks
    Matching = Hungarian(allcostm);
    cost_check = allcostm < ospa_c;
    Matching = Matching .* cost_check;
    
    L1_idx =  Matching * l2_idx;
    Q = [l1_idx,L1_idx];
    Q_check = prod(Q>0,2)>0;
    Q = Q(Q_check,:); % List of all matched track

end