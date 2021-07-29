function settings =  gen_settings(varargin)
    % Generate a general setting for a particular scenario via a
    % variable-length input argument list, i.e., a pair of (property, value).
    % Example usage: settings =  gen_settings('case_id',1,'sel_pd',0.98);    

    % --- Input Parser
    p = inputParser;
    addParameter(p,'case_id', 1, @isscalar);                                                        %scenario id, possible values: [1,2,3]
    addParameter(p,'n_sensors',0, @isscalar);                                                       %number of sensors used in a particular scenario
    addParameter(p,'sel_pd', 0.98, @isscalar);                                                      %detection probability, any value within the interval of (0,1)
    addParameter(p,'save_data', false, @islogical);                                                 %save data flag, possible values: {'true', 'false'}
    parse(p, varargin{:});                                 
    settings.p.Results = p.Results;                                                                 %store input parameters
    
    if p.Results.save_data
        settings.folder_path = create_subfolder_by_timestamp('results');
        write_to_log(settings.folder_path,'%%%%%%%%%%----- Start program ------%%%%%%%%%%%%%%%%%\n','fopen_tag','a');
    end
    
    % --- Switching among 3 Scenarios in the paper
    switch p.Results.case_id
        case 1 % Scenario 1 
            
            settings.K = 80;                                                                        %search time
            settings.limit = [-500,1500;0,1000];                                                    %search area
            
            if p.Results.n_sensors > 0
                n_sensors = p.Results.n_sensors;                                                    %input number of sensors, max = 2 for this case
            else
                n_sensors = 2;                                                                      %default number of sensors
            end

            if p.Results.sel_pd > 0
                sel_pd = p.Results.sel_pd;                                                          %input detection probability
            else
                sel_pd = 0.98;                                                                      %default detection probability
            end

            init_source_pos = [200 0; 800 0]';                                                      %initial two sensor positions
            for i = 1 : n_sensors
                settings.source_info{i}.source_id = i;
                settings.source_info{i}.source_pos = init_source_pos(:,i);
            end
            
            settings.source_info{1}.P_D = sel_pd;                                                   %sensor  detection probability
            settings.source_info{1}.neighbor_id = 2;                                                %neighboring node id
            
            settings.source_info{2}.P_D = sel_pd;                                                   %sensor  detection probability
            settings.source_info{2}.neighbor_id = 1;                                                %neighboring node id
            
            settings.fov_angle = 60;                                                                %FoV angle (deg)
            settings.fov_center = 90;                                                               %FoV Center (deg) of [fov_center-fov_angle, fov_center + fov_angle]
            settings.rD_max = 800;                                                                  %maximum detection range (m)

            % object info
            settings.xstart(:,1)  = [ -200; 17 ; 600; 0 ];       settings.tbirth(1)  = 1;           settings.tdeath(1)  = 80;
            settings.xstart(:,2)  = [ 1200; -17 ; 400; 0 ];      settings.tbirth(2)  = 1;           settings.tdeath(2)  = 80;
            settings.xstart(:,3)  = [ 0; 20 ; 200; 10 ];         settings.tbirth(3)  = 10;          settings.tdeath(3)  = 60;
            settings.sigma_v_truth = 0.1;                                                           %small processing noise in generating ground truth
            
            % track matching
            settings.winlen_lm = 5;                                                                 %window length to use for track matching
        
        case 2 % Scenario 2 
            
            settings.K = 80;                                                                        %search time
            settings.limit = [-500,1800;-100,1000];                                                 %search area
            
            if p.Results.n_sensors > 0
                n_sensors = p.Results.n_sensors;                                                    %input number of sensors, max = 2 for this case
            else
                n_sensors = 2;                                                                      %default number of sensors
            end
            
            if p.Results.sel_pd > 0
                sel_pd = p.Results.sel_pd;                                                          %input detection probability
            else
                sel_pd = 0.98;                                                                      %default detection probability
            end
            
            init_source_pos = [300 -100; 1000 -100]';                                               %positions of two sensors
            for i = 1 : n_sensors
                settings.source_info{i}.source_id = i;
                settings.source_info{i}.source_pos = init_source_pos(:,i);
                
            end
            
            settings.source_info{1}.P_D = sel_pd;                                                   %sensor  detection probability
            settings.source_info{1}.neighbor_id = 2;                                                %neighboring node id
            
            
            settings.source_info{2}.P_D = sel_pd;                                                   %sensor  detection probability
            settings.source_info{2}.neighbor_id = 1;                                                %neighboring node id
            
            settings.fov_angle = 50;                                                                %FoV angle (deg)
            settings.fov_center = 90;                                                               %FoV Center (deg) of [fov_center-fov_angle, fov_center + fov_angle]
            settings.rD_max = 1000;                                                                 %maximum detection range (m)
            
            
            
            % object info
            settings.xstart(:,1)  = [ 1e3; -12; 400; 2.5 ];      settings.tbirth(1)  = 1;           settings.tdeath(1)  = 80;
            settings.xstart(:,2)  = [ 1400; -4; 600; -2.5 ];     settings.tbirth(2)  = 1;           settings.tdeath(2)  = 80;
            settings.xstart(:,3)  = [ 1400; -4; 500; -2.5 ];     settings.tbirth(3)  = 1;           settings.tdeath(3)  = 80;
            settings.xstart(:,4)  = [ 1150; -4; 400; -2.5 ];     settings.tbirth(4)  = 1;           settings.tdeath(4)  = 80;
            settings.xstart(:,5)  = [ 500; -6; 100; 12];         settings.tbirth(5)  = 10;          settings.tdeath(5)  = 60;
            settings.xstart(:,6)  = [ 1100; 5; 800; -4];         settings.tbirth(6)  = 10;          settings.tdeath(6)  = 80;
            settings.xstart(:,7)  = [ 200; -5; 800; -4];         settings.tbirth(7)  = 10;          settings.tdeath(7)  = 80;
            settings.xstart(:,8)  = [ 50; 0; 700; -4];           settings.tbirth(8)  = 10;          settings.tdeath(8)  = 80;
            settings.xstart(:,9)  = [ 1e3; -9; 200; 9 ];         settings.tbirth(9)  = 10;          settings.tdeath(9)  = 60;
            settings.xstart(:,10)  = [ 1e3; -9; 100; 9 ];        settings.tbirth(10)  = 10;         settings.tdeath(10)  = 60;
            settings.xstart(:,11)  = [ 1250; -14; 800; -7 ];     settings.tbirth(11)  = 20;         settings.tdeath(11)  = 60;
            settings.xstart(:,12)  = [ 1250; -14; 600; -7 ];     settings.tbirth(12)  = 20;         settings.tdeath(12)  = 60;
            settings.xstart(:,13)  = [ 1e3; -12; 600; -7];       settings.tbirth(13)  = 20;         settings.tdeath(13)  = 60;
            settings.xstart(:,14)  = [ 1.1e3; -12; 600; -7];     settings.tbirth(14)  = 20;         settings.tdeath(14)  = 60;
            settings.xstart(:,15)  = [ 250; 6; 200; 11];         settings.tbirth(15)  = 20;         settings.tdeath(15)  = 60;
            settings.xstart(:,16)  = [ 100; 6; 200; 11];         settings.tbirth(16)  = 20;         settings.tdeath(16)  = 60;
            settings.xstart(:,17)  = [ 1250; -16; 300; 0 ];      settings.tbirth(17)  = 30;         settings.tdeath(17)  = 60;
            settings.xstart(:,18)  = [ 1250; -16; 200; 0 ];      settings.tbirth(18)  = 30;         settings.tdeath(18)  = 60;
            settings.xstart(:,19) = [ -150; 30; 500; 0 ];        settings.tbirth(19) = 30;          settings.tdeath(19) = 80;
            settings.xstart(:,20) = [ 1500; -30; 400; 0 ];       settings.tbirth(20) = 30;          settings.tdeath(20) = 80;
            settings.xstart(:,21) = [ 400; 12; 600; 3 ];         settings.tbirth(21) = 40;          settings.tdeath(21) = 80;
            settings.xstart(:,22) = [ 300; 12; 600; 3 ];         settings.tbirth(22) = 40;          settings.tdeath(22) = 80;
            settings.sigma_v_truth = 0.2;                                                           %small processing noise in generating ground truth
            
            % track matching
            settings.winlen_lm = 5;                                                                 %window length to use for track matching
        
        case 3 % Scenario 3 
            
            settings.K = 75;                                                                        %search time
            settings.limit = [-1000,1000;-1000,1000];                                               %search area
            
            if p.Results.n_sensors > 0
                n_sensors = p.Results.n_sensors;                                                    %input number of sensors, max = 16 for this case
            else
                n_sensors = 16;                                                                     %default number of sensors
            end
            
            if p.Results.sel_pd > 0
                sel_pd = p.Results.sel_pd;                                                          %input detection probability
            else
                sel_pd = 0.98;                                                                      %default detection probability
            end
            
            init_source_pos = [-600 -800; -200 -800; 200 -800; 600 -800;-600 800; -200 800;200 800;600 800;-800 -600;...
                                -800 -200; -800 200;-800 600; 800 -600;800 -200; 800 200; 800 600]'; %initial 16 sensor positions
            
            neighbor_list = 1 : n_sensors;
            for i = 1 : n_sensors
                settings.source_info{i}.source_id = i;
                settings.source_info{i}.source_pos = init_source_pos(:,i);
                settings.source_info{i}.P_D = sel_pd;
                settings.source_info{i}.neighbor_id = neighbor_list(neighbor_list ~= i);
            end
            
            settings.fov_angle = 25;                                                                %FoV angle (deg)
            settings.fov_center = [90,90,90,90,-90,-90,-90,-90,0,0,0,0,180,180,180,180]';           %FoV Center (deg) of [fov_center-fov_angle, fov_center + fov_angle]
            settings.rD_max = 1000;                                                                 %maximum detection range (m)

            
            % object birth info
            settings.xstart(:,1)  = [ 0; -8-1/3; 500; -10 ];        settings.tbirth(1)  = 1;        settings.tdeath(1)  = 61;
            settings.xstart(:,2)  = [ 100; -8-1/3; 500; -6 ];       settings.tbirth(2)  = 1;        settings.tdeath(2)  = 61;
            settings.xstart(:,3)  = [ 500; -12.5; -100; -2.5];      settings.tbirth(3)  = 1;        settings.tdeath(3)  = 61;
            settings.xstart(:,4)  = [ 400; -12.5; 100; -8];         settings.tbirth(4)  = 1;        settings.tdeath(4)  = 61;
            settings.xstart(:,5)  = [ 500; -14; 700; 0 ];           settings.tbirth(5)  = 15;       settings.tdeath(5)  = 61;
            settings.xstart(:,6)  = [ -400; 10; 500; 7-1/3 ];       settings.tbirth(6)  = 15;       settings.tdeath(6)  = 61;
            settings.xstart(:,7)  = [ 100; 12+2/9; 500; -4-4/9];    settings.tbirth(7)  = 15;       settings.tdeath(7)  = 61;
            settings.xstart(:,8)  = [ 100; 10; 50; 3];              settings.tbirth(8)  = 15;       settings.tdeath(8)  = 61;
            settings.xstart(:,9) = [ 500; 5; -500; 12 ];            settings.tbirth(9) = 30;        settings.tdeath(9) = 75;
            settings.xstart(:,10) = [ -700; 5; 0; -12 ];            settings.tbirth(10) = 30;       settings.tdeath(10) = 75;
            settings.xstart(:,11) = [ -800; 15; 600; -2 ];          settings.tbirth(11) = 30;       settings.tdeath(11) = 75;
            settings.xstart(:,12) = [ 800; -15; 600; 1 ];           settings.tbirth(12) = 30;       settings.tdeath(12) = 75;
            settings.xstart(:,13)  = [ 500; -10; 100; -10 ];        settings.tbirth(13)  = 45;      settings.tdeath(13)  = 75;
            settings.xstart(:,14) = [ 800; -10; 100; -8 ];          settings.tbirth(14) = 45;       settings.tdeath(14) = 75;
            settings.xstart(:,15) = [ 800; -12; 100; 8 ];           settings.tbirth(15) = 45;       settings.tdeath(15) = 75;
            settings.xstart(:,16) = [ -700; 7; 0; 12 ];             settings.tbirth(16) = 45;       settings.tdeath(16) = 75;
            settings.xstart(:,17) = [ 600; -15; -450; -5 ];         settings.tbirth(17) = 45;       settings.tdeath(17) = 75;
            settings.xstart(:,18) = [ -600; 15; -500; -5 ];         settings.tbirth(18) = 45;       settings.tdeath(18) = 75;
            settings.sigma_v_truth = 0.2;                                                           %small processing noise in generating ground truth
            
            % track matching
            settings.winlen_lm = 10;                                                                %window length to use for track matching
        
        otherwise
            error('this scenario setting is not exist');
    end

    % birth info: birth parameters (LMB birth model, single component only) --- 
    % when adaptive birth not used (i.e., at k = 1 when no measurements available yet)
    settings.T_birth = 2;                                                                           %no. of LMB birth terms
    settings.L_birth = zeros(settings.T_birth,1);                                                   %no of Gaussians in each LMB birth term
    settings.r_birth = zeros(settings.T_birth,1);                                                   %prob of birth for each LMB birth term
    settings.w_birth = cell(settings.T_birth,1);                                                    %weights of GM for each LMB birth term
    settings.m_birth = cell(settings.T_birth,1);                                                    %means of GM for each LMB birth term
    settings.B_birth = cell(settings.T_birth,1);                                                    %std of GM for each LMB birth term
    settings.P_birth = cell(settings.T_birth,1);                                                    %cov of GM for each LMB birth term
    settings.Bb_birth = diag([ 30; 20; 30; 20 ]);                                                   %std of Gaussians diag([ 30; 20; 30; 20 ]);
    settings.Pb_birth = settings.Bb_birth * settings.Bb_birth';                                     %std of Gaussians
    settings.rb_birth = 0.04;                                                                       %prob of birth

    settings.L_birth(1) = 1;                                                                        %no of Gaussians in birth term 1
    settings.r_birth(1) = settings.rb_birth;                                                        %prob of birth
    settings.w_birth{1}(1,1)= 1;                                                                    %weight of Gaussians - must be column_vector
    settings.m_birth{1}(:,1)= [0;0;0;0];                                                            %mean of Gaussians
    settings.B_birth{1}(:,:,1)= settings.Bb_birth;                                                  %std of Gaussians
    settings.P_birth{1}(:,:,1)= settings.Pb_birth;                                                  %cov of Gaussians

    settings.L_birth(2)= 1;                                                                         %no of Gaussians in birth term 2
    settings.r_birth(2)= settings.rb_birth;                                                         %prob of birth
    settings.w_birth{2}(1,1)= 1;                                                                    %weight of Gaussians - must be column_vector
    settings.m_birth{2}(:,1)= [100;0;100;0];                                                        %mean of Gaussians
    settings.B_birth{2}(:,:,1)= settings.Bb_birth;                                                  %std of Gaussians
    settings.P_birth{2}(:,:,1)= settings.Pb_birth;                                                  %cov of Gaussians
    
    % adaptive birth procedure
    settings.abp.enable = true; 
    settings.abp.lambda_b = 0.5;                                                                    %expected number of births at each time
    settings.abp.rB_max = 0.03;                                                                     %maximum existence probability of a newly born object
    settings.abp.w_birth = 1;                                                                       %weight of Gaussians
    settings.abp.P_birth = settings.Pb_birth;                                                       %birth covariance     
    
end
