express = require 'express'
http = require 'http' 
path = require 'path' 
mongo = require 'mongodb'
mongoose = require 'mongoose'
jade = require 'jade'
stylus = require 'stylus'
bodyParser = require 'body-parser'
_ = require 'underscore'
request = require 'request'
util = require './util'

app = express()

app.set 'port', process.env.PORT or 3000
app.set 'views', './views'
app.set 'view engine', 'jade'

http.createServer(app).listen app.get('port'), ->
	console.log 'Express server listening on port ' + app.get('port')

app.use bodyParser.json()
app.use bodyParser.urlencoded({extended: true})

app.use stylus.middleware({
	src: __dirname + '/stylesheets',
	dest: __dirname + '/public'
	})

app.use express.static(__dirname +  '/public')

app.get '/', (req, res) ->
	res.render 'index'

app.get '/vote', (req, res) ->
	res.render 'vote',
		errors: {}

app.post '/vote', (req, res) ->
	color = req.body.color
	tastingNumber = req.body.tastingNumber
	errors = {}
	unless util.isInt(color)
		errors.color = true
	unless util.isInt(tastingNumber)
		errors.tastingNumber = true
	if _.isEmpty errors
		res.redirect '/thanks'
	else
		res.render 'vote',
			tastingNumber: tastingNumber
			color: color
			errors: errors
	# Log the vote to DB
	# If vote saves, redirect to thank you
	# if vote fails to save, rerender vote with error


app.get '/thanks', (req, res) ->
	res.render 'thanks'

app.get '/search', (req, res) ->
	res.render 'search'


app.post '/search', (req, res) ->
	snoothKey = "5na931xwbey79ngkupjjobm2akv7da7caa7b5rhl1asux25c" #DONT PUT THIS IN GITHUB. ENV VARS YO.
	# reqURL = "http://api.snooth.com/wines?akey=" + snoothKey + "&amp;q=" + req.body.wineName + "&amp;n=20&amp;a=0"
	reqOptions =
		url: "http://api.snooth.com/wines"
		qs:
			akey: snoothKey
			q: req.body.wineName
			n: 20
			a: 0
	request.get reqOptions, (error, response, body) ->
		if error
			console.log 'error requesting api'
			console.log error
			res.send 500
		else if response.statusCode isnt 200
			res.send 500
		else if body
			bodyAsJSON = JSON.parse body
			console.log bodyAsJSON.wines
			res.render 'results',
				wines: bodyAsJSON.wines
	# console.log req.body



