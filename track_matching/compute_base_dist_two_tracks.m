function dist = compute_base_dist_two_tracks(X1,X2,ospa_c,ospa_q,varargin)
    % Compute the OSPA track-to-track distance, see equation (2)

     % --- Input Parser
    p = inputParser;
    addParameter(p,'metric_type','ospa_union');             %metric type, possible values: {'ospa_union','wasserstein'}
    addParameter(p,'time_idx',[]);
    parse(p, varargin{:});
    metric_type = p.Results.metric_type;
    time_idx = p.Results.time_idx;
    if strcmp(metric_type,'ospa_union')
        if any(isnan(X1(:,end))) || any(isnan(X2(:,end)))   %put higher cost if end of line is empty
            dist = ospa_c;
        else
            X1_exist = ~any(isnan(X1));
            X2_exist = ~any(isnan(X2));
            X12_exist = X1_exist | X2_exist;
            
            distance = sum(abs(X1 - X2).^ospa_q,1);
            distance(isnan(distance)) = ospa_c.^ospa_q;
            distance = distance(X12_exist);
            distance = min(distance,ospa_c^ospa_q);
            dist = mean(distance,'omitnan')^(1/ospa_q);
        end
    elseif strcmp(metric_type,'wasserstein')
        if ~isempty(time_idx)                               %include time 
            alpha = 20;                                     %constant velocity to include time index to ensure the same unit of meter
            X1 = [X1;alpha.*time_idx];
            X2 = [X2;alpha.*time_idx];
        end
        X1_exist = ~any(isnan(X1));
        X2_exist = ~any(isnan(X2));
        X1 = X1(:,X1_exist);
        X2 = X2(:,X2_exist);
        
        dist = wasserstein_dist(X1,X2,ospa_c*1e3,ospa_q);
    end
end
