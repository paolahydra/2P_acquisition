classdef FastStimulus < AuditoryStimulus
    % Basic subclass for making (amplitude modulated) pips
    % symmetrical around zero (for speaker?)
    % put rng('shuffle') in startup

    
    properties
        AM                  = 1;
        amplitude           = 1;        % [0,1], relative to max voltage
        singleStimDur       = 0.250;    % seconds
        pipDur              = 10;
        carrPhase           = -0.25; %for now
        carrierFrequencies  =  [0   0   0   0  ...
            8    58    90   116   136   154   170   184   200   214   230   246   264   286   324   400];
%                                 8, 38, 62, 82, 100, 116, 130, ...
%                                 142, 154, 164, 174, 184, 192, ...
%                                 202, 212, 220, 230, 240, 250, ...
%                                 262, 274, 290, 310, 340, 400];
        singlePip = 1;
    end
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        stimulus
        frequencySeries
    end
    
    methods       
        %%------Calculate Dependents-----------------------------------------------------------------
        function obj = set.amplitude(obj,value)
            if (value > 0  &&  value <= 1)
                obj.amplitude = value;
            else
                error('Amplitude property values must be within the (0, 1] range, relative to maximum voltage')
            end
        end
        
        
        function frequencySeries = get.frequencySeries(obj)
            numSt = obj.pipDur / obj.singleStimDur;
            repPre = ceil(numSt/length(obj.carrierFrequencies));
            carrFrequencies = reshape(repmat(obj.carrierFrequencies, repPre,1),1,[]);
            carrFrequencies = carrFrequencies(randperm(length(carrFrequencies)));
            frequencySeries = carrFrequencies(1:numSt);
        end
        
        function stimulus = get.stimulus(obj)  
            numSt = obj.pipDur / obj.singleStimDur;
% carrPhases = -0.25; %for now
            freqs = obj.frequencySeries;
            % Make pip
            stimulus = [];
            for i = 1:numSt
                if freqs(i) ~= 0
                    pipT = obj.makeSine(freqs(i),obj.singleStimDur,(obj.carrPhase / freqs(i)));
                else
                    pipT = zeros(obj.singleStimDur * obj.sampleRate,1);
                end
                stimulus = cat(1, stimulus, pipT);
            end
            
            % apply the envelope to pip
            if obj.AM
                modEnvelope = 1 + obj.makeSine(1/obj.singleStimDur,obj.pipDur, ( -1/4 * obj.singleStimDur));
                stimulus = modEnvelope.*stimulus;
            end
            
            % Scale the stim to the maximum voltage in the amp
            maxFound = max(stimulus);
            stimulus = (stimulus/maxFound)*obj.amplitude;
            stimulus = stimulus * obj.maxVoltage;
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
            
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            if obj.singlePip == 1
                endPadDur = obj.totalDur - obj.pipDur - obj.startPadDur;
            else
%                 stimDur = obj.pipDur * obj.numPips + obj.ipi*(obj.numPips - 1);
%                 endPadDur = floor(obj.totalDur - stimDur - obj.startPadDur);
            end
        end
    end    
end


