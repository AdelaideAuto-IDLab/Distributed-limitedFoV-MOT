function idx =  mod_edit(i,n)
    % Fix modulo indexing issue in MATLAB
    idx = mod(i,n);
    if idx == 0, idx = n; end
end