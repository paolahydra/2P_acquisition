classdef ClickStimulus < AuditoryStimulus
    % Basic subclass for making series of clicks 
    
    properties
        numClicks           = 20;        % number of clicks within the same stimulus
        ici                 = 0.50;    % inter-click-interval?
        freqGauss           = 700;      %700 ?
        expGauss            = 0.4;      %0.4 ? 0.3-1, 1 piu' tonfo. Meno di 0.3, sweep
        tend                = 0.01;
    end
    
    properties (Dependent = true, SetAccess = private)
        substimulus
        endPadDur
        stimulus
    end
    
    methods      
        %%------Calculate Dependents-----------------------------------------------------------------       
        function substimulus = get.substimulus(obj)            
            % Make click
            T = 0 : 1/obj.sampleRate : obj.tend;
            D = [obj.tend; 1]';
            click = pulstran(T,D,'gauspuls',obj.freqGauss,obj.expGauss);
            % generate click train
            spacePip = [zeros(round(obj.ici*obj.sampleRate)+1,1);click'];
            substimulus = [click';repmat(spacePip,obj.numClicks-1,1)];        
            % Scale the stim to the maximum voltage in the amp
            maxFound = max(substimulus);
            substimulus = (substimulus/maxFound)*obj.maxVoltage;
            substimulus = substimulus(1 : floor(length(substimulus)/obj.sampleRate) * obj.sampleRate);
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            stimDur = length(obj.substimulus)/obj.sampleRate;
            endPadDur = obj.totalDur - stimDur - obj.startPadDur;
        end
        
        function stimulus = get.stimulus(obj)
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(obj.substimulus);
        end        
    end    
end