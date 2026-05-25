📢 Complaint & Feedback Management System
A mobile application built with Flutter & Firebase that gives the general public a structured, transparent, and accountable channel to submit complaints, track their status in real time, and receive notifications on resolution — replacing informal and ineffective reporting methods.

📱 Screenshots
�
￼
Login Screen ￼
User Home Dashboard ￼
Submit Complaint ￼
My Complaints List ￼
Complaint Detail & Status History ￼
Admin Executive Dashboard ￼
Admin Review & Status Update ￼
User Notifications 
📁 Place your screenshots in a /screenshots folder at the root of the repo with the filenames above.
✨ Features
User Side
🔐 Register & login with email/password or Google Sign-In
📝 Submit complaints with title, category, description, and photo attachment
📋 View all submitted complaints with status badges
🔍 Filter complaints by category and search by keyword
📊 Track status history: Pending → In Progress → Resolved
🔔 Real-time push notifications on every status change
⭐ Rate the resolution of a closed complaint
Admin Side
📈 Executive dashboard with statistics: Total, Pending, In Progress, Resolved
📂 View and filter all complaints by category, status, and date
✏️ Respond to complaints and update their status
🕐 Full status history timeline per complaint
Additional
🌐 English & Amharic language support
🔒 Role-based access control via Firebase Security Rules
📶 Offline error handling with retry support
🛠️ Tech Stack
Layer
Technology
Mobile Framework
Flutter (Dart)
State Management
Provider / Riverpod
Database
Firebase Firestore
Authentication
Firebase Auth (Email + Google)
File Storage
Firebase Storage
Push Notifications
Firebase Cloud Messaging (FCM)
Version Control
Git / GitHub
🚀 Getting Started
Prerequisites
Flutter SDK >=3.0.0
Dart SDK >=3.0.0
A Firebase project with Firestore, Auth, Storage, and FCM enabled
Installation
# 1. Clone the repository
git clone https://github.com/your-username/complaint-feedback-system.git
cd complaint-feedback-system

# 2. Install dependencies
flutter pub get

# 3. Add your Firebase config
# Place google-services.json in android/app/
# Place GoogleService-Info.plist in ios/Runner/

# 4. Run the app
flutter run
Firebase Setup
Create a project at Firebase Console
Enable Authentication (Email/Password + Google)
Create a Firestore database in production mode
Enable Firebase Storage
Set up Cloud Messaging for push notifications
Apply the security rules from firestore.rules
🗂️ Project Structure
complaint_app/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_styles.dart
│   │   │
│   │   ├── routes/
│   │   │   └── app_routes.dart
│   │   │
│   │   └── utils/
│   │       ├── validators.dart
│   │       └── helpers.dart
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── complaint_model.dart
│   │   └── notification_model.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── complaint_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── complaint_provider.dart
│   │   └── notification_provider.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   │
│   │   ├── user/
│   │   │   ├── user_home_screen.dart
│   │   │   ├── submit_complaint_screen.dart
│   │   │   ├── complaint_detail_screen.dart
│   │   │   └── notification_screen.dart
│   │   │
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart
│   │       ├── admin_complaint_detail_screen.dart
│   │       └── admin_notification_screen.dart
│   │
│   └── widgets/
│       ├── complaint_card.dart
│       ├── status_badge.dart
│       ├── status_timeline.dart
│       ├── image_picker_widget.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── bottom_nav_bar.dart
│
├── assets/
│   ├── images/
│   │   └── logo.png
│   └── icons/
│
├── pubspec.yaml
└── README.md
🔒 Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /complaints/{id} {
      allow read: if request.auth != null &&
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if isAdmin();
    }
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid))
               .data.role == 'admin';
    }
  }
}
📊 Database Collections
Collection
Description
users
User profiles with role field (user / admin)
complaints
All submitted complaints with status and history
notifications
Status-change alerts per user
categories
Complaint category definitions
🧪 Testing
✅ 15 manual test cases covering all core flows
✅ Unit tests for auth, repository, and validators
✅ Integration tests for submit → admin → notify flow
✅ UAT with 6 participants — 4.66 / 5.0 satisfaction score
🔮 Planned Features
🤖 AI-based complaint auto-categorization (Gemini API)
📱 SMS notification support
⏱️ Auto-escalation for unresolved complaints past a deadline
📉 Advanced analytics and reporting for admins
📄 License
This project was developed as a final academic project at Adama Science and Technology University for the course Mobile Computing and Applications (CSEg3306).
�
Made with ❤️ by Team 5 — ASTU, May 2026

