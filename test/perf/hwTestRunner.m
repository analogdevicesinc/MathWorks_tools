import matlab.unittest.plugins.DiagnosticsRecordingPlugin
import matlab.unittest.plugins.TestReportPlugin
import matlab.unittest.selectors.HasName;

runner = matlab.unittest.TestRunner.withNoPlugins;
runner.addPlugin(DiagnosticsRecordingPlugin);
runner.addPlugin(TestReportPlugin.producingPDF('Report.pdf',...
    'IncludingPassingDiagnostics',true,'IncludingCommandWindowText',true));
runner.ArtifactsRootFolder = pwd;

suite = testsuite('HardwarePerformanceTests');

% suite = suite.selectIf(HasName('HardwarePerformanceTests/LTE_R4_Two_Pluto'));

if ~exist('logs', 'dir')
    mkdir('logs')
end

results = runner.run(suite);
t = table(results);
disp(t);

exit(any([results.Failed]));
