import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.XMLPlugin

try
    suite = testsuite({'AD9361Tests','AD9363Tests','AD9364Tests'...
        'AD9371Tests','ADRV9009Tests','DAQ2Tests'});
    runner = TestRunner.withNoPlugins;
    xmlFile = 'HWTestResults.xml';
    plugin = XMLPlugin.producingJUnitFormat(xmlFile);
    
    runner.addPlugin(plugin);
    results = runner.run(suite);
    
    t = table(results);
    disp(t);
    disp(repmat('#',1,80));
    for test = results
        if test.Failed
            disp(test.Name);
        end
    end
catch e
    disp(getReport(e,'extended'));
    bdclose('all');
    exit(1);
end
save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH:MM:SS'),'.mat'],'t');
bdclose('all');
exit(any([results.Failed]));
