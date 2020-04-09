#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
    scheduleWakeupAction(topic, payload)

Schedule a wakeup call.

"""
function scheduleWakeupAction(topic, payload)

    # log:
    #
    Snips.printLog("action scheduleWakeupAction() started.")

    # get time and sound from slot:
    #
    siteId = payload[:siteId]
    wakeupTime = Snips.readTimeFromSlot(payload, SLOT_TIME)
    if wakeupTime == nothing
        Snips.publishEndSession(:dunno)
        return true
    end

    # descide which ringtone to use:
    #
    soundName = Snips.extractSlotValue(payload, SLOT_SOUND)
    if soundName == nothing
        if haskey(DEFAULT_SOUND, siteId)
            soundName = DEFAULT_SOUND[siteId]
        end
    end
    if soundName == nothing
        soundName = Snips.getConfig(INI_DEFAULT_SOUND)
    end
    if soundName == nothing
        Snips.publishEndSession(:no_sounds)
        return true
    end

    sound = Snips.getConfigPath(soundName, SOUNDS_PATH)
    Snips.printDebug("Name: $soundName, File: $sound, PATH: $SOUNDS_PATH")
    if !isfile(sound)
        Snips.publishEndSession(:no_sound_file)
        return true
    end

    # get description of ringtone:
    #
    soundDescr = Snips.getConfig(soundName, onePrefix=LANG)
    if soundDescr == nothing
        soundDescr = "unknown sound"
    end


    fadeIn = Snips.getConfig(INI_FADE_IN)
    if fadeIn == nothing
        fadeIn = 0
    end


    # correct time:
    #
    while wakeupTime < Dates.now()
        wakeupTime += Dates.Hour(12)
    end

    scheduleWakeup(wakeupTime, sound, fadeIn, siteId)

    # calculate time until alarm:
    #
    inTime = makeSpokenUntilTime(wakeupTime, Dates.now())

    msg = "$(Snips.langText(:wakeup_scheduled)) $(Snips.readableDateTime(wakeupTime))" *
          " $(Snips.langText(:with)) $soundDescr. " *
          " $(Snips.langText(:remaining)) $inTime"

    Snips.publishEndSession(msg)
    return false
end





"""
    ringtoneWakeupAction(topic, payload)

Set the default ringtone for a siteId.

"""
function ringtoneWakeupAction(topic, payload)

    # log:
    #
    Snips.printLog("action ringtoneWakeupAction() started.")

    # get time and sound from slot:
    #
    siteId = payload[:siteId]

    soundName = Snips.extractSlotValue(payload, SLOT_SOUND)
    if soundName == nothing
        Snips.publishEndSession(:which_sound)

    elseif !Snips.isInConfig(soundName)
        Snips.publishEndSession(:no_sounds)

    else
        sound = Snips.getConfigPath(soundName, SOUNDS_PATH)
        if sound == nothing
            sound = ""
        end
        Snips.printDebug("Name: $soundName, File: $sound, PATH: $SOUNDS_PATH")
        if !isfile(sound)
            Snips.publishEndSession(:no_sound_file)
        else
            DEFAULT_SOUND[siteId] = soundName
            Snips.publishEndSession("$(Snips.langText(:sound_set)) $soundName")
        end
    end
    return true
end


"""
    deleteWakeupAction(topic, payload)

Delete all scheduled wakeup calls.

"""
function deleteWakeupAction(topic, payload)

    # log:
    #
    Snips.printLog("action deleteWakeupAction() started.")

    topic = "qnd/trigger/andreasdominik:ADoSnipsWakeup"
    Snips.schedulerDeleteTopic(topic)

    Snips.publishEndSession(:deleted)
end


"""
    triggerWakeup(topic, payload)

Respond to the trigger ADoSnipsWakeup.

The trigger must have the following JSON format:
    {
      "topic" : "qnd/trigger/andreasdominik:ADoSnipsWakeup",
      "origin" : "ADoSnipsWakeup",
      "sessionId": "1234567890abcdef",
      "siteId" : "default",
      "time" : "timeString",
      "trigger" : {
        "room" : "bedrooom",
        "wakeupTime" : "timestring",
        "fade_in" : 15,
        "media" : "path to ringtone"
      }
    }
"""
function triggerWakeup(topic, payload)

    Snips.printLog("trigger action ADoSnipsWakeup started!")

    # test if trigger is complete:
    #
    payload isa Dict || return false
    haskey( payload, :trigger) || return false
    trigger = payload[:trigger]

    haskey(trigger, :room) || return false
    haskey(trigger, :wakeupTime) || return false
    haskey(trigger, :media) || return false
    haskey(trigger, :fade_in) || return false

    cmd = `$PLAY_SCRIPT $(trigger[:media]) $(trigger[:fade_in]) $(trigger[:room])`
    Snips.tryrun(cmd; wait=true)
    Snips.publishSay("$(Snips.langText(:good_morning)) $(Snips.readableDateTime(Dates.now()))")

Snips.printDebug("after say good morning")

    sleep(1.0)
    Snips.publishHotwordOn(trigger[:room])
end
