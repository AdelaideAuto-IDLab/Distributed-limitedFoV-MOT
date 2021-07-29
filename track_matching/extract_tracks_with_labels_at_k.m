function [X_track_k,l_list_k]= extract_tracks_with_labels_at_k(est,cur_j,cur_k)
    try
        [X_track,l_list]= extract_tracks_with_labels(est,cur_j,cur_k);
        if isempty(l_list)
            X_track_k = X_track;
            l_list_k = l_list;
        else
            l_check = ismember(l_list',est.L{cur_k}','rows');

            X_track_k = X_track(:,:,l_check);
            l_list_k = l_list(:,l_check);
        end
    catch err
        error(['extract_tracks_with_labels_at_k: ',err.message]);
    end
end
