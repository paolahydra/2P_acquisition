classdef Chirp < AuditoryStimulus
    % Basic subclass for courtship song
    %
    % AVB 2015
    
    properties
        startFrequency      = 90;
        endFrequency        = 1500;
        chirpLength         = 10;
        envelopeCorrection  = 0;
    end
    
    properties (Dependent = true, SetAccess = private)
        endPadDur
        stimulus
    end
    
    methods
        %%------Constructor-----------------------------------------------------------------
        function stimulus = get.stimulus(obj)
            stimTime = (1/obj.sampleRate):(1/obj.sampleRate):obj.chirpLength;
            stimulus = chirp(stimTime,obj.startFrequency,stimTime(end),obj.endFrequency)';
%             spectrogram(y,256,250,256,obj.sampleRate,'yaxis')

            % this should be done when using a speaker and should be
            % calibrated with the ultimate goal of equaling the particle
            % velocity produced at the varying frequencies.
            
            %or even to correct for piezo nonlinearities
            
            if obj.envelopeCorrection
                % Calculate envelope
                sampsPerChirp = length(stimulus);
                sampsPerRamp = floor(sampsPerChirp/10);
                ramp = sin(linspace(0,pi/2,sampsPerRamp));
                modEnvelope = [ramp,ones(1,sampsPerChirp - sampsPerRamp*2),fliplr(ramp)]';
                
                % apply the envelope to pip
                stimulus = modEnvelope.*stimulus;
                
                % Calculate ramp down
                rampdown = linspace(1,0.25,sampsPerChirp)';
                stimulus = rampdown.*stimulus;
            end
            
            % Scale the stim to the maximum voltage in the amp
            stimulus = stimulus*obj.maxVoltage;
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
        end
        
        function endPadDur = get.endPadDur(obj)
            %calculate remaining interval
            endPadDur = obj.totalDur - obj.chirpLength - obj.startPadDur;
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