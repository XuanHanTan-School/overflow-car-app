# Overflow Car (Apps)

> Apps to drive an RC car remotely over a WebSocket connection.

This project provides a framework to control a robotic vehicle with video streaming capabilities using WebSocket communication. You can use tilt gestures and a joystick to drive the car, along with a live video stream. There is also a time trial feature. It works great with the [Overflow Car Command](https://github.com/XuanHanTan-School/overflow-car-command), which handles the video stream, connection logic and issues drive commands.

## Features

- **Intuitive gestures:** Tilt the phone left and right to steer, and use the joystick to go forwards or backwards.
- **Time trial support:** Compete with your friends or classmates around a track with remotely-controlled time trials and a leaderboard.
- **Low latency:** WebSockets and RTSP streaming keeps the latency as low as 30ms, making the car feel responsive.
- **Easy to set up:** Just be on the same network as your car, and import the same JSON settings file across all cars.

## Importing cars

Car settings can be imported from a JSON file, saving the time needed to add them manually in the app.

The JSON file should be formatted as follows
```json
[
   {
      "name": "Car 1",
      "host": "127.0.0.1",
      "commandPort": 8665,
      "videoPort": 8555,
      "username": "YOUR_CAR_USERNAME_HERE",
      "password": "YOUR_CAR_PASSWORD_HERE"
   },
   {
      "name": "Car 2",
      "host": "192.168.1.103",
      "commandPort": 8665,
      "videoPort": 8555,
      "username": "YOUR_CAR_USERNAME_HERE",
      "password": "YOUR_CAR_PASSWORD_HERE"
   },
]
```

## Apps

### Control App
This is the app that is used to drive the car.

**Supported platforms: Android, iOS**

### Live View App
This app is meant to be run on a big screen to let spectators view the POV of the car, current time trial status and the leaderboard at the end of the time trial.

**Supported platforms: macOS**

### Management App

This app allows admins to create, continue and delete time trials.

**Supported platforms: Web**

## Development

### Setting up

This project was tested to work with **Flutter 3.27**.

You must add your own Firebase project in the app to use time trial features. 
1. Follow Step 1 of the [official guide](https://firebase.google.com/docs/flutter/setup) on setting up Firebase CLI and Flutterfire, then run `flutterfire configure` in every app's folder that you want to use.
2. Enable **Realtime Database**  on the Firebase Console.

### Directory Structure

This is a melos monorepo, where there are 3 apps and some shared packages. The 3 apps share 3 blocs, which manages the car driving state, time trial state and car management state respectively.

`apps` folder:
- `control_app`: The control app.
- `live_view_app`: The live view app.
- `management_app`: The car management app.

`packages` folder:
- `app_utilities`: Miscellaneous utilities for importing cars from JSON, converting values etc.
- `car_api`: The API and interfaces to communicate with the car over a WebSocket connection.
- `car_bloc`: The state management for driving the car.
- `car_management_bloc`: The state management for managing the car (simplified version of `car_bloc`, used mainly in management app).
- `time_trial_api`: The API and interfaces to manage time trials stored in Firebase Realtime Database.
- `time_trial_bloc`: The state management for time trials.
- `local_storage`: Helps store the application data locally.
- `shared_car_components`: Widgets, views and pages that are shared across the apps (e.g. settings, adding cars).

### Testing

You can use the ADB reverse proxy to proxy the video and command ports from overflow-car-command to your Android phone. iOS and macOS should work fine.

Have Fun! 🚗💨
