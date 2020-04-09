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


function makeSpokenUntilTime(endTime, startTime)

    millis = Dates.CompoundPeriod(endTime - startTime)
    vals = Dates.canonicalize(millis)

    spokenTime = ""
    for val in vals.periods
        if val isa Dates.Hour
            if val == 1
                timeUnit = Snips.langText(:hour)
            else
                timeUnit = Snips.langText(:hours)
            end
            spokenTime *= "$(Dates.value(val)) $timeUnit"
        elseif val isa Dates.Minute
            if val == 1
                timeUnit = Snips.langText(:minute)
            else
                timeUnit = Snips.langText(:minutes)
            end

            if !isempty(spokenTime)
                spokenTime *= " $(Snips.langText(:and)) "
            end

            spokenTime *= "$(Dates.value(val)) $timeUnit"
        end
    end

    return spokenTime
end
