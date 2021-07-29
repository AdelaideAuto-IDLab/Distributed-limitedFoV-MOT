function [dist varargout]= wasserstein_dist(X,Y,c,p)

    % This is the MATLAB code for Wasserstein distance proposed in
    %
    % @ARTICLE{1288344,
    %   author={J. R. {Hoffman} and R. P. S. {Mahler}},
    %   journal={IEEE Transactions on Systems, Man, and Cybernetics - Part A: Systems and Humans}, 
    %   title={Multitarget miss distance via optimal assignment}, 
    %   year={2004},
    %   volume={34},
    %   number={3},
    %   pages={327-336},}
    %---

    % Compute Wasserstein distance between two finite sets X and Y
    % Inputs: X,Y-   matrices of column vectors
    %        p  -   p-parameter for the metric
    % Output: scalar distance between X and Y
    % Note: the Euclidean 2-norm is used as the "base" distance on the region

    if nargout ~=1 & nargout ~=3
    error('Incorrect number of outputs'); 
    end

    if isempty(X) & isempty(Y)
        dist = c;

        if nargout == 3
            varargout(1)= {0};
            varargout(2)= {0};
        end
        
        return;
    end

    if isempty(X) | isempty(Y)
        dist = c;

        if nargout == 3
            varargout(1)= {0};
            varargout(2)= {c};
        end
        
        return;
    end


    %Calculate sizes of the input point patterns
    nX = size(X,1);
    n = size(X,2);
    m = size(Y,2);
    G = gcd(m,n) ; 
    m_star = n/G ; 
    n_star = m/G ; 
    N_wass = m * m_star ; 

    X_star = repmat(X,1,n_star);%+rand(nX,N_wass)*eps;
    Y_star = repmat(Y,1,m_star);%+rand(nX,N_wass)*eps;



    %Calculate cost/weight matrix for pairings - fast method with vectorization
    XX= repmat(X_star,[1 N_wass]);
    YY= reshape(repmat(Y_star,[N_wass 1]),[size(Y,1) N_wass*N_wass]);
    D = reshape((sum((abs(XX-YY)).^p).^(1/p)),[N_wass N_wass]);
    D = D.^p;

    % %Calculate cost/weight matrix for pairings - slow method with for loop
    % D= zeros(n,m);
    % for j=1:m
    %     D(:,j)= sqrt(sum( ( repmat(Y(:,j),[1 n])- X ).^2 )');
    % end
    % D= min(c,D).^p;

    %Compute optimal assignment and cost using the Hungarian algorithm
    if sum(isnan(D(:))) == 0
        [~,cost]= Hungarian(D);
    else
    cost = c^p*N_wass; 
    end
    %Calculate final distance
    dist= (cost/N_wass) ^(1/p);
end

