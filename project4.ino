// This #include statement was automatically added by the Particle IDE.
#include <MQTT.h>

// This #include statement was automatically added by the Particle IDE.
#include <google-maps-device-locator.h>

void callback(char* topic, byte* payload, unsigned int length);
MQTT client("broker.hivemq.com", 1883, callback); // Call back for the client to listen to the messages arrived

GoogleMapsDeviceLocator locator;

void setup() {
    Serial.begin(9600);
    Particle.subscribe("hook-response/deviceLocator/26001a000d47373334323233/0", myHandler);
    client.connect("MyPhoton-Rushin");
    locator.withLocatePeriodic(60); 
}

void loop() {
    locator.loop();
    if (client.isConnected()) {
        client.loop();
    }
}

void callback(char* topic, byte* payload, unsigned int length) {
    char p[length + 1];
    memcpy(p, payload, length); // Copy the payload to a character array
    p[length] = NULL;
    // Blink the led based on the message received
    if (!strcmp(p, "RED"))
        RGB.color(255, 0, 0);
    else if (!strcmp(p, "GREEN"))
        RGB.color(0, 255, 0);
    else if (!strcmp(p, "BLUE"))
        RGB.color(0, 0, 255);
    else
        RGB.color(255, 255, 255);
    delay(1000); // Delay the by 1s
}

void myHandler(const char *event, const char *data) {
  String coordinates = data; 
  String device = "26001a000d47373334323233";
  String message = device + "," + coordinates;
  client.publish("location/myLocation/project4", message);
}






