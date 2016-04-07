classdef noStimulus < AuditoryStimulus
    % Basic subclass for making just the pad and no stimulus
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        stimulus
    end
    
    methods
        
        %%------Calculate Dependents-----------------------------------------------------------------
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            endPadDur = obj.totalDur - obj.startPadDur;
        end

        function stimulus = get.stimulus(obj)
            % Make a full-zeros stimulus
            stimulus = [];
            stimulus = obj.addPad(stimulus);
        end
        
    end
end
