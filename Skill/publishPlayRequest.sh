#!/bin/bash -xv
#
MEDIA="$1"
FADE_IN="$2"
PLAY_SITE="$3"

SESSION_ID="no_session:Wakeup-Trigger"
ID="id:$(uuidgen)"

# set config path:
#
CONFIG="/etc/susi.toml"
source $SUSI_INSTALLATION/bin/toml2env $CONFIG

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/funs.sh
source $SUSI_INSTALLATION/src/Tools/topics.sh

# base names for recveived and subm. MQTT message files:
#
MQTT_BASE_NAME="QnDWakeup"
MQTT_COUNTER=0

MEDIA_B64=playWakeup.b64
base64 -w 0 $MEDIA > $MEDIA_B64

PAYLOAD_FILE="${MQTT_BASE_NAME}-$(printf "%04d" $MQTT_COUNTER).payload"

# write payload and publish:
#
echo -n "{
  \"sessionId\": \"$SESSION_ID\",
  \"siteId\": \"$PLAY_SITE\",
  \"id\": \"$ID\",
  \"hotword\": \"sensitive\",
  \"fade_in\": \"$FADE_IN\",
  \"audio\": \""              >  $PAYLOAD_FILE
  cat $MEDIA_B64              >> $PAYLOAD_FILE
  echo "\" }"                 >> $PAYLOAD_FILE

publishFile "$TOPIC_PLAY_REQUEST" "$PAYLOAD_FILE"


# wait for finished:
#
FINISHED=false
while [[ $FINISHED == false ]] ; do
  subscribeSiteOnce $PLAY_SITE $TOPIC_PLAY_FINISHED
  if [[ $MQTT_ID == $ID ]] ; then
    FINISHED=true
  fi
done
