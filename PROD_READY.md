# CreatorBridge Production Guide 🚀

This app is designed to be production-ready. Follow these steps to move from development to a live environment.

## 1. Backend Production Setup (FastAPI)

### Environment Variables
Modify `backend/.env` for production:
- `ENV=production`
- `SECRET_KEY=generate-a-secure-random-key` (Use `openssl rand -hex 32`)
- `MONGO_URL`: Point to your production MongoDB (e.g., Atlas).
- `CORS_ORIGINS`: Restrict this to your Flutter Web domain or mobile app scheme.

### Deployment with Docker
A `Dockerfile` and `docker-compose.yml` are provided. To deploy:
```bash
docker-compose up --build -d
```

### Security Checklist
- [ ] Enable HTTPS on your server (use Nginx or Caddy with Let's Encrypt).
- [ ] Change the default `password123` for seeded demo users immediately.
- [ ] Implement rate limiting (e.g., using `slowapi` for FastAPI).

---

## 2. Flutter Frontend Production Setup

### API Configuration
In `lib/providers/api_service.dart`, change `baseUrl` to your live API domain:
```dart
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
```

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
