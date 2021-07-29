function [X_report,N_report,L_report,l_space,l_asso_hist] = fuse_two_estimated_tracks(est1,est2,l_space,l_asso_hist,ospa_info,k,w)
    % Algorithm 1: Fuse two estimated tracks from two agents
    
    % --- make code look nicer
    win_len = ospa_info.winlen_lm;
    min_track_len = ospa_info.min_track_len;
    use_consecutive_len = ospa_info.use_consecutive_len;
    j = max(1,k - win_len+1); 
    s1 = est1.source_id;
    s2 = est2.source_id;

    % --- extract tracks
    try
        [X_track1,l_list1]= extract_tracks_with_labels_at_k(est1,j,k);
        [X_track2,l_list2]= extract_tracks_with_labels_at_k(est2,j,k);
        l1_idx = (1 : size(l_list1,2))';
        l2_idx = (1 : size(l_list2,2))';
    catch err
       error(err); 
    end
    
    % --- update label space and its association history
    if ~isempty(l_list1)
        l_space{s1} = unique([l_space{s1},l_list1]','rows','stable')';
    end
    if ~isempty(l_list2)
        l_space{s2} = unique([l_space{s2},l_list2]','rows','stable')';
    end
   
    
    if isempty(l_asso_hist{s1,s2})
        l_asso_hist{s1,s2} = zeros(size(l_space{s1},2),size(l_space{s2},2));
    else
        temp = l_asso_hist{s1,s2};
        l_asso_hist{s1,s2} = zeros(size(l_space{s1},2),size(l_space{s2},2));
        l_asso_hist{s1,s2}(1:size(temp,1),1:size(temp,2)) = temp;
    end
    
    % --- determine matched pairs
    Q = determine_matched_pairs(X_track1,l_list1,X_track2,l_list2,ospa_info,k);
    
    % --- determine unmatched tracks
    Q1 = l1_idx(~ismember(l1_idx,Q(:,1))); % unmatched track 1
    
    if ~isempty(Q1) && k>=2 && win_len > 1
        if ~use_consecutive_len
            sel_Q1 = reshape(sum(any(~isnan(X_track1(:,:,Q1)))),[],length(Q1)) >= min_track_len; % select only unmatched tracks with len >= min_track_len
        else
            sel_Q1 = consecutive_max_track_len(X_track1(:,:,Q1))' >= min_track_len & reshape(sum(any(~isnan(X_track1(:,:,Q1)))),[],length(Q1)) >= min_track_len+1; % select only unmatched tracks with len >= min_track_len
        end
        Q1 = Q1(sel_Q1);
    end
    Q2 = l2_idx(~ismember(l2_idx,Q(:,2))); % unmatched track 2
    if ~isempty(Q2) && k>=2 && win_len > 1
        if ~use_consecutive_len
            sel_Q2 = reshape(sum(any(~isnan(X_track2(:,:,Q2)))),[],length(Q2)) >= min_track_len; % select only unmatched tracks with len >= min_track_len
        else
            sel_Q2 = consecutive_max_track_len(X_track2(:,:,Q2))' >= min_track_len  & reshape(sum(any(~isnan(X_track2(:,:,Q2)))),[],length(Q2)) >= min_track_len+1;
        end
        Q2 = Q2(sel_Q2);
    end
    
    if isempty(X_track1) && isempty(X_track2)
        X_report = []; N_report = 0; L_report = [];
    else
        % --- update asso hist
        if ~isempty(Q)
            try
                l_asso_hist{s1,s2} = update_asso_hist(l_asso_hist{s1,s2},l_space{s1},l_space{s2},l_list1(:,Q(:,1)),l_list2(:,Q(:,2)));
            catch err
                st = struct2table(dbstack); disp_try_catch_err(st.name{1}, err);
            end
        end
        % --- fuse matched tracks
        if isempty(Q)
            X_fused = []; l_fused = zeros(2,0);
        else
            [X_fused,l_fused] = fuse_matched_tracks(X_track1(:,end,:),X_track2(:,end,:),l_list1,l_list2,Q,w);
        end
        % --- keep the unmatched tracks
        if isempty(Q1) && isempty(Q2)
            X_rem = []; l_rem = zeros(2,0);
        else
            [X_rem,l_rem] = concate_unmatched_tracks(X_track1(:,end,:),X_track2(:,end,:),l_list1,l_list2,l1_idx,l2_idx,Q1,Q2);
        end
        % --- report result
        X_report = [X_fused,X_rem];
        L_report = [l_fused,l_rem];
        
        N_report = size(L_report,2);
        
        nan_check =  any(isnan(X_report));
        if nan_check
            X_report = X_report(:,~nan_check);
            L_report = L_report(:,~nan_check);
        end
        if size(unique(L_report','rows')',2) < size(L_report,2)
           disp('labels are not uniqe'); 
           [X_report,L_report] =  merge_same_labels(X_report,L_report);
        end
        if isempty(L_report)
            L_report = [];
            N_report = 0;
            X_report = [];
        end

        
    end
end