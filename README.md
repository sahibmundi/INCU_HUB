<h1 align="center">INCU-HUB</h1>
<p align="center">
  <b>A SMART IOT BASED EGG HATCHING SYSTEM.</b>
</p>


## 🌟 OVERVIEW
IncuHub is an innovative IoT-based egg-hatching machine designed to create ideal conditions for egg incubation. It features temperature and humidity control using the BMP280 sensor, automated egg tray rotation with a motor, and consistent air circulation via a fan. The system also integrates water level monitoring using an ultrasonic sensor.

<p align="center">
<img src="https://github.com/user-attachments/assets/22458371-73cf-4777-95dc-a3f0ca7cde2c"
alt="image" width="500" >
</p>

--------------------------------------------
## ✨ FEATURES
1. TEMPERATURE CONTROL:
   - Maintains optimal temperature using the BMP280 sensor to control a relay-connected heating element.
2. AUTOMATED EGG TRAY ROTATION:
   - Motorized tray rotates eggs periodically to ensure uniform incubation.
3. HUMIDITY MANAGEMENT:
   - Monitors and maintains ideal humidity levels with a water tank and ultrasonic sensor for water level detection.
4. CONSTANT AIR CIRCULATION:
   - 12V DC fan ensures consistent airflow for even temperature and humidity distribution.
5. FLUTTER MOBILE APP:
   - Provides real-time data visualization, monitoring, and control of the incubation system.
  
  --------------------------------------------------------------
  ## 🚀 HOW TO USE
   HARDWARE REQUIREMENTS:
   - ESP32 Microcontroller
   - Temperature Sensor
   - Ultrasonic Sensor
   - Relay Module
   - Motor For Egg Tray Rotation

  SOFTWARE REQUIREMENTS:
   - Flutter SDK
   - Arduino IDE
   - MQTT BROKER

   - ------------------------------------------------------------------------
 ## 🔧 STEPS TO CONFIGURE
1. SET UP THE CIRCUIT:  
   Here Is Pins Connection Of Hardware. 
  - ULTRASONIC SENSOR (HCSR04)
  
| **PIN**           | **CONNECTION (ESP32)** |
|-------------------------|------------------|
| **VCC**           | 5V                     |
| **GND**           | GND                    |
| **TrigPin**       | GPIO 5                 |
| **EchoPin**       | GPIO 18                |

- RELAY MODULE (2 CHANNEL)
  
| **PIN**           | **CONNECTION (ESP32)** |
|-------------------------|------------------|
| **VCC**           | 5V                     |
| **GND**           | GND                    |
| **IN1**           | GPIO 25                |

- SERVO MOTOR

| **PIN**           | **CONNECTION (ESP32)** |
|-------------------|------------------------|
| **VCC**           | 5V                     |
| **GND**           | GND                    |
| **Signal**        | GPIO 32                |

2. FLASH THE CODE:
   - Use the Arduino IDE to flash the ESP32 with the provided Arduino code.
   - Set up the necessary pins and MQTT topics.

3. RUN THE FLUTTER APP:
   - Open the Flutter project in your IDE.
   - Run the app on an Android or iOS device to connect with the ESP32.
  
-------------------------------------------------------------------------------
## 📊 MOBILE APP
   - Here is our Flutter based mobile application.

<p align="center">
  <img src="https://github.com/user-attachments/assets/fbaac3be-f12d-4957-8838-5e9149a6a812" alt="image" width="200" height="500">
</p>

---------------------------------------------------------------------
## 🛠️ TECHNOLOGY USED
1. **IoT**: ESP32 for hardware integration.
2. **Flutter**: Mobile app development.
3. **MQTT Protocol**: For data communication.
4. **Arduino-IDE**: To program the Microcontroller.

----------------------------------------------------------------------
## 💡 FUTURE IMPROVEMENTS
1. Integration of advanced humidity control mechanisms.
2. Addition of multiple egg tray support for larger capacity.
3. Development of AI-based temperature and humidity prediction.

------------------------------------------------------------------------
## 📜 LICENSE
This project is licensed under the MIT License.  
See License File For More Detail.

-----------------------------------------------------------------------
## 🤝 CONTRIBUTIONS
We welcome contributions!  
Feel free to open an issue or submit a pull request.

------------------------------------------------------------------------
## 📞 CONTACT
For any queries, suggestions, or collaboration inquiries, feel free to reach out to:  
SAHIBJOT SINGH  
[sahibjotmundi000@gmail.com]







