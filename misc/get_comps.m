function Xc= get_comps(X,c)
    
    if isempty(X)
        Xc= [];
    else
        Xc= X(c,:);
    end
end