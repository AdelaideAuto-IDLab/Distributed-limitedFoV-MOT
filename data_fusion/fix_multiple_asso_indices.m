function asso_out = fix_multiple_asso_indices(asso_in)
    % fix multiple indices
    % --- column
    idx = sum(asso_in>0,1) >1;
    idx = idx .* [1:size(asso_in,2)];
    idx = idx(:,idx>0);
    
    for i = idx
        temp = asso_in(:,i);
        [temp_max,ii] = max(temp);
        temp = zeros(size(temp));
        temp(ii) = temp_max;
        asso_in(:,i) = temp;
    end
    % --- row
    idx = sum(asso_in>0,2)' >1;
    idx = idx .* [1:size(asso_in,1)];
    idx = idx(:,idx>0);
    
    for i = idx
        temp = asso_in(i,:);
        [temp_max,ii] = max(temp);
        temp = zeros(size(temp));
        temp(ii) = temp_max;
        asso_in(i,:) = temp;
    end
    asso_out = asso_in;
end