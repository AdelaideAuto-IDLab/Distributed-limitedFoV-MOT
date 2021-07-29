function model = update_model_info(model,source_info)
    model.P_D = source_info.P_D;
    model.Q_D = 1 - model.P_D;
end