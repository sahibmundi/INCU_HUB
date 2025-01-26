#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP280.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Servo.h>
#include <Preferences.h>

#define RELAY_PIN 25
#define SERVO_PIN 32
#define TRIG_PIN 5
#define ECHO_PIN 18

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
#define OLED_I2C_ADDRESS 0x3C
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

Adafruit_BMP280 bmp;
Servo eggTrayServo;
Preferences preferences;

#define TEMP_TARGET 37.7
#define TEMP_HYSTERESIS 0.2

const char* ssid = "USER_ID";
const char* password = "PASSWORD";
const char* mqttServer = "mqtt3.thingspeak.com";
const int mqttPort = 1883;
const char* mqttUser = "MQTT_USER";
const char* mqttPassword = "MQTT_PASSWORD";
const char* mqttClientID = "MQTT_CLIENT_ID";
const char* mqttTopic = "channels/CHANNEL-ID/publish";

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

unsigned long lastRotateTime = 0;
unsigned long lastPublishTime = 0;
const unsigned long publishInterval = 10000;
const unsigned long trayRotateInterval = 6000;

unsigned long previousMillis = 0;
const long interval = 86400000;
int dayCount = 3;

void setup() {
  Serial.begin(115200);

  preferences.begin("day-storage", false);
  dayCount = preferences.getInt("day", 3);

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(RELAY_PIN, LOW);

  eggTrayServo.attach(SERVO_PIN);

  rotateServoSlowly(0, 320, 15);

  if (!bmp.begin(0x76)) {
    while (true);
  }

  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_I2C_ADDRESS)) {
    while (true);
  }
  display.clearDisplay();

  connectWiFi();
  mqttClient.setServer(mqttServer, mqttPort);
  connectMQTT();
}

void loop() {
  if (!mqttClient.connected()) {
    connectMQTT();
  }
  mqttClient.loop();

  float temperature = bmp.readTemperature();
  long distance = getUltrasonicDistance();
  int mappedValue = map(distance, 4, 11, 100, 0);
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    dayCount++;
    preferences.putInt("day", dayCount);
  }

  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print("TEMP: ");
  display.print(temperature, 1);
  display.println(" C");
  display.setTextSize(1);
  display.setCursor(0, 25);
  display.print("WATER LEVEL: ");
  display.print(mappedValue);
  display.println(" %");
  display.setTextSize(1);
  display.setCursor(0, 50);
  display.print("HATCHING DAY: ");
  display.print(dayCount);
  display.display();

  if (temperature < (TEMP_TARGET - TEMP_HYSTERESIS)) {
    digitalWrite(RELAY_PIN, LOW);
  } else if (temperature > (TEMP_TARGET + TEMP_HYSTERESIS)) {
    digitalWrite(RELAY_PIN, HIGH);
  }

  if (millis() - lastRotateTime >= trayRotateInterval) {
    lastRotateTime = millis();
    rotateServoSlowly(180, 0, 15);
    delay(2000);
    rotateServoSlowly(0, 180, 15);
  }

  if (millis() - lastPublishTime >= publishInterval) {
    publishSensorData(temperature, mappedValue);
    lastPublishTime = millis();
  }

  delay(2000);
}

long getUltrasonicDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH);
  long distance = duration * 0.034 / 2;
  return distance;
}

void connectWiFi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
  }
}

void connectMQTT() {
  while (!mqttClient.connected()) {
    if (mqttClient.connect(mqttClientID, mqttUser, mqttPassword)) {
    } else {
      delay(500);
    }
  }
}

void publishSensorData(float temperature, int mappedValue) {
  String payload = String("field1=") + temperature + "&field2=" + mappedValue;
  mqttClient.publish(mqttTopic, payload.c_str());
}

void rotateServoSlowly(int startAngle, int endAngle, int stepDelay) {
  int step = (startAngle < endAngle) ? 1 : -1;
  for (int angle = startAngle; angle != endAngle; angle += step) {
    eggTrayServo.write(angle);
    delay(stepDelay);
  }
  eggTrayServo.write(endAngle);
}

