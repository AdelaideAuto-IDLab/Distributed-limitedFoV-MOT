function rvect= get_rvals(tt_lmb)                           
    %function to extract vector of existence probabilities from LMB track table
    rvect= zeros(length(tt_lmb),1);
    for tabidx=1:length(tt_lmb)
        rvect(tabidx)= tt_lmb{tabidx}.r;
    end
end
