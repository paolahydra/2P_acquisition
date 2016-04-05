classdef PI_tonicDisplacement < AuditoryStimulus
    % subclass for static displacements
    
    properties
        time1           = 1; %slope consegues. time = 0 means square change (if any)
        voltage2        = 0.5;  %(normalized to maximum, range -1,1)
        time2        	= 4;    %tonic
        time3           = 1; %slope consegues. time = 0 means square change (if any)
        voltage4        = 1;    %(normalized to maximum, range -1,1)
        time4           = 4;    %tonic
        time5           = 2; %slope consegues. time = 0 means square change (if any)
        slopeshape      = 'parabolic';
    end
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        stimulus
    end
    
    methods       
        %%------Calculate Dependents-----------------------------------------------------------------
        function obj = set.voltage2(obj,value)
            if (abs(value) <= 1)
                obj.voltage2 = value;
            else
                error('Voltage properties values must be within [-1, 1] range, relative to maximum')
            end
        end
        function obj = set.voltage4(obj,value)
            if (abs(value) <= 1)
                obj.voltage4 = value;
            else
                error('Voltage properties values must be within [-1, 1] range, relative to maximum')
            end
        end
        
        function stimulus = get.stimulus(obj)      
            % build up the voltage function - core
            if strcmp(obj.slopeshape, 'parabolic') || strcmp(obj.slopeshape, 'p')
                % stim1
                xv = 0;
                yv = 0; %voltage0 - not necessary in equation in this context
                xp = obj.time1*obj.sampleRate;
                yp = obj.voltage2;
                %find coefficient a and parabola equation
                a = (yp-yv)/(xp-xv)^2;
                parabola = @(x) a*(x-xv).^2 +yv;
                x = linspace(0,obj.sampleRate*obj.time1, obj.sampleRate*obj.time1 +1);
                x(1) = []; %otherwise zero wuld be doubled
                stim1 = parabola(x); 
                
                % stim3
                yv = obj.voltage2; %voltage2
                xp = obj.time3*obj.sampleRate;
                yp = obj.voltage4;
                %find coefficient a and parabola equation
                a = (yp-yv)/(xp-xv)^2;
                parabola = @(x) a*(x-xv).^2 +yv; 
                x = linspace(0,obj.sampleRate*obj.time3, obj.sampleRate*obj.time3 +1);
                x(1) = []; %otherwise zero wuld be doubled
                stim3 = parabola(x); 
                
                % stim5
                yv = obj.voltage4; %voltage2
                xp = obj.time5*obj.sampleRate;
                yp = 0;
                %find coefficient a and parabola equation
                a = (yp-yv)/(xp-xv)^2;
                parabola = @(x) a*(x-xv).^2 +yv; 
                x = linspace(0,obj.sampleRate*obj.time5, obj.sampleRate*obj.time5 +1);
                x(1) = []; %otherwise zero wuld be doubled
                stim5 = parabola(x); 
            else
                stim1 = linspace(0, obj.voltage2, obj.sampleRate*obj.time1 +1);
                stim3 = linspace(obj.voltage2, obj.voltage4, obj.sampleRate*obj.time3 +1);
                stim5 = linspace(obj.voltage4, 0, obj.sampleRate*obj.time5 +1);
                stim1(1) = [];
                stim3(1) = [];
                stim5(1) = [];
            end
            stim2 = obj.voltage2 * ones(1, obj.sampleRate*obj.time2);   
            stim4 = obj.voltage4 * ones(1, obj.sampleRate*obj.time4);  
            stimulus = [stim1, stim2, stim3, stim4, stim5]';
            
            
            % Scale the stim to the maximum voltage in the amp
            stimulus = stimulus*obj.maxVoltage;
            
            % Add pause at the beginning of the stim
            stimulus = obj.addPad(stimulus);
            
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            endPadDur = round(obj.totalDur - (obj.time1 +obj.time2 +obj.time3 +obj.time4 +obj.time5) - obj.startPadDur);
        end
    end    
end


