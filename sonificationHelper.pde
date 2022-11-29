import beads.*;

TextToSpeechMaker ttsMaker;
Gain ttsGain; 
boolean songPlayed;

boolean ttsCheck;
boolean muscleCheck;
boolean trackCheck;
boolean playCheck;

double trackTimer;
//wave stuff
WavePlayer muscleContractTone;

Glide muscleContractGlide;
Gain muscleContractGain;
Glide muscleContractGainGlide;


//master gain
Gain masterGain;
Glide masterGainGlide;


double waveTimer;

boolean setEnvelope;

//sampleplayers
SamplePlayer track;
double trackLength;

Gain trackGain;
Glide trackGainGlide;

Bead trackEndListener;
Glide trackRateGlide;

// filters
BiquadFilter lowPassFilter;
Glide lowPassGlide;

BiquadFilter highPassFilter;
Glide highPassGlide;

// envelopes
Envelope envelope;

// panner
Panner panner;
Glide pannerGlide;

void setupAudio() {
  setupMasterGain();
  setupUgens();
  setupSamplePlayers();
  setupWavePlayers();
  setupInputs();
  ac.out.addInput(masterGain);
}

void setupMasterGain() {
  masterGainGlide = new Glide(ac, 1.0, 1.0);  
  masterGain = new Gain(ac, 2, masterGainGlide);
  
}

void setupUgens() {
  // filters
  highPassGlide = new Glide(ac, 10.0, 500);
  highPassFilter = new BiquadFilter(ac, BiquadFilter.HP, highPassGlide, .5);
  
  
  
  lowPassGlide = new Glide(ac, 10.0, 500);
  lowPassFilter = new BiquadFilter(ac, BiquadFilter.LP, lowPassGlide, .5);
  
  
  // envelopes
  envelope = new Envelope(ac);
  
  // panner
  pannerGlide = new Glide(ac, 2, 5);
  panner = new Panner(ac, pannerGlide);
}

void setupSamplePlayers() {
  ttsMaker = new TextToSpeechMaker();
  
  track = getSamplePlayer("AllSpice.wav");
  
  trackLength = track.getSample().getLength();
  
  trackRateGlide = new Glide(ac, 0, 500);
  
  track.setRate(trackRateGlide);
  
  trackGainGlide = new Glide(ac, .3 , 1.0);
  trackGain = new Gain(ac, 1 , trackGainGlide);
  
   trackEndListener = new Bead() {
   public void messageReceived(Bead message) {
      SamplePlayer sp = (SamplePlayer) message;
      sp.setEndListener(null);
      //setPlaybackRate(0,true);
    }
   };
  
  
}

void setupWavePlayers() {
  muscleContractGlide = new Glide(ac, 200.0, 0);
  muscleContractTone = new WavePlayer(ac, muscleContractGlide, Buffer.SINE);
  
  muscleContractGain = new Gain(ac, 2, 0);
  
  
  
}

public void waveCheck() {
  if(muscleCheck == true && waveTimer <= 30) {
    if(muscleContractGain.getGain() == 0) {
      envelope.addSegment(.3, 1, 1);
      envelope.addSegment(0, 100, 1);
      muscleContractGain.setGain(envelope);
    }
    waveTimer += 1;

  } else if (waveTimer >= 30) {
    muscleCheck = false;
    waveTimer = 0;
    envelope.clear();
    muscleContractGain.setGain(0.0);
  }
}

public void trackCheck() {
  if(trackCheck == true && trackTimer <= 75) {
    trackGainGlide.setValue(.1);
    trackTimer +=1;
  } else if (trackTimer >= 75) {
    trackCheck = false;
    trackGainGlide.setValue(.3);
    trackTimer = 0;
  }
}
  
public void addEndListener() {
  if (track.getEndListener() == null) {
    track.setEndListener(trackEndListener);
  }
}

public void setPlaybackRate(float rate, boolean immediately) {
  if (track.getPosition() < 0) {
    track.reset();
  }
  if (immediately) {
    trackRateGlide.setValueImmediately(rate);
  }
  else {
    trackRateGlide.setValue(rate);
  }
}
public void Play(int val) {
  if (track.getPosition() <= 0) {
    if(trackRateGlide.getValue() == 0) {
       setPlaybackRate(1, false);
    }
    
    if(demoPicked <= 3) {
     demoSelector.hide();
     if(demoPicked == 0) {
       notificationServer.loadEventStream(eventDataJSON1);
      } else if (demoPicked == 1) {
      notificationServer.loadEventStream(eventDataJSON2);
      } else if (demoPicked == 2) {
      notificationServer.loadEventStream(eventDataJSON3);
      }
    }
    playCheck = true;
    addEndListener();
    track.start();
    track.setToLoopStart();
  } else {
    resetData();
    if(demoPicked <= 3) {
     demoSelector.hide();
     if(demoPicked == 0) {
       notificationServer.loadEventStream(eventDataJSON1);
      } else if (demoPicked == 1) {
      notificationServer.loadEventStream(eventDataJSON2);
      } else if (demoPicked == 2) {
        notificationServer.loadEventStream(eventDataJSON3);
      }
    }
    timer = 0;
    track.reTrigger();
  }
}

void playMuscle(int muscleSelected) {
  if(waveTimer == 0) {
    if(playCheck == true) {
      totalAlarmsGiven++;
    }
    trackCheck = true;
    if(muscleSelected == 0) {
      if(ttsCheck == true) {
        ttsExamplePlayback("Chest");
      } else {
          muscleCheck = true;
          muscleContractGlide.setValue(200);
      }
    } else if (muscleSelected == 1) {
      if(ttsCheck == true) {
        ttsExamplePlayback("Calves");
      } else {        
          muscleCheck = true;
          muscleContractGlide.setValue(300);        
      }
    } else if (muscleSelected == 2) {
      if(ttsCheck == true) {
        ttsExamplePlayback("Arms");
      } else { 
          muscleCheck = true;
          muscleContractGlide.setValue(400);      
      }
    } else if (muscleSelected == 3) {
      if(ttsCheck == true) {
        ttsExamplePlayback("Shoulders");
      } else {      
          muscleCheck = true;
          muscleContractGlide.setValue(500);       
      }
    } else if (muscleSelected == 4) {
      if(ttsCheck == true) {
        ttsExamplePlayback("Legs");
      } else {       
          muscleCheck = true;
          muscleContractGlide.setValue(600);       
      }
    } else if (muscleSelected == 5) {
      if(ttsCheck == true) {
        ttsExamplePlayback("Back");
      } else {        
          muscleCheck = true;
          muscleContractGlide.setValue(700);
      }
    }
  }
}

void setupInputs() {
  trackGain.addInput(track);
  highPassFilter.addInput(trackGain);
  lowPassFilter.addInput(trackGain);
  panner.addInput(lowPassFilter);
  panner.addInput(highPassFilter);
  muscleContractGain.addInput(muscleContractTone);
  panner.addInput(muscleContractGain);
  masterGain.addInput(panner);
}
void ttsExamplePlayback(String inputSpeech) {
  

  ttsGain = new Gain(ac, 2, 1.0);

  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer ttsSP = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ttsGain.addInput(ttsSP);
  panner.addInput(ttsGain);
  ttsSP.setToLoopStart();
  ttsSP.start();
  println("TTS: " + inputSpeech);
}
