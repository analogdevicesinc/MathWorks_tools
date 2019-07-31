classdef Tx < adi.AD9144.Base & adi.common.Tx & adi.common.DDS
    % adi.AD9144.Tx Transmit data to the AD9144 high speed DAC
    %   The adi.AD9144.Tx System object is a signal source that can send
    %   complex data from the AD9144.
    %
    %   tx = adi.AD9144.Tx;
    %   tx = adi.AD9144.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9144.pdf">AD9144 Datasheet</a>
    %
    %   See also adi.DAQ2.Tx
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   in samples per second. This value is constant
        SamplingRate = 1e9;
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
        channel_names = {'voltage0','voltage1'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9144-hpc';
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9144.Base(varargin{:});
        end
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
        
        function bName = getDescriptiveName(~)
            bName = 'AD9144';
        end
        
    end
end

