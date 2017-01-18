# open-xprofile

Browse Chromium with temporary or encrypted profiles

(credit to @mittman for the original script)

## Why use this instead of Incognito/Guest mode?

In Chromium, neither Incognito nor Guest mode store persistent browsing data.
However, they are far from perfect. Incognito windows are associated with a
given profile, and are therefore affected by that profile's settings. This may
allow sites to track you despite the use of Incognito mode. Guest mode is a
bit better since it always uses the default Chromium settings, but even it is
affected by the settings in `chrome://flags`.

open-xprofile makes it easy to use multiple, independent browsing profiles
(e.g. one for school and another for work) at the same time, and also to spin
up temporary sessions with full settings/extension support for just about any
sort of browsing activity. You can also encrypt profile data when not in use
(instead of using Chrome sync and childlock).

## Usage

`open-xprofile.sh [options] [profile-name]`

## Options

By default, the script creates a temporary user data directory and destroys it
after the browser is closed. However, providing a profile name will cause the
data to be retained indefinitely. Profiles are stored under `~/Private`.

To encrypt a named profile, enter the `-p` or `--passwd` options. The password
is taken via interactive input before the browser is launched, and the profile
directory is encrypted after the browser is closed.

The browser is selected either via interactive input, or with the following
options:

- `-C`, `--chromium` - Selects the Chromium browser.
- `-G`, `--google-chrome` - Selects the Google Chrome browser.
- `-N`, `--chrome-canary` - Selects the Google Chrome Canary browser.
- `-V`, `--vivaldi` - Selects the Vivaldi browser.

Additional browsers may be supported in the future (feel free to make a PR, or
simply edit the script yourself).

## Requirements

- Bash
- OpenSSL
- At least one (supported) Chromium-based browser

## Tested Configurations

- GNU/Linux (Fedora, Slackware)
- Mac OS X 10.11
