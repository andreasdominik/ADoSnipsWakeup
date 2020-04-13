#
# The main file for the App.
#
# Normally, it is NOT necessary to change anything in this file,
# unless you know what you are doing!
#
module ADoSnipsWakeup

import Dates
import StatsBase

const MODULE_DIR = @__DIR__
const APP_DIR = replace(MODULE_DIR, r"/[^/]*/?$"=>"")
const SKILLS_DIR = replace(APP_DIR, r"/[^/]*/?$"=>"")
const APP_NAME = split(APP_DIR, "/")[end]

const FRAMEWORK_DIR = "$SKILLS_DIR/ADoSnipsQnD"
include("$FRAMEWORK_DIR/SnipsHermesQnD/src/SnipsHermesQnD.jl")
import .SnipsHermesQnD
Snips = SnipsHermesQnD

const SOUNDS_PATH = joinpath(APP_DIR, "Sounds")
const PLAY_SCRIPT = joinpath(APP_DIR, "Skill/publishPlayRequest.sh")

Snips.readConfig("$APP_DIR")
Snips.readConfig("$FRAMEWORK_DIR")
Snips.setLanguage(Snips.getConfig(:language))
Snips.setAppDir(APP_DIR)
Snips.setAppName(APP_NAME)

include("api.jl")
include("skill-actions.jl")
include("languages.jl")
include("config.jl")
include("exported.jl")


export getIntentActions, callbackRun

end
