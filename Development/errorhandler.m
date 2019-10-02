%codegen
function errorhandler(~,ME)
%     rethrow(ME);
    f = uifigure();
    uialert(f,[ME.identifier,newline,...
        ME.message,newline],'Error');
end