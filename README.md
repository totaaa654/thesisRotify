# ROTIFY: Sensor-Based Dish Spoilage Detection System with Mobile Application

ROTIFY is an IoT-powered food spoilage detection system designed to monitor the freshness of cooked dishes using environmental and gas sensor data. The system utilizes sensor readings, cloud connectivity, and machine learning techniques to detect potential spoilage conditions and provide real-time notifications through a mobile application.

## Overview

Food spoilage remains a significant concern for households, food establishments, and institutions due to its impact on food safety, waste generation, and operational costs. ROTIFY addresses this challenge by continuously monitoring spoilage-related indicators and providing users with timely alerts before food becomes unsafe for consumption.

The system collects data from multiple sensors connected to an ESP32 microcontroller and transmits the information to a cloud database. Sensor readings are analyzed to determine spoilage conditions and predict food quality status in real time.

## Key Features

* Real-time food spoilage monitoring
* IoT-based sensor data collection using ESP32
* Cloud database integration for remote access
* Mobile application for monitoring and notifications
* Spoilage detection using gas and pH sensors
* Automated alerts when spoilage thresholds are detected
* Historical sensor data tracking and visualization
* Machine learning-assisted spoilage prediction

## Sensors Used

* Ammonia (NH₃) Gas Sensor
* Hydrogen Sulfide (H₂S) Gas Sensor
* Volatile Organic Compound (VOC) Sensor
* pH Sensor

These sensors monitor chemical changes commonly associated with food decomposition and spoilage.

## System Architecture

1. Sensors collect spoilage-related environmental data.
2. ESP32 processes and transmits sensor readings.
3. Data is stored in a cloud database.
4. Machine learning models analyze sensor patterns.
5. The mobile application displays real-time information and notifications.
6. Users receive alerts when spoilage is detected or predicted.

## Research Objectives

* Detect spoilage conditions in cooked meat-based dishes.
* Monitor food quality using multiple sensor parameters.
* Improve food safety through early spoilage detection.
* Reduce food waste through predictive monitoring.
* Evaluate the accuracy and reliability of sensor-based spoilage detection.

## Technology Stack

### Hardware

* ESP32 Microcontroller
* NH₃ Gas Sensor
* H₂S Gas Sensor
* VOC Sensor
* pH Sensor

### Software

* Firebase
* Android Mobile Application
* Machine Learning Models
* Embedded Systems Programming
* IoT Communication Technologies

## Scope

The study focuses on monitoring spoilage in selected meat-based dishes:

* Bicol Express
* Menudo
* Chicken Curry

The system evaluates spoilage conditions based on sensor measurements and corresponding laboratory validation data.

## Expected Benefits

* Enhances food safety monitoring
* Reduces food waste
* Supports sustainable food management practices
* Provides real-time spoilage awareness
* Assists food establishments in maintaining food quality standards

## Project Status

Academic Thesis Project

Developed as a Computer Engineering research project focused on integrating IoT, cloud computing, sensor technology, and machine learning for intelligent food spoilage detection and monitoring.

---

ROTIFY combines IoT sensing, cloud connectivity, and machine learning to create a smarter approach to food safety and spoilage detection.
