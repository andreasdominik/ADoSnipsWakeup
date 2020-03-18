#!/bin/bash -xv
#
MEDIA="$1"
FADE_IN="$2"
PLAY_SITE="$3"

SESSION_ID="no_session:Wakeup-Trigger"
ID="id:$(uuidgen)"

# set config path:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh

# base names for recveived and subm. MQTT message files:
#
MQTT_BASE_NAME="QnDWakeup"

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

# deactivate hotwords in session manager:
#
publish "$TOPIC_DIALOGUE_STOP_LISTEN" '{}'
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

publish "$TOPIC_DIALOGUE_START_LISTEN" '{}'

# payload for hotword on again:
#
HOTWORD_PAYLOAD="{
  \"sessionId\": \"no_session\",
  \"siteId\": \"$PLAY_SITE\"
}"
publish "$TOPIC_HOTWORD_ON" "$HOTWORD_PAYLOAD"
