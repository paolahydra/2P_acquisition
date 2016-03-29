classdef PulseSong < AuditoryStimulus
    % Basic subclass for courtship song
    %
    % AVB 2015
    
    properties (Dependent = true, SetAccess = private)
        stimulus
    end
    
    methods
        %%------Constructor-----------------------------------------------------------------
        function stimulus = get.stimulus(obj)
            % Read in courtship song recording
            [stimulus, obj.sampleRate] = audioread('C:\Users\Alex\Documents\GitHub\auditoryExpts\stimGeneration\courtshipSamps\PulseSongRepeat_Standard.wav');
            
            % Make stimulus a normal length
            stimToAdd = obj.sampleRate - rem(length(stimulus),40000);
            stimulus = [stimulus;zeros(stimToAdd,1)];
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
        end
        
    end
    
end