classdef fakeChirp < AuditoryStimulus
    % Basic subclass for courtship song
    %
    % AVB 2015
    
    %% fix for frequencies
      
    properties
        startFrequency  = 200;
        corrector       = 0.6;
        chirpLength     = 8;
        amplitude       = 1; 
    end
    
    properties (Dependent = true, SetAccess = private)
%         endPadDur
        stimulus
        totalDur
    end
    
    methods
        %%------Constructor-----------------------------------------------------------------
        function stimulus = get.stimulus(obj)
            stimTime = (1/obj.sampleRate):(1/obj.sampleRate):obj.chirpLength;
            stimulus = chirp(stimTime,obj.startFrequency,stimTime(end),obj.startFrequency)';
%             spectrogram(y,256,250,256,obj.sampleRate,'yaxis')
            
            % Calculate envelope
            sampsPerChirp = length(stimulus);
            sampsPerRamp = floor(sampsPerChirp/10);
            ramp = sin(linspace(0,pi/2,sampsPerRamp));
            modEnvelope = [ramp,ones(1,sampsPerChirp - sampsPerRamp*2),fliplr(ramp)]';

            % apply the envelope to pip
            stimulus = modEnvelope.*stimulus;
            
            % Calculate ramp down 
            ramp_correct = linspace(obj.corrector,obj.corrector,sampsPerChirp)';
            stimulus = ramp_correct.*stimulus; 
            
            % Scale the stim to the maximum voltage in the amp
%             maxFound = max(stimulus);
            stimulus = (stimulus)*obj.amplitude;
            stimulus = stimulus * obj.maxVoltage;
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
        end
%         
%         function endPadDur = get.endPadDur(obj)
%             %calculate remaining interval
%             endPadDur = obj.totalDur - obj.chirpLength - obj.startPadDur;
%         end
        function totalDur = get.totalDur(obj)
            totalDur = obj.chirpLength + obj.startPadDur + obj.endPadDur;
        end   
                
        %%------Plot Spectogram--------------------------------------------------------------------
        function spectPlot(obj,varargin)
            spectrogram(obj.stimulus,128,64,0:10:1500,obj.sampleRate,'yaxis');
            box off; axis on;
            set(gca,'TickDir','Out')
            title('Current Auditory Stimulus','FontSize',obj.defaultFontSize)
            ylabel('Frequency (Hz)','FontSize',obj.defaultFontSize)
            xlabel('Time (seconds)','FontSize',obj.defaultFontSize)
        end
        
    end
    
end