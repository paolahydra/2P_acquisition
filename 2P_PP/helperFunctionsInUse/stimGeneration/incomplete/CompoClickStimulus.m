classdef CompoClickStimulus < AuditoryStimulus
    % Basic subclass for making series of clicks 
    
    properties
        numClicks           = 20;        % number of clicks within the same stimulus
        ici                 = 0.50;    % inter-click-interval?
        amplitudes          = [3, 1; 2, 3; 1, 4];   %relative
        freqGauss           = [1000, 500, 400];          %should be of the same length as rows in amplitudes, at least
        expGauss            = [1, 0.5, 0.4];             %should be of the same length as rows in amplitudes, at least
        flipHor             = [0, 0, 0];                 %logic, should be of the same length as rows in amplitudes, at least
        tend                = 0.001;
    end
    
    properties (Dependent = true, SetAccess = private)
        substimulus
        endPadDur
        stimulus
    end
    
    methods      
        %%------Calculate Dependents-----------------------------------------------------------------       
        function substimulus = get.substimulus(obj)            
            % Make composite click
            T = 0 : 1/obj.sampleRate : obj.tend;
            click = [];
            for i = 1 : size(obj.amplitudes, 1)
                a = linspace(0, obj.tend, size(obj.amplitudes, 2));      
                D = [a; obj.amplitudes(i,:)]';
                Y = pulstran(T,D,'gauspuls',obj.freqGauss(i),obj.expGauss(i));
                if obj.flipHor(i)
                    Y = fliplr(Y);
                end
                click = cat(2, click, Y);   
            end
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