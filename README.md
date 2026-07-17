# 🌃 Smart Street Light System

A Smart Street Light IoT system that combines a Flutter mobile application with an ESP32 microcontroller and Supabase backend for real-time monitoring and control of street lighting.

## 📌 Project Overview

This repository contains two integrated projects:

1. **Smart Street Light Mobile App (Flutter)**
2. **Smart Street Light ESP32 + Supabase (IoT)**

The system monitors ambient light intensity, automatically controls street lights, stores data in Supabase, and displays real-time information in the mobile application.

---

# 📂 Repository Structure

```
Smart-Street-Light/
│
├── smart_street_light_app/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   ├── assets/
│   ├── pubspec.yaml
│   └── README.md
│
├── SmartStreetLight_ESP32_Supabase/
│   ├── src/
│   ├── include/
│   ├── lib/
│   ├── platformio.ini
│   ├── diagram.json
│   └── README.md
│
└── README.md
```

---

# 🚀 Features

## Mobile Application

- Real-time light intensity monitoring
- Automatic day/night detection
- Street light ON/OFF status
- LED color indication
- Beautiful Flutter UI
- Fetches live data from Supabase

## ESP32 IoT System

- Reads light intensity using LDR
- Automatically controls street lights
- Sends sensor data to Supabase
- Updates light status in real time
- Supports Wokwi simulation
- PlatformIO project

---

# 🛠 Technologies Used

## Mobile App

- Flutter
- Dart
- HTTP Package

## IoT

- ESP32
- PlatformIO
- Arduino Framework
- LDR Sensor
- LED

## Backend

- Supabase
- REST API

---

# 📊 System Workflow

```
LDR Sensor
      │
      ▼
ESP32 Controller
      │
      ▼
Supabase Database
      │
      ▼
Flutter Mobile App
```

---

# 📱 Mobile App Functions

- Displays light intensity percentage
- Shows street light status
- Shows LED color
- Detects environmental condition
- Refreshes data automatically

---

# 🔌 ESP32 Functions

- Read LDR sensor value
- Determine Day/Night
- Turn street light ON/OFF
- Update Supabase database
- Send LED status

---

# 📸 Project Output

The project demonstrates:

- Flutter mobile interface
- ESP32 simulation in Wokwi
- Live Supabase database updates
- Automatic street light control

---

# ⚙ Installation

## Flutter App

```bash
cd smart_street_light_app

flutter pub get

flutter run
```

---

## ESP32 Project

Open

```
SmartStreetLight_ESP32_Supabase
```

using PlatformIO.

Build and Upload

```
PlatformIO → Build

PlatformIO → Upload
```

---

# 📋 Requirements

- Flutter SDK
- Android Studio / VS Code
- PlatformIO
- ESP32 Board
- Supabase Account
- Wokwi (Optional)

---

# 👩‍💻 Author

**A. Z. Ahunah**

BICT (Hons) Software Technologies

South Eastern University of Sri Lanka

---

# 📄 License

This project is developed for educational and academic purposes.
