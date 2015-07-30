controller = require "../controller/user.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })
 
@include = ->

	@get '/api/user', bearer, ->
		controller.User.list(@request, @response)
		
	@post '/api/user', bearer, ->
		controller.User.create(@request, @response) 
		
	@get '/api/user/:id', bearer, ->
		controller.User.read(@request, @response)
		
	@put '/api/user/:id', bearer, ->
		controller.User.update(@request, @response)
		
	@del '/api/user/:id', bearer, ->
		controller.User.delete(@request, @response)