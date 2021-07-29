function report_single_result(s,fused_agents)
    % Report a result for a particular agent s


    hor_str = repmat('-',57,1)';
    % --- OSPA
    fprintf('%s\n',hor_str);
    fprintf('Fused  Agent %d - %-12s - Mean OSPA         : %-5.1f m\n',s,fused_agents{s}.fused_strategy,mean(fused_agents{s}.ospa(1,:)));
    
    % --- OSPA2
    fprintf('%s\n',hor_str);
    fprintf('Fused  Agent %d - %-12s - Mean OSPA2        : %-5.1f m\n',s,fused_agents{s}.fused_strategy,mean(fused_agents{s}.ospa2(1,:)));
    
    % --- Fused time
    fprintf('%s\n',hor_str);
    fprintf('Fused  Agent %d - %-12s - Fused Time        : %-5.3f s\n',s,fused_agents{s}.fused_strategy,mean(fused_agents{s}.each_fused_time));
end