function meas= gen_meas(model,truth,source_info,fov_shape)
    % Generate measurements for a single sensor (node)

    %variables
    meas.K = truth.K;
    meas.Z = cell(truth.K,1);
    meas.base = cell(truth.K,1);
    meas.fov_shape = cell(truth.K,1);
    meas.source_id = source_info.source_id;
    %generate measurements
    for k=1:truth.K
        if truth.N(k) > 0
            pD = compute_pD(model, truth.X{k},fov_shape);
            idx= rand(truth.N(k),1) <= pD ;                                            %detected target indices
            meas.Z{k}= gen_observation_fn(model,truth.X{k}(:,idx),'noise');                          %single target observations if detected 
        end
        N_c = poissrnd(model.lambda_c);                                                               %number of clutter points
        
        % using rejection sampling method to generate clutters inside the FoV
        C = repmat(model.range_c(:,1),[1 10*N_c])+ diag(model.range_c*[ -1; 1 ])*rand(model.z_dim,10*N_c);  %clutter generation
        IN = inpolygon(C(1,:), C(2,:), fov_shape.Vertices(:,1), fov_shape.Vertices(:,2));
        C = C(:,IN);
        idx = randperm(size(C,2));
        C = C(:,idx(1:min(size(C,2),N_c)));
        meas.Z{k} = [ meas.Z{k} C ];                                                                  %measurement is union of detections and clutter
        meas.base{k} = source_info.source_pos; 
        meas.fov_shape{k} = fov_shape;
    end
end
    