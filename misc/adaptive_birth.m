function tt_birth = adaptive_birth(model,abp_info,k,varargin)
    % Adaptive birth procedure based on previous measurement data

     % --- Input Parser
    p = inputParser;
    addParameter(p,'include_ah',false); % include ah for glmb filter
    parse(p, varargin{:});
    include_ah = p.Results.include_ah;
    abp = abp_info.abp;
    unique_multiplier = abp_info.source_id * model.ospa.unique_multiplier;
    glmb_update = abp_info.glmb_update;
    z = abp_info.z;
    if isempty(z)
        tt_birth= cell(length(model.r_birth),1);                                           %initialize cell array
        for tabbidx=1:length(model.r_birth)
            tt_birth{tabbidx}.r= model.r_birth(tabbidx);                                   %birth prob for birth track
            tt_birth{tabbidx}.m= model.m_birth{tabbidx};                                   %means of Gaussians for birth track
            tt_birth{tabbidx}.P= model.P_birth{tabbidx};                                   %covs of Gaussians for birth track
            tt_birth{tabbidx}.w= model.w_birth{tabbidx}(:);                                %weights of Gaussians for birth track
            tt_birth{tabbidx}.l= [k;tabbidx];                                              %track label
            if include_ah
                tt_birth{tabbidx}.ah= [];                                                  %track association history (empty at birth)
            end
        end
    else
        n_z = size(z,2);
        tt = glmb_update.tt;
        tt_idx = 1 : length(tt);
        ah = cellfun(@(x) x.ah,tt);
        rU = zeros(n_z,1);
        for i=1:n_z
            if ismember(i,ah)
                temp_tt_idx = tt_idx(i == ah);
                c_idx = cellfun(@(x) ~isempty(intersect(temp_tt_idx,x)),glmb_update.I);
                rU(i) = sum(glmb_update.w(c_idx));
            end
        end
        rB = min([abp.rB_max * ones(n_z,1),(1-rU).*abp.lambda_b./(sum(1-rU))],[],2);
        tt_birth = cell(n_z,1);
        rand_idx = randperm(n_z);
        for i = 1 : n_z
            tt_birth{i}.r= rB(i);                                                           %birth prob for birth track
            tt_birth{i}.m = [z(1,i);0;z(2,i);0];                                            %means of Gaussians for birth track
            tt_birth{i}.P= abp.P_birth;                                                     %covs of Gaussians for birth track
            tt_birth{i}.w= abp.w_birth;                                                     %weights of Gaussians for birth track
            tt_birth{i}.l= [k;rand_idx(i)+unique_multiplier];                               %track label
            if include_ah
                tt_birth{i}.ah= [];                                                         %track association history (empty at birth)
            end
        end

        % update birth from previous neighbor
        if isfield(abp_info,'z_neighbor') && ~isempty(abp_info.z_neighbor) && ~isempty(abp_info.l_neighbor)
            for j =  1 : size(abp_info.z_neighbor,2)
                i = i + 1;
                tt_birth{i}.r = abp.rB_max;                                                 % x times more
                tt_birth{i}.m = abp_info.z_neighbor(:,j);                                   %means of Gaussians for birth track
                tt_birth{i}.P = abp.P_birth;                                                %covs of Gaussians for birth track
                tt_birth{i}.w = abp.w_birth;                                                %weights of Gaussians for birth track
                tt_birth{i}.l = abp_info.l_neighbor(:,j);                                   %track label
                if include_ah
                    tt_birth{i}.ah= [];                                                     %track association history (empty at birth)
                end
            end
        end

    end
end