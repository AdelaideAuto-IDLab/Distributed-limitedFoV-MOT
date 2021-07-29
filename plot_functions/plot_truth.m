function [handler,colorarray] = plot_truth(source_info, model, truth)
    % Plot object ground truth with fov shapes of all sensors
    
    % --- Make code look nicer
    text_offset = model.text_offset;
    K = truth.K;
    LineWidth = 2;
    font_size = 14; 
    Transparency = 1;
    font_name = model.font_name;
    
    [X_track,k_birth,k_death]= extract_tracks(truth.X,truth.track_list,truth.total_tracks);
    if  exist('colorarray','var') == 0 || exist('colorarray','var') == 1 &&  isempty(colorarray)
        try
            colorarray = load('colorarray.mat'); colorarray = colorarray.colorarray;
        catch
            labelcount= countestlabels(truth)+1;
            colorarray= makecolorarray(labelcount);
        end
    end
    ntarget = truth.total_tracks;
    
    handler = figure();
    set(handler, 'Position', [1031,246,809,610]);
    axis square;
    hold on; 
    plot_fov(source_info,model.fov_range,model.rD_max);
    for i=1:ntarget
        k_b_temp = k_birth(i); k_b_temp = k_b_temp(k_b_temp<=K);  % update birth time
        k_d_temp = k_death(i); k_d_temp = min(k_d_temp,K);   % update death time
        life_temp = k_b_temp : k_d_temp;
        pos_temp = X_track([1 3],:,i);
        if K > k_d_temp, Transparency_temp = Transparency; else, Transparency_temp = 1; end
        if ~isempty(k_b_temp)
            try
            color_temp = colorarray.rgb(assigncolor(truth.L{k_birth(i)}(i)),:) ;
            catch err
                disp(err.message);
            end
            htruth{i} = plot(pos_temp(1,life_temp),pos_temp(2,life_temp),'LineWidth',LineWidth, 'LineStyle','-','Color' , color_temp);
            htruth{i}.Color(4) = Transparency_temp;
        end
    end
    for i=1:ntarget
        k_b_temp = k_birth(i); k_b_temp = k_b_temp(k_b_temp<=K);  % update birth time
        k_d_temp = k_death(i); k_d_temp = min(k_d_temp,K);   % update death time
        pos_temp = X_track([1 3],:,i);
        if K > k_d_temp, Transparency_temp = Transparency; else, Transparency_temp = 1; end
        try
            color_temp = colorarray.rgb(assigncolor(truth.L{k_birth(i)}(i)),:) ;
        catch err
            disp(err.message);
        end
        if ~isempty(k_b_temp)
            text(pos_temp(1,k_d_temp) ,pos_temp(2,k_d_temp) -text_offset, num2str(i),'FontSize',12, 'FontName', font_name);
            plot_temp = scatter(pos_temp(1,k_b_temp),pos_temp(2,k_b_temp),100, 'LineWidth',1,...
                'Marker' , 'o', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
            plot_temp.MarkerEdgeAlpha =  Transparency_temp; plot_temp.MarkerFaceAlpha =  Transparency_temp;
            if K >= k_death(i)
                plot_temp = scatter(pos_temp(1,k_d_temp),pos_temp(2,k_d_temp),100, 'LineWidth',1,...
                    'Marker' , 's', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
            end
            
            plot_temp.MarkerEdgeAlpha =  Transparency_temp; plot_temp.MarkerFaceAlpha =  Transparency_temp;
        end
    end
    
    for i = 1:length(source_info)
        plot(source_info{i}.source_pos(1),source_info{i}.source_pos(2),'pr','MarkerSize',20); hold on;
        text(source_info{i}.source_pos(1),source_info{i}.source_pos(2)+3*text_offset,['Node ',num2str(i)],...
            'FontName',model.font_name,'FontSize',model.font_size); 
        hold on;
    end
    
    xlabel('x-coordinate (m)', 'FontSize', font_size);
    ylabel('y-coordinate (m)', 'FontSize', font_size);
    set(gcf,'color','w');
    set(gca, 'FontSize', font_size, 'FontName', font_name);
    grid on;
    return;
    
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


