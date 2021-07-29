function tt_lmb= glmb2lmb(glmb)
    %  Convert from GLMB density to LMB density

    %find unique labels (with different possibly different association histories)
    lmat= zeros(2,length(glmb.tt),1);
    for tabidx= 1:length(glmb.tt)
        lmat(:,tabidx)= glmb.tt{tabidx}.l;
    end
    lmat= lmat';
    
    [cu,~,ic]= unique(lmat,'rows'); cu= cu';
    
    %initialize LMB struct
    tt_lmb= cell(size(cu,2),1);
    for tabidx=1:length(tt_lmb)
        tt_lmb{tabidx}.r= 0;
        tt_lmb{tabidx}.m= [];
        tt_lmb{tabidx}.P= [];
        tt_lmb{tabidx}.w= [];
        tt_lmb{tabidx}.l= cu(:,tabidx);
    end
    
    %extract individual tracks
    for hidx=1:length(glmb.w)
        for t= 1:glmb.n(hidx)
            trkidx= glmb.I{hidx}(t);
            newidx= ic(trkidx);
            tt_lmb{newidx}.m= cat(2,tt_lmb{newidx}.m,glmb.tt{trkidx}.m);
            tt_lmb{newidx}.P= cat(3,tt_lmb{newidx}.P,glmb.tt{trkidx}.P);
            tt_lmb{newidx}.w= cat(1,tt_lmb{newidx}.w,glmb.w(hidx)*glmb.tt{trkidx}.w);
        end
    end
    
    %extract existence probabilities and normalize track weights
    for tabidx=1:length(tt_lmb)
        tt_lmb{tabidx}.r= sum(tt_lmb{tabidx}.w);
        tt_lmb{tabidx}.w= tt_lmb{tabidx}.w/tt_lmb{tabidx}.r;
        tt_lmb{tabidx}.r = limit_range(tt_lmb{tabidx}.r);
    end
    
end