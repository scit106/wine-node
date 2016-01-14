isInt = (stringtotest) ->
	if(/^(\-|\+)?([0-9]+|Infinity)$/.test(stringtotest))
		true
	else
		false

module.exports =
	isInt: isInt