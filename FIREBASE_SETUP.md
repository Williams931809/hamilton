# Firebase backend setup — Hamilton Ezeonu
The frontend is deployed on Vercel. Firebase hosts authentication, data, and uploaded media.

1. In [Firebase Console](https://console.firebase.google.com/), create or select a dedicated project.
2. Register a **Web app** in Project settings and copy its public Firebase configuration (apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId) into the repository's `firebase-config.json`. These values identify the Firebase app; never place private service account keys in the repository.
3. Enable **Authentication → Sign-in method → Email/Password**.
4. Create **Cloud Firestore** and deploy the exact contents of `firestore.rules` under Firestore → Rules.
5. Enable **Cloud Storage** and deploy `storage.rules` under Storage → Rules. Storage may require an eligible billing plan.
6. Add `hamilton-eosin.vercel.app` and any other live domain under Authentication → Settings → Authorized domains.
7. Visit `/admin.html` and register the first administrator. The bootstrap is a Firestore atomic batch: only one user can create the unique owner marker.
8. Test a published news post, an image upload, and a contact enquiry. Set up App Check and anti-spam protection before publicly promoting the contact form.

Note: the email destination is optional. Enquiries are stored in Firestore. Email delivery is not configured.

## Content management
- Admin dashboard: `/admin.html`
- Collection `siteContent`: pages, posts, announcements, videos, images and settings
- Collection `enquiries`: contact submissions
- Storage folder `site-media/`: uploaded files
- Collection `siteAdmins` and document `siteConfig/bootstrap`: admin access

The original supplied photos still need to be committed to the repository's `assets/` folder.
