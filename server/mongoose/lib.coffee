path = require 'path'
env = require '../../env.coffee'
model = require '../../model.coffee'

logger = env.log4js.getLogger('permission')

field = (name) ->
	if name.charAt(0) == '-'
		return name.substring(1)
	return name
	
order = (name) ->
	if name.charAt(0) == '-'
		return -1
	return 1
	
order_by = (name) ->
	ret = {}
	ret[field(name)] = order(name)
	return ret
		
newHome = ->
	(req, res, next) ->
		model.File.findOrCreate {path: "#{req.user.username}/", createdBy: req.user}, (err, file) ->
			if err
				res.json 501, error: err
			else next()

module.exports =
	field:				field
	order:				order
	order_by:			order_by
	newHome:			newHome