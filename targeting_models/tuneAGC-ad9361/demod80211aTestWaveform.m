classdef demod80211aTestWaveform
    properties (Constant)
        thresh = 15000
        NFFT = 64
        NCO_res = 0.05
        SFDR = 100  
        lltfFlip = [-0.0315692172910537 - 0.741727115766384i,0.245031345132797 - 0.685217283054502i,0.596906339316113 + 0.510395901763690i,0.130140496685690 + 0.171898768639155i,0.368775557652229 - 0.540655809477193i,-0.709709949842901 - 0.340152292136460i,-0.236193315653035 - 0.654475445340436i,0.601279187368844 - 0.159585026057797i,0.328792854823845 + 0.0251279330936467i,0.00609642433628817 - 0.708929719997044i,-0.843314147664839 - 0.292066088346766i,0.150877895176733 - 0.360810904891321i,0.361655245757893 - 0.0920893310381723i,-0.138594518013667 + 0.990349210923379i,0.735032351447327 - 0.0252467075259909i,0.385272334260397 - 0.385272334260397i,0.227575387053458 + 0.606228485471383i,-0.352640358534722 + 0.242250540783645i,-0.809149628176744 + 0.402083948498530i,0.506823119242761 + 0.569318789687270i,0.428773263427974 + 0.0870527992083324i,-0.371773010052903 + 0.501076716496710i,-0.348009585893427 - 0.134407158215291i,-0.216006853108447 - 0.930129694578592i,-0.751355079949597 - 0.102120088517317i,-0.784872853597668 - 0.126377832366101i,0.462781096176534 - 0.456411600462252i,-0.0172968425843895 + 0.331483794696952i,-0.566427726489160 + 0.709694502760234i,0.565373583531186 + 0.652630744165548i,0.0757266054624828 + 0.601638525363045i,-0.963180835650993 + 0.00000000000000i,0.0757266054624827 - 0.601638525363045i,0.565373583531186 - 0.652630744165548i,-0.566427726489160 - 0.709694502760234i,-0.0172968425843894 - 0.331483794696952i,0.462781096176534 + 0.456411600462252i,-0.784872853597668 + 0.126377832366101i,-0.751355079949598 + 0.102120088517317i,-0.216006853108447 + 0.930129694578592i,-0.348009585893427 + 0.134407158215291i,-0.371773010052903 - 0.501076716496710i,0.428773263427974 - 0.0870527992083324i,0.506823119242761 - 0.569318789687270i,-0.809149628176744 - 0.402083948498530i,-0.352640358534722 - 0.242250540783645i,0.227575387053458 - 0.606228485471383i,0.385272334260397 + 0.385272334260397i,0.735032351447328 + 0.0252467075259909i,-0.138594518013667 - 0.990349210923379i,0.361655245757893 + 0.0920893310381724i,0.150877895176733 + 0.360810904891321i,-0.843314147664839 + 0.292066088346766i,0.00609642433628825 + 0.708929719997044i,0.328792854823845 - 0.0251279330936467i,0.601279187368844 + 0.159585026057797i,-0.236193315653035 + 0.654475445340436i,-0.709709949842901 + 0.340152292136460i,0.368775557652229 + 0.540655809477193i,0.130140496685690 - 0.171898768639155i,0.596906339316113 - 0.510395901763690i,0.245031345132797 + 0.685217283054502i,-0.0315692172910535 + 0.741727115766384i,0.963180835650993 + 0.00000000000000i,-0.0315692172910537 - 0.741727115766384i,0.245031345132797 - 0.685217283054502i,0.596906339316113 + 0.510395901763690i,0.130140496685690 + 0.171898768639155i,0.368775557652229 - 0.540655809477193i,-0.709709949842901 - 0.340152292136460i,-0.236193315653035 - 0.654475445340436i,0.601279187368844 - 0.159585026057797i,0.328792854823845 + 0.0251279330936467i,0.00609642433628817 - 0.708929719997044i,-0.843314147664839 - 0.292066088346766i,0.150877895176733 - 0.360810904891321i,0.361655245757893 - 0.0920893310381723i,-0.138594518013667 + 0.990349210923379i,0.735032351447327 - 0.0252467075259909i,0.385272334260397 - 0.385272334260397i,0.227575387053458 + 0.606228485471383i,-0.352640358534722 + 0.242250540783645i,-0.809149628176744 + 0.402083948498530i,0.506823119242761 + 0.569318789687270i,0.428773263427974 + 0.0870527992083324i,-0.371773010052903 + 0.501076716496710i,-0.348009585893427 - 0.134407158215291i,-0.216006853108447 - 0.930129694578592i,-0.751355079949597 - 0.102120088517317i,-0.784872853597668 - 0.126377832366101i,0.462781096176534 - 0.456411600462252i,-0.0172968425843895 + 0.331483794696952i,-0.566427726489160 + 0.709694502760234i,0.565373583531186 + 0.652630744165548i,0.0757266054624828 + 0.601638525363045i,-0.963180835650993 + 0.00000000000000i,0.0757266054624827 - 0.601638525363045i,0.565373583531186 - 0.652630744165548i,-0.566427726489160 - 0.709694502760234i,-0.0172968425843894 - 0.331483794696952i,0.462781096176534 + 0.456411600462252i,-0.784872853597668 + 0.126377832366101i,-0.751355079949598 + 0.102120088517317i,-0.216006853108447 + 0.930129694578592i,-0.348009585893427 + 0.134407158215291i,-0.371773010052903 - 0.501076716496710i,0.428773263427974 - 0.0870527992083324i,0.506823119242761 - 0.569318789687270i,-0.809149628176744 - 0.402083948498530i,-0.352640358534722 - 0.242250540783645i,0.227575387053458 - 0.606228485471383i,0.385272334260397 + 0.385272334260397i,0.735032351447328 + 0.0252467075259909i,-0.138594518013667 - 0.990349210923379i,0.361655245757893 + 0.0920893310381724i,0.150877895176733 + 0.360810904891321i,-0.843314147664839 + 0.292066088346766i,0.00609642433628825 + 0.708929719997044i,0.328792854823845 - 0.0251279330936467i,0.601279187368844 + 0.159585026057797i,-0.236193315653035 + 0.654475445340436i,-0.709709949842901 + 0.340152292136460i,0.368775557652229 + 0.540655809477193i,0.130140496685690 - 0.171898768639155i,0.596906339316113 - 0.510395901763690i,0.245031345132797 + 0.685217283054502i,-0.0315692172910535 + 0.741727115766384i,0.963180835650993 + 0.00000000000000i,-0.0315692172910537 - 0.741727115766384i,0.245031345132797 - 0.685217283054502i,0.596906339316113 + 0.510395901763690i,0.130140496685690 + 0.171898768639155i,0.368775557652229 - 0.540655809477193i,-0.709709949842901 - 0.340152292136460i,-0.236193315653035 - 0.654475445340436i,0.601279187368844 - 0.159585026057797i,0.328792854823845 + 0.0251279330936467i,0.00609642433628817 - 0.708929719997044i,-0.843314147664839 - 0.292066088346766i,0.150877895176733 - 0.360810904891321i,0.361655245757893 - 0.0920893310381723i,-0.138594518013667 + 0.990349210923379i,0.735032351447327 - 0.0252467075259909i,0.385272334260397 - 0.385272334260397i,0.227575387053458 + 0.606228485471383i,-0.352640358534722 + 0.242250540783645i,-0.809149628176744 + 0.402083948498530i,0.506823119242761 + 0.569318789687270i,0.428773263427974 + 0.0870527992083324i,-0.371773010052903 + 0.501076716496710i,-0.348009585893427 - 0.134407158215291i,-0.216006853108447 - 0.930129694578592i,-0.751355079949597 - 0.102120088517317i,-0.784872853597668 - 0.126377832366101i,0.462781096176534 - 0.456411600462252i,-0.0172968425843895 + 0.331483794696952i,-0.566427726489160 + 0.709694502760234i,0.565373583531186 + 0.652630744165548i,0.0757266054624828 + 0.601638525363045i,-0.963180835650993 + 0.00000000000000i].';
    end
    
    properties (Access = public) % derived properties
        lstf_len1
        lstf_len2
        NCO_wl
        QAB
        dither
    end
    
    properties (Access = public)
        evm_per_frame
        bErrs_per_frame
        pErrs
        rxPSDU
    end
    
    properties (Access = private)
        delay1_pd
        delay1_se
        delay2_se
        delay3_se
        
        pd_fir1
        pd_fir2
        sym_fir
        NCO
    end
    
    methods
        function obj = demod80211aTestWaveform(sim_settings)
            clear count;
            
            obj.lstf_len1 = obj.NFFT/4;
            obj.lstf_len2 = obj.lstf_len1*10;

            obj.NCO_wl = ceil(log2(obj.fs/obj.NCO_res));
            obj.QAB = round((obj.SFDR-12)/6);
            obj.dither = obj.NCO_wl - obj.QAB; 
            
            obj.delay1_pd = dsp.Delay(obj.lstf_len1);
            obj.delay1_se = dsp.Delay(obj.NFFT);
            obj.delay2_se = dsp.Delay(86+64+80+64-32); % accounting for the group delays of filters used
            obj.delay3_se = dsp.Delay(1);
            
            % FIRs for correlation to perform packet detection
            obj.pd_fir1 = dsp.FIRFilter('Numerator',ones(1, obj.lstf_len1));
            obj.pd_fir2 = dsp.FIRFilter('Numerator',ones(1, obj.lstf_len1));
            
            % NCO
            obj.NCO = dsp.NCO;
            obj.NCO.NumDitherBits = obj.dither;
            obj.NCO.NumQuantizerAccumulatorBits = obj.QAB;
            nt = numerictype(1, obj.NCO_wl, obj.NCO_wl-1);
            nt.Signedness = 'Auto';
            obj.NCO.CustomOutputDataType = nt;
            
            obj.sym_fir = dsp.FIRFilter('Numerator', obj.lltfFlip(1:80).');
            
            if (sim_settings.SIM_STUDY == true)
                wlan_rx_data = obj.rxWaveform;
                for ii = 1:length(wlan_rx_data)
                    % packet detection
                    [out1, temp, out2, detection] = obj.packet_detect(wlan_rx_data(ii)); 
                    % CFO estimation
                    data = obj.cfo_est(wlan_rx_data(ii), out1, detection);
                    % symbol timing offset estimation
                    [final_est_all(ii), symbol_est, detection_delay, symbol_est_delay] = obj.symTime_est(data, out2, detection);                
                end

                % Decode
                a_ret = 0;
                prev = 0;
                count = 1;
                done = 0;
                k = find(final_est_all);
                j = 1;
                while ~done
                    if (a_ret)
                        j = j-1;
                    end
                    % Move to start of LLTF
                    i = k(j) - 160;
                    buff = wlan_rx_data(i-1:end);
                    % Decode
                    [a_ret, prev, count, obj] = obj.DecodeWLANFrame(buff, true, prev, count);   

                    if ( (j == length(k)) && (a_ret == 0) )
                        done = 1;
                    end
                    j = j+1;
                end
                obj.pErrs = sum((obj.bErrs_per_frame > 0));
            else
                
            end
        end       
    end
    
    methods (Access = private)
        function [in1, out1, out2, detection] = packet_detect(obj, data)
            Scale = 1/100;
            persistent tappedLine;
            if isempty(tappedLine)
                tappedLine = zeros(60,1)>0;
            end
            
            dataDelay = obj.delay1_pd(complex(data));
            in1 = dataDelay.*conj(data);
            in2 = dataDelay.*conj(dataDelay);

            out1 = real(obj.pd_fir2(complex(in1)));
            out2 = Scale.*obj.pd_fir1(real(in2));

            % tmp_detection = (out1 > out2) .* (out1>obj.thresh);
            tmp_detection = (out1 > out2);

            tappedLine = [tmp_detection; tappedLine(1:end-1)];
            detection = all(tmp_detection);
        end
        
        function data = cfo_est(obj, data, in, detection)
            persistent ncoBuffer;
            if isempty(ncoBuffer)
                ncoBuffer = zeros(16,1);
            end
            cfoest = obj.fs/obj.lstf_len1 * angle(in) / (2*pi);

            if 0%detection
                ncoBuffer = [cfoest; ncoBuffer(1:end-1)];
            end
            phase_inc = (2^obj.NCO_wl)/(obj.fs) * mean(ncoBuffer);

            shift = obj.NCO( int32(phase_inc) );

            data = data.*double(shift);
        end
        
        function [final_est_all, symbol_est, detection_delay, symbol_est_delay] = symTime_est(obj, data, out, detection)
            sym_est = obj.sym_fir(complex(data));
            sym_est = real(conj(sym_est).*sym_est);

            % Apply thresholding
            D = out .* (obj.lstf_len2*obj.lstf_len1/(obj.lstf_len2*2));
            symbol_est = sym_est > (D*400);

            %% Aligned Checks
            % Filter only transistions [down -> up]
            symbol_est = ~obj.delay3_se(symbol_est) .* symbol_est;

            % Align lstf_len2 delayed peaks
            symbol_est_delay = obj.delay1_se(symbol_est);

            % Align LSTF est over lstf_len2
            detection_delay = obj.delay2_se(detection);

            % Apply lstf_len2 PD condition to lstf_len2 peaks
            final_est_all = symbol_est .* detection_delay .* symbol_est_delay;
        end
        
        function [a_ret, prev, count, obj] = DecodeWLANFrame(obj, buffer, visual, prev, count)
            cfgNonHT = wlanNonHTConfig;
            cfgRec = wlanRecoveryConfig('EqualizationMethod', 'MMSE');
            cfgRec.PilotPhaseTracking = 'None';
            chanBW = 'CBW20';
            
            inds = wlanFieldIndices(cfgNonHT, 'L-LTF');
            rxLLTF = buffer((inds(1):inds(end))-160);
            inds = wlanFieldIndices(cfgNonHT, 'L-SIG');
            rxLSIG = buffer((inds(1):inds(end))-160);
            
            % rxLLTF = buffer(1:160);
            % rxLSIG = buffer(161:160+80);

            EVMPerPkt = comm.EVM;
            EVMPerPkt.Normalization = 'Average constellation power';
            EVMPerPkt.ReferenceSignalSource  = 'Estimated from reference constellation';
            EVMPerPkt.AveragingDimensions = [2 1]; % Nst-by-Nsym-by-Nss
            
            % Perform channel estimation based on L-LTF
            demodLLTF = wlanLLTFDemodulate(rxLLTF, chanBW, 1);
            noiseVar = helperNoiseEstimate(demodLLTF);
            chanEst = wlanLLTFChannelEstimate(demodLLTF, chanBW);

            % Recover information bits in L-SIG
            [recLSIGBits,failParityCheck] = wlanLSIGRecover(rxLSIG, chanEst, noiseVar, chanBW);
            if ~failParityCheck 
                rate = bi2de(double(recLSIGBits(1:3).'), 'left-msb');
                if rate <= 1
                    cfgNonHT.MCS = rate + 6;
                else
                    cfgNonHT.MCS = mod(rate, 6);
                end
                cfgNonHT.PSDULength = bi2de(double(recLSIGBits(6:17)'));
                
                indNonHTData = wlanFieldIndices(cfgNonHT,'NonHT-Data');
                % Decode                
                inds = (indNonHTData(1):indNonHTData(2))-160;
                % inds = (fieldInds.NonHTData(1):fieldInds.NonHTData(2))-160;
                [obj.rxPSDU{count}, eqSym, ~] = wlanNonHTDataRecover(buffer(inds), chanEst, ...
                    noiseVar, cfgNonHT, cfgRec);

                EVMPerPkt.ReferenceConstellation = wlanReferenceSymbols(cfgNonHT);
                obj.evm_per_frame(count) = EVMPerPkt(eqSym);
                if (obj.MSDULenBits(count) == cfgNonHT.PSDULength*8)
                    obj.bErrs_per_frame(count) = biterr(obj.txPSDU{count}, double(obj.rxPSDU{count}));
                    prev = prev+cfgNonHT.PSDULength*8;                    
                    % Evaluate recovered bits
                    if visual
                        fprintf('MCS %d | PSDULength detected %4d | PSDULength expected %d\n',...
                            cfgNonHT.MCS, cfgNonHT.PSDULength, obj.MSDULenBits(count)/8);
                    end                

                    count = count + 1;  
                    a_ret = 0;
                else
                    if visual
                        fprintf('Packet Lost\n');
                    end
                    obj.bErrs_per_frame(count) = obj.MSDULenBits(count);
                    prev = prev+obj.MSDULenBits(count);
                    count = count + 1;          
                    a_ret = 1;
                    return;
                end                                    
            else
                if visual
                    fprintf('LSIG Invalid\n');
                end
            end
        end
    end
end