function [X_track,k_birth,k_death,Y_track,l_birth,l_death]= extract_results(model,truth,meas,est)
    % Extract ground truth tracks and estimated tracks with its birth and death time

    meas_K = length(meas);
    [X_track,k_birth,k_death]= extract_tracks(truth.X,truth.track_list,truth.total_tracks);

    labelcount= countestlabels();
    colorarray= makecolorarray(labelcount);
    est.total_tracks= labelcount;
    est.track_list= cell(truth.K,1);
    for k=1:truth.K
        for eidx=1:size(est.X{k},2)
            est.track_list{k} = [est.track_list{k} assigncolor(est.L{k}(:,eidx))];
        end
    end
    [Y_track,l_birth,l_death]= extract_tracks(est.X,est.track_list,est.total_tracks);
    return;

    %plot ground truths
    figure; truths= gcf; hold on;
    for i=1:truth.total_tracks
        Pt= (1/60).*X_track(:,k_birth(i):1:k_death(i),i); Pt=Pt([1 3],:);
        plot( Pt(1,:),Pt(2,:),'k-'); hold on;
        plot( Pt(1,1), Pt(2,1), 'ko','MarkerSize',6); hold on;
        plot( Pt(1,(k_death(i)-k_birth(i)+1)), Pt(2,(k_death(i)-k_birth(i)+1)), 'k^','MarkerSize',4); hold on;  
    end
    hold on
    for  t=1:1:est.total_tracks
       Pyt = (1/60).*Y_track(:,l_birth(i):1:l_death(i),i);Pyt= Pyt([1 3],:);
        plot( Pyt(1,:),Pyt(2,:),'r-'); hold on;
        plot( Pyt(1,1), Pyt(2,1), 'o','LineStyle','none','Marker','o'); hold on;
        plot( Pyt(1,(l_death(i)-l_birth(i)+1)), Pyt(2,(l_death(i)-l_birth(i)+1)), 'LineStyle','none','Marker','x'); hold on;

    end
    axis equal;
    axis([model.limit(1,1) model.limit(1,2) model.limit(2,1) model.limit(2,2)]./60); 
    xlabel('latitude (deg)');ylabel('longitude (deg)');
    print('Groundtruth-new','-depsc');

    %plot x tracks and measurements in x/y
    figure; tracking= gcf; hold on;

    %plot x measurement
    subplot(211); box on; 

    for k=1:meas_K
        if ~isempty(meas.Z{k})
            hlined= line(k*ones(size(meas.Z{k},2),1),meas.Z{k}(2,:).*sin(meas.Z{k}(1,:)),'LineStyle','none','Marker','x','Markersize',5,'Color',0.7*ones(1,3));
        end   
    end

    %plot x track
    for i=1:truth.total_tracks
        Px= (1/60).*X_track(:,k_birth(i):1:k_death(i),i); Px=Px([1 3],:);
        hline1= line(k_birth(i):1:k_death(i),Px(1,:),'LineStyle','-','Marker','none','LineWidth',1,'Color',0*ones(1,3));
    end

    %plot x estimate
    for t=1:size(Y_track,3)
        hline2= line(1:truth.K,(1/60).*Y_track(1,:,t),'LineStyle','none','Marker','o','Markersize',5,'Color',colorarray.rgb(t,:));
    end

    %plot y measurement
    subplot(212); box on;

    for k=1:meas_K
        if ~isempty(meas.Z{k})
            yhlined= line(k*ones(size(meas.Z{k},2),1),meas.Z{k}(2,:).*cos(meas.Z{k}(1,:)),'LineStyle','none','Marker','x','Markersize',5,'Color',0.7*ones(1,3));
        end
    end

    %plot y track
    for i=1:truth.total_tracks
            Py= (1/60).*X_track(:,k_birth(i):1:k_death(i),i); Py=Py([1 3],:);
            yhline1= line(k_birth(i):1:k_death(i),Py(2,:),'LineStyle','-','Marker','none','LineWidth',1,'Color',0*ones(1,3));
    end

    %plot y estimate
    for t=1:size(Y_track,3)
        hline2= line(1:truth.K,(1/60).*Y_track(3,:,t),'LineStyle','none','Marker','o','Markersize',5,'Color',colorarray.rgb(t,:));
    end

    subplot(211); xlabel('Time'); ylabel('latitude (deg)');
    set(gca, 'XLim',[1 truth.K]); set(gca, 'YLim',[model.limit(1,1) model.limit(1,2)]./60);%[-model.range_c(2,2) model.range_c(2,2)])
    legend([hline2 hline1 hlined],'Estimates          ','True tracks','Measurements');

    subplot(212); xlabel('Time'); ylabel('longitude (deg)');
    set(gca, 'XLim',[1 truth.K]); set(gca, 'YLim',[model.limit(2,1) model.limit(2,2)]./60);%[ model.range_c(1,2) model.range_c(2,2)] )
    print('latlongmeas','-depsc');

    %plot error
    ospa_vals= zeros(truth.K,3);
    ospa_c= 100;
    ospa_p= 1;
    for k=1:meas_K
        [ospa_vals(k,1), ospa_vals(k,2), ospa_vals(k,3)]= ospa_dist(get_comps(truth.X{k},[1 3]),get_comps(est.X{k},[1 3]),ospa_c,ospa_p);
    end

    figure; ospa= gcf; hold on;
    subplot(3,1,1); plot(1:meas_K,ospa_vals(:,1),'k'); grid on; set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 ospa_c]); ylabel('OSPA Dist');
    subplot(3,1,2); plot(1:meas_K,ospa_vals(:,2),'k'); grid on; set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 ospa_c]); ylabel('OSPA Loc');
    subplot(3,1,3); plot(1:meas_K,ospa_vals(:,3),'k'); grid on; set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 ospa_c]); ylabel('OSPA Card');
    xlabel('Time');
    print('OSPA','-depsc');

    %plot error - OSPA^(2)
    order = model.ospa.p;
    cutoff = model.ospa.c;
    win_len= model.ospa.win_len;%10;

    ospa2_cell = cell(1,length(win_len));
    for i = 1:length(win_len)
        ospa2_cell{i} = compute_ospa2(X_track([1 3],:,:),Y_track([1 3],:,:),cutoff,order,win_len);
    end

    figure; ospa2= gcf; hold on;
    windowlengthlabels = cell(1,length(win_len));
    subplot(3,1,1);
    for i = 1:length(win_len)
        plot(1:truth.K,ospa2_cell{i}(1,:),'k'); grid on; set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 cutoff]); ylabel('OSPA$^{(2)}$ Dist','interpreter','latex');
        windowlengthlabels{i} = ['$L_w = ' int2str(win_len(i)) '$'];
    end
    legend(windowlengthlabels,'interpreter','latex');

    subplot(3,1,2);
    for i = 1:length(win_len)
        plot(1:truth.K,ospa2_cell{i}(2,:),'k'); grid on; set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 cutoff]); ylabel('OSPA$^{(2)}$ Loc','interpreter','latex');
        windowlengthlabels{i} = ['$L_w = ' int2str(win_len(i)) '$'];
    end

    subplot(3,1,3);
    for i = 1:length(win_len)
        plot(1:truth.K,ospa2_cell{i}(3,:),'k'); grid on; set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 cutoff]); ylabel('OSPA$^{(2)}$ Card','interpreter','latex');
        windowlengthlabels{i} = ['$L_w = ' int2str(win_len(i)) '$'];
    end
    xlabel('Time','interpreter','latex');
    print('OSPA2_mix','-depsc');

    %plot cardinality
    figure; cardinality= gcf; 
    subplot(2,1,1); box on; hold on;
    stairs(1:meas_K,truth.N,'k'); 
    plot(1:meas_K,est.N,'k.');

    grid on;
    legend(gca,'True','Estimated');
    set(gca, 'XLim',[1 meas_K]); set(gca, 'YLim',[0 max(truth.N)+1]);
    xlabel('Time'); ylabel('Cardinality');

    %return
    handles=[ truths tracking ospa ospa2 cardinality ];

    function ca= makecolorarray(nlabels)
        lower= 0.1;
        upper= 0.9;
        rrr= rand(1,nlabels)*(upper-lower)+lower;
        ggg= rand(1,nlabels)*(upper-lower)+lower;
        bbb= rand(1,nlabels)*(upper-lower)+lower;
        ca.rgb= [rrr; ggg; bbb]';
        ca.lab= cell(nlabels,1);
        ca.cnt= 0;   
    end

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

    function count= countestlabels
        labelstack= [];
        for k=1:meas_K
            labelstack= [labelstack est.L{k}];
        end
        [c,~,~]= unique(labelstack','rows');
        count=size(c,1);
    end

end
