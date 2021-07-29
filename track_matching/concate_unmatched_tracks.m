function [X_rem,l_rem] = concate_unmatched_tracks(X_track1,X_track2,l_list1,l_list2,l1_idx,l2_idx,Q1,Q2)
    X1_rem = reshape(X_track1(:,:,Q1),[],length(Q1));
    X1_rem_idx = any(~isnan(X1_rem));
    l1_rem = l_list1(:,l1_idx(Q1(X1_rem_idx)));
    X1_rem_final = X1_rem(:,X1_rem_idx);
    
    X2_rem = reshape(X_track2(:,:,Q2),[],length(Q2));
    X2_rem_idx = any(~isnan(X2_rem));
    l2_rem = l_list2(:,l2_idx(Q2(X2_rem_idx)));
    X2_rem_final = X2_rem(:,X2_rem_idx);
    
    X_rem = [X1_rem_final,X2_rem_final];
    l_rem = [l1_rem,l2_rem];
end