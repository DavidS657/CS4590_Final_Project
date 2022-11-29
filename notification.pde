enum NotificationType { handPlacement, workoutPace, muscleAlert, barPosition, markSet }

class Notification {
   
  int timestamp;
  NotificationType type; // door, person_move, object_move, appliance_state_change, package_delivery, message
  float intensity;
  int muscleType;
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    
    
    this.intensity = json.getFloat("intensity");
    
    this.muscleType = json.getInt("muscleType");      
       
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public float getIntensity() { return intensity; }
  public int getMuscle() { return muscleType; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(intensity: " + getIntensity() + ") ";
      output += "(muscle: " + getMuscle() + ") ";
      return output;
    }
}
