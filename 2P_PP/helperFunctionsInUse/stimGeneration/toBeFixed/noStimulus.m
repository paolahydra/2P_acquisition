classdef noStimulus < AuditoryStimulus
    % Basic subclass for making just the pad and no stimulus'
%     
%     need to add zeros as an effective fake stimulus if going to use it
    
    properties (Dependent = true, SetAccess = private)
%         endPadDur
        stimulus
        totalDur
    end
    
    methods
        
        %%------Calculate Dependents-----------------------------------------------------------------
%         function endPadDur = get.endPadDur(obj)
%             %calculate remaining interval
%             endPadDur = obj.totalDur - obj.startPadDur;
%         end

        function stimulus = get.stimulus(obj)
            % Make a full-zeros stimulus
            stimulus = [];
            stimulus = obj.addPad(stimulus);
        end
        
        function totalDur = get.totalDur(obj)
            totalDur =  obj.startPadDur + obj.minEndPadDur; %add zeros
        end        
    end
end
