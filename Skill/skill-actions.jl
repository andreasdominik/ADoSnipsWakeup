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
    wakeupTime = Snips.readTimeFromSlot(payload, SLOT_TIME)
    soundName = Snips.extractSlotValue(payload, SLOT_SOUND)
    siteId = payload[:siteId]

    # values from config.ini:
    #
    sound = Snips.getConfig(soundName)
    if sound == nothing
        if haskey(DEFAULT_SOUND, siteId)
            soundName = DEFAULT_SOUND[siteId]
            sound = Snips.getConfigPath(soundName, SOUNDS_PATH)
        end
    end
    if sound == nothing
        soundName = Snips.getConfig(INI_DEFAUT_SOUND)
        sound = Snips.getConfigPath(soundName, SOUNDS_PATH)
    end
    if sound == nothing
        Snips.publishEndSession(:no_sounds)
        return true
    end
    if !isfile(sound)
        Snips.publishEndSession(:no_sound_file)
        return true
    end


    fadeIn = Snips.getConfig(INI_FADE_IN)
    if fadeIn == nothing
        fadeIn = 0
    end


    # check if intent is complete:
    #
    if wakeupTime == nothing
        Snips.publishEndSession(:dunno)
        return true
    end

    # set default sound, if no time given:
    #
    if wakeupTime == nothing
        DEFAULT_SOUND[siteId] = soundName
        Snips.publishEndSession("$(Snips.langText(:sound_set)) $sound")
        return true
    end

    # correct time:
    #
    while wakeupTime < Dates.now()
        wakeupTime += Dates.Hour(12)
    end

    scheduleWakeup(wakeupTime, sound, fadeIn, siteId)

    Snips.publishEndSession("$(Snips.langText(:wakeup_scheduled)) $(Snips.readableDateTime(wakeupTime))")
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

    # start a listener for the hotword in room siteId:
    #
    # hotwordChannel = Channel(32)
    # @async waitForHotword(trigger[:room], hotwordChannel)
    #
    # # play the snippets:
    # #
    # snippet = 1
    # playIt = true
    # while playIt
    #     wavFile = "$dirName/snippet$(lpad(snippet,3,'0')).wav"
    #     Snips.printDebug("WAV: $wavFile")
    #     if !isfile(wavFile)
    #         playIt = false
    #     else
    #         rId = "wakeup-call-$snippet"
    #         Snips.publishMQTTfile("hermes/audioServer/$(trigger[:room])/playBytes/$rId",
    #                               wavFile)
    #
    #         playing = true
    #         while playing
    #             (topic, payload) = Snips.readOneMQTT("hermes/audioServer/$(trigger[:room])/playFinished")
    #             if (payload isa Dict) && haskey(payload, :id) && (payload[:id] == rId)
    #                 Snips.printDebug("finished detected: $payload")
    #                 playing = false
    #             end
    #         end
    #         if isready(hotwordChannel)
    #             siteId = take!(hotwordChannel)
    #             playIt = false
    #         end
    #         snippet += 1
    #     end
    # end

    # publish play request:
    #


    Snips.publishSay("$(Snips.langText(:good_morning)) $(Snips.readableDateTime(Dates.now()))")
end


function waitForHotword(siteId, hotwordChannel)

    wait4hotword = true
    payload = Dict()
    while wait4hotword
        (topic, payload) = Snips.readOneMQTT("hermes/hotword/default/detected")

        if payload isa Dict && haskey(payload, :siteId) && payload[:siteId] == siteId
            wait4hotword = false
        end
    end
    Snips.printDebug("put siteId to Channel: $payload[:siteId]")
    put!(hotwordChannel, payload[:siteId])
end
