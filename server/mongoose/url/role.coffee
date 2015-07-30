controller = require "../controller/role.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })
 
@include = ->

	@get '/api/role', bearer, ->
		controller.Role.list(@request, @response)
		
	@post '/api/role', bearer, ->
		controller.Role.create(@request, @response) 
		
	@get '/api/role/:id', bearer, ->
		controller.Role.read(@request, @response)
		
	@put '/api/role/:id', bearer, ->
		controller.Role.update(@request, @response)
		
	@del '/api/role/:id', bearer, ->
		controller.Role.delete(@request, @response)