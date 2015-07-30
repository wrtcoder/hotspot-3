env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'
fs = require 'fs'
Promise = require '../../../promise.coffee'

error = (res, msg) ->
	res.json 501, error: if typeof msg == 'string' then msg else msg.message

class File
	@_list: (req, res) ->
		path = req.params[0].replace /\/$/, ''			# remove trailing slash
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = { dir: path }
		# search is not empty or null
		if !! req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.File.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			# tags contains input search criteria
			fields.push tags: req.query.search
			# file under the input path and file name match input search criteria
			cond = $and: [
				dir:	new RegExp('^' + path)
				$or:	fields
			]
		
		order_by = lib.order_by model.File.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.File.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.File.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, files) ->
			if err
				return error res, err
			model.File.count cond, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: files}
			
	@_read: (req, res) ->
		path = req.params[0]
		model.File.findOne(path: path).populate('createdBy updatedBy').exec (err, file) ->
			if err or file == null
				return error res, if err then err else "File not found1"
			res.json file
	
	@open: (req, res) ->
		path = model.FileUtil.abspath req.params[0]
		if fs.existsSync path
			stat = fs.statSync path  
			if stat.isDirectory()
				File._list req, res
			else
				res.sendfile path
		else
			error res, err: "#{req.params[0]} does not exist"
		
	@create: (req, res) ->
		path = req.body.path
		file = new model.File {path: path, contentType: req.body.contentType, createdBy: req.user}
		file.stream = req.body.file
		file.save (err) =>
			if err
				return error res, err
			res.json file			
			
	@read: (req, res) ->
		path = model.FileUtil.abspath req.params[0]
		if fs.existsSync path
			stat = fs.statSync path  
			func = if stat.isDirectory() then File._list else File._read
			func req, res
		else
			error res, err: "#{req.params[0]} does not exist"
			
	@update: (req, res) ->
		path = req.params[0]
		model.File.findOne {path: path, __v: req.body.__v}, (err, file) ->
			if err or file == null
				return error res, if err then err else "File not found2"
			
			if req.body.file?
				file.stream = req.body.file
			_.extend file, _.pick(req.body, 'path', 'contentType')
			if not _.isUndefined(req.body.name)
				file.rename req.body.name
			file.tags = JSON.parse req.body.tags
			file.updatedBy = req.user
			file.save (err) ->
				if err
					return error res, err
				res.json file				
					
	@delete: (req, res) ->
		path = req.params[0]
		model.File.findOne {path: path}, (err, file) ->		
			if err or file == null
				return error res, if err then err else "File not found3"
			
			file.remove (err, file) ->
				if err
					return error res, err
				res.json {deleted: true}
			
	@tag: (user, search) ->
		return new Promise (fulfill, reject) ->
			success = (files) ->
				tags = []
				_.each files, (file) ->
					tags = _.union tags, file.tags
				tags = _.filter tags, (tag) ->
					(new RegExp(search)).test tag
				fulfill tags
			model.File.find(createdBy: user).select('tags').exec().then success, reject 
				
module.exports = 
	File: 		File