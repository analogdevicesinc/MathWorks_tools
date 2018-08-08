results = run(BSPTests);
t = table(results);
disp(t);
save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH:MM:SS'),'.mat'],'t');