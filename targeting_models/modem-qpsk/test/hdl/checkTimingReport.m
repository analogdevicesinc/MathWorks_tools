
function r = checkTimingReport(varargin)
% Find timing report
if isempty(varargin)
    hdl_prj = 'hdl_prj';
else
    hdl_prj = varargin{1};
end
path = [hdl_prj,'/vivado_ip_prj/vivado_prj.runs/impl_1'];
filename = 'system_wrapper_timing_summary_routed.rpt';
full = [path,'/',filename];

if ~isfile(full)
   error(['No timing report found under: ',full]); 
end

fid = fopen(full);
str = textscan(fid, '%s');
str = strcat(str{1}{:});
%%
if ~contains(str,'(VIOLATED)')
    disp('Passed Timing');
    r = true;
else
    disp('Failed Timing');
    r = false;
end
