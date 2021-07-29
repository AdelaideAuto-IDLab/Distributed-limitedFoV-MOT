function ca = makecolorarray(nlabels)
    
    lower= 0.1;
    upper= 0.9;
    
    color_list = get(gca,'colororder');
    close gcf; 
    
    if nlabels > size(color_list,1)
        n_color = nlabels - size(color_list,1);
        color_temp = lower + (upper-lower) * rand(n_color,3);
        color_list = [color_list;color_temp];
    end
    ca.rgb = color_list(1:nlabels,:);
    ca.lab = cell(nlabels,1);
    ca.cnt = 0;
end