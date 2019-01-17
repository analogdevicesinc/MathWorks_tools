import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.DiagnosticsRecordingPlugin
import matlab.unittest.plugins.TestReportPlugin
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.CodeCoveragePlugin;
import matlab.unittest.plugins.codecoverage.CoberturaFormat;

runner = TestRunner.withTextOutput;

runner.addPlugin(DiagnosticsRecordingPlugin);

runner.addPlugin(TestReportPlugin.producingPDF('Report.pdf',...
    'IncludingPassingDiagnostics',true,'IncludingCommandWindowText',true));
runner.ArtifactsRootFolder = pwd;

xmlFile = 'BSPTestResults.xml';
plugin = XMLPlugin.producingJUnitFormat(xmlFile);
runner.addPlugin(plugin);

coverageFile = 'Coverage.xml';
foldersToIgnore = {'+utils','.','..','Contents.m'};
folders = dir('+adi');
folders = {folders.name};
f = {};
for folder = folders
    if ~contains(foldersToIgnore,folder{:})
        f = [f(:)',{['+adi/',folder{:}]}];
    end
end
runner.addPlugin(CodeCoveragePlugin.forFolder(f,...
    'IncludingSubfolders',true,...
    'Producing', CoberturaFormat(coverageFile)));

suite = [testsuite('AD9361Tests'),testsuite('AD9363Tests'),testsuite('AD9364Tests')];

if ~exist('logs', 'dir')
    mkdir('logs')
end

results = runner.run(suite);
t = table(results);
disp(t);

exit(any([results.Failed]));
