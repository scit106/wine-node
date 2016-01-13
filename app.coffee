express = require 'express'
http = require 'http' 
path = require 'path' 
mongo = require 'mongodb'
mongoose = require 'mongoose'
jade = require 'jade'
stylus = require 'stylus'
# bodyParser = express.bodyParser

app = express()

app.set 'port', process.env.PORT or 3000
app.set 'views', './views'
app.set 'view engine', 'jade'

http.createServer(app).listen app.get('port'), ->
	console.log 'Express server listening on port ' + app.get('port')

app.use stylus.middleware({
	src: __dirname + '/stylesheets',
	dest: __dirname + '/public'
	})

app.use express.static(__dirname +  '/public')

app.get '/', (req, res) ->
	res.render 'index', 
		title: 'Hi'
		message: 'Hello There'
