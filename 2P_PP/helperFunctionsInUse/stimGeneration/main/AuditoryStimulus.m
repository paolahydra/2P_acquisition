classdef AuditoryStimulus < hgsetget %matlab.mixin.SetGet % r2015a
    % Basic superclass for auditory stimuli that holds samplerate and a plotting function
    %
    % SLH 2014
    
    properties
        sampleRate      = 4E4;
        startPadDur     = 2.5;    %seconds
        minEndPadDur    = 0.5;    %seconds
        totalDur        = 13;   %seconds  
        speakerOrder    = {'L','M','R'}; % From fly's point of view
        speaker         = 2;
        probe           = 'off';
        maxVoltage      = 0.5; %do not change
    end
    
    properties (Dependent = true, SetAccess = private)
        maxStimDur
        stimDur     %this gives a common, general property wich is easily accessible
    end
    
    methods       
        
        %%------Calculate Dependents-----------------------------------------------------------------
        function stimDur = get.stimDur(obj)
            stimDur = obj.totalDur - obj.startPadDur - obj.endPadDur;
        end
        
        function maxStimDur = get.maxStimDur(obj)
            maxStimDur = obj.totalDur - obj.startPadDur - obj.minEndPadDur;
        end
        
        %%------Common Utilities---------------------------------------------------------
        function carrier = makeSine(obj,frequency,dur, varargin)
            if nargin > 3
                phase = varargin{1};
            else
                phase = 0;
            end
            ts = (0 : (1/obj.sampleRate) : dur - (1/obj.sampleRate) ) + phase;
            carrier = sin(2*pi*frequency*ts)';
        end
        
        function static = makeStatic(obj,dur)
            static = ones(obj.sampleRate*dur,1);
        end
        
        
        %%-----Add Pad----------------------------------------------------------------------
        function stimulus = addPad(obj,stimulus)
            startPad = zeros(round(obj.sampleRate*obj.startPadDur),1);
            endPad = zeros(round(obj.sampleRate*obj.endPadDur),1);
            stimulus = [startPad;stimulus;endPad];
        end
        
        %%-----Record digital ON - OFF stimulus.
        function digitalStim = makeDigital(obj)
            startPad = zeros(round(obj.sampleRate*obj.startPadDur),1);
            endPad = zeros(round(obj.sampleRate*obj.endPadDur),1);
            onPadDur = length(obj.stimulus) - (length(startPad) + length(endPad));
            digital = ones(onPadDur,1);
            digitalStim = [startPad;digital;endPad];
        end
        
        %%-----Playing----------------------------------------------------------------------
        function [varargout] = play(obj)
            player = audioplayer(obj.stimulus, obj.sampleRate);
            play(player)
            varargout{1} = player;
        end
        
        %%------Plotting--------------------------------------------------------------------
        function [handle,plotHandle] = plot(obj,varargin)
            if nargin >1
                % get figure hangle
                handle = varargin{1};
                if isa(handle, 'matlab.ui.Figure')
                    set(handle, 'Color',[1 1 1],'Name','AuditoryStimulus');
                end
            else
                handle = figure('Color',[1 1 1],'Name','AuditoryStimulus');
                
            end
            if nargin >2
                titlefig = varargin{2};
            else
                titlefig = 'Current Auditory Stimulus';
            end
            
            fontSize = 13;
            lineWidth = 1; 
            timeInS = (1/obj.sampleRate):(1/obj.sampleRate):(1*length(obj.stimulus)/obj.sampleRate);
            
            plotHandle = plot(timeInS,obj.stimulus);
            set(plotHandle,'LineWidth',lineWidth)
            
            box off; axis on;
            set(gca,'TickDir','Out')
            title(titlefig, 'FontSize', fontSize, 'Interpreter', 'none')
            ylabel('Amplitude (V)','FontSize',fontSize)
            xlabel('Time (seconds)','FontSize',fontSize)
            ylim([-obj.maxVoltage, obj.maxVoltage])
        end
    end
    
end
