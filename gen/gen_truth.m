function truth= gen_truth(model,settings)
    % Generate ground truth based on model and settings values
    
    % --- Initialise truth variables
    truth.K = model.K;                   %length of data/number of scans
    truth.X = cell(truth.K,1);             %ground truth for states of targets
    truth.N = zeros(truth.K,1);            %ground truth for number of targets
    truth.L = cell(truth.K,1);             %ground truth for labels of targets (k,i)
    truth.track_list = cell(truth.K,1);    %absolute index target identities (plotting)
    truth.total_tracks = 0;          %total number of appearing tracks
    
    % --- Target initial states and birth/death times
    xstart = settings.xstart;
    tbirth = settings.tbirth;
    tdeath = settings.tdeath;
    nbirths = size(xstart,2);
    
    % --- Generate the true tracks
    for targetnum=1:nbirths
        targetstate = xstart(:,targetnum);
        for k=tbirth(targetnum):min(tdeath(targetnum),truth.K)
            targetstate = gen_newstate_fn(model,targetstate,'smallnoise'); %noiseless / smallnoise /  noise
            truth.X{k}= [truth.X{k} targetstate];
            truth.track_list{k} = [truth.track_list{k} targetnum];
            truth.N(k) = truth.N(k) + 1;
        end
    end
    truth.total_tracks= nbirths;
    truth.L = truth.track_list;
end