%codegen
function errorhandler(~,ME)
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
        
    end
    close(f);
end