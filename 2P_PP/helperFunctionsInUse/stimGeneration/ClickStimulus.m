classdef ClickStimulus < AuditoryStimulus
    % Basic subclass for making series of clicks 
    
    properties
        maxClicksDur        = 8;        % seconds
        freqHz              = 10;       % frequency of click repetition. Number of stimuli conseques.
        freqGauss           = 250;      %700 ?
        direction           = 1;        % flip vertically?
        expGauss            = 0.4;      %0.4 ? 0.3-1, 1 piu' tonfo. Meno di 0.3, sweep
        tend                = 0.025;    %must be less than 1. 0.025 barely fits symmetrical at 250Hz.
        D                   = 1;        %can be 0: descending half; 
                                              % 0.5, symmetrical 
                                              % 1, ascending half.
    end
    
    properties (Dependent = true, SetAccess = private)
        click
        effectiveFreqHz
        numClicks
        substimulus
        endPadDur
        stimulus
    end
    
    methods      
        %%------Calculate Dependents-----------------------------------------------------------------       
        function click = get.click(obj)            
            % Make click
            T = 0 : 1/obj.sampleRate : 1;
%             D = [obj.tend; 1]';
            click = pulstran(T,obj.D,'gauspuls',obj.freqGauss,obj.expGauss);
            switch obj.D
                case 0
                    click = click(1:round(obj.tend*obj.sampleRate));
                case 0.5
                    click = click(round(length(click)/2) - round(obj.tend*obj.sampleRate/2) : ...
                                  round(length(click)/2) + round(obj.tend*obj.sampleRate/2)-1);
                case 1
                    click = click(end-round(obj.tend*obj.sampleRate)+1 : end);
            end
%             %crop zeros at the start of the array to sinchronize onsets
%             %(rather than peaks). DOESN"T WORK UNLESS I FIT THE EXPONENTIAL
%             %AND SET A ZERO...
%             firstSig = find(click~=0, 1);
%             if firstSig > 1
%                 click(1:firstSig-1) = [];
%             end
            %add zeros at the end
            clicklength = obj.sampleRate/obj.freqHz;
            if clicklength > length(click)
                %add remaining space
                click = [click, zeros(1, round(clicklength - obj.tend*obj.sampleRate)) ];
            end
                 
            % Scale the stim to the maximum voltage in the amp
            maxFound = max(click);
            click = (click/maxFound)*obj.maxVoltage;
            
            if obj.direction == -1
                click = -click;
            end
        end
        
        function effectiveFreqHz = get.effectiveFreqHz(obj)
            effectiveFreqHz = obj.sampleRate / length(obj.click);
        end
        
        function numClicks = get.numClicks(obj)
            %how many can you fit?
            numClicks = floor( (obj.maxClicksDur*obj.sampleRate) / length(obj.click) );
        end
        
        function substimulus = get.substimulus(obj)
            substimulus = repmat(obj.click, 1, obj.numClicks);
            substimulus = substimulus';
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            stimDur = ceil(length(obj.substimulus)/obj.sampleRate);
            endPadDur = round(obj.totalDur - stimDur - obj.startPadDur);
        end
        
        function stimulus = get.stimulus(obj)
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(obj.substimulus);
        end        
    end    
end