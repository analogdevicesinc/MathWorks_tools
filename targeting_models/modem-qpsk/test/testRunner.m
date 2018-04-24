
%% Import necessary infrastructure
import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.selectors.HasTag
import matlab.unittest.plugins.TestRunProgressPlugin
import matlab.unittest.plugins.LoggingPlugin
import matlab.unittest.plugins.DiagnosticsRecordingPlugin;
%import matlab.unittest.plugins.StopOnFailuresPlugin;

addpath('hdl');
%% Pick Tags
%Tags = {'Radio','Simulink','Environmental','Fixed'};
%Tags = {'HDL','Fixed','Environmental'};
Tags = {'Simulation'};
sm = TestSuite.fromClass(?matlab_tests);
ss = TestSuite.fromClass(?simulink_tests);
hs = TestSuite.fromClass(?hdl_tests);
if ~isempty(Tags)
    % Pick all tests with specific tags
    for t=1:length(Tags)
        sm = sm.selectIf(HasTag(Tags{t}));
        ss = ss.selectIf(HasTag(Tags{t}));
        hs = hs.selectIf(HasTag(Tags{t}));
    end
end
suites = [sm,ss,hs];
disp('Running Tests');
for s = 1:length(suites)
   disp([num2str(s),': ',suites(s).Name]); 
end
disp('-------------');
%% Add runner and pluggin(s)
runner = TestRunner.withNoPlugins;
p = LoggingPlugin.withVerbosity(4);
runner.addPlugin(p);
p = TestRunProgressPlugin.withVerbosity(4);
runner.addPlugin(p);
runner.addPlugin(DiagnosticsRecordingPlugin);
%runner.addPlugin(StopOnFailuresPlugin);
%% Run Tests
if license('test','Distrib_Computing_Toolbox')
    r = runInParallel(runner,suites);
else
    r = run(runner,suites);
end
%% Check results
rt = table(r);
disp(rt)
