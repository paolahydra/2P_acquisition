function [metadata, M, ST] = stimulusManagerMaxi(varargin)
    if nargin >= 1
        runfolder = varargin{1};
        if nargin >= 2
            metadata = varargin{2};
            maxiReps = metadata.maxiReps; %temp fix
            maxiPreWL = metadata.maxiPreWL; % temp fix
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
    
    metadata.random = 1;
    
    
    
    
    for j = 1 : maxiReps  
        [M(j).metadata, M(j).stimuli, M(j).ALLstimuli] = stimulusInterpreterII(metadata, plotting);
        temp = zeros(maxiPreWL*metadata.fs,1);
        for jj= 1:length(M(j).ALLstimuli)
            temp= [temp; M(j).ALLstimuli(jj).stim.stimulus];
        end
        ST(j).stimulus = temp;
    end
end

