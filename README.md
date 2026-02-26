# 📋 Task Manager App

A production-ready Task Management / Productivity application built with Flutter.

This project demonstrates clean architecture, Firebase integration, Riverpod state management, modern UI design (Material 3), and real-world mobile development practices.

---
## 📦 Download

Download latest APK from:
https://github.com/YOUR_USERNAME/YOUR_REPO/releases

---

## 🚀 Features

### 🔐 Authentication
- Firebase Email & Password Login
- User Registration (First Name, Last Name, Email, Password)
- Display name stored and used in greeting
- Logout functionality
- AuthWrapper for automatic login state handling

### 🗂 Task Management
- Fetch tasks from Cloud Firestore
- Create Task
- Edit Task
- Delete Task
- Task fields:
    - Title
    - Description
    - Status (Todo / In Progress / Done)
    - Due Date
- Pull-to-refresh
- Search functionality
- Loading state
- Empty state
- Error state with retry button

---

## 🎨 UI / UX

- Material 3 design system
- Custom theme configuration
- Light & Dark mode support
- System theme detection
- Manual theme toggle (Riverpod-based)
- Clean typography (Google Fonts)
- Consistent spacing and layout
- Responsive mobile UI
- Status-based accent colors
- Description limited to 3 lines with ellipsis

---

## 🧠 Architecture

Feature-based modular structure:

```
lib/
 ├── core/
 │    ├── app_theme.dart
 │    ├── auth_service.dart
 │    ├── theme_provider.dart
 │
 ├── features/
 │    ├── auth/
 │    │     ├── presentation/
 │    │           ├── login_screen.dart
 │    │           ├── register_screen.dart
 │    │
 │    ├── tasks/
 │          ├── data/
 │          │     ├── task_model.dart
 │          │     ├── task_service.dart
 │          │
 │          ├── presentation/
 │                ├── home_screen.dart
 │                ├── add_task_screen.dart
 │                ├── edit_task_screen.dart
 │                ├── task_provider.dart
 │
 ├── main.dart
```

### Architectural Decisions

- Feature-first structure for scalability
- Separation of concerns:
    - Models
    - Services
    - State management
    - UI
- Auth-driven navigation using `StreamBuilder`
- Riverpod for predictable reactive state updates

---

## ⚙️ State Management

Implemented using **Riverpod**.

Used for:
- Task state management
- Theme state management

Riverpod was chosen for:
- Scalability
- Clean separation of UI and logic
- Testability
- Compile-time safety

---

## 🔥 Backend

- Firebase Authentication
- Cloud Firestore
- Firestore security rules (user-based access control)

Each user can:
- Access only their own tasks
- Access only their own profile document

---

## 💾 Local Storage

- Hive initialized
- Ready for local caching support

---

## 🌙 Dark Mode Support (Bonus)

- System theme detection
- Manual override via AppBar toggle
- Full theme adaptation for:
    - Cards
    - Text
    - Status pills
    - Backgrounds

---

## 🛠 Setup Instructions

1. Clone the repository:
   ```bash
   git clone <your-repo-link>
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
    - Add `google-services.json`
    - Ensure `firebase_options.dart` is generated

4. Run the app:
   ```bash
   flutter run
   ```

---

## 📱 Deployment

- GitHub repository provided
- APK build available

---

## 🧪 AI Usage Disclosure

AI tools were used to assist with:
- Architectural validation
- UI refinement
- Code optimization

All implementation logic is fully understood and can be explained in detail.

---

## 📊 Technical Assessment Coverage

Requirement | Status
------------|--------
Login & Registration | ✅ Implemented
Task CRUD | ✅ Implemented
Pull-to-refresh | ✅ Implemented
Loading / Empty / Error states | ✅ Implemented
Modern UI (Material 3) | ✅ Implemented
State Management | ✅ Riverpod
API Integration | ✅ Firestore
Input Validation | ✅ Implemented
Dark Mode | ✅ Implemented
Local Caching | ⚠ Hive initialized (ready for expansion)

---

## 👨‍💻 Built With

- Flutter
- Firebase Auth
- Cloud Firestore
- Riverpod
- Hive
- Google Fonts

---

## 📌 Summary

This application demonstrates real-world Flutter development practices including clean architecture, state management, Firebase integration, UI consistency, and scalable project structure.