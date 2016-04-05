simpleClick = 

  CompoClickStimulusII with properties:

       numClicks: 1
             ici: 0.0100
      amplitudes: [3x1 double]
       freqGauss: [1000 500 900]
        expGauss: [1 0.5000 0.8000]
         flipHor: [0 0 0]
            tend: 0.0025
        stimulus: [101x1 double]
      sampleRate: 40000
     startPadDur: 0
       endPadDur: 0
    speakerOrder: {'L'  'M'  'R'}
         speaker: 2
           probe: 'off'
      maxVoltage: 0.5000
        totalDur: 0.0025
         stimDur: 0.0025
        
         
         
%         fast,  faster onset and offset:
stim = 

  CompoClickStimulusII with properties:

       numClicks: 1
             ici: 0.0100
      amplitudes: [3x1 double]
       freqGauss: [1000 500 900]
        expGauss: [1 0.5000 0.8000]
         flipHor: [0 0 1]
            tend: 0.0020
        stimulus: [81x1 double]
      sampleRate: 40000
     startPadDur: 0
       endPadDur: 0
    speakerOrder: {'L'  'M'  'R'}
         speaker: 2
           probe: 'off'
      maxVoltage: 0.5000
        totalDur: 0.0020
         stimDur: 0.0020
         
         