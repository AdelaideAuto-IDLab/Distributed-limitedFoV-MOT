function cur_l_asso_hist = update_asso_hist(cur_l_asso_hist,l_space1,l_space2,matched_l1,matched_l2)
    % Algorithm B.2 Update Matched History
    try
    idx1 = 1 : size(l_space1,2);
    idx2 = 1 : size(l_space2,2);
    u_idx1 = zeros(size(matched_l1,2),1);
    u_idx2 = zeros(size(matched_l2,2),1);
    for i = 1 : size(matched_l1,2)
        u_idx1(i) = idx1(ismember(l_space1',matched_l1(:,i)','rows'));
    end
    for i = 1 : size(matched_l2,2)
        u_idx2(i) = idx2(ismember(l_space2',matched_l2(:,i)','rows')); 
    end

    for i = 1 : length(u_idx1)
        cur_l_asso_hist(u_idx1(i),u_idx2(i)) = cur_l_asso_hist(u_idx1(i),u_idx2(i)) +1;
    end
    catch err
        error(err);
    end
end