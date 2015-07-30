env = require './env.coffee'


iconUrl = (type) ->
	icon = 
		"text/directory":				"img/dir.png"
		"text/plain":					"img/txt.png"
		"text/html":					"img/html.png"
		"application/javascript":		"img/js.png"
		"application/octet-stream":		"img/dat.png"
		"application/pdf":				"img/pdf.png"
		"application/excel":			"img/xls.png"
		"application/x-zip-compressed":	"img/zip.png"
		"application/msword":			"img/doc.png"
		"image/png":					"img/png.png"
		"image/jpeg":					"img/jpg.png"
	return if type of icon then icon[type] else "img/unknown.png"
		
model = (ActiveRecord, $rootScope, $upload, platform) ->
	
	class Model extends ActiveRecord
		constructor: (attrs = {}, opts = {}) ->
			@$initialize(attrs, opts)
			
		$changedAttributes: (diff) ->
			_.omit super(diff), '$$hashKey' 
		
		$save: (values, opts) ->
			if @$hasChanged()
				super(values, opts)
			else
				return new Promise (fulfill, reject) ->
					fulfill @
		
	class Collection extends Model
		constructor: (@models = [], opts = {}) ->
			super({}, opts)
			@length = @models.length
					
		add: (models, opts = {}) ->
			singular = not _.isArray(models)
			if singular and models?
				models = [models]
			_.each models, (item) =>
				if not @contains item 
					@models.push item
					@length++
				
		remove: (models, opts = {}) ->
			singular = not _.isArray(models)
			if singular and models?
				models = [models]
			_.each models, (model) =>
				model.$destroy().then =>
					@models = _.filter @models, (item) =>
						item[@$idAttribute] != model[@$idAttribute]
			@length = @models.length
				
		contains: (model) ->
			cond = (a, b) ->
				a == b
			if typeof model == 'object'
				cond = (a, b) =>
					a[@$idAttribute] == b[@$idAttribute]
			ret = _.find @models, (elem) =>
				cond(model, elem) 
			return ret?	
		
		$fetch: (opts = {}) ->
			return new Promise (fulfill, reject) =>
				@$sync('read', @, opts)
					.then (res) =>
						data = @$parse(res.data, opts)
						if _.isArray data
							@add data
							fulfill @
						else
							reject 'Not a valid response type'
					.catch reject
		
	class PageableCollection extends Collection
		constructor: (models = [], opts = {}) ->
			@state =
				count:		0
				page:		0
				per_page:	10
				total_page:	0
			super(models, opts)
				
		###
		opts:
			params:
				page:		page no to be fetched (first page = 1)
				per_page:	no of records per page
		###
		$fetch: (opts = {}) ->
			opts.params = opts.params || {}
			opts.params.page = @state.page + 1
			opts.params.per_page = opts.params.per_page || @state.per_page
			return new Promise (fulfill, reject) =>
				@$sync('read', @, opts)
					.then (res) =>
						data = @$parse(res.data, opts)
						if data.count? and data.results?
							@add data.results
							@state = _.extend @state,
								count:		data.count
								page:		opts.params.page
								per_page:	opts.params.per_page
								total_page:	Math.ceil(data.count / opts.params.per_page)
							fulfill @
						else
							reject 'Not a valid response type'
					.catch reject
		
	class User extends Model
		$idAttribute: 'username'
		
		$urlRoot: "#{env.authUrl}/org/api/users/"
			
		@me: ->
			(new User(username: 'me/')).$fetch()	
			
	class File extends PageableCollection
		$idAttribute: 'path'
	
		$urlRoot: "#{env.serverUrl()}/api/file/"
			
		constructor: (attrs = {}, opts = {}) ->
			_.extend @, attrs
			@isdir = /\/$/.test @path
			super([], opts)
			
		$parseModel: (res, opts) ->
			res.selected = false
			res.atime = new Date(Date.parse(res.atime))
			res.ctime = new Date(Date.parse(res.ctime))
			res.mtime = new Date(Date.parse(res.mtime))
			res.iconUrl = iconUrl(res.contentType) 
			res.url = if env.isNative() then "#{env.serverUrl()}/api/file/content/#{res.path}" else "#{env.serverUrl()}/#{res.path}"
			return new File res
						
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = @$parseModel(res.results[key], opts)
			return @$parseModel(res, opts)
			
		$isNew: ->
			not @_id?
			
		toggleSelect: ->
			@selected = not @selected
			$rootScope.$broadcast 'mode:select'	
		
		open: ->
			platform.open @
			
		nselected: ->
			(_.where @models, selected: true).length
					
		$fetch: (opts) ->
			new Promise (fulfill, reject) =>
				fetch = =>
					if @isdir
						super(opts).then fulfill, reject
					else
						fulfill @
				if _.isEmpty @path or _.isNull @path or _.isUndefined @path
					User.me()
						.then (user) =>
							@path = "#{user.username}/"
							@isdir = true
							fetch()
						.catch reject
				else
					fetch()
	
		$sync: (op, model, opts) ->
			if op in ['create', 'update']
				crudMapping =
					create:		'POST'
					read:		'GET'
					update:		'PUT'
					"delete":	'DELETE'
				$upload.upload
					url:	if op == 'create' then @$urlRoot else @$url()
					method:	crudMapping[op]
					fields:	_.pick model, 'name', 'path', 'tags', '__v'
					file:	model.file
			else
				super(op, model, opts)
			
	class Permission extends Model
		$idAttribute: '_id'
		
		$urlRoot: "#{env.serverUrl()}/api/permission"
		
	class Acl extends PageableCollection
		$idAttribute: '_id'
	
		$urlRoot: "#{env.serverUrl()}/api/permission"
		
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = new Permission res.results[key]
			return res
		
	class UserGrps extends Collection
		$idAttribute: 'group'
		
		$urlRoot: "#{env.imUrl()}/api/roster"
		
		$parse: (res, opts) ->
			ret = []
			_.each res, (rosteritem) ->
				_.each rosteritem.groups, (group) ->
					if group not in ret
						ret.push group
			return ret
			
		select: (group) ->
			_.each @models, (item) ->
				item.selected = item.group == group
				
		selected: ->
			_.findWhere @models, selected: true
			
		toString: ->
			@selected()?.group
			
	class FileGrps extends Collection
		$idAttribute: 'group'
		
		$urlRoot: "#{env.serverUrl()}/api/tag"
		
		select: (group) ->
			_.each @models, (item) ->
				item.selected = item.group == group
				
		selected: ->
			_.findWhere @models, selected: true
			
		toString: ->
			@selected()?.group


	class Todo extends Model
		$idAttribute: '_id'
		
		$urlRoot: "#{env.serverUrl()}/api/todo"
		#$urlRoot: "http://localhost:3000/file/api/todo/"
		
		$save: (values, opts) ->
			if @$hasChanged()
				if _.isUndefined(values)
					this.dateStart = new Date(this.dateStart.toDateString() + " " + this.timeStart.toTimeString())
					this.dateEnd = new Date(this.dateEnd.toDateString() + " " + this.timeEnd.toTimeString())
				else				
					values.dateStart = new Date(values.dateStart.toDateString() + " " + values.timeStart.toTimeString())
					values.dateEnd = new Date(values.dateEnd.toDateString() + " " + values.timeEnd.toTimeString())
							
				super(values, opts)
			else
				return new Promise (fulfill, reject) ->
					fulfill @		
		
	class TodoList extends Collection
		$idAttribute: '_id'
	
		#$urlRoot: "http://localhost:3000/file/api/todo/"
		$urlRoot: "#{env.serverUrl()}/api/todo"
		
		$parseModel: (res, opts) ->
			res.dateStart = new Date(Date.parse(res.dateStart))
			res.dateEnd = new Date(Date.parse(res.dateEnd))
			return new Todo res
			
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = @$parseModel(res.results[key], opts)
			return res.results
	
	class Hotspot extends Model
		$idAttribute: '_id'
		
		$urlRoot: "#{env.serverUrl()}/api/hotspot"
	
	class HotspotList extends Collection
		$idAttribute: '_id'
	
		$urlRoot: "#{env.serverUrl()}/api/hotspot"
		
		$parseModel: (res, opts) ->
			return new Hotspot res
			
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = @$parseModel(res.results[key], opts)
			return res.results		
	
	
	class Venue extends Model
		$idAttribute: '_id'
		
		$urlRoot: "#{env.serverUrl()}/api/venue"

	class VenueList extends Collection
		$idAttribute: '_id'
	
		$urlRoot: "#{env.serverUrl()}/api/venue"
		
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = new Venue res.results[key]
			return res.results

	class Provider extends Model
		$idAttribute: '_id'
		
		$urlRoot: "#{env.serverUrl()}/api/provider"
	
	class ProviderList extends Collection
		$idAttribute: '_id'
	
		$urlRoot: "#{env.serverUrl()}/api/provider"
		
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = new Provider res.results[key]
			return res.results	

	class District extends Model
		$idAttribute: '_id'
		
		$urlRoot: "#{env.serverUrl()}/api/district"

	class DistrictList extends Collection
		$idAttribute: '_id'
	
		$urlRoot: "#{env.serverUrl()}/api/district"
		
		$parse: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = new District res.results[key]
			return res.results
		
				
	Model:			Model
	Collection:		Collection
	User:			User
	File:			File
	Permission:		Permission
	Acl:			Acl
	UserGrps:		UserGrps
	FileGrps:		FileGrps
	Todo:			Todo
	TodoList:		TodoList
	Venue:			Venue
	VenueList:		VenueList
	Hotspot:		Hotspot
	HotspotList: 	HotspotList
	Provider:		Provider
	ProviderList:	ProviderList
	District:		District
	DistrictList:	DistrictList
	
				
config = ->
	return
	
angular.module('starter.model', ['ionic', 'ActiveRecord', 'angularFileUpload']).config [config]

angular.module('starter.model').factory 'model', ['ActiveRecord', '$rootScope', '$upload', 'platform', model]