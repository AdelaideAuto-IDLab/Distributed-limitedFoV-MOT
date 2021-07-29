function plot_fov(source_info,fov_range,rD_max)
    % Plot field of view of a single sensor (node) based on its field of view range and its detection range

    n_s = length(source_info);
    if size(fov_range,1) == 1
        a1 = deg2rad(fov_range(1));
        a2 = deg2rad(fov_range(2));
        t = linspace(a1,a2);
        for s = 1 : n_s
            x0 = source_info{s}.source_pos(1);
            y0 = source_info{s}.source_pos(2);
            x = x0 + rD_max*cos(t);
            y = y0 + rD_max*sin(t);
            plot([x0,x,x0],[y0,y,y0],'k--','LineWidth',0.5); hold on;
            axis equal;
        end
    else
        for s = 1 : n_s
            a1 = deg2rad(fov_range(s,1));
            a2 = deg2rad(fov_range(s,2));
            t = linspace(a1,a2);
            x0 = source_info{s}.source_pos(1);
            y0 = source_info{s}.source_pos(2);
            x = x0 + rD_max*cos(t);
            y = y0 + rD_max*sin(t);
            plot([x0,x,x0],[y0,y,y0],'k--','LineWidth',0.5); hold on;
            axis equal;
        end
    end
end