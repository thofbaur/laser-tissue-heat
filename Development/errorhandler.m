%codegen
function errorhandler(app,ME)
%     rethrow(ME);
    f = uifigure();
    msg = [ME.identifier,newline,...
        ME.message,newline];
    for ii = 1:length(ME.stack)
        msg = [msg,newline,newline...
            ME.stack(ii).file,newline,...
            ME.stack(ii).name,newline,...
            num2str(ME.stack(ii).line)];
    end
    selection = uiconfirm(f,msg,'Error','Option',{'Dismiss','Create Logfile'});
    if strcmp(selection,'Create Logfile')
        t = datetime(now,'ConvertFrom','datenum');
        t.Format = 'yyyy-MM-dd_HH-mm-ss';
        filename = [app.vPathLog,'\Log-',char(t),'.log'];
        fileID = fopen(filename,'w');
        fprintf(fileID,'%s',msg);
        fclose(fileID);
    end
    close(f);
end