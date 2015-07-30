env = require '../../../env.coffee'
path = require 'path'
controller = require "../controller/file.coffee"
passport = require 'passport'
lib = require '../lib.coffee'
newHome = lib.newHome
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
middleware = require '../../../middleware.coffee'
ensurePermission = middleware.ensurePermission
 
authURL = path.join(env.app.path, env.oauth2.authURL)
bearer = middleware.rest.user

@include = ->

	path = new RegExp "^/((?:[^/]+/)*[^/]*)$"
	api = new RegExp "^/api/file/((?:[^/]+/)*[^/]*)*$"
	content = new RegExp "^/api/file/content/((?:[^/]+/)*[^/]*)*$"

	@get '/api/tag/:search?', bearer, ->
		handler = middleware.rest.handler(@response)
		controller.File.tag(@request.user, @request.params.search).then handler.fulfill, handler.reject
		
	@post api, bearer, newHome(), ensurePermission('write'), ->
		controller.File.create(@request, @response) 
		
	@get content, bearer, newHome(), ensurePermission('read'), ->
		controller.File.open(@request, @response)
		
	@get api, bearer, newHome(), ensurePermission('read'), ->
		controller.File.read(@request, @response)
			
	@put api, bearer, newHome(), ensurePermission('write'), ->
		controller.File.update(@request, @response)
		
	@del api, bearer, newHome(), ensurePermission('write'), ->
		controller.File.delete(@request, @response)
		
	@get path, ensureLoggedIn(authURL), ensurePermission('read'), ->
		controller.File.open(@request, @response)