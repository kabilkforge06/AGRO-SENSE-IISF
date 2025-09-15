# Google Sign-In Configuration for Firebase

## Steps to Enable Google Sign-In in Firebase Console

### 1. Open Firebase Console
- Go to [Firebase Console](https://console.firebase.google.com/)
- Select your project: `farming-assist-7bb6a`

### 2. Enable Google Sign-In
1. Navigate to **Authentication** in the left sidebar
2. Click on the **Sign-in method** tab
3. Click on **Google** from the list of providers
4. Toggle the **Enable** switch to ON
5. Add your project support email
6. Click **Save**

### 3. Configure OAuth 2.0 (For Production)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** > **Credentials**
4. Create OAuth 2.0 Client IDs for:
   - Android (use package name: `com.example.farming_assist`)
   - iOS (use bundle ID: `com.example.farmingAssist`)
   - Web (for web deployment)

### 4. SHA-1 Configuration (Android)
For Android release builds:
1. Generate SHA-1 fingerprint: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
2. Add SHA-1 fingerprint to Firebase project settings
3. Download updated `google-services.json`

## Current Status
- ✅ Google Sign-In package added (`google_sign_in: ^6.2.1`)
- ✅ Firebase Auth integrated
- ✅ UI updated with Google Sign-In button
- ✅ AuthService handles Google authentication
- ✅ User name personalization implemented
- 🔄 **Needs Firebase Console configuration to work in production**

## Features Implemented
1. **Google Sign-In Button**: Added to login screen with proper styling
2. **Authentication State Management**: Automatic login state tracking
3. **User Information Display**: Shows user's name from Google account
4. **Logout Functionality**: Properly signs out from both Google and Firebase
5. **Fallback Authentication**: Static credentials still available for demo

## Testing
For development testing, the Google Sign-In will work on:
- Android emulator/device (after proper configuration)
- Web (with web OAuth client ID)
- iOS simulator/device (after proper configuration)

**Note**: Google Sign-In requires proper OAuth configuration in both Firebase Console and Google Cloud Console to work in production.
