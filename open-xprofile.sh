#!/bin/bash


# Paths to the browsers, cipher program, and user data storage
dirpath="$HOME/Private"
secure="openssl"
if [[ $OSTYPE == darwin* ]]; then # macOS
  chromium="/Applications/Chromium.app/Contents/MacOS/Chromium"
  googlechrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  gccanary="/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
  vivaldi="/Applications/Vivaldi.app/Contents/MacOS/Vivaldi"
elif [[ $OSTYPE == "linux-gnu" ]]; then # GNU/Linux
  chromium="/usr/bin/chromium-browser"
  googlechrome="/usr/bin/google-chrome"
  vivaldi="/usr/bin/vivaldi"
fi


# Default browser flags and first-run URL.
params="--disable-bundled-ppapi-flash --no-default-browser-check --no-first-run"
url="https://duckduckgo.com"


# Prints usage information for this script.
PRINT_USAGE() {
  echo "Usage: $0 [options] [profile-name]"
  echo "Options:"
  echo "  -h, --help            Displays this usage information and exits."
  echo "  -p, --passwd          Prompts for a password before running; the"
  echo "                        profile is encrypted with the specified"
  echo "                        password when not in use. If a profile is"
  echo "                        already encrypted, this option is implied. If"
  echo "                        no profile name is given, this option is"
  echo "                        ignored."
  echo "  -C, --chromium        Selects the Chromium browser, if it is"
  echo "                        installed."
  echo "  -G, --google-chrome   Selects the Google Chrome browser, if it is"
  echo "                        installed."
  echo "  -N, --chrome-canary   Selects the Google Chrome Canary browser, if"
  echo "                        it is installed."
  echo "  -V, --vivaldi         Selects the Vivaldi browser, if it is"
  echo "                        installed."
  echo "Notes:"
  echo "  This script requires at least one Chromium-based browser, as"
  echo "  defined in the script, to be installed. Additional browsers may be"
  echo "  supported in the future."
  echo "  Profile encryption is done using OpenSSL, and is provided only as a"
  echo "  convenience. Generally, leaving profiles unencrypted helps with"
  echo "  speed, and full-disk encryption is a better choice for protecting"
  echo "  your information."
}

# Decrypts the selected profile, if it is encrypted.
OPEN_PROFILE() {
  if [ -f "$data" ] || [ ! -z "$usekey" ]; then
    [ -z "$key" ] &&
    read -p "Enter the password for $data: " -s key
    echo

    if [ -f "$data" ] && [ ! -z "$key" ]; then
      mv "$data" "$data.enc" &&
      $secure enc -d -aes-256-cbc -k "$key" -in "$data.enc" -out "$data.tar"

      if [ ! -f "$data.tar" ]; then
        mv "$data.enc" "$data"
        exit 1
      fi

      tar -xf "$data.tar" &&
      rm "$data.enc" &&
      rm "$data.tar" &&
      usekey="y"
    else
      exit 1
    fi
  fi
  [ -d "$data" ] && unset url
}

# Prompts the user to select a browser.
SELECT_BROWSER() {
  while [ -z "$browser" ]; do
    echo "    AVAILABLE BROWSERS"
    [ -f "$chromium" ] && echo "C) Chromium"
    [ -f "$googlechrome" ] && echo "G) Google Chrome"
    [ -f "$gccanary" ] && echo "N) Google Chrome Canary"
    [ -f "$vivaldi" ] && echo "V) Vivaldi"

    read -p "Select the browser to use: " choice

    case "$choice" in
      C)
        browser="$chromium"
        ;;
      G)
        browser="$googlechrome"
        ;;
      N)
        browser="$gccanary"
        ;;
      V)
        browser="$vivaldi"
        ;;
    esac
    [ -f "$browser" ] || unset browser
  done
}

# Launches the selected profile in the selected browser.
LOAD_PROFILE() {
  echo "==> Loading $data"
  (nice "$browser" $params --user-data-dir="${PWD}/$data" "$url" 3>&1 2>&1) >/dev/null
  [ -d "$data" ] || exit 1
}

# Encrypts the selected profile, if encryption is enabled.
CLOSE_PROFILE() {
  if [ ! -z "$usekey" ]; then
    [ -z "$key" ] &&
    read -p "Enter the password for $data: " -s key
    echo

    if [ ! -z "$key" ]; then
      tar -cf "$data.tar" "$data" &&
      rm -rf "$data"

      $secure enc -aes-256-cbc -salt -k "$key" -in "$data.tar" -out "$data.enc" &&
      mv "$data.enc" "$data" &&
      rm "$data.tar"
    fi
  fi
}


# Create user data storage and perform sanity checks
[ -d "$dirpath" ] || mkdir -p "$dirpath"
[ $UID -ne 0 ] || exit 1
cd "$dirpath" || exit 1
[ -f "$chromium" ] || [ -f "$googlechrome" ] || [ -f "$gccanary" ] || [ -f "$vivaldi" ] || exit 1

# Parse command-line params
for p in $@; do
  if [[ "$p" == "-h" ]] || [[ "$p" == "--help" ]]; then
    PRINT_USAGE
    exit 0
  elif [[ "$p" == "-p" ]] || [[ "$p" == "--passwd" ]]; then
    usekey="y"
  elif [[ "$p" == "-C" ]] || [[ "$p" == "--chromium" ]]; then
    [ -z "$browser" ] && browser="$chromium"
  elif [[ "$p" == "-G" ]] || [[ "$p" == "--google-chrome" ]]; then
    [ -z "$browser" ] && browser="$googlechrome"
  elif [[ "$p" == "-N" ]] || [[ "$p" == "--chrome-canary" ]]; then
    [ -z "$browser" ] && browser="$gccanary"
  elif [[ "$p" == "-V" ]] || [[ "$p" == "--vivaldi" ]]; then
    [ -z "$browser" ] && browser="$vivaldi"
  else
    [ -z "$data" ] && data="$p"
  fi
done

# Sanity check for selecting the browser via command-line params
[ -f "$browser" ] || unset browser

# Launch either a temporary profile, or the named profile
if [ -z "$data" ]; then
  data=$(date +%s)
  SELECT_BROWSER
  LOAD_PROFILE
  rm -rf "$data"
else
  OPEN_PROFILE
  SELECT_BROWSER
  LOAD_PROFILE
  CLOSE_PROFILE
fi
