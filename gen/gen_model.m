function model= gen_model(settings,varargin)
    % Generate a model containing system dynamic and measurement parameters for a particular scenario via a
    % variable-length input argument list, i.e., a pair of (property, value).
    % Example usage: model = gen_model(settings,'meas_sigma',10,'lambda_c',10,'track_threshold',0.001,'metric_type','ospa_union');   


    % --- Input Parser
    p = inputParser;
    addParameter(p,'lambda_c',10);                                                                  %measurement clutter rate
    addParameter(p,'meas_sigma',10);                                                                %measurement noise
    addParameter(p,'track_threshold',1e-4);                                                         %track threshold
    addParameter(p,'metric_type','ospa_union');                                                     %metric type, possible values: {'ospa_union','wasserstein'}
    parse(p, varargin{:});
    model.p.Results = p.Results;                                                                    %store input variable values
    
    % --- make code look nicer
    lambda_c = p.Results.lambda_c;    
    track_threshold = p.Results.track_threshold;
    meas_sigma = p.Results.meas_sigma;
    metric_type = p.Results.metric_type;
    
    winlen_lm = settings.winlen_lm;
    rD_max = settings.rD_max;
    fov_angle = settings.fov_angle;

    
    % --- initialisation
    if settings.p.Results.save_data
        model.folder_path = settings.folder_path;
    end
    model.limit = settings.limit;
    model.abp = settings.abp;
    model.T_birth = settings.T_birth; 
    model.L_birth = settings.L_birth;                                                               %no of Gaussians in birth term 1
    model.r_birth = settings.r_birth;                                                               %prob of birth
    model.w_birth = settings.w_birth;                                                               %weight of Gaussians - must be column_vector
    model.m_birth = settings.m_birth;                                                               %mean of Gaussians
    model.B_birth = settings.B_birth;                                                               %std of Gaussians
    model.P_birth = settings.P_birth;                                                               %cov of Gaussians
                            
    % --- basic parameters                      
    model.K = settings.K;                                                                           %number of time steps
    model.x_dim= 4;                                                                                 %dimension of state vector
    model.z_dim= 2;                                                                                 %dimension of observation vector
    model.pos_idx = [1,3];

    % --- dynamical model parameters (CV model)
    model.T= 1;                                                                                     %sampling period
    model.A0= [ 1 model.T; 0 1 ];                                                                   %transition matrix                     
    model.F= [ model.A0 zeros(2,2); zeros(2,2) model.A0 ];                      
    model.B0= [ (model.T^2)/2; model.T ];                       
    model.B= [ model.B0 zeros(2,1); zeros(2,1) model.B0 ];                      
    model.sigma_v = 5;                                                                              %process noise
    model.Q= (model.sigma_v)^2* model.B*model.B';                                                   %process noise covariance
    model.sigma_v_truth = settings.sigma_v_truth;                                                   %small processing noise in generating ground truth

    % --- survival/death parameters
    model.P_S= 0.95;
    model.Q_S= 1-model.P_S;    
    

    % --- observation model parameters (noisy x/y only)
    model.H = [ 1 0 0 0 ; 0 0 1 0 ];                                                                %observation matrix
    model.D = meas_sigma * diag([ 1; 1 ]);                                                          %observation noise
    model.R = model.D*model.D';                                                                     %observation noise covariance



    % --- plot parameters                       
    model.font_size = 12;                       
    model.font_name = 'Times New Roman';                        
    model.line_width = 1;                       
    model.marker_size = 2;                      
    model.text_offset = 20;                     

    % --- OSPA                      
    model.ospa.c = 100;                                                                             %OSPA cut-off value 
    model.ospa.p = 1;                                                                               %OSPA order (integer) value
    model.ospa.q = 1;                                                                               %OSPA2 order (integer) value
    model.ospa.win_len = 10;                                                                        %window length of computing OSPA2 for reporting performance
    model.ospa.c_lm = model.ospa.c;                                    
    model.ospa.winlen_lm = winlen_lm;                                                               %window length of computing OSPA2 for label matching
    min_track_len = floor((winlen_lm-1)/2);                
    model.ospa.min_track_len = min_track_len;                                                       %minimum track length (C_len in Algorithm 1)
    model.ospa.min_lmb_len = min_track_len;                                        
    model.ospa.r_min = 1e-3;                                                                        %extract lmb hist for r >= r_min
    model.ospa.matched_label_only = true;                                      
    model.ospa.use_consecutive_len = false;                                        
    model.ospa.unique_multiplier = 1e5;                                                             %a multiplier to ensure unique id among agents.
    model.ospa.F = model.F;                                                                         %for predicting target into future for track matching
    model.ospa.metric_type = metric_type; 
    
    
    % --- setup filter parameters
    model.filter.H_bth= 5;                                                                          %requested number of birth components/hypotheses (for LMB to GLMB casting before update)
    model.filter.H_sur= 1000;                                                                       %requested number of surviving components/hypotheses (for LMB to GLMB casting before update)
    model.filter.T_max= 100;                                                                        %maximum number of tracks          
    model.filter.track_threshold = track_threshold;                                                 %track threshold, only keep labelled tracks higher than track_threshold                                        
    model.filter.H_upd= 1000;                                                                       %requested number of updated components/hypotheses (for GLMB update)
    model.filter.L_max= 5;                                                                          %limit on number of Gaussians in each track
    model.filter.elim_threshold= 1e-5;                                                              %pruning threshold for Gaussians in each track
    model.filter.merge_threshold= 4;                                                                %merging threshold for Gaussians in each track
    model.filter.P_G= 0.9999999;                                                                    %gate size in percentage
    model.filter.gamma= chi2inv(model.filter.P_G,model.z_dim);                                      %inv chi^2 dn gamma value
    model.filter.gate_flag= 1;                                                                      %gating on or off 1/0
    model.filter.run_flag= 'disp';                                                                  %'disp' or 'silence' for on the fly output
    model.filter.gamma_threshold = 4;                                                               %gamma threshold for measurement gating
    
    % --- detection parameters
    model.P_D= settings.source_info{1}.P_D;                                                         %source detection probability
    model.pD_min = 0.2;                                                                             %minimum detection probability
    model.rD_max = rD_max;                                                                          %maximum detection range
    model.search_shape = polyshape([ model.limit(1,:), flip(model.limit(1,:))],[model.limit(2,1) * ones(1,2),model.limit(2,2) * ones(1,2)]);
    model.fov_range = [settings.fov_center - fov_angle,settings.fov_center + fov_angle];            %field of view (fov) interval
    model.fov_shape = gen_fov_shape(settings.source_info,model.fov_range,model.rD_max);             %initialise fov
    for s = 1: length(model.fov_shape)
        model.fov_shape{s} = intersect(model.fov_shape{s},model.search_shape);                      %fov inside search are
    end
    
    % --- clutter parameters
    model.lambda_c = lambda_c;                                                                      %poisson average rate of uniform clutter (per scan)
    model.range_c = model.limit;                                                                    %uniform clutter region    
    model.pdf_c = 1/max(cellfun(@(x) area(intersect(x,model.search_shape)),model.fov_shape));       %clutter density
    
    % --- save data
    No_Yes_Vect = {'no','yes'};
    file_name = cell2mat(['Fused_case_',num2str(settings.p.Results.case_id),...
                          '_ns_',num2str(length(settings.source_info)),...
                          '_pD_',num2str(settings.source_info{1}.P_D),...
                          '_useabp_',No_Yes_Vect(settings.abp.enable+1),...
                          '_winlm_',num2str(winlen_lm),'_ldc_',num2str(lambda_c),...
                          '_tracThr_',num2str(track_threshold),...
                          '_fov_',num2str(fov_angle),...
                          '_metric_',model.ospa.metric_type,...
                          '_rD_',num2str(model.rD_max),'.mat']);
    model.file_name = file_name;
    fprintf('File Name: %s\n',model.file_name);
    
end