{exec, child} = require 'child_process'
PomodoroTimer = require './pomodoro-timer'
PomodoroView = require './pomodoro-view'

module.exports =
	config:
		period:
			type: "integer"
			default: 25
		restPeriod:
			type: "integer"
			default: 5
		pathToExecuteWithTimerStart:
			type: "string"
			default: ""
		pathToExecuteWithTimerAbort:
			type: "string"
			default: ""
		pathToExecuteWithTimerFinish:
			type: "string"
			default: ""
		LoopPomodoroRest:
			type: "boolean"
			default: true
		playSounds:
			type: "boolean"
			default: true
		loopStartSound:
			type: "boolean"
			default: false
	
	activate: ->
		atom.commands.add "atom-workspace",
			"pomodoro:start": => @manualStart(),
			"pomodoro:abort": => @abort(),
			"pomodoro:manualStartRest": => @manualStartRest()
			
		@timer = new PomodoroTimer()
		@timer.on 'finished', => @finish()

	consumeStatusBar: (statusBar) ->
		@view = new PomodoroView(@timer)
		statusBar.addRightTile(item: @view, priority: 200)

	manualStart: ->
		console.log "pomodoro: start"
		@timer.manualStart()
		@exec atom.config.get("pomodoro.pathToExecuteWithTimerStart")

	manualStartRest: ->
		console.log "pomodoro: start rest"
		@timer.manualStartRest()
		# TODO pathToExecuteWithRestStart?

	abort: ->
		console.log "pomodoro: abort"
		@timer.abort()
		@exec atom.config.get("pomodoro.pathToExecuteWithTimerAbort")

	finish: ->
		console.log "pomodoro: finish"
		@timer.finish()
		@exec atom.config.get("pomodoro.pathToExecuteWithTimerFinish")

	exec: (path) ->
		if path
			exec path, (err, stdout, stderr) ->
				if stderr
					console.log stderr
				console.log stdout

	deactivate: ->
		@view?.destroy()
		@view = null
