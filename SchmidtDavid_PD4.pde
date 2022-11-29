import controlP5.*;
import beads.*;
import java.util.*; 

ControlP5 p5;

boolean setDone;
boolean bothFalse;

//Data to keep track of
int totalAlarmsGiven;
float totalTimeOfWorkout;

float timer;

float totalSets;
float timeOfSet;

float timeSpentLeft;
float timeSpentRight;

float timeSpentFast;
float timeSpentSlow;

float timeSpentHigh;
float timeSpentLow;

boolean textToSpeechOn;
boolean mutedRun;
int completedSets;

float previousMasterVal;

Toggle toggler;
Toggle muteToggler;

Slider masterVolume;
Knob handPlacement;
Knob workoutPace;
Knob benchPosition;

Button chestAlert;
Button calvesAlert;
Button armsAlert;
Button shouldersAlert;
Button legsAlert;
Button backAlert;
Button playButton;

RadioButton demoSelector;

int demoPicked = 3;

String eventDataJSON1 = "bicep_curl.json";
String eventDataJSON2 = "push_up.json";
String eventDataJSON3 = "bench_press.json";

NotificationServer notificationServer;
ArrayList<Notification> notifications;

MyNotificationListener myNotificationListener;

void setup() {
  size(800,700);
  
  ac = new AudioContext();
  p5 = new ControlP5(this);
  setupAudio();
  notificationServer = new NotificationServer();
  
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
  
 chestAlert = p5.addButton("chest") 
    .setPosition(480, 250)
    .setSize(60, 60)
    .setLabel("Chest");
  calvesAlert = p5.addButton("calves") 
    .setPosition(580, 250)
    .setSize(60, 60)
    .setLabel("Calves");
  armsAlert = p5.addButton("arms")
    .setPosition(680, 250)
    .setSize(60, 60)
    .setLabel("arms");
  shouldersAlert = p5.addButton("shoulders")
    .setPosition(480, 330)
    .setSize(60, 60)
    .setLabel("Shoulders");
  legsAlert = p5.addButton("legs")
    .setPosition(580, 330)
    .setSize(60, 60)
    .setLabel("Legs");
  backAlert = playButton = p5.addButton("back")
    .setPosition(680, 330)
    .setSize(60, 60)
    .setLabel("Back");
  
  
  playButton = p5.addButton("Play")
    .setPosition(640, 420)
    .setSize(100, 100)
    .setLabel("Run");
    
  benchPosition = p5.addKnob("benchPressPosition")
    .setPosition(575,50)
    .setRadius(75)
    .setRange(-100,100)
    .setNumberOfTickMarks(6)
    .setTickMarkLength(5)
    .snapToTickMarks(true)
    .setLabel("Bench Press Position");
    
  workoutPace = p5.addKnob("workoutPace")
    .setPosition(325, 50)
    .setRadius(75)
    .setNumberOfTickMarks(6)
    .setTickMarkLength(5)
    .snapToTickMarks(false)
    .setRange(0.95, 1.05)
    .setValue(1)
    .setLabel("Workout Pace");
    
  handPlacement = p5.addKnob("handPlacement")
    .setPosition(75, 50)
    .setRadius(75)
    .setNumberOfTickMarks(6)
    .setTickMarkLength(5)
    .snapToTickMarks(false)
    .setRange(-1, 1)
    .setValue(0)
    .setLabel("Hand Placement");
    
 masterVolume = p5.addSlider("masterVolume")
    .setPosition(380,320)
    .setSize(50,200)
    .setRange(0,100)
    .setValue(50)
    .setLabel("Master Volume");
    
  p5.addButton("reset")
    .setPosition(480,460)
    .setSize(60,60)
    .setLabel("Reset");
    
  p5.addButton("markSet") 
    .setPosition(560, 460)
    .setSize(60,60)
    .setLabel("Mark Set");
    
  muteToggler = p5.addToggle("mute")
    .setPosition(560, 420)
    .setSize(60,20)
    .setValue(false);
  toggler = p5.addToggle("ttsToggle")
    .setPosition(480,420)
    .setSize(60, 20)
    .setValue(true);
    
  demoSelector = p5.addRadioButton("demoSelection")
    .setPosition(50,440)
    .setSize(60,30)
    .setSpacingRow(20)
    .setSpacingColumn(90)
    .setItemsPerRow(2)
    .addItem("Curl Demo", 0)
    .addItem("Push-up Demo", 1)
    .addItem("Bench Press Demo",2)
    .addItem("Evaluation Mode", 3)
    .activate(3);
  ac.start();
 
}

void demoSelection(int selection) {
  if(selection <= 2) {
    chestAlert.hide();
    calvesAlert.hide();
    shouldersAlert.hide();
    backAlert.hide();
    armsAlert.hide();
    legsAlert.hide();
    workoutPace.hide();
    handPlacement.hide();
    benchPosition.hide();
    if (selection == 0) {
      demoPicked = 0;
    } else if (selection == 1) {
      demoPicked = 1;
    } else if (selection == 2) {
      demoPicked = 2;
    } 
  } else if (selection == 3) {
      demoPicked = 3;
      chestAlert.show();
      calvesAlert.show();
      armsAlert.show();
      legsAlert.show();
      shouldersAlert.show();
      backAlert.show();
      workoutPace.show();
      handPlacement.show();
      benchPosition.show();
  }
}


