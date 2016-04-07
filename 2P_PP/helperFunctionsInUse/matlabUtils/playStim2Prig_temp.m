%% play stimulus 2p rig (after setting up nidaq)

stim = stimuli(1).stim;
stim.plot;


extTrig = ones(size(stim.stimulus));
extTrig(1) = 0;
extTrig(end) = 0;
%
queueOutputData(s,[stim.stimulus extTrig]); %check channel order and everything
data = s.startForeground;
close