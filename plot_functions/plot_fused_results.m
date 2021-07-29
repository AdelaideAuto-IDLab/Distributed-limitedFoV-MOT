function [h_ospa,h_ospa2,h_card,h_proc] =  plot_fused_results(model,truth,fused_agents,varargin)
    % Plot performance in terms of OSPA, OSPA2, Cardinality and fusing
    % time via model, truth, fused_agents, and a variable-length input argument list, i.e., a pair of (property, value).
    
    % --- Input Parser
    p = inputParser;
    addParameter(p,'sel_agent', 1, @isnumeric);
    parse(p, varargin{:});
    s = p.Results.sel_agent;
    % --- main plot program
    ospa_c= model.ospa.c;
    font_size = 14;
    font_name = 'Times New Roman';
    line_width = 1;
    MarkerSize = 5;
    marker_list = {'o','x','+','s','^','>'};
    line_style = {'-','--'};
    
    idx_marker = 1;
    idx_line = 1;
    % --- OSPA Dist
    h_ospa = figure();
    set(gcf,'color','w','Position',[652,553,560,331]);
    legend_names = {};
    plot(1:model.K,fused_agents{s}.ospa(1,:),'LineStyle',line_style{idx_line},'LineWidth',line_width,'Marker',marker_list{idx_marker},'MarkerSize',MarkerSize); hold on; % single agent
    legend_names = [legend_names, {fused_agents{s}.fused_strategy}];
    
    title('OSPA');
    legend(legend_names,'Location','best');
    ylabel('OSPA Dist (m)');
    xlabel('Time Step');
    grid on;
    set(gca, 'XLim',[1 model.K],'YLim',[0 ospa_c],'FontSize', font_size,'XGrid','off','YGrid','on', 'FontName', font_name);
    
    % --- OSPA2 Dist
    h_ospa2 = figure();
    set(gcf,'color','w','Position',[672,73,560,354]);
    legend_names = {};
    plot(1:model.K,fused_agents{s}.ospa2(1,:),'LineStyle',line_style{idx_line},'LineWidth',line_width,'Marker',marker_list{idx_marker},'MarkerSize',MarkerSize); hold on; % single agent
    legend_names = [legend_names, {fused_agents{s}.fused_strategy}];
    title('OSPA_2');
    legend(legend_names,'Location','best');
    ylabel('OSPA_2 Dist (m)');
    xlabel('Time Step');
    grid on;
    set(gca, 'XLim',[1 model.K],'YLim',[0 ospa_c],'FontSize', font_size,'XGrid','off','YGrid','on', 'FontName', font_name);
    
    % --- Cardinality
    h_card = figure();
    set(gcf,'color','w','Position',[1236,49,560,372]);
    legend_names = {};
    plot(1:model.K,truth.N,'k-','LineWidth',line_width); hold on;
    legend_names = {'Truth'};
    plot(1:model.K,fused_agents{s}.est.N,'LineStyle',line_style{idx_line},'LineWidth',line_width,'Marker',marker_list{idx_marker},'MarkerSize',MarkerSize); hold on; % single agent
    legend_names = [legend_names, {fused_agents{s}.fused_strategy}];
    title('Cardinality');
    legend(legend_names,'Location','best');
    ylabel('Cardinality');
    xlabel('Time Step');
    grid on;
    set(gca, 'XLim',[1 model.K],'FontSize', font_size,'XGrid','off','YGrid','on', 'FontName', font_name);
    
    % --- Fused time
    h_proc = figure();
    set(gcf,'color','w','Position',[1228,563,560,324]);
    legend_names = {};
    plot(1:model.K,fused_agents{s}.each_fused_time,'LineStyle',line_style{idx_line},'LineWidth',line_width,'Marker',marker_list{idx_marker},'MarkerSize',MarkerSize); hold on; % single agent
    legend_names = [legend_names, {fused_agents{s}.fused_strategy}];
    title('Fusing Time');
    legend(legend_names,'Location','best');
    ylabel('Fusing Time (s)');
    xlabel('Time Step');
    grid on;
    set(gca, 'XLim',[1 model.K],'FontSize', font_size,'XGrid','off','YGrid','on', 'FontName', font_name);
end


