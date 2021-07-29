function [est,filter,tt_lmb_update] = setup_filter(model,meas)
    %=== Setup
    filter = model.filter;
    %output variables
    est.X= cell(meas.K,1);
    est.N= zeros(meas.K,1);
    est.L= cell(meas.K,1);
    
    est.filter= filter;
    
    %=== Filtering
    
    %initial prior
    tt_lmb_update= cell(0,1);      %track table for LMB (cell array of structs for individual tracks)
end