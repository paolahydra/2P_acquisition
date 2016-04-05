function [metadata, varargout] = stimulusInterpreterII(metadata, plotting)
%% makes actual trials list, with properties;
% to be completed. Only supports random list for now.
metadata.trials = [];
metadata.totDurRun = 0;
if ~isfield(metadata, 'totalDur')
     a = AuditoryStimulus;
    metadata.totalDur = a.totalDur;
    delete(a)
end
if ~isfield(metadata, 'startPadDur')
     a = AuditoryStimulus;
    metadata.startPadDur = a.startPadDur;
    delete(a)
end
if ~isfield(metadata, 'fs')
     a = AuditoryStimulus;
    metadata.fs = a.sampleRate;
    delete(a)
end
if ~isfield(metadata, 'maxVoltage')
     a = AuditoryStimulus;
    metadata.maxVoltage = a.maxVoltage;
    delete(a)
end

countStim = 0;
countALLStim = 0;
metadata.haveSubstimuli = ones(1, length(metadata.stimuli));

starts = [1; cumsum(metadata.nRows(1:end-1))+1];
ends = cumsum(metadata.nRows);


% # of repetitions could be different across stimuli, so I'll loop.
for i = 1:length(metadata.stimuli)
    clear subcombs sub vals subindx
    %find substimuli
    rowCurrentStimulus = starts(i);
    rowSubProperties = rowCurrentStimulus+1 : ends(i);
    
    if ~isempty(rowSubProperties)
        %loop through and get parameters
        for js = 1 : length(rowSubProperties)
            %get property
            if isfield(metadata, 'full')
                sub(js).prop = metadata.full(rowSubProperties(js),2);
                %get values
                vals = metadata.full{rowSubProperties(js),3};
            else
                sub(js).prop = metadata.tdata(rowSubProperties(js),2);
                %get values
                vals = metadata.tdata{rowSubProperties(js),3};
            end
                
            if isnumeric(vals) %only happens for default values: always single values
                sub(js).values = vals;
                subindx{1,js} = 1;
            else
                %check if char string - easiest and improved.
                %[NEW CONSTRAIN IN DEFINING PROPERTIES: strings will
                %not contain numbers]
                % future TO BE IMPLEMENTED: set all (and only) strings as cells within {''}, so
                % that you can also define more string subproperties.
                if isempty(regexpi(vals, '\d')) %it's a char string, and it's only one (for now)
                    sub(js).values = vals;      %full string now!
                    subindx{1,js} = 1;
                else
                    sub(js).values = eval(vals);
                    subindx{1,js} = 1:length(sub(js).values);
                end
            end
        end
        
        % generate combinations
        subcombs = allcomb(subindx{:}); %each row a combination, each column a parameter and its value
        metadata.substimuli(i).subcombs = subcombs;
        if size(subcombs, 1) == 1
            metadata.haveSubstimuli(i) = 0;
        end
        for icombs = 1:size(subcombs, 1)
            countStim = countStim + 1;
            rep_supp = countStim * ones(1, metadata.repetitions(i)); %horiz vector, length as # repetitions
            metadata.trials = cat(2, metadata.trials, rep_supp);
            stimuli(countStim).stim = eval(metadata.stimuli{i}); %make specific stim
            stimuli(countStim).stim.startPadDur = metadata.startPadDur;
            stimuli(countStim).stim.totalDur = metadata.totalDur;
            stimuli(countStim).stim.sampleRate = metadata.fs;
            stimuli(countStim).stim.maxVoltage = metadata.maxVoltage;
            for iprop = 1:size(subcombs, 2)
                app = sub(iprop).values(subcombs(icombs, iprop));
                set( stimuli(countStim).stim, eval('sub(iprop).prop{1}'), app )
            end
            metadata.totDurRun = metadata.totDurRun + metadata.totalDur*metadata.repetitions(i);
            if plotting 
%             hf(i) = figure('WindowStyle', 'docked');
                stimuli(countStim).stim.plot;
            end
            % MOREOVER, repeat the actual stim as many times as the repetitions.
            for jj = 1:metadata.repetitions(i)
                countALLStim = countALLStim + 1;
                ALLstimuli(countALLStim).stim = eval(metadata.stimuli{i}); %make specific stim
                ALLstimuli(countALLStim).stim.startPadDur = metadata.startPadDur;
                ALLstimuli(countALLStim).stim.totalDur = metadata.totalDur;
                ALLstimuli(countALLStim).stim.sampleRate = metadata.fs;
                ALLstimuli(countALLStim).stim.maxVoltage = metadata.maxVoltage;
                for iprop = 1:size(subcombs, 2)
                    app = sub(iprop).values(subcombs(icombs, iprop));
                    set( ALLstimuli(countALLStim).stim, eval('sub(iprop).prop{1}'), app )
                end
            end
        end
    else
        countStim = countStim + 1;
        rep_supp = countStim * ones(1, metadata.repetitions(i)); %horiz vector, length as # repetitions
        metadata.trials = cat(2, metadata.trials, rep_supp);
        stimuli(countStim).stim = eval(metadata.stimuli{i}); %make specific stim
        stimuli(countStim).stim.startPadDur = metadata.startPadDur;
        stimuli(countStim).stim.totalDur = metadata.totalDur;
        stimuli(countStim).stim.sampleRate = metadata.fs;
        stimuli(countStim).stim.maxVoltage = metadata.maxVoltage;
        metadata.haveSubstimuli(i) = 0;
        metadata.totDurRun = metadata.totDurRun + metadata.totalDur*metadata.repetitions(i);
        if plotting
%             hf(i) = figure('WindowStyle', 'docked');
            stimuli(countStim).stim.plot;
        end
        % MOREOVER, repeat the actual stim as many times as the repetitions.
        for jj = 1 : metadata.repetitions(i)
            countALLStim = countALLStim + 1;
            ALLstimuli(countALLStim).stim = eval(metadata.stimuli{i}); %make specific stim
            ALLstimuli(countALLStim).stim.startPadDur = metadata.startPadDur;
            ALLstimuli(countALLStim).stim.totalDur = metadata.totalDur;
            ALLstimuli(countALLStim).stim.sampleRate = metadata.fs;
            ALLstimuli(countALLStim).stim.maxVoltage = metadata.maxVoltage;
        end
    end
end
randKey = randperm(length(metadata.trials));
metadata.trials = metadata.trials(randKey);
ALLstimuli = ALLstimuli(randKey);

if nargout >= 2
    varargout{1} = stimuli;
end
if nargout == 3
    varargout{2} = ALLstimuli;
end
end
