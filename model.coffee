fs = require 'fs'
_ = require 'underscore'
env = require './env'
path = require 'path'
mongoose = require 'mongoose'
findOrCreate = require 'mongoose-findorcreate'
taggable = require 'mongoose-taggable'
Promise = require './promise.coffee'

mongoose.connect env.db.url, { db: { safe: true }}, (err) ->
  	if err
  		console.log "Mongoose - connection error: #{err}"
  	else console.log "Mongoose - connection OK"

###
	perm = domain:action:obj
### 
PermissionSchema = new mongoose.Schema
	order:		{ type: Number }
	userGrp:	{ type: String, required: true }
	fileGrp:	{ type: String, required: true }
	action:		[ { type: String } ]
	createdBy:	{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }

PermissionSchema.statics =
	ordering_fields: ->
		order: 1, userGrp: 1, fileGrp: 1
		
PermissionSchema.methods =
	implies: (user, file, action) ->
		if not _.contains file.tags @fileGrp
			return false
	
PermissionSchema.plugin(findOrCreate)

Permission = mongoose.model 'Permission', PermissionSchema
			
TagSchema = new mongoose.Schema
	name:			{ type: String, required: true, index: {unique: true} }
	permissions:	[ { type: String } ]
	
TagSchema.plugin(findOrCreate)

Tag = mongoose.model 'Tag', TagSchema
	
UserSchema = new mongoose.Schema
	url:			{ type: String, required: true, index: {unique: true} }
	username:		{ type: String, required: true }
	email:			{ type: String }
	
UserSchema.statics =
	search_fields: ->
		return ['username', 'email']
	ordering_fields: ->
		return ['username', 'email']
	ordering: ->
		return 'username'
	isUser: (oid) ->
		p = @findById(oid).exec()
		p1 = p.then (user) ->
			return user != null
		p1.then null, (err) ->
			return false		
		
UserSchema.methods =
	checkPermission: (perm) ->
		q = @model('Tag').find(name: $in: @tags).exec()
		q.then (perms) ->
			_.some perms, (r) ->
				_.some r.permissions, (p) ->
					p = new Permission(p)
					p.implies perm
	checkPermissions: (perms) ->
		promises = _.map perms, (p) ->
			@checkPermission(p)
		Promise.all(promises).done (permitted) ->
			_.all permitted
			
UserSchema.plugin(findOrCreate)
UserSchema.plugin(taggable)

UserSchema.pre 'save', (next) ->
	@addTag(env.role.all)
	@increment()
	next()
User = mongoose.model 'User', UserSchema

class FileUtil 
	@abspath: (path) ->
		"#{env.app.uploadDir}/#{path}"
			
	@isDir: (path) ->
		/\/$/.test path
		
	@isRealDir: (path) ->
		fs.statSync(FileUtil.abspath(path)).isDirectory()
		
	# ignore exception if path already exists
	@newDir: (path) ->
		try 
			fs.mkdirSync FileUtil.abspath(path), env.app.mode
		catch
			return
	
	@newFile: (path) ->
		fs.openSync FileUtil.abspath(path), 'w', env.app.mode
		
	@rm: (path) ->
		func = if FileUtil.isDir(path) then fs.rmdirSync else fs.unlinkSync 
		func FileUtil.abspath(path)
	
FileSchema = new mongoose.Schema
	path:			{ type: String, index: {unique: true} }
	dir:			{ type: String }
	name:			{ type: String }
	ext:			{ type: String }
	isdir:			{ type: Boolean }
	contentType:	{ type: String }
	size:			{ type: Number }			
	atime:			{ type: Date }
	ctime:			{ type: Date }			
	mtime:			{ type: Date }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
FileSchema.statics =
	search_fields: ->
		return ['name']
	ordering_fields: ->
		return ['path']
	ordering: ->
		return 'path'

FileSchema.methods =
	rename: (newname) ->
		@path = "#{@dirname()}/#{newname}#{if @isDir() then '/' else ''}"
	dirname: ->
		path.dirname @path
	basename: ->
		path.basename @path
	extname: ->
		path.extname @path
	isFile: ->
		not @isDir
	isDir: ->
		FileUtil.isRealDir(@path)
		
FileSchema.plugin(findOrCreate)
FileSchema.plugin(taggable)

FileSchema.path('path').set (newpath) ->
	@oldpath = @path
	return newpath
	
FileSchema.pre 'save', (next) ->
	try
		if @isNew
			func = if FileUtil.isDir(@path) then FileUtil.newDir else FileUtil.newFile
			func @path
		else
			fs.renameSync FileUtil.abspath(@oldpath), FileUtil.abspath(@path)
			 
		@dir = @dirname()
		@name = @basename()
		@ext = @extname()
		@isdir = @isDir()
		if FileUtil.isDir(@path)
			@contentType = 'text/directory'
		@increment()
		
		success = =>
			stat = fs.statSync FileUtil.abspath(@path)
			_.extend @, _.pick(stat, 'size', 'atime', 'ctime', 'mtime')
			next()
			
		if @stream?
			out = fs.createWriteStream FileUtil.abspath(@path), mode: env.app.mode
			@stream.pipe(out)
			out.on 'finish', =>
				success()
		else		
			success()
	catch e
		next(e)

FileSchema.pre 'remove', (next) ->
	try
		FileUtil.rm @path
		next()
	catch e
		next(e)

File = mongoose.model 'File', FileSchema

TodoSchema = new mongoose.Schema
	task:		{ type: String, required: true }
	dateStart:	{ type: Date }
	dateEnd:	{ type: Date }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
TodoSchema.statics =
	search_fields: ->
		return ['task', 'dateStart']
	ordering_fields: ->
		return ['task', 'dateStart']
	ordering: ->
		return 'task'

Todo = mongoose.model 'Todo', TodoSchema

HotspotSchema = new mongoose.Schema
	serviceProvider:		{ name: String, code: String }
	hotspotName:			{ type: String }
	district:				{ district: String, districtCode: String, area: String, areaCode: String }
	venueType:				{ name: String, code: String }
	address:				{ type: String }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
HotspotSchema.statics =
	search_fields: ->
		return ['serviceProvider', 'hotspotName', 'district', 'venueType']
	ordering_fields: ->
		return ['serviceProvider', 'hotspotName']
	ordering: ->
		return 'serviceProvider'	

Hotspot = mongoose.model 'Hotspot', HotspotSchema	

VenueSchema = new mongoose.Schema
	name:			{ type: String }
	code:			{ type: String }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }

VenueSchema.statics =
	ordering: ->
		return 'name'

Venue = mongoose.model 'Venue', VenueSchema	

DistrictSchema = new mongoose.Schema
	district:		{ type: String }
	districtCode:	{ type: String }
	area:			{ type: String }
	areaCode:		{ type: String }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }

DistrictSchema.statics =
	ordering_fields: ->
		return ['district', 'areaCode']
	ordering: ->
		return 'district'

District = mongoose.model 'District', DistrictSchema	

ProviderSchema = new mongoose.Schema
	name:			{ type: String }
	code:			{ type: String }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }

ProviderSchema.statics =
	ordering: ->
		return 'name'

Provider = mongoose.model 'Provider', ProviderSchema


	
				
module.exports = 
	Permission:	Permission
	Tag:		Tag
	User: 		User
	FileUtil:	FileUtil
	File: 		File
	Todo:		Todo
	Hotspot:	Hotspot
	Venue:		Venue
	District:	District
	Provider:	Provider