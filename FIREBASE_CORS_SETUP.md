# Firebase Storage CORS Configuration

If you're experiencing image upload issues on Flutter Web, you need to configure CORS for Firebase Storage.

## Steps to fix CORS issues:

1. Install Google Cloud SDK if you haven't already:
   - Download from: https://cloud.google.com/sdk/docs/install
   - Or use Cloud Shell in Google Cloud Console

2. Authenticate with Google Cloud:
   ```bash
   gcloud auth login
   ```

3. Set your project ID:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

4. Create a `cors.json` file with the following content:
   ```json
   [
     {
       "origin": ["*"],
       "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
       "maxAgeSeconds": 3600,
       "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"]
     }
   ]
   ```

5. Apply CORS configuration to your Firebase Storage bucket:
   ```bash
   gsutil cors set cors.json gs://YOUR_PROJECT_ID.appspot.com
   ```

6. Verify the configuration:
   ```bash
   gsutil cors get gs://YOUR_PROJECT_ID.appspot.com
   ```

## Alternative Workaround

If you can't configure CORS immediately, the app now includes a fallback option to save events without images when upload fails.

## For Development Only

For development, you can also temporarily disable web security in Chrome:
```bash
chrome.exe --user-data-dir="C:/chrome-dev-session" --disable-web-security --disable-features=VizDisplayCompositor
```

**Note:** Only use this for development, never for production.
