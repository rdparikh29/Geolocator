// This #include statement was automatically added by the Particle IDE.
#include <MQTT.h>
// This #include statement was automatically added by the Particle IDE.
// This #include statement was automatically added by the Particle IDE.
#include <google-maps-device-locator.h>
#include <sstream>


void callback(char* topic, byte* payload, unsigned int length);

char* hive = "broker.hivemq.com";
MQTT client(hive, 1883, callback);


GoogleMapsDeviceLocator locator;
int photoresistor = D0; // This is where your photoresistor is plugged in. The other side goes to the "power" pin (below).
// recieve message
void callback(char* topic, byte* payload, unsigned int length) {
    char p[length + 1];
    memcpy(p, payload, length);
    p[length] = NULL;
    String message(p);

    if (message.equals("RED"))
        RGB.color(255, 0, 0);
    else if (message.equals("GREEN"))
        RGB.color(0, 255, 0);
    else if (message.equals("BLUE"))
        RGB.color(0, 0, 255);
    else
        RGB.color(255, 255, 255);
    delay(1000);
}

#define ONE_DAY_MILLIS (24 * 60 * 60 * 1000)
unsigned long lastSync = millis();
String device = "1c001f000c47343438323536";
void setup() {
    Serial.begin(9600);
  // Scan for visible networks and publish to the cloud every 30 seconds
  // Pass the returned location to be handled by the locationCallback() method
    locator.withSubscribe(locationCallback).withLocatePeriodic(30);
    pinMode(photoresistor,INPUT_PULLDOWN);  // Our photoresistor pin is input (reading the photoresistor)
   
    // Subscribe to the webhook response event
    Particle.subscribe("hook-response/deviceLocator", myLocHandler, MY_DEVICES);
    
    if (millis() - lastSync > ONE_DAY_MILLIS) {
        Particle.syncTime();
        lastSync = millis();
    }

    RGB.control(true);
    locator.withLocatePeriodic(60); 

    // connect to the server
    client.connect("nishanclient");
}

void myLocHandler(const char *event, const char *data) {
  // Handle the webhook response
  // publish the message to MQTT cloud
  //"{ \"latitude\":\"AbC D\", \"longitude\":\"http://www.andrew.cmu.edu/user/abcd\"}"
  //Particle.publish("photonLocation", data, PRIVATE);
   String coordinates = data;
   Particle.publish("sendLocaton", coordinates);
   client.publish("location/myLocation/project4", "location,"+ device + "," + coordinates);
}

void locationCallback(float lat, float lon, float accuracy) {
  // Handle the returned location data for the device. This method is passed three arguments:
  // - Latitude
  // - Longitude
  // - Accuracy of estimated location (in meters)
}

void loop() {
  locator.loop();
  	//This will run in a loop
  	if (client.isConnected()){
        
    	if(digitalRead(photoresistor) == HIGH){
    	    //Particle.publish("OnOrOffValue", "1");
    	     //Particle.publish("photonConnection", "1", PRIVATE);
    	     client.publish("location/connection/project4", "connection,"+device+",1");
    	}else if(digitalRead(photoresistor) == LOW) {
    	    //Particle.publish("OnOrOffValue", "0");
    	    //Particle.publish("photonConnection", "0", PRIVATE);
    	    client.publish("location/connection/project4","connection,"+ device+",0");
    	}else{
    	    //Particle.publish("photonConnection", "-1", PRIVATE);
    	    client.publish("location/connection/project4","connection,"+ device+",-1");
    	}
            
            //loop to make Photon and MQTT broker stay connected
            client.loop();
           
    }
	delay(3000);
	
}
            

