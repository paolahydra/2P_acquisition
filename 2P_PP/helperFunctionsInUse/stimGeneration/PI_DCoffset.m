classdef PI_DCoffset < AuditoryStimulus
    
    properties
        DCoffset            = 0.5;      % [0,1], relative to max voltage
        DCduration          = 3;        % counts as stimDuration
        lowpassfilter       = 0;
    end
    
    properties (Dependent = true, SetAccess = private)
        stimulus
        totalDur
    end
    
    methods       
        %%------Calculate Dependents-----------------------------------------------------------------
        function obj = set.DCoffset(obj,value)
            if abs(value) <= 1
                obj.DCoffset = value;
            else
                error('DCoffset property values must be within the [-1, 1] range, relative to maximum voltage')
            end
        end
        
        function stimulus = get.stimulus(obj)    
            stimulus = zeros(obj.sampleRate*obj.DCduration,1);
            stimulus = stimulus + obj.DCoffset;            
            
            % scale with respect to maxVoltage
            stimulus = stimulus * obj.maxVoltage;
            
            % Add pause at the beginning and end of of the stim
            stimulus = obj.addPad(stimulus);
            
            
            if obj.lowpassfilter
                d = designfilt('lowpassfir','FilterOrder',10,'CutoffFrequency',100/(obj.sampleRate/2));
                stimulus = filtfilt(d,stimulus);
            end
        end
        
        function totalDur = get.totalDur(obj)
            totalDur = obj.DCduration + obj.startPadDur + obj.endPadDur;
        end        
%         function endPadDur = get.endPadDur(obj)
%             %calculate remaining interval
%             endPadDur = obj.totalDur - obj.DCduration - obj.startPadDur;
%         end
    end    
end


