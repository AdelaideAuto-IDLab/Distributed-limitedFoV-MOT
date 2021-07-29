function len =  consecutive_max_track_len(X_track,varargin)
     % --- Input Parser
    parser = inputParser;
    addParameter(parser,'count_all',false);
    parse(parser, varargin{:});
    count_all = parser.Results.count_all;
    if count_all
        len = sum(any(~isnan(X_track)));
    else
        if length(size(X_track)) == 3
            n = size(X_track,3);
            len = zeros(n,1);
            for i = 1 : n
                temp = X_track(:,:,i);
                D = diff([false,all(~isnan(temp)),false]);
                L = find(D<0)-find(D>0); % length
                len(i) = max(L,[],2);
            end
        else
            D = diff([false,all(~isnan(X_track)),false ]);
            L = find(D<0)-find(D>0); % length
            len = max(L);
        end
    end
end