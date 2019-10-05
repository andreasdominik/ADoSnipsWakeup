
# language settings:
# 1) set LANG to "en", "de", "fr", etc.
# 2) link the Dict with messages to the version with
#    desired language as defined in languages.jl:
#

lang = Snips.getConfig(:language)
const LANG = (lang != nothing) ? lang : "de"

# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_TIME = "WakeupTime"
const SLOT_SOUND = "Ringtone"

# name of entry in config.ini:
#
const INI_SOUNDS_DIR = "sounds_dir"
const INI_SOUND = "default_sound"
const INI_SOUNDS = "sounds"


# default ringtone (per siteId):
#
DEFAULT_SOUND = Dict("default" => Snips.getConfig(INI_SOUND))

#
# link between actions and intents:
# intent is linked to action{Funktion}
# the action is only matched, if
#   * intentname matches and
#   * if the siteId matches, if site is  defined in config.ini
#     (such as: "switch TV in room abc").
#
# Language-dependent settings:
#
if LANG == "de"
    Snips.registerIntentAction("wakeupCallDE", scheduleWakeupAction)
    Snips.registerIntentAction("wakeupDeleteDE", deleteWakeupAction)
elseif LANG == "en"
    # Snips.registerIntentAction("pleaseRepeatEN", templateAction)
else
    Snips.registerIntentAction("wakeupCallDE", scheduleWakeupAction)
    Snips.registerIntentAction("wakeupDeleteDE", deleteWakeupAction)
end
Snips.registerTriggerAction("ADoSnipsWakeup", triggerWakeup)
