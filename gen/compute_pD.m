function pD = compute_pD(model,X, fov_shape,varargin)
    % Compute detection probability based on FoV and the object's postion

    % --- Input Parser
    p = inputParser;
    addParameter(p,'pD_min',0);
    parse(p, varargin{:});
    pD_min = p.Results.pD_min;
    if isempty(X)
        pD= [];
    else
        
        P = X(model.pos_idx,:);
        IN = inpolygon(P(1,:), P(2,:), fov_shape.Vertices(:,1), fov_shape.Vertices(:,2));
        pD = model.P_D * IN;
        pD= pD(:);
        pD = max(pD,pD_min);
        
    end
end