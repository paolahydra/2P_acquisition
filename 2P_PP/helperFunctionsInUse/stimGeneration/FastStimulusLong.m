classdef FastStimulusLong < AuditoryStimulus
    % Basic subclass for making (amplitude modulated) pips
    % put rng('shuffle') in startup

    
    properties
        AM                  = 1;
        amplitude           = 0.2;      % [0,1], relative to max voltage
        singleStimDur       = 0.500;    % seconds
        ipi                 = 0.524; %0.262;    % 8 datapoints at 15.6250Hz span 0.512sec
        pipDur              = 10;
        carrPhase           = -0.25;    % fixed within
    end
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        stimulus
    end
    properties (Dependent = false, SetAccess = private)
        carrierRange        = 240:20:280;
        carriers
    end
    
    methods
        %% constructor method
        function obj = FastStimulusFast()
            obj = obj@AuditoryStimulus;
            obj.carriers = randomizefrequencies(obj);
        end
        
        %% Calculate Dependents
        function obj = set.amplitude(obj,value)
            if (value > 0  &&  value <= 1)
                obj.amplitude = value;
            else
                error('Amplitude property values must be within the (0, 1] range, relative to maximum voltage')
            end
        end
        
        
        function stimulus = get.stimulus(obj)  
            % Make pip
            stimulus = [];
            for i = 1:length(obj.carriers)
                pipT = obj.makeSine(obj.carriers(i),obj.singleStimDur,(obj.carrPhase / obj.carriers(i)));
                if obj.AM
                    modEnvelope = 1 + obj.makeSine(1/obj.singleStimDur,obj.singleStimDur, ( -1/4 * obj.singleStimDur));
                    pipT = modEnvelope.*pipT;
                end
                stimulus = cat(1, stimulus, pipT);
                pipT = zeros(obj.ipi * obj.sampleRate,1);
                stimulus = cat(1, stimulus, pipT);
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
            endPadDur = obj.totalDur - obj.pipDur - obj.startPadDur;
        end
    end    
end

function carriers = randomizefrequencies(obj)
    numSt = round(obj.pipDur / (obj.singleStimDur + obj.ipi));
    repPre = ceil(numSt/length(obj.carrierRange));
    carrFrequencies = reshape(repmat(obj.carrierRange, repPre,1),1,[]);
    carrFrequencies = carrFrequencies(randperm(length(carrFrequencies)));
    carriers = carrFrequencies(1:numSt);
end
