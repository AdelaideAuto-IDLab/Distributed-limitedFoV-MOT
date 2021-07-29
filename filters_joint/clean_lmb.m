function tt_lmb_out= clean_lmb(tt_lmb_in,filter)
    % Clean an LMB density by prunning, capping and merge Gaussian mixtures

    %prune tracks with low existence probabilities
    rvect= get_rvals(tt_lmb_in);
    idxkeep= find(rvect > filter.track_threshold);
    rvect= rvect(idxkeep);
    tt_lmb_out= tt_lmb_in(idxkeep);
    
    %enforce cap on maximum number of tracks
    if length(tt_lmb_out) > filter.T_max
        [~,idxkeep]= sort(rvect,'descend');
        tt_lmb_out= tt_lmb_out(idxkeep);
    end
    
    %cleanup tracks
    for tabidx=1:length(tt_lmb_out)
        [tt_lmb_out{tabidx}.w,tt_lmb_out{tabidx}.m,tt_lmb_out{tabidx}.P]= gaus_prune(tt_lmb_out{tabidx}.w,tt_lmb_out{tabidx}.m,tt_lmb_out{tabidx}.P,filter.elim_threshold);

        [tt_lmb_out{tabidx}.w,tt_lmb_out{tabidx}.m,tt_lmb_out{tabidx}.P]= gaus_merge(tt_lmb_out{tabidx}.w,tt_lmb_out{tabidx}.m,tt_lmb_out{tabidx}.P,filter.merge_threshold);

        [tt_lmb_out{tabidx}.w,tt_lmb_out{tabidx}.m,tt_lmb_out{tabidx}.P]= gaus_cap(tt_lmb_out{tabidx}.w,tt_lmb_out{tabidx}.m,tt_lmb_out{tabidx}.P,filter.L_max);
    end
end