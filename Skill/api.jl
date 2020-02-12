#
# API function goes here, to be called by the
# skill-actions:
#

function scheduleWakeup(wakeupTime, sound, fadeIn, siteId)

    topic = "qnd/trigger/andreasdominik:ADoSnipsWakeup"

    trigger = Dict("wakeupTime" => "$wakeupTime",
                   "room" => siteId,
                   "fade_in" => fadeIn,
                   "media" => sound)
    (topic, schedule) = Snips.makeSystemTrigger(topic, trigger)
    Snips.schedulerAddAction(wakeupTime, topic, schedule)
end
