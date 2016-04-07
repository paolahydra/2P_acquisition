classdef PipStimulus < AuditoryStimulus
    % Basic subclass for making (amplitude modulated) pips
    %
    % SLH 2014
    
    properties
        modulationDepth     = 1;
        modulationFreqHz    = 2;
        carrierFreqHz       = 300;
        envelope            = 'cos-theta';
        numPips             = 100;
        pipDur              = 0.015;
        ipi                 = 0.034;
    end
    
    properties (Dependent = true, SetAccess = private)
        cyclesPerPip
        stimulus
    end
    
    methods
       
        %%------Calculate Dependents-----------------------------------------------------------------
        function cyclesPerPip = get.cyclesPerPip(obj)
            cyclesPerPip = obj.pipDur / (1/obj.carrierFreqHz);
            if ~isinteger(mod(cyclesPerPip,0.5))
                error('numCyclesPerPip must be divisible by 0.5')
            end
        end
        
        function stimulus = get.stimulus(obj)
            
            % Make pip
            pip = obj.makeSine(obj.carrierFreqHz,obj.pipDur);
            
            % Calculate envelope
            sampsPerPip = length(pip);
            switch lower(obj.envelope)
                case {'none',''}
                    % pass back unchanged
                    return
                case {'sinusoid','sin'}
                    modEnvelope = obj.modulationDepth*sin(pi*[0:1/(sampsPerPip-1):1])';
                case {'triangle','tri'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[.25:1/(2*(sampsPerPip-1)):.75],.5)';
                case {'rampup'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[.5:1/(2*(sampsPerPip-1)):1])';
                case {'rampdown'}
                    modEnvelope = obj.modulationDepth*sawtooth(2*pi*[0:1/(2*(sampsPerPip-1)):.5],0)';
                case {'cos-theta'}
                    sampsPerRamp = floor(sampsPerPip/10);
                    ramp = sin(linspace(0,pi/2,sampsPerRamp));
                    modEnvelope = [ramp,ones(1,sampsPerPip - sampsPerRamp*2),fliplr(ramp)]';
                otherwise
                    error(['Envelope ' obj.Envelope ' not accounted for.']);
            end
            
            % apply the envelope to pip
            pip = modEnvelope.*pip;
            
            % generate pip train
            spacePip = [zeros(round((obj.ipi-obj.pipDur)*obj.sampleRate),1);pip];
            stimulus = [pip;repmat(spacePip,obj.numPips-1,1)];
            
            % Scale the stim to the maximum voltage in the amp
            stimulus = stimulus*obj.maxVoltage;
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
        end
        
        
        
    end
    
end


