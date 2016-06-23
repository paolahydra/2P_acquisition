classdef Broadband_8 < AuditoryStimulus
    
    properties
        sineAmplitude        = 0.2;  
    end
    properties (Dependent = true, SetAccess = private)
        stimulus
        totalDur
    end
    
    methods
        %%------Constructor-----------------------------------------------------------------
        function stimulus = get.stimulus(obj)
            % Read in courtship song recording
            g = getpref;
            [stimulus, obj.sampleRate] = audioread(g.broadBandSnippets.CourtshipSong_B);
            stimulus = stimulus(65860:65860+4e4);
            stimulus(end) = [];
            
            maxFound = max(abs(stimulus));
            stimulus = (stimulus/maxFound);
            sinePeak = 0.2; %given the filepath and the normalization. Approximative, more like 90prctile than peak.
            if obj.sineAmplitude < sinePeak
                scalingFactor = obj.sineAmplitude/sinePeak; 
                stimulus = stimulus.*scalingFactor;
            end
            
            assert(max(abs(stimulus)) <= 1, 'Amplitude exceeds maxVoltage.')
            stimulus = stimulus * obj.maxVoltage;

            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
        end
        
        function totalDur = get.totalDur(obj)
            stimdur = length(obj.stimulus)/obj.sampleRate;
            totalDur = stimdur + obj.startPadDur + obj.endPadDur;
        end
        
    end
    
end


