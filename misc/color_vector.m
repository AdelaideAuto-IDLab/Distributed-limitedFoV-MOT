function color_list = color_vector(ncolor)
    % Create a list of color vector appended from Color Order of GCA
    % Input: % Number of needed colors.
    % Output: List of ncolor in RGB matrix
    % Date: 28-01-2018
    % Rev: 1.0
    % Author: Hoa Van Nguyen
    color_order = '[[0,0.447,0.741],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188],[0.301,0.745,0.933],[0.635,0.078,0.184]]';
    color_list = jsondecode(color_order);
    if ncolor > size(color_list,1)
        n_color_rand = ncolor-size(color_list,1);
        color_list = [color_list;rand(n_color_rand,3)];
    else
        color_list = color_list(1:ncolor,:);
    end
end