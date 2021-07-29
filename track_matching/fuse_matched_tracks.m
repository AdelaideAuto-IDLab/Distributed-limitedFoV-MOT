function [X_fused,l_fused] = fuse_matched_tracks(X_track1,X_track2,l_list1,l_list2,Q,w)
    try
        X1_to_fuse = reshape(X_track1(:,:,Q(:,1)),[],length(Q(:,1)));
        X1_fused_idx = any(~isnan(X1_to_fuse));
        X2_to_fuse = reshape(X_track2(:,:,Q(:,2)),[],length(Q(:,2)));
        X2_fused_idx = any(~isnan(X2_to_fuse));
        X12_fused_idx = X1_fused_idx | X2_fused_idx;
        X1_to_fuse = X1_to_fuse(:,X12_fused_idx);
        X2_to_fuse = X2_to_fuse(:,X12_fused_idx);
        l_fused1 = l_list1(:,Q(X12_fused_idx,1));   
%         l_fused2 = l_list2(:,Q(X12_fused_idx,2)); 
        l_fused = l_fused1;
%         idx = l_fused2(1,:) <  l_fused1(1,:);
%         l_fused(:,idx) = l_fused2(:,idx);
        X_fused = X1_to_fuse ;
        X_fused = w*X1_to_fuse + (1-w) *X2_to_fuse;
    catch err
        error(err.message);
    end
end