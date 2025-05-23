#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status

NR_INI_FILE="/usr/local/etc/php/conf.d/newrelic.ini"

# Check if the required environment variables are set
if [ -z "$NEW_RELIC_LICENSE_KEY" ]; then
  echo "Error: NEW_RELIC_LICENSE_KEY environment variable is not set."
  exit 1
fi

if [ -z "$NEW_RELIC_APP_NAME" ]; then
  echo "Error: NEW_RELIC_APP_NAME environment variable is not set."
  exit 1
fi

# The newrelic-install script should have already created a newrelic.ini.
# We will modify it.
if [ -f "$NR_INI_FILE" ]; then
  echo "Updating $NR_INI_FILE with environment variables..."

  # Use sed to replace the placeholder or existing values for license and appname.
  # The patterns "newrelic.license =.*" and "newrelic.appname =.*" will match
  # the lines starting with these keys, regardless of their current value.
  # We use @ as a sed delimiter to avoid issues if license keys or app names contain slashes.
  sed -i \
    "s@newrelic.license =.*@newrelic.license = \"${NEW_RELIC_LICENSE_KEY}\"@" \
    "$NR_INI_FILE"

  sed -i \
    "s@newrelic.appname =.*@newrelic.appname = \"${NEW_RELIC_APP_NAME}\"@" \
    "$NR_INI_FILE"

  echo "$NR_INI_FILE updated successfully."
  echo "--- Content of $NR_INI_FILE (for verification) ---"
  cat "$NR_INI_FILE"
  echo "----------------------------------------------------"
else
  echo "Warning: $NR_INI_FILE not found. New Relic agent may not be configured correctly."
  # Depending on strictness, you might want to exit 1 here too.
fi

# Execute the command passed as arguments to this script (the Docker CMD)
exec "$@"