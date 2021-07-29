function glmb_clean= clean_update(glmb_temp)
    %flag used tracks
    usedindicator= zeros(length(glmb_temp.tt),1);
    for hidx= 1:length(glmb_temp.w)
        usedindicator(glmb_temp.I{hidx})= usedindicator(glmb_temp.I{hidx})+1;
    end
    trackcount= sum(usedindicator>0);
    
    %remove unused tracks and reindex existing hypotheses/components
    newindices= zeros(length(glmb_temp.tt),1); newindices(usedindicator>0)= 1:trackcount;
    glmb_clean.tt= glmb_temp.tt(usedindicator>0);
    glmb_clean.w= glmb_temp.w;
    for hidx= 1:length(glmb_temp.w)
        glmb_clean.I{hidx}= newindices(glmb_temp.I{hidx});
    end
    glmb_clean.n= glmb_temp.n;
    glmb_clean.cdn= glmb_temp.cdn;
end