classdef TestFiltWiz < handle
    properties
        BasebandSampleRate   = 1e6;
        FIRCoefficients      = zeros(2,128);
        FIRGain              = zeros(2,1);
        FIRDecimInterpFactor = zeros(2,1);
        AnalogFilterCutoff   = zeros(2,1);
        FilterPathRates      = zeros(2,6);
            
        FilterDesignTypeForRx = 'FooRx';
        FilterDesignTypeForTx = 'FooTx';
    end
    
    methods
        function designDefaultFilter(obj)
            % DIRECT INVOCATION WITH NO WIZARD -- FOR TESTING OF THIS
            % TESTBENCH
            tohwRx = internal_designrxfilters9361_default(obj.BasebandSampleRate);
            applyFilterWizardCallback(obj, tohwRx);

            obj.checkFilterDesign();
        end
        function designCustomFilter(obj)


            % designCustomFilter Design a custom filter
            %   Design a custom filter using the ADI 9361 Filter Wizard app.
            %
            defVals = struct('Rdata', obj.BasebandSampleRate);

            h = AD9361_Filter_Wizard( ...
                'remote', 'hide', ...
                'PathConfig', 'rx', ...
                'ApplyString','Apply filter design', ...
                'helpurl', 'http://www.mathworks.com', ... % FIXME for TMW: how to make a stable url here?
                'DefaultRxVals', defVals, ...
                'DefaultTxVals', defVals, ...
                'ApplyCallback', '@(obj, tohwRx)(applyFilterWizardCallback(obj, tohwRx))', ... % FIXME: do not have callback arg yet
                'CallbackObj', obj ...
                );
            waitfor(h);

            obj.checkFilterDesign();

        end

        function checkFilterDesign(obj)
            % BASIC CHECK THAT DESIGN WAS MADE
            if (obj.BasebandSampleRate == obj.FilterPathRates(1,6))
                disp('looks good!');
            else
                error('does not look like the filter design was applied correctly');
            end
        end
        
        function applyFilterWizardCallback(obj, tohwRx)
            tohwTx = internal_designtxfilters9361_default(tohwRx.RXSAMP);
            obj.applyFilterWizardDesign('CustomFilter', tohwTx, tohwRx);
        end
        % ***** Callback set during wizard invocation *****
        function applyFilterWizardDesign(obj, filterKind, tohwTx, tohwRx)
            % for default filter: BasebandSampleRate was the INPUT to the
            %   process, so no need to set BasebandSampleRate.
            % for custom filter: user MAY have changed in GUI so we will
            %   clobber existing if it is different.
            % ASSUME: can only call custom filter GUI outside of codegen
            
            if isempty(coder.target())
                if obj.BasebandSampleRate ~= tohwRx.RXSAMP
                    warning(message('sdrpluginbase:Sysobj:ClobberingPreviousValue', 'BasebandSampleRate', num2str(obj.BasebandSampleRate), num2str(tohwRx.RXSAMP)));
                    obj.BasebandSampleRate = tohwRx.RXSAMP;
                end
            end
            
            assert(obj.BasebandSampleRate == tohwRx.RXSAMP, 'BasebandSampleRate does not match the filter design');
            
            if(length(tohwRx.Coefficient) < length(tohwTx.Coefficient))
                padLength = (length(tohwTx.Coefficient) - length(tohwRx.Coefficient)) / 2;
                tohwRx.Coefficient = [zeros(1, padLength) tohwRx.Coefficient zeros(1, padLength)];
            end
            obj.FIRCoefficients      = [tohwTx.Coefficient; tohwRx.Coefficient];
            obj.FIRGain              = [tohwTx.Gain ; tohwRx.Gain];
            obj.FIRDecimInterpFactor = [tohwTx.Interp ; tohwRx.Decimation];
            obj.AnalogFilterCutoff   = [tohwTx.RFBandwidth ; tohwRx.RFBandwidth];
            obj.FilterPathRates      = [tohwTx.BBPLL, tohwTx.DAC, tohwTx.T2, tohwTx.T1, tohwTx.TF, tohwTx.TXSAMP; ...
                tohwRx.BBPLL, tohwRx.ADC, tohwRx.R2, tohwRx.R1, tohwRx.RF, tohwRx.RXSAMP];
            
            obj.FilterDesignTypeForRx = filterKind;
            obj.FilterDesignTypeForTx = [filterKind 'FromOther'];
            
            % No need for Rx1==Rx2 consistency check--only one value now.
            % Tx/Rx consistency check done in ESW.
        end
        
    end
end