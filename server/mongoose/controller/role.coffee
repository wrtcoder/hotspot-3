env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class Role

	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = {}
		if req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.Role.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			cond = $or: fields 
		
		order_by = lib.order_by model.Role.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Role.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.Role.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, roles) ->
			if err
				return error res, err
			model.Role.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: roles}
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		role = new model.Role data
		role.save (err) =>
			if err
				return error res, err
			res.json role			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Role.findById(id).populate('createdBy updatedBy').exec (err, role) ->
			if err or role == null
				return error res, if err then err else "Role not found"
			res.json role			
			
	@update: (req, res) ->
		id = req.param('id')
		model.Role.findOne {_id: id, __v: req.body.__v}, (err, role) ->
			if err or role == null
				return error res, if err then err else "Role not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				role[key] = value
			role.updatedBy = req.user
			role.save (err) ->
				if err
					error res, err
				else res.json role				
					
	@delete: (req, res) ->
		id = req.param('id')
		model.Role.findOne {_id: id}, (err, role) ->		
			if err or role == null
				return error res, if err then err else "Role not found"
			
			role.remove (err, role) ->
				if err
					error res, err
				else
					res.json {deleted: true}
					
module.exports = 
	Role: 		Role