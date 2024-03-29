function [metadata, M, ST] = stimulusManagerMaxi(varargin)
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
    
    for j = 1 : metadata.maxiReps  
        [M(j).metadata, M(j).stimuli, M(j).ALLstimuli] = stimulusInterpreterII(metadata, plotting);
        tempSt = zeros(metadata.maxiPreWL*metadata.fs,1);
        tempDig = tempSt;
        for jj= 1:length(M(j).ALLstimuli)
            tempSt  = [tempSt;  M(j).ALLstimuli(jj).stim.stimulus];
            digital = M(j).ALLstimuli(jj).stim.makeDigital;
            tempDig = [tempDig;  digital];
        end
        ST(j).stimulus  = tempSt;
        ST(j).digital   = tempDig;
    end
end

