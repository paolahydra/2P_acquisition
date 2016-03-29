classdef Stimulus2CorrectAmplitude < AuditoryStimulus
    % Basic subclass for making (amplitude modulated) pips
    % put rng('shuffle') in startup
    %with correction

    
    properties
        AM                  = 0;
        amplitude           = 0.25;      % [0,1], relative to max voltage
        singleStimDur       = 1;    % seconds
        ipi                 = 0;    % 8 datapoints at 15.6250Hz span 0.512sec
        pipDur              = 10;
        carrPhase           = 0;    % fixed within
        randomize           = 0;
    end
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        stimulus
    end
    properties (Dependent = false, SetAccess = private)
        carrierRange        = 60:80:800;
        carriers
    end
    
    methods
        %% constructor method
        function obj = Stimulus2CorrectAmplitude()
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
            load('C:\Users\Paola\Dropbox\Data\correctorFunction30um.mat')
            % Make pip
            stimulus = [];
            for i = 1:length(obj.carriers)
                pipT = obj.makeSine(obj.carriers(i),obj.singleStimDur,(obj.carrPhase / obj.carriers(i)));
                if obj.AM
                    modEnvelope = 1 + obj.makeSine(1/obj.singleStimDur,obj.singleStimDur, ( -1/4 * obj.singleStimDur));
                    pipT = modEnvelope.*pipT;
                end
                maxFound = max(pipT);
                amplitudeCorrect = obj.amplitude * cf30(obj.carriers(i));
                assert(amplitudeCorrect <= 1, 'Corrected amplitude as function of frequency exceeds maxVoltage. Reduce amplitude or maximum frequency')
                pipT = (pipT/maxFound)*amplitudeCorrect;
                stimulus = cat(1, stimulus, pipT);% Scale the stim to the maximum voltage in the amp
                
                pipT = zeros(obj.ipi * obj.sampleRate,1);
                stimulus = cat(1, stimulus, pipT);
            end
            
            % scale with respect to maxVoltage
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
    if obj.randomize
        carrFrequencies = carrFrequencies(randperm(length(carrFrequencies)));
    end
    carriers = carrFrequencies(1:numSt);
end
