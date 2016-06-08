classdef CourtshipSong_B < AuditoryStimulus
    % Basic subclass for courtship song
    %
    % AVB 2015
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
            [stimulus, obj.sampleRate] = audioread('C:\Users\Paola\Documents\GitHub\2P_acquisition\2P_PP\helperFunctionsInUse\stimGeneration\usableSnippets\LongCourtshipSong_Standard.wav');

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


