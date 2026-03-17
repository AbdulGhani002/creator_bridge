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

---

## 2. Flutter Frontend Production Setup

### API Configuration
The app is pre-configured to use:
- `baseUrl`: `https://creator-bridge.apex-logic.net/api/v1`

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
