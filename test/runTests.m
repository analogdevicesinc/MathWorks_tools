function runTests(board)

import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.ToUniqueFile;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.DiagnosticsValidationPlugin
import matlab.unittest.parameters.Parameter

runParallel = false;
SynthesizeDesign = {false};
param = Parameter.fromData('SynthesizeDesign',SynthesizeDesign);

if nargin == 0
    suite = testsuite({'BSPTests'});
else
    boards = ['*',lower(board),'*'];
    suite = TestSuite.fromClass(?BSPTests,'ExternalParameters',param);
    suite = suite.selectIf('ParameterProperty','configs', 'ParameterName',boards);
end
    
try

    runner = matlab.unittest.TestRunner.withTextOutput('OutputDetail',1);
    runner.addPlugin(DiagnosticsValidationPlugin)
    
    xmlFile = 'BSPTestResults.xml';
    plugin = XMLPlugin.producingJUnitFormat(xmlFile);
    runner.addPlugin(plugin);
    
    if runParallel
        try %#ok<UNRCH>
            parpool(2);
            results = runInParallel(runner,suite);
        catch ME
            disp(ME);
            results = runner.run(suite);
        end
    else
        results = runner.run(suite);
    end
    
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

try
    poolobj = gcp('nocreate');
    delete(poolobj);
catch ME
    disp(ME)
end

save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH:MM:SS'),'.mat'],'t');
bdclose('all');
exit(any([results.Failed]));