void chest() {
  playMuscle(0);
}

void calves() {
  playMuscle(1);
}

void arms() {
  playMuscle(2);
}

void shoulders() {
  playMuscle(3);
}

void legs() {
  playMuscle(4);
}

void back() {
  playMuscle(5);
}
void benchPressPosition(float val) {
  if (val < 0) {
    lowPassFilter.pause(false);
    lowPassGlide.setValue((2600.0/ (-val/60)));
    highPassFilter.pause(true);
  } else if (val > 0) {
    lowPassFilter.pause(true);
    highPassFilter.pause(false);
    highPassGlide.setValue(5 * val);
  } else if (val == 0) {
    highPassGlide.setValue(1);
    highPassFilter.pause(false);
    lowPassFilter.pause(true);
  }
}

void workoutPace(float val) {
  if(trackRateGlide.getValue() != 0) {
     trackRateGlide.setValue(val);
  }
}
  
void handPlacement(float val) {
  pannerGlide.setValue(val);
}

void masterVolume(float val) {
  masterGainGlide.setValue(val/40);
}
void ttsToggle(boolean val) {
   if(val == true) {
     ttsCheck = true;
     ttsExamplePlayback("text to speech on.");
  } else {
    ttsCheck = false;
    ttsExamplePlayback("text to speech off.");
  }
}

void mute(boolean val) {
  if(val == true) {
    previousMasterVal = masterGainGlide.getValue();
    masterGainGlide.setValue(0);
    masterVolume.hide();
  } else if(val == false && masterGainGlide.getValue() == 0) {
    masterVolume.show();
    masterGainGlide.setValue(previousMasterVal);
  }
}

void reset() {
  resetData();
  playCheck = false;
  timer = 0;
  completedSets = 0;
}

void markSet() {
 if(ttsCheck == true) {
   ttsExamplePlayback("Set Completed");
 } else {
    muscleCheck = true;
    muscleContractGlide.setValue(900); 
 }
 completedSets++;
 playCheck = false;
 resetData();

}

class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + " ms");
    
    String debugOutput = ">>> ";
    switch (notification.getType()) {
      case handPlacement:
        handPlacement.setValue(notification.getIntensity());
        break;
      case workoutPace:
        workoutPace.setValue(notification.getIntensity());
        break;
      case muscleAlert:
        playMuscle(notification.getMuscle());
        break;
      case barPosition:
        benchPosition.setValue(notification.getIntensity());
        break;
      case markSet:
        markSet();
        break;
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();
    
    println(debugOutput);
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}

void resetData() {
 demoSelector.show();
 waveTimer = 0;
 trackTimer = 0;
 timeOfSet = 0;
 notificationServer.stopEventStream();
 toggler.show();
 muteToggler.setValue(false);
 muteToggler.show();
 totalAlarmsGiven = 0;
 timeSpentFast = 0;
 timeSpentSlow = 0;
 timeSpentRight = 0;
 timeSpentLeft = 0;
 timeSpentHigh = 0;
 timeSpentLow = 0;
 workoutPace.setValue(1);
 benchPosition.setValue(0);
 handPlacement.setValue(0);
 track.reset();
 track.pause(true);
}
void draw() {
  if(playCheck == true) {
     timer++;
     timeOfSet++;
     toggler.hide();
     muteToggler.hide();
     if(workoutPace.getValue() > 1) {
      timeSpentFast++;
     } else if (workoutPace.getValue() < 1) {
      timeSpentSlow++;
    }
     if(handPlacement.getValue() > 0) {
      timeSpentRight++;
     } else if (handPlacement.getValue() < 0) {
      timeSpentLeft++;
  }
      if(benchPosition.getValue() > 0) {
        timeSpentHigh++;
      } else if (benchPosition.getValue() < 0) {
        timeSpentLow++;
    }
  }
  
  waveCheck();
  trackCheck();
  background(1);
  fill(color(255,128,100));
  rect(0,0,800,560);
  fill(color(255,80,60));
  rect(0,550, 800, 150);
  fill(color(255,255,255));
  text("sets:       " + String.format("%.02f",float(completedSets)), 125, 590);
  text("tts:         " + String.format("%.02f", toggler.getValue()), 125, 610);
  text("Muted:   " + String.format("%.02f", muteToggler.getValue()), 125, 630);
  text("Alerts:    " + String.format("%.02f", float(totalAlarmsGiven)), 125, 650);
  text("Total Time:                        " + String.format("%.02f", timer/60), 300, 590);
  text("Set Time:                           " + String.format("%.02f",timeOfSet/60), 300, 610);
  text("Time Spent w/ fast pace:   " + String.format("%.02f", timeSpentFast/60), 300, 630);
  text("Time Spent w/ slow pace:  " + String.format("%.02f",timeSpentSlow/60), 300, 650);
  text("Time Spent w/ bar high:      " + String.format("%.02f", timeSpentHigh/60), 550, 590);
  text("Time Spent w/ bar low:       " + String.format("%.02f", timeSpentLow/60), 550, 610);
  text("Time Spent w/ hand left:     " + String.format("%.02f", timeSpentLeft/60), 550, 630);
  text("Time Spent w/ hand right:   " + String.format("%.02f", timeSpentRight/60),550, 650);
  
}
