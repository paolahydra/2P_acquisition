classdef PipStimulus < AuditoryStimulus
    % Basic subclass for making (amplitude modulated) pips
    % symmetrical around zero (for speaker?)
    % SLH 2014
    
    properties
        amplitude           = 1;        % [0,1], relative to max voltage
        modulationDepth     = 1;        % [0,1]
        modulationFreqHz    = 1;
        modulationPhase     = -1/4;     % betwwen (-1, 1), refers to a full cycle
        carrierFreqHz       = 300;
        carrierPhase        = 0;
        envelope            = 'sinusoid';
        numPips             = 1;
        pipDur              = 5;
        ipi                 = 0.034;
    end
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        cyclesPerPip
        stimulus
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
        
        function cyclesPerPip = get.cyclesPerPip(obj)
            cyclesPerPip = obj.pipDur / (1/obj.carrierFreqHz);
            if ~isinteger(mod(cyclesPerPip,0.5))
                error('numCyclesPerPip must be divisible by 0.5')
            end
        end
        
        function stimulus = get.stimulus(obj)   
            g = getpref;
            load(g.correctFreqDisplacPiezo.Piezo30um)
            % Make pip
            pip = obj.makeSine(obj.carrierFreqHz,obj.pipDur,(obj.carrierPhase / obj.carrierFreqHz));
            
            % Calculate envelope
            sampsPerPip = length(pip);
            switch lower(obj.envelope)
                case {'none',''}
                    % pass back unchanged
                    return
                case {'sinusoid','sin','s'}
                      modEnvelope = 1 + obj.modulationDepth * obj.makeSine(obj.modulationFreqHz,obj.pipDur, (obj.modulationPhase / obj.modulationFreqHz));  %1 is fixed amplitude of carrier signal      
                case {'triangle','tri','t'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[.25:1/(2*(sampsPerPip-1)):.75],.5)';
                case {'rampup','r'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[.5:1/(2*(sampsPerPip-1)):1])';
                case {'rampdown','d'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[0:1/(2*(sampsPerPip-1)):.5],0)';
                case {'cos-theta','c'}
                    sampsPerRamp = floor(sampsPerPip/10);
                    ramp = sin(linspace(0,pi/2,sampsPerRamp));
                    modEnvelope = [ramp,ones(1,sampsPerPip - sampsPerRamp*2),fliplr(ramp)]';
                otherwise
                    error(['Envelope ' obj.Envelope ' not accounted for.']);
            end
            
            % apply the envelope to pip
            pip = modEnvelope.*pip;
            
            % generate pip train
            spacePip = [zeros(round(obj.ipi*obj.sampleRate),1);pip];
            stimulus = [pip;repmat(spacePip,obj.numPips-1,1)];
            
            % Scale the stim to the maximum voltage in the amp
            maxFound = max(abs(stimulus));
            amplitudeCorrect = obj.amplitude * cf30(obj.carrierFreqHz);
            assert(amplitudeCorrect <= 1, 'Corrected amplitude as function of frequency exceeds maxVoltage. Reduce amplitude or maximum frequency')
            stimulus = (stimulus/maxFound)*amplitudeCorrect;
            stimulus = stimulus * obj.maxVoltage;
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
            
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            if obj.numPips == 1
                endPadDur = obj.totalDur - obj.pipDur - obj.startPadDur;
            else
                stimDur = obj.pipDur * obj.numPips + obj.ipi*(obj.numPips - 1);
                endPadDur = floor(obj.totalDur - stimDur - obj.startPadDur);
            end
        end
    end    
end


