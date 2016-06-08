events = require 'events'

module.exports =
class PomodoroTimer extends events.EventEmitter

	constructor: ->
		@ticktack = new Audio(require("../resources/ticktack").data())
		@bell = new Audio(require("../resources/bell").data())
		@ticktack.loop = atom.config.get("pomodoro.loopStartSound")
	
	manualStart: ->
		if @timer?
			@stop()
		if atom.config.get("pomodoro.playSounds")
			@ticktack.play()
		@start()
	
	manualStartRest: ->
		if @timer?
			@stop()
		if atom.config.get("pomodoro.playSounds")
			@ticktack.play()
		@startRest()
	
	start: ->
		@startTime = new Date()
		@minutes = atom.config.get("pomodoro.period")
		@isRest = false
		@timer = setInterval ( => @step() ), 1000
	
	startRest: ->
		@startTime = new Date()
		@minutes = atom.config.get("pomodoro.restPeriod")
		@isRest = true
		@timer = setInterval ( => @step() ), 1000
	
	abort: ->
		@status = "aborted (#{new Date().toLocaleString()})"
		@stop()

	time: ->
		@minutes * 60 * 1000

	finish: ->
		@status = "finished (#{new Date().toLocaleString()})"
		@stop()
		if atom.config.get("pomodoro.playSounds")
			@bell.play()
		if atom.config.get("pomodoro.LoopPomodoroRest")
			if @isRest
				@start()
			else
				@startRest()

	stop: ->
		if(@ticktack.loop)
			@ticktack.pause()
		clearTimeout @timer
		@updateCallback(@status)

	step: ->
		time = (@time() - (new Date() - @startTime)) / 1000
		if time <= 0
			@emit 'finished'
		else
			min = @zeroPadding(Math.floor(time / 60))
			sec = @zeroPadding(Math.floor(time % 60))
			@status = "#{min}:#{sec}"
			@updateCallback(@status)

	zeroPadding: (num) ->
		("0" + num).slice(-2)

	setUpdateCallback: (fn) ->
		@updateCallback = fn
