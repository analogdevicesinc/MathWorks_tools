import matlab.unittest.plugins.DiagnosticsRecordingPlugin
import matlab.unittest.plugins.TestReportPlugin

runner = matlab.unittest.TestRunner.withNoPlugins;
runner.addPlugin(DiagnosticsRecordingPlugin);
runner.addPlugin(TestReportPlugin.producingPDF('Report.pdf',...
    'IncludingPassingDiagnostics',true,'IncludingCommandWindowText',true));
runner.ArtifactsRootFolder = pwd;

suite = testsuite('HardwareTests');

if ~exist('logs', 'dir')
    mkdir('logs')
end

results = runner.run(suite);
t = table(results);
disp(t);

exit(any([results.Failed]));
