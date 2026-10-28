# Hamilton Website backend setup

1. Create a dedicated Supabase project in your chosen organization.
2. Run `schema.sql` in the Supabase SQL Editor. This creates the content tables, enquiries inbox, media bucket and first-user admin trigger.
3. Replace the placeholder values in `/site-config.json` with your project's public API URL and publishable key. **Never commit a secret or service-role key.**
4. In Supabase Auth settings, configure the site URL and allowed redirect URLs for the Vercel deployment. Consider disabling public signups after the first administrator registers.
5. Visit `/admin.html`, register the first account and verify its role in `site_roles`.
6. Test an upload, publish a post, and verify it appears on the site.

The public enquiry form stores messages in the database, not email. Add CAPTCHA, rate limiting, and abuse protection before enabling it broadly.

**Security note:** The first-user role trigger assumes this is a fresh dedicated project with no preexisting Auth users. Other users get `viewer` roles, not admin. A public signup can still create viewer accounts until signups are disabled in Auth settings.
