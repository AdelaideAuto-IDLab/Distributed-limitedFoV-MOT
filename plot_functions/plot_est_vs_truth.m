function plot_est_vs_truth(model, settings, truth, fused_agents,varargin)
    % Plot estimates versus ground truth using OSPA2 to match the colors of estimates to colors of ground truth
    % via model, settings, truth, fused_agents and a variable-length input argument list, i.e., a pair of (property, value).

    % ---Input Parser
    p = inputParser;
    % Setup parsing schema
    addParameter(p,'K', truth.K, @isnumeric);
    addParameter(p,'Transparency', 1, @isnumeric);
    addParameter(p,'sel_agent', 1, @isnumeric);
    addParameter(p,'colorarray',[]);
    parse(p, varargin{:});
    
    % --- Make code look nicer
    Transparency = p.Results.Transparency;
    sel_agent = p.Results.sel_agent;
    colorarray = p.Results.colorarray;
    if isempty(colorarray)
       colorarray= makecolorarray(labelcount); 
    end
    LineWidth = 1;
    text_offset = 50;
    font_name = model.font_name;
    font_size = 14;
    source_info = settings.source_info;
    K = p.Results.K;
    est = fused_agents{sel_agent}.est;
    fused_strategy = fused_agents{sel_agent}.fused_strategy;
    
    % --- plot truth
    color_list = color_vector(10000)';
    [X_track,k_birth,k_death]= extract_tracks(truth.X,truth.track_list,truth.total_tracks);
    ntarget = truth.total_tracks;
    for i = 1 : ntarget                                                                         % assign truth label id first
       assigncolor(truth.L{k_birth(i)}(i)) ;
    end
    figure();
    hold on; 
    plot_fov(source_info,model.fov_range,model.rD_max);
    
    
    htruth = cell(ntarget,1);
    for i=1:ntarget
        k_b_temp = k_birth(i); k_b_temp = k_b_temp(k_b_temp<=K);                                % update birth time
        k_d_temp = k_death(i); k_d_temp = min(k_d_temp,K);                                      % update death time
        life_temp = k_b_temp : k_d_temp;
        pos_temp = X_track(model.pos_idx,:,i);
        cur_color = 'k';
        Transparency_temp = Transparency;                                                       % to make the whole truth blure
        if ~isempty(k_b_temp)
            htruth{i} = plot(pos_temp(1,life_temp),pos_temp(2,life_temp),'LineWidth',LineWidth, 'LineStyle','-','Color' , cur_color);
            htruth{i}.Color(4) = Transparency_temp;
            plot_temp = scatter(pos_temp(1,k_b_temp),pos_temp(2,k_b_temp),100, 'LineWidth',1,...
                'Marker' , 'o', 'MarkerFaceColor', cur_color, 'MarkerEdgeColor', 'black');
            plot_temp.MarkerEdgeAlpha =  Transparency_temp; plot_temp.MarkerFaceAlpha =  Transparency_temp;
            if K >= k_death(i)
                plot_temp = scatter(pos_temp(1,k_d_temp),pos_temp(2,k_d_temp),100, 'LineWidth',1,...
                    'Marker' , 's', 'MarkerFaceColor', cur_color, 'MarkerEdgeColor', 'black');
            end
            plot_temp.MarkerEdgeAlpha =  Transparency_temp; plot_temp.MarkerFaceAlpha =  Transparency_temp;
        end
    end
    

    % --- Plot source info
    for i = 1:length(source_info)
        plot(source_info{i}.source_pos(1),source_info{i}.source_pos(2),'pr','MarkerSize',10); hold on;
        text(source_info{i}.source_pos(1),source_info{i}.source_pos(2)+3*text_offset,['Node ',num2str(i)],...
            'FontName',model.font_name,'FontSize',model.font_size); 
        hold on;
    end
    
    % --- plot est
    [Y_track,l_list,ke_birth,ke_death]= extract_tracks_with_labels(est,1,K);
    n_est = size(l_list,2);

    % For color matching between truth and est
    [~,allcostm]=compute_ospa2(X_track([1 3],:,:),Y_track([1 3],:,:),model.ospa.c,model.ospa.p,K);
    if size(allcostm,2) ~= n_est
        allcostm = allcostm';
    end
    % --- List of matched and unmatched tracks
    Matching = Hungarian(allcostm);
    cost_check = allcostm < model.ospa.c;
    Matching = Matching .* cost_check;
    
    l1_idx = (1 : ntarget)';
    l2_idx = (1 : n_est)';
    L1_idx =  Matching * l2_idx;
    Q = [l1_idx,L1_idx];
    Q_check = prod(Q>0,2)>0;
    Q = Q(Q_check,:); % List of all matched track
    
    
    hest = cell(n_est,1);
    for i = 1 : n_est
        pos_temp = Y_track(model.pos_idx,:,i);
        k_b_temp = ke_birth(i); k_b_temp = k_b_temp(k_b_temp<=K);                                   % update birth time
        k_d_temp = ke_death(i); k_d_temp = min(k_d_temp,K);                                         % update death time
        life_temp = k_b_temp : k_d_temp;
        
        if ismember(i,Q(:,2))
            truth_idx = Q(i == Q(:,2),1);
            cur_color = colorarray.rgb(assigncolor(truth.L{k_birth(truth_idx)}(truth_idx)),:)' ;
        else
            cur_color =  color_list(:,i+n_est);
        end
        if K > k_d_temp, Transparency_temp = Transparency; else, Transparency_temp = 1; end
        if ~isempty(k_b_temp)
            hest{i} = plot(pos_temp(1,life_temp),pos_temp(2,life_temp), '.','Color', cur_color, 'LineWidth',2,'MarkerSize',15); hold on;
            hest{i}.Color(4) = Transparency_temp;
        end
    end
    
    % --- Format plot
    title(['Estimated vs Truth using ', fused_strategy, ' at Node ', num2str(sel_agent)]);
    xlabel('x-coordinate (m)', 'FontSize', font_size);
    ylabel('y-coordinate (m)', 'FontSize', font_size);
    xlim(model.limit(1,:));
    ylim(model.limit(2,:) );     
    set(gcf,'color','w');
    set(gca, 'FontSize', font_size, 'FontName', font_name);
    grid on;
    function idx= assigncolor(label)
        str= sprintf('%i*',label);
        tmp= strcmp(str,colorarray.lab);
        if any(tmp)
            idx= find(tmp);
        else
            colorarray.cnt= colorarray.cnt + 1;
            colorarray.lab{colorarray.cnt}= str;
            idx= colorarray.cnt;
        end
    end
end