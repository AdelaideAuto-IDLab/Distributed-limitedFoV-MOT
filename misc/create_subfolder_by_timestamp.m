function fullPath = create_subfolder_by_timestamp(storedFolder)
    % Create a subfolder inside the storedFolder using timestamp
    folderName = ['/',storedFolder,'/',datestr(now, 'yyyymmdd_HHMMss_FFF'),'/'];
    currentFolder = pwd;
    fullPath = fullfile(currentFolder, folderName);
    if ~exist(fullPath, 'dir')
        % Folder does not exist so create it.
        mkdir(fullPath);
    end
end