function glmb_temp= clean_predict(glmb_raw)
    %hash label sets, find unique ones, merge all duplicates
    for hidx= 1:length(glmb_raw.w)
        glmb_raw.hash{hidx}= sprintf('%i*',sort(glmb_raw.I{hidx}(:)'));
    end
    
    [cu,~,ic]= unique(glmb_raw.hash);
    
    glmb_temp.tt= glmb_raw.tt;
    glmb_temp.w= zeros(length(cu),1);
    glmb_temp.I= cell(length(cu),1);
    glmb_temp.n= zeros(length(cu),1);
    for hidx= 1:length(ic)
        glmb_temp.w(ic(hidx))= glmb_temp.w(ic(hidx))+glmb_raw.w(hidx);
        glmb_temp.I{ic(hidx)}= glmb_raw.I{hidx};
        glmb_temp.n(ic(hidx))= glmb_raw.n(hidx);
    end
    glmb_temp.cdn= glmb_raw.cdn;
end