# DNS-01 hook interacting with Versio's API

The following environment variables will have to be set for this hook to
function properly:
* `CUSTOMER_ID` - Your customer ID, can be found on your control panel,
* `CUSTOMER_PW` - The SHA1 of your password.

The following optional environment variables are available as well:
* `TTL`      - The time to live for the challenge record in seconds. Versio
               requires this to be be the same for all TXT records for a given
               domain
* `USE_TEST` - set to 1 to use the test API. This is typically used to prevent
               expenses on API operations costing money. In the case of this
               hook the challenge TXT records will simply not be created
               causing certificate provisioning to fail.

Note that you'll have to explicitly permit the IP address this hook runs from
to interact with Versio's API from your control panel.

Based on the dns-01 manual hook (https://github.com/gheja/dns-01-manual)
