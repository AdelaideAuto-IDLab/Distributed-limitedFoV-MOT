function meas = gen_all_meas(settings,model,truth)
    % Generate measurements of all sensors for all objects over time 
    n_s = length(settings.source_info);
    meas = cell(n_s,1);
    for s = 1 : n_s
        model = update_model_info(model,settings.source_info{s});
        meas{s} = gen_meas(model,truth,settings.source_info{s},model.fov_shape{s});
    end
end