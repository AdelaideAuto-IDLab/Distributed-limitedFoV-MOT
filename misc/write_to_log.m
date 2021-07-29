function write_to_log(folder_path,disp_str,varargin)
    % Write to a log file with try catch error

    p = inputParser;% --- Input Parser
    addParameter(p,'fopen_tag','a');
    parse(p, varargin{:});
    try
        file_id = fopen([folder_path,'log.txt'],p.Results.fopen_tag);
        fprintf(file_id,[disp_str,'\n']);
        fclose(file_id);
    catch msg
        disp(msg.message)
    end
end