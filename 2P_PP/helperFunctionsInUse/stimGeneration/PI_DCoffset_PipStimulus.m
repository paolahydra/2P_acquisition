classdef PI_DCoffset_PipStimulus < AuditoryStimulus
    
    properties
        DCoffset            = 0.5;      % [0,1], relative to max voltage
        pipLatency          = 1.25;        % seconds after DCoffset change
        DCduration          = 3;        % counts as stimDuration
        %pip
        amplitude           = 0.16;     % [0,1], relative to max voltage
        modulationDirection = 1;        % 1 up, -1 down, 0 bidirectional
        modulationDepth     = 1;        % [0,1]
        modulationFreqHz    = 2;
        modulationPhase     = -1/4;     % betwwen (-1, 1), refers to a full cycle
        carrierFreqHz       = 240;
        carrierPhase        = - 1/4;    % betwwen (-1, 1), refers to a full cycle
        envelope            = 'sinusoid';
        numPips             = 1;
        pipDur              = 0.500;
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
        function obj = set.DCoffset(obj,value)
            if abs(value) <= 1
                obj.DCoffset = value;
            else
                error('DCoffset property values must be within the [-1, 1] range, relative to maximum voltage')
            end
        end
        function obj = set.pipDur(obj,value)
            if value <= (obj.DCduration-obj.pipLatency) 
                obj.pipDur = value;
            else
                error('pipDur property values must be smaller than DCduration-pipLatency')
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
            pip = obj.makeSine(obj.carrierFreqHz,obj.pipDur, (obj.carrierPhase / obj.carrierFreqHz));
            
            % Calculate envelope
            sampsPerPip = length(pip);
            switch lower(obj.envelope)
                case {'none',''}
                    % pass back unchanged
                    return
                case {'sinusoid','sin','s'}
                    
                    
                      modEnvelope = (  1 + obj.modulationDepth * obj.makeSine(obj.modulationFreqHz,obj.pipDur, ...
                          (obj.modulationPhase / obj.modulationFreqHz))   )/(1+abs(obj.modulationDirection));  %1 is fixed amplitude of carrier signal 
                      
                      pip = (pip + abs(obj.modulationDirection))/(1+abs(obj.modulationDirection));
                      pip = modEnvelope.*pip;
                      
                      if obj.modulationDirection == -1
                          pip = -1*pip;
                      end
                      
                case {'rampup','r'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[0:1/((sampsPerPip)):1])';
                    modEnvelope(end) = [];
                    
                    modEnvelope = (modEnvelope + 1)/2;
                    pip = (pip + 1)/2;
                    pip = modEnvelope.*pip;
                    
                    if obj.modulationDirection == -1
                        pip = -pip;
                    end
                    
                case {'rampdown','d'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[0:1/((sampsPerPip)):1])';
                    modEnvelope(end) = [];
                    modEnvelope = flip(modEnvelope);

                    modEnvelope = (modEnvelope + 1)/2;
                    pip = (pip + 1)/2;
                    pip = modEnvelope.*pip;
                    
                    if obj.modulationDirection == -1
                        pip = -pip;
                    end
                    
                otherwise
                    error(['Envelope ' obj.Envelope ' not accounted for.']);
            end
            
            % generate pip train
            spacePip = [zeros(round((obj.ipi-obj.pipDur)*obj.sampleRate),1);pip];
            stimulus = [pip;repmat(spacePip,obj.numPips-1,1)];
            % Scale the stim to the maximum voltage in the amp
            maxFound = max(abs(stimulus));
            amplitudeCorrect = obj.amplitude * cf30(obj.carrierFreqHz);
            assert(amplitudeCorrect <= 1, 'Corrected amplitude as function of frequency exceeds maxVoltage. Reduce amplitude or maximum frequency')
            assert(amplitudeCorrect + abs(obj.DCoffset) <= 1, 'Stimulus command globally exceeding maxVoltage')
            stimulus = (stimulus/maxFound)*amplitudeCorrect;
            
            
            % add DCoffset
            startPadDCoffset = zeros(obj.sampleRate*obj.pipLatency,1);
            endPadDCoffset = zeros(obj.sampleRate*(obj.DCduration-obj.pipLatency)-length(stimulus),1);
            stimulus = [startPadDCoffset;stimulus;endPadDCoffset];
            stimulus = stimulus + obj.DCoffset;
            
            
            % scale with respect to maxVoltage
            stimulus = stimulus * obj.maxVoltage;
            
            % Add pause at the beginning and end of of the stim
            stimulus = obj.addPad(stimulus);
            
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            endPadDur = obj.totalDur - obj.DCduration - obj.startPadDur;
        end
    end    
end


