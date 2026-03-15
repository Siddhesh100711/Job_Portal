# Pro Job Portal

A modern, premium job portal application built with Flutter, Firebase, and Riverpod. 

## 🚀 Key Features

* **Role-Based Access**: Specialized and separate dashboards tailored for both Candidates and Employers.
* **Media Integration**: Seamless profile picture and PDF Resume uploads integrated via the Cloudinary API.
* **Real-Time Database**: Robust backend powered by Firebase Firestore for real-time job postings and application tracking.
* **Modern UI**: A premium Dark Mode design featuring custom interactive widgets and smooth, declarative routing via GoRouter.
* **Architecture**: Engineered with a strict **MVVM (Model-View-ViewModel)** architectural pattern utilizing **Riverpod** for robust, scalable state management.

## 🛠️ Technical Challenges Solved

### Firebase Authentication: `DEVELOPER_ERROR`
Successfully resolved the common Google Sign-In `DEVELOPER_ERROR` handshake issue by correctly configuring and verifying the SHA-1 fingerprints in the Firebase Console and correctly registering the Android app credentials.

### Client-Side Media Handling
Implemented **unsigned Cloudinary uploads** directly from the Flutter client. This allowed for secure and efficient direct-to-cloud media uploads (specifically for profile images and PDF resumes) without the overhead of maintaining a dedicated backend server for file processing.

## 💻 Getting Started

### Prerequisites
* Flutter SDK
* Dart SDK
* Firebase project (Authentication & Firestore) setup
* Cloudinary Account (Cloud name and unsigned upload preset)

### Build & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Siddhesh100711/Job_Portal.git
   ```

2. Navigate to the project directory:
   ```bash
   cd ag_jobportal
   # or wherever the repo is cloned
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the application:
   ```bash
   flutter run
   ```

> **Note**: Ensure that `lib/firebase_options.dart` is populated with your specific Firebase configurations before running.
