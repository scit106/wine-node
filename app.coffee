express = require 'express'
http = require 'http' 
path = require 'path' 
mongo = require 'mongodb'
mongoose = require 'mongoose'
jade = require 'jade'
# bodyParser = express.bodyParser

app = express()

app.set 'port', process.env.PORT or 3000
app.set 'views', './views'
app.set 'view engine', 'jade'

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')

# app.use express.bodyParser.json()

app.get '/', (req, res) ->
	res.render 'index', 
		title: 'Hi'
		message: 'Hello There'
