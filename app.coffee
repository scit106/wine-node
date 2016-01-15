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
pg = require 'pg'
util = require './util'


app = express()

app.set 'port', process.env.PORT or 3000
app.set 'views', './views'
app.set 'view engine', 'jade'

pgClient = {}

http.createServer(app).listen app.get('port'), ->
	console.log 'Express server listening on port ' + app.get('port')
	# todo - allow this to work in multiple envs.
	pg.connect 'postgres://postgres@localhost/node_test_db', (error, client, done) ->
		if error
			console.log error
		else
			console.log 'Connected to database'
			util.setUpDB(client)
			pgClient = client


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
		queryOptions = {
			text: "INSERT INTO votes (tasting_number, color) VALUES ($1, $2)"
			values: [tastingNumber, color]
		}
		pgClient.query queryOptions, (error, result) ->
			if error
				console.log 'voting error'
				console.log error
			else
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
	wineName = req.body.wineName
	reqOptions =
		url: "http://api.snooth.com/wines"
		qs:
			akey: snoothKey
			q: wineName
			n: 20
			a: 0
	request.get reqOptions, (error, response, body) ->
		if error
			console.log 'error requesting snooth API'
			console.log error
			res.send 500
		else if response.statusCode isnt 200
			res.send 500
		else if body
			bodyAsJSON = JSON.parse body
			res.render 'results',
				wineName: wineName
				wines: bodyAsJSON.wines

app.get '/new', (req, res) ->
	if req.query.snoothId
		snoothKey = "5na931xwbey79ngkupjjobm2akv7da7caa7b5rhl1asux25c"
		reqOptions =
			url: "http://api.snooth.com/wine"
			qs:
				akey: snoothKey
				id: req.query.snoothId
				i: 1
				food: 1
		request.get reqOptions, (error, response, body) ->
			if error
				console.log 'error requesting snooth API'
				console.log error
				res.send 500
			else if response.statusCode isnt 200
				console.log 'response contained error'
				res.send 500
			else if body
				bodyAsJSON = JSON.parse body
				wine = bodyAsJSON.wines[0]
				# Transform wine props
				color =
					switch wine.type
						when 'Red Wine' then 1
						when 'White Wine' then 2
						when 'Sparkling Wine' then 3
						else null
				res.render 'new',
					name: wine.name
					winery: wine.winery
					varietal: wine.varietal
					color: wine.color
					isSnooth: true
					image: wine.image
					wm_notes: wine.wm_notes
					winery_tasting_notes: wine.winery_tasting_notes
					price: wine.price
					snoothId: wine.code
	else
		res.render 'new',
			name: req.query.name

app.post '/new', (req, res) ->
	r = req.body
	queryOptions = {
		text: "INSERT INTO wines (person_name, name, winery, varietal, color, price, snooth_id, tasting_number)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)"
		values: [r.personName, r.name, r.winery, r.varietal, r.color, r.price, r.snoothId, r.tastingNumber]
	}
	pgClient.query queryOptions, (error, result) ->
		if error
			console.log 'Insert error'
			console.log error
		else
			res.redirect '/thanks'

app.get '/results', (req, res) ->
	console.log 'foo'
	# query = pgClient.query("select * from information_schema.tables where table_name like '%diagnos%'")
	# query.on 'end', (results) ->
	# 	console.log results
