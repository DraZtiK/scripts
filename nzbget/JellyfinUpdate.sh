#!/bin/bash
##############################################################################
### NZBGET POST-PROCESSING SCRIPT                                          ###

# PP-Script Version: 1.0.0.
#
# NOTE: This script only runs on *nix based hosts with BASH.
#       It also requires that curl is installed and is in the $PATH.
#		This script may need to be modifed if "Require HTTPS" is enabled
#		or if "Base URL:" has not 

##############################################################################
### OPTIONS                                                                ###

# The hostname or IP address of the host running Jellyfin.
#
# This can be a remote host or a local host. e.g. 192.168.1.50 or localhost
#host=localhost

# To create your token:
#
# Sign into your Jellyfin Server,
# Browse to the Dashboard --> API keys,
# Generate an API key and copy to your API token field
#APIToken=APIToken

# The port Jellyfin is listening on.
#
# To find your port, connect to your Jellyfin server and find the port after IP or URL":XXXX".
# Default is currently selected.
#Port=8096

# Custom subdirectory
#
# Set this if you have modifed the "Base URL:" option. This may need testing if 
# you have not created/changed the Base URL option. It will require the leading 
# forward slash to function correctly.
#Baseurl=/jellfin

### NZBGET POST-PROCESSING SCRIPT                                          ###
##############################################################################

SUCCESS=93
ERROR=94
SKIP=95

# Check that the required options have been set before continuing
[[ -n $NZBPO_HOST ]] || { echo "[ERROR] Host not set"; exit $ERROR; }
[[ -n $NZBPO_APITOKEN ]] || { echo "[ERROR] APIToken not set"; exit $ERROR; }
[[ -n $NZBPO_PORT ]] || { echo "[ERROR] Port not set"; exit $ERROR; }
[[ -n $NZBPO_BASEURL ]] || { echo "[ERROR] Base URL: not set"; exit $ERROR; }

jellyfin_is_local () {
  if [[ $NZBPO_HOST == 'localhost'  || $NZBPO_HOST == '127.0.0.1' ]]; then
    return 0
  else
    return 1
  fi
}

jellyfin_is_running_locally () {
  if pgrep jellyfin* 1>/dev/null 2>&1; then
    return 0
  elif ps ax | grep [j]ellyfin* 1>/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

if ! which curl 1>/dev/null 2>&1; then
  echo '[ERROR] Can not find curl. update_jellyfin requires curl to be installed and in $PATH.'
  exit $ERROR
fi

curl  --connect-timeout 5 -d "" \
  http://${NZBPO_HOST}:${NZBPO_PORT}${NZBPO_BASEURL}/library/refresh?api_key=${NZBPO_APIXTOKEN} 1>/dev/null 2>&1

curl_return_value="$?"

case $curl_return_value in
  0)
    exit $SUCCESS ;;
  6)
    echo "[ERROR] Couldn't resolve host: ${NZBPO_HOST}"
    exit $ERROR ;;
  6)
    echo "[ERROR] Couldn't resolve APIToken: ${NZBPO_APITOKEN}"
    exit $ERROR ;;
  7)
    echo "[ERROR] Could not connect to the Jellyfin API endpoint at ${NZBPO_APITOKEN}."
    echo "[ERROR] Is Jellyfin running and is 'Valid API token configured'?"
    exit $ERROR ;;
  *)
    echo "[ERROR] Unknown error occured. Curl returned: ${curl_return_value}"
    exit $ERROR ;;
esac
