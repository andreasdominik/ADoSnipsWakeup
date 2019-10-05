#
# API function goes here, to be called by the
# skill-actions:
#

function scheduleWakeup(wakeupTime, sound, siteId)

    topic = "qnd/trigger/andreasdominik:ADoSnipsWakeup"

    trigger = Dict("wakeupTime" => "$wakeupTime",
                   "room" => siteId,
                   "wav" => sound)
    (topic, schedule) = Snips.makeSystemTrigger(topic, trigger)
    Snips.schedulerAddAction(wakeupTime, topic, schedule)
end
