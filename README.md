# 🕌 E-Masjid - Digital Mosque Management System

A Muslim Community Application build with Flutter.

![E-Masjid Logo](assets/images/e_masjid_web.png)

## 📱 App Showcase

| ![Home](https://github.com/user-attachments/assets/8036700d-58bb-49a2-85c0-740fa07fedf5) | ![Ask Imam](https://github.com/user-attachments/assets/b853b7d5-d4d1-44c2-aa1d-5858bf99d52f) | ![Rent Aula](https://github.com/user-attachments/assets/d2cb53b9-d8c2-49d2-8b77-3cc3c8af48c7) |
|:--:|:--:|:--:|
| **Home Screen**<br>Prayer times and quick access to services | **Ask Imam**<br>Direct questions to religious scholars | **Rent Aula**<br>Book Masjid facilities for events |

| ![Programs](https://github.com/user-attachments/assets/7b9b2153-fcf4-4027-9bed-2fdf16423182) | ![Donations](https://github.com/user-attachments/assets/9c69c2d2-bba1-4fa7-aa40-75b96aac69ec) | ![Status](https://github.com/user-attachments/assets/2bf865d1-de8c-4b1b-a90e-dc5a6a9360fe) |
|:--:|:--:|:--:|
| **Programs**<br>Masjid Program | **Donations**<br>Donations for Masjid | **Check Status**<br>Track donation, Ask Imam, rent place status |

| ![Quran](https://github.com/user-attachments/assets/20b1ad19-ac51-47da-8ede-8de1fb3adaa1) | ![Hadith](https://github.com/user-attachments/assets/6f1c6566-d4d0-489d-bbe1-8a64ffff6ea7) | ![Prayer](https://github.com/user-attachments/assets/63dff0d1-b73b-4f79-a2f5-6b8d4fb6cc4c) |
|:--:|:--:|:--:|
| **Quran**<br>Read Al Quran | **Hadith**<br>Explore hadith arbain | **Prayer Times**<br>Collection of Doa |



## ✨ Features

### 🔐 Authentication & User Management
- Secure login with google auth
- Role-based access (Staff, Jamaah)
- Password recovery

### 🕌 Core Mosque Services
- **Prayer Times**: Real-time prayer schedules with notifications
- **Quran Digital**: Complete Quran with search and bookmark features
- **Hadith Collection**: Authentic hadith with search functionality
- **Ask Imam**: Direct communication with religious scholars
- **Program Management**: Program management
- **Facility Booking**: Rent Place In Masjid facilities
- **Donation System**: Secure digital donations

### 👥 Community Features
- Program announcements
- Ask Imam
- Donation

### 🛠️ Administrative Tools
- Program creation and management
- Approval System


## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase (Firestore, Cloudify)
- **State Management**: Provider
- **Local Storage**: Hive, SharedPreferences
- **UI Components**: Material Design 3
- **Image Handling**: Cloudinary
- **HTTP Client**: Dio

## 📋 Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase project setup
- Cloudinary account

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/e_masjid.git
   cd e_masjid
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore

4. **Configure Cloudinary**
   - Create a Cloudinary account
   - Update the configuration in `lib/services/cloudinary_service.dart`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)

## 🏗️ Project Structure

```
lib/
├── animations/          # Custom animations
├── config/             # App configuration
├── mixins/             # Reusable mixins
├── models/             # Data models
├── providers/          # State management
├── screens/            # UI screens
│   ├── login/          # Authentication screens
│   ├── modul_produktiviti/  # Productivity modules
│   ├── modul_tanya/    # Q&A modules
│   ├── petugas/        # Staff/admin screens
│   └── quran/          # Quran-related screens
├── services/           # Business logic
├── utils/              # Utility functions
└── widgets/            # Reusable UI components
```

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Email/Password, Google Sign-in)
3. Create Firestore database
4. Set up security rules
5. Add configuration files to respective platform folders

### Environment Variables
Create a `.env` file in the root directory:
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## 📊 Features by User Role

### 👤 Community Member
- View prayer times
- Read Quran and Hadith
- Ask questions to Imam
- Register for programs
- Book facilities
- Make donations
- Track application status

### 👨‍💼 Staff Member
- Manage programs
- Handle applications
- Update announcements
- Monitor donations
- Manage facility bookings

## 🎨 UI/UX Features

- **Responsive Design**: Works seamlessly across all device sizes
- **Smooth Animations**: Flutter Staggered Animations for enhanced UX
- **Loading States**: Shimmer effects and loading indicators

## 🔒 Security Features

- Firebase Authentication
- Role-based access control
- Secure API communication
- Data encryption
- Input validation

## 📈 Performance Optimizations

- Lazy loading for Quran content
- Image optimization with Cloudinary
- Efficient state management
- Memory management
- Offline support with Hive

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
