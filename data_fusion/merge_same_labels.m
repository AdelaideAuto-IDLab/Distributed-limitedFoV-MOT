function [X_m,L_m] =  merge_same_labels(X,L)
     % Merge the same label together to ensure the label uniqueness contraint
     L_m = unique(L','rows')';
     n_Lm = size(L_m,2);
     X_m = zeros(size(X,1), n_Lm);
     for i = 1 : n_Lm
         cur_l = L_m(:,i);
         idx = ismember(L',cur_l','rows')';
         X_temp = X(:,idx);
         X_m(:,i) = mean(X_temp,2);
     end
end