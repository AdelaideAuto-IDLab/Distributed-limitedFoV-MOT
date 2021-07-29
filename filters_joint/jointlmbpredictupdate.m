function glmb_nextupdate= jointlmbpredictupdate(tt_lmb_update,model,filter,meas,k,varargin)
    % An LMB joint prediction and update filter
    % input: an LMB density
    % output: a GLMB density (which will be converted to an LMB density later)

    % --- Input Parser
    p = inputParser;
    addParameter(p,'abp_info',[]);                                                                                          %glmb_update for adaptive birth procedure
    addParameter(p,'pD_min',0);
    parse(p, varargin{:});
    abp_info = p.Results.abp_info;
    pD_min = p.Results.pD_min;
    %---generate birth tracks
    if k>1 && model.abp.enable
        tt_birth = adaptive_birth(model,abp_info,k);  
    else
        tt_birth= cell(length(model.r_birth),1);                                                                            %initialize cell array
        unique_multiplier = abp_info.source_id * model.ospa.unique_multiplier;
        rand_idx = randperm(length(model.r_birth));
        base_pos = pinv(model.H) * model.fov_shape{1}.Vertices(1,:)';
        for tabbidx=1:length(model.r_birth)
            tt_birth{tabbidx}.r= model.r_birth(tabbidx);                                                                    %birth prob for birth track
            tt_birth{tabbidx}.m= model.m_birth{tabbidx}+base_pos;                                                           %means of Gaussians for birth track
            tt_birth{tabbidx}.P= model.P_birth{tabbidx};                                                                    %covs of Gaussians for birth track
            tt_birth{tabbidx}.w= model.w_birth{tabbidx}(:);                                                                 %weights of Gaussians for birth track
            tt_birth{tabbidx}.l= [k;rand_idx(tabbidx)+unique_multiplier];                                                   %track label
        end
    end
    
    %---generate surviving tracks
    tt_survive= cell(length(tt_lmb_update),1);                                                                              %initialize cell array
    for tabsidx=1:length(tt_lmb_update)   
        tt_survive{tabsidx}.r= model.P_S*tt_lmb_update{tabsidx}.r;                                                          %predicted existence probability for surviving track
        [mtemp_predict,Ptemp_predict]= kalman_predict_multiple(model,tt_lmb_update{tabsidx}.m,tt_lmb_update{tabsidx}.P);    %kalman prediction
        tt_survive{tabsidx}.m= mtemp_predict;                                                                               %means of Gaussians for surviving track
        tt_survive{tabsidx}.P= Ptemp_predict;                                                                               %covs of Gaussians for predicted track
        tt_survive{tabsidx}.w= tt_lmb_update{tabsidx}.w;                                                                    %weights of Gaussians for predicted track
        tt_survive{tabsidx}.l= tt_lmb_update{tabsidx}.l;                                                                    %track label
    end
    
    %create predicted tracks - concatenation of birth and survival
    tt_predict= cat(1,tt_birth,tt_survive);                                                                                 %copy track table back to GLMB struct
    
    
    %gating by tracks
    if filter.gate_flag
        for tabidx=1:length(tt_predict)
            tt_predict{tabidx}.gatemeas= gate_meas_gms_idx(meas.Z{k},filter.gamma,model,tt_predict{tabidx}.m,tt_predict{tabidx}.P);
        end
    else
        for tabidx=1:length(tt_predict)
            tt_predict{tabidx}.gatemeas= 1:size(meas.Z{k},2);
        end
    end
    
    %precalculation loop for average survival/death probabilities
    avps= zeros(length(tt_predict),1);
    for tabidx=1:length(tt_predict)
        avps(tabidx)= tt_predict{tabidx}.r;
    end
    avqs= 1-avps;
    
    %precalculation loop for average detection/missed probabilities
    avpd= zeros(length(tt_predict),1);
    for tabidx=1:length(tt_predict)
        avpd(tabidx)= mean(compute_pD(model, tt_predict{tabidx}.m,meas.fov_shape{k},'pD_min',pD_min));
    end
    avqd= 1-avpd;
    
    %create updated tracks (single target Bayes update)
    m= size(meas.Z{k},2);                                                                                                                   %number of measurements
    tt_update= cell((1+m)*length(tt_predict),1);                                                                                            %initialize cell array
    
    %missed detection tracks (legacy tracks)
    for tabidx= 1:length(tt_predict)
        tt_update{tabidx}= tt_predict{tabidx};                                                                                              %same track table
        tt_update{tabidx}.ah= 0;                                                                                                            %missed detection --- for adaptive birth
    end
    %measurement updated tracks (all pairs)
    allcostm= zeros(length(tt_predict),m);
    for tabidx= 1:length(tt_predict)
        for emm= tt_predict{tabidx}.gatemeas
            stoidx= length(tt_predict)*emm + tabidx;                                                                                        %index of predicted track i updated with measurement j is (number_predicted_tracks*j + i)
            [qz_temp,m_temp,P_temp] = kalman_update_multiple(meas.Z{k}(:,emm),model,tt_predict{tabidx}.m,tt_predict{tabidx}.P);             %kalman update for this track and this measurement
            w_temp= qz_temp.*tt_predict{tabidx}.w+eps;                                                                                      %unnormalized updated weights
            tt_update{stoidx}.m= m_temp;                                                                                                    %means of Gaussians for updated track
            tt_update{stoidx}.P= P_temp;                                                                                                    %covs of Gaussians for updated track
            tt_update{stoidx}.w= w_temp/sum(w_temp);                                                                                        %weights of Gaussians for updated track
            tt_update{stoidx}.l = tt_predict{tabidx}.l;                                                                                     %track label
            tt_update{stoidx}.ah = emm;                                                                                                     %assign measurement association for adative birth
            allcostm(tabidx,emm)= sum(w_temp);                                                                                              %predictive likelihood
        end
    end
    glmb_nextupdate.tt= tt_update;                                                                                                          %copy track table back to GLMB struct
    %joint cost matrix
    jointcostm= [diag(avqs) ...
        diag(avps.*avqd) ...
        repmat(avps.*avpd,[1 m]).*allcostm/(model.lambda_c*model.pdf_c)];
    %gated measurement index matrix
    gatemeasidxs= zeros(length(tt_predict),m);
    for tabidx= 1:length(tt_predict)
        gatemeasidxs(tabidx,1:length(tt_predict{tabidx}.gatemeas))= tt_predict{tabidx}.gatemeas;
    end
    gatemeasindc= gatemeasidxs>0;
    
    
    %component updates
    
    %calculate best updated hypotheses/components
    cpreds= length(tt_predict);
    nbirths= length(tt_birth);%model.T_birth;
    nexists= length(tt_lmb_update);
    ntracks= nbirths + nexists;
    tindices= [(1:nbirths) nbirths+(1:nexists)];                                                                                        %indices of all births and existing tracks  for current component
    lselmask= false(length(tt_predict),m); lselmask(tindices,:)= gatemeasindc(tindices,:);                                              %logical selection mask to index gating matrices
    mindices= unique_faster(gatemeasidxs(lselmask));                                                                                    %union indices of gated measurements for corresponding tracks
    costm= abs(jointcostm(tindices,[tindices cpreds+tindices 2*cpreds+mindices]));                                                      %cost matrix - [no_birth/is_death | born/survived+missed | born/survived+detected]
    neglogcostm= -log(costm);                                                                                                           %negative log cost
    [uasses,nlcost]= gibbswrap_jointpredupdt_custom(neglogcostm,round(filter.H_upd));                                                   %murty's algo/gibbs sampling to calculate m-best assignment hypotheses/components
    uasses(uasses<=ntracks)= -inf;                                                                                                      %set not born/track deaths to -inf assignment
    uasses(uasses>ntracks & uasses<= 2*ntracks)= 0;                                                                                     %set survived+missed to 0 assignment
    uasses(uasses>2*ntracks)= uasses(uasses>2*ntracks)-2*ntracks;                                                                       %set survived+detected to assignment of measurement index from 1:|Z|
    uasses(uasses>0)= mindices(uasses(uasses>0));                                                                                       %restore original indices of gated measurements
    
    %generate corrresponding jointly predicted/updated hypotheses/components
    for hidx=1:length(nlcost)
        update_hypcmp_tmp= uasses(hidx,:)';
        update_hypcmp_idx= cpreds.*update_hypcmp_tmp+[(1:nbirths)'; nbirths+(1:nexists)'];
        glmb_nextupdate.w(hidx)= -model.lambda_c+m*log(model.lambda_c*model.pdf_c)-nlcost(hidx);                                        %hypothesis/component weight
        glmb_nextupdate.I{hidx}= update_hypcmp_idx(update_hypcmp_idx>0);                                                                %hypothesis/component tracks (via indices to track table)
        glmb_nextupdate.n(hidx)= sum(update_hypcmp_idx>0);                                                                              %hypothesis/component cardinality
    end
    
    glmb_nextupdate.w= exp(glmb_nextupdate.w-logsumexp(glmb_nextupdate.w));                                                                                                                 %normalize weights
    
    %extract cardinality distribution
    for card=0:max(glmb_nextupdate.n)
        glmb_nextupdate.cdn(card+1)= sum(glmb_nextupdate.w(glmb_nextupdate.n==card));                                                                                                       %extract probability of n targets
    end
    
    %remove duplicate entries and clean track table
    glmb_nextupdate= clean_update(clean_predict(glmb_nextupdate));
      
end

