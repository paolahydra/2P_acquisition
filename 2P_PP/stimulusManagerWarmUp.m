function [metadata, stimuli] = stimulusManagerWarmUp(varargin)
    if nargin >= 1
        runfolder = varargin{1};
        if nargin >= 2
            metadata = varargin{2};
            metadata = StimulusController_warmUp(runfolder, metadata);
        else
            metadata = StimulusController_warmUp(runfolder);
        end
    else
        metadata = StimulusController_warmUp();
    end 
    
    if nargin >=3
        plotting = varargin{3};
    else
        plotting = 0;
    end
    
    metadata.random = 1;
    [metadata, stimuli] = stimulusInterpreter(metadata, plotting);
end

