results = run(BSPTests);
t = table(results);
disp(t);
disp('################################################################################');
for test = results
    if test.Failed
        disp(results.Details.DiagnosticRecord.Report);
    end
end
save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH:MM:SS'),'.mat'],'t');