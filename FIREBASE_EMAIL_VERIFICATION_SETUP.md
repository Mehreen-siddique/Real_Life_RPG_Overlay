# Firebase Email Verification Setup Guide

## Problem: "Site Not Reached" When Clicking Verification Link

The email verification link shows "site not reached" because Firebase needs a proper action code handler page configured.

## Solution: Configure Firebase Auth Action URL

### Step 1: Set Up Firebase Hosting (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Hosting** in the left sidebar
4. Click **Get Started**
5. Follow the setup wizard to initialize hosting

### Step 2: Create Action Code Handler Page

Create a file `public/action.html` in your project:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Email Verification</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    .container {
      background: white;
      padding: 40px;
      border-radius: 16px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.2);
      text-align: center;
      max-width: 400px;
    }
    .icon {
      font-size: 64px;
      margin-bottom: 20px;
    }
    h1 {
      color: #333;
      margin-bottom: 10px;
    }
    p {
      color: #666;
      line-height: 1.6;
    }
    .spinner {
      border: 3px solid #f3f3f3;
      border-top: 3px solid #667eea;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin: 20px auto;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .success { color: #4CAF50; }
    .error { color: #f44336; }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon" id="icon">📧</div>
    <h1 id="title">Verifying Email...</h1>
    <div class="spinner" id="spinner"></div>
    <p id="message">Please wait while we verify your email address.</p>
  </div>

  <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
  <script>
    // Your Firebase config
    const firebaseConfig = {
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
      projectId: "YOUR_PROJECT_ID",
      // ... other config
    };

    firebase.initializeApp(firebaseConfig);

    const auth = firebase.auth();
    const urlParams = new URLSearchParams(window.location.search);
    const mode = urlParams.get('mode');
    const oobCode = urlParams.get('oobCode');

    const icon = document.getElementById('icon');
    const title = document.getElementById('title');
    const message = document.getElementById('message');
    const spinner = document.getElementById('spinner');

    if (mode === 'verifyEmail') {
      auth.applyActionCode(oobCode)
        .then(() => {
          icon.textContent = '✅';
          title.textContent = 'Email Verified!';
          title.className = 'success';
          message.textContent = 'Your email has been successfully verified. You can now close this page and return to the app to log in.';
          spinner.style.display = 'none';
        })
        .catch((error) => {
          icon.textContent = '❌';
          title.textContent = 'Verification Failed';
          title.className = 'error';
          message.textContent = 'Error: ' + error.message;
          spinner.style.display = 'none';
        });
    }
  </script>
</body>
</html>
```

### Step 3: Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

### Step 4: Configure Action URL in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** → **Templates**
4. Find **Email Verification** template
5. Click the pencil/edit icon
6. Change the **Action URL** to:
   ```
   https://YOUR_PROJECT_ID.web.app/action.html
   ```
7. Click **Save**

### Alternative: Use Default Firebase Handler

If you don't want to set up hosting, you can use Firebase's default handler:

1. In Firebase Console → Authentication → Templates
2. Set Action URL to:
   ```
   https://YOUR_PROJECT_ID.firebaseapp.com/__/auth/action
   ```

### For Mobile Apps: Dynamic Links (Optional)

To redirect back to your mobile app after verification:

1. Go to Firebase Console → Dynamic Links
2. Create a new Dynamic Link prefix
3. Set up URL patterns to redirect to your app
4. Update the Action URL to use the Dynamic Link

## Testing Email Verification

1. Sign up a new user in your app
2. Check email for verification link
3. Click the link - should show success page
4. Return to app and try logging in
5. Should now work without "email not verified" error

## Troubleshooting

### Still seeing "site not reached"?
- Verify the Hosting URL is correct
- Check that `action.html` was deployed successfully
- Try accessing the URL directly in browser

### Email verified but app still says not verified?
- The app needs to reload the user to see the updated verification status
- User needs to log out and log back in
- Or call `reloadUser()` before checking `isEmailVerified()`

### Using Custom Domain?
- Update the Action URL to your custom domain
- Ensure SSL certificate is valid
- Add domain to authorized domains in Firebase Console
