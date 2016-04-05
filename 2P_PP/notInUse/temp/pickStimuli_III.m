function metadata = pickStimuli_III()
%pickStimuli Summary of this function goes here
%   Detailed explanation goes here

path2StimFolder = which('PipStimulus');
[path2StimFolder,~,~] = fileparts(path2StimFolder);
stimulus_set = uipickfiles('FilterSpec', path2StimFolder);
% parse stimuli
for i = 1:length(stimulus_set)
    [~,trials.stimSet{i},~] = fileparts(stimulus_set{i});
    stim = eval(trials.stimSet{i});
    trials.stimDurs{i} = stim.totalDur;
    mc = metaclass(stim);
    hasDef = cell2mat({mc.PropertyList.HasDefault});
    n = find(hasDef==0,1)-1;
    trials.properties(i).parameters = {mc.PropertyList(1:n,1).Name};
    trials.properties(i).defValues = {mc.PropertyList(1:n,1).DefaultValue};
end

%decide repetitions (GUI):
metadata = StimulusControllerIII(trials);
metadata.stimuli = trials.stimSet;
metadata.fs = stim.sampleRate; %redundant, but ok
end



% metadata = StimulusControllerII(trials);