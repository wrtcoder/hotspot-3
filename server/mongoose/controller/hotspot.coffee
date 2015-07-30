env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
Promise = require '../../../promise.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class Hotspot
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		hotspot = new model.Hotspot data
		hotspot.save (err) =>
			if err
				return error res, err
			res.json hotspot
			
	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = {}
		if req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.Hotspot.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			cond = $or: fields 
		
		order_by = lib.order_by model.Hotspot.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Hotspot.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.Hotspot.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, hotspots) ->
			if err
				return error res, err
			model.Hotspot.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: hotspots}	
	
	@delete: (req, res) ->
		id = req.param('id')
		model.Hotspot.findOne {_id: id}, (err, hotspot) ->		
			if err or hotspot == null
				return error res, if err then err else "Hotspot not found"
			
			hotspot.remove (err, hotspot) ->
				if err
					error res, err
				else
					res.json {deleted: true}

	@read: (req, res) ->
		id = req.param('id')
		model.Hotspot.findById(id).populate('createdBy updatedBy').exec (err, hotspot) ->
			if err or hotspot == null
				return error res, if err then err else "Hotspot not found"
			res.json hotspot	

	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		hotspot = new model.Hotspot data
		hotspot.save (err) =>
			if err
				return error res, err
			res.json hotspot

	@update: (req, res) ->
		id = req.param('id')
		model.Hotspot.findOne {_id: id, __v: req.body.__v}, (err, hotspot) ->
			if err or hotspot == null
				return error res, if err then err else "hotspot not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->	
			
				hotspot[key] = value
			hotspot.updatedBy = req.user
			hotspot.save (err) ->
				if err
					error res, err
				else res.json hotspot		
		
class Venue

	@list: (req, res) ->

		order_by = lib.order_by model.Venue.ordering()
		
		model.Venue.find().populate('createdBy updatedBy').sort(order_by).exec (err, venues) ->
			if err
				return error res, err
			model.Venue.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: venues}
				
class District

	@list: (req, res) ->

		order_by = lib.order_by model.District.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.District.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.District.find().populate('createdBy updatedBy').sort(order_by).exec (err, districts) ->
			if err
				return error res, err
			model.District.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: districts}

class Provider

	@list: (req, res) ->

		order_by = lib.order_by model.Provider.ordering()
		
		model.Provider.find().populate('createdBy updatedBy').sort(order_by).exec (err, providers) ->
			if err
				return error res, err
			model.Provider.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: providers}

				
				
module.exports = 
	Hotspot: 		Hotspot
	Venue:			Venue
	District:		District
	Provider:		Provider