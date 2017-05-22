# Capital One Investing Open Redirect Vulnerability

You could pass any URL in the `tl` parameter of the Capital One Investing login
page, and get redirected to any site on the Internet. An attacker could use
this to redirect a user to an untrusted site, and potentially phish for users
information.

This error has since been fixed.

For example:

    https://www.capitaloneinvesting.com/main/authentication/signin.aspx?tl=https://kev.inburke.com/foo/bar

If you were already logged in, you are automatically redirected to the URL
in the `tl` parameter. An attacker could use this to present a URL for
capitaloneinvesting.com that immediately redirects to their phishing site.

More information about this class of vulnerability is available here:
https://www.owasp.org/index.php/Unvalidated_Redirects_and_Forwards_Cheat_Sheet

## Timeline

- **February 12:** Initial report

- **March 5**: Reach a security engineer for Capital One

- **May 12:** Disclosure deadline end; notice the error has been fixed.
