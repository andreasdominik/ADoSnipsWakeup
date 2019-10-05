# ADoSnipsWakeup

This is a skill for the SnipsHermesQnD framework for Snips.ai
written in Julia to implement a simple alarm clock.

 The full documentation is just work-in-progress!
 Current version can be visited here:

 [Framework Documentation](https://andreasdominik.github.io/ADoSnipsQnD/dev)


## Skill

The skill can schedule a wakeup call and will use a system trigger to
play a series of sounds (as wav files) in the room (i.e. siteId) in
which the programming have been scheduled.

##### Sounds

The alarm sounds must be provided as snippets in wav-formate
(example sounds are 5 sec each). Name of the directory and names of
the subdirectories with the sounds are configured in the `config.ini`.

The qnd-scheduler will play the
sounds and stop if the hotword is detected in the respective room (siteId).


# Julia

This skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here: https://julialang.org/
