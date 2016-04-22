function [metadata, stimuli, ALLstimuli] = stimulusManager(varargin)
    if nargin >= 1
        runfolder = varargin{1};
        if nargin >= 2
            metadata = varargin{2};
            metadata = StimulusController(runfolder, metadata);
        else
            metadata = StimulusController(runfolder);
        end
    else
        metadata = StimulusController();
    end 
    
    if nargin >=3
        plotting = varargin{3};
    else
        plotting = 0;
    end

    [metadata, stimuli, ALLstimuli] = stimulusInterpreterII(metadata, plotting);
end

