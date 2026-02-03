# mealie

How I built and configure Mealie in my homelab.

# supporting documentation
- Main page: https://docs.mealie.io/
- Installation Checklist: https://docs.mealie.io/documentation/getting-started/installation/installation-checklist/
- Using SQLite: https://docs.mealie.io/documentation/getting-started/installation/sqlite/

# SSL
Certificate is a public certificate from AWS, validated by my managed Route53 domain and host record.
NOTE: On export, had to configure a pass phrase. Mealie doesn't support using a certificate with a pass phrase so had to remove it via OpenSSL. Commands on how to do that are readily available on the internet.

# In-app setup
- Once the application is running, open the main page:
https://<url_from_compose_file>:9925

- Change the user and password to an admin account user/password combination.
