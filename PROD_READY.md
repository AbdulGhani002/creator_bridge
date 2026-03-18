# CreatorBridge Production Guide 🚀

This app is designed to be production-ready. Follow these steps to move from development to a live environment.

## 1. Backend Production Setup (FastAPI)

### Environment Variables
Modify `backend/.env` for production:
- `ENV=production`
- `PORT=8003`
- `SECRET_KEY=generate-a-secure-random-key` (Use `openssl rand -hex 32`)
- `MONGO_URL`: `mongodb://admin:PASSWORD@YOUR_IP:27017/creator_bridge?authSource=admin`
- `CORS_ORIGINS`: `https://creator-bridge.apex-logic.net`

### Deployment with Docker
A `Dockerfile` and `docker-compose.yml` are provided. To deploy:
```bash
docker-compose up --build -d
```

### API Testing
Run the automated test script to verify all endpoints are responding correctly:
```bash
cd backend
python test_endpoints.py
```

### Production Checklist
- [x] **Password Hashing:** Fixed Decisive Bcrypt/Passlib compatibility crash.
- [x] **CORS Robustness:** Hardcoded production domain and common dev ports.
- [x] **Error Resiliency:** Guaranteed CORS headers even on 500 Internal Server errors.
- [ ] **HTTPS:** Ensure your reverse proxy (Nginx/PM2) handles SSL via Let's Encrypt.
- [ ] **Secrets:** Rotate the `SECRET_KEY` in your VPS `.env` file.

---

## 2. Flutter Frontend Production Setup

### API Configuration
The app is pre-configured to use:
- `baseUrl`: `https://creator-bridge.apex-logic.net/api/v1`

### Google Maps Setup
1.  Obtain an API Key from [Google Cloud Console](https://console.cloud.google.com/).
2.  **Android:** Add the key to `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY_HERE"/>
    ```
3.  **iOS:** Add the key to `ios/Runner/AppDelegate.swift`:
    ```swift
    GMSServices.provideAPIKey("YOUR_KEY_HERE")
    ```
4.  **Web:** Add the key to `web/index.html`:
    ```html
    <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY_HERE"></script>
    ```

### GitHub Actions (iOS Build)
A pipeline is configured in `.github/workflows/ios-build.yml`. Every push to `main` will trigger an automated iOS build to ensure compatibility.

### Build & Release
#### Android
1.  Configure signing in `android/key.properties`.
2.  Run `flutter build apk --release` or `flutter build appbundle`.

#### iOS
1.  Set the Bundle Identifier and Version in Xcode.
2.  Configure a valid Provisioning Profile.
3.  Run `flutter build ipa`.

---

## 3. Database Maintenance
- **Backups**: Ensure your MongoDB has automated backups.
- **Data Privacy**: Ensure you handle user data according to GDPR/CCPA.
- **Seeding**: The `seed_data.py` script is for demo/testing. Do not run it on a production database unless you want to wipe all real user data.

## 4. Maintenance & Monitoring
- **Logs**: Backend logs are configured to stdout. Use a log aggregator like ELK or Datadog in production.
- **Monitoring**: Consider using Sentry or Firebase Crashlytics for the Flutter app to track crashes.
