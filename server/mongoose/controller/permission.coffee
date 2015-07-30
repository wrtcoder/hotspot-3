model = require '../../../model.coffee'
Promise = require '../../../promise.coffee'
_ = require 'underscore'

class Permission
	@list: (condition, pagination, order) ->
		return new Promise (fulfill, reject) ->
			p = new Promise.all [
				model.Permission.find(condition, null, pagination).sort(order).exec(),
				model.Permission.count(condition).exec()
			]
			success = (res) ->
				fulfill {count: res[1], results: res[0]}
			p.then success, reject
		
	@create: (user, data) ->
		return new Promise (fulfill, reject) ->
			data.createdBy = user
			perm = new model.Permission data
			perm.save (err, perm) ->
				if err
					reject err
				else
					fulfill perm.toJSON()
	
	@update: (user, id, data) ->
		return new Promise (fulfill, reject) ->
			model.Permission.findOne {_id: id, createdBy: user, __v: data.__v}, (err, perm) ->
				if err or perm == null
					reject err || "Permission not found"
				_.extend perm, _.pick(data, 'order', 'fileGrp', 'userGrp', 'action')
				perm.save()
					.then ->
						fulfill perm.toJSON()
					.then null, (err) ->
						reject err

	@delete: (user, id) ->
		return new Promise (fulfill, reject) ->
			model.Permission.findById id, (err, perm) ->		
				if err or perm == null
					reject if err then err else "Permission not found"
				
				perm.remove (err) ->
					if err
						reject(err)
					else
						fulfill("deleted successfully")
			
module.exports = 
	Permission: 	Permission