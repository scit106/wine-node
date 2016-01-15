isInt = (stringtotest) ->
	if(/^(\-|\+)?([0-9]+|Infinity)$/.test(stringtotest))
		true
	else
		false

setUpDB = (client) ->
	client.query "CREATE TABLE IF NOT EXISTS wines (
		id serial primary key,
		person_name text,
		name text,
		winery text,
		varietal text,
		color text,
		price text,
		snooth_id text,
		tasting_number integer
		)
	", (error, result) ->
		if error
			console.log 'error creating wines table'
			console.log error

	client.query "CREATE TABLE IF NOT EXISTS votes (
		id serial primary key,
		tasting_number integer,
		color text
		)
	", (error, result) ->
		if error
			console.log 'error creating votes table'
			console.log error


module.exports =
	isInt: isInt
	setUpDB: setUpDB