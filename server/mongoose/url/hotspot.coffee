controller = require "../controller/hotspot.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })

ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
middleware = require '../../../middleware.coffee'
#ensurePermission = middleware.ensurePermission
 

bearer = middleware.rest.user
 
@include = ->
		
	@post '/api/hotspot', bearer, ->
		controller.Hotspot.create(@request, @response)
		 
	@put '/api/hotspot/:id', bearer, ->
		controller.Hotspot.update(@request, @response)	

	@get '/api/hotspot', bearer, ->
		controller.Hotspot.list(@request, @response)
				
	@get '/api/hotspot/:id', bearer, ->
		controller.Hotspot.read(@request, @response)
		
	@del '/api/hotspot/:id', bearer, ->
		controller.Hotspot.delete(@request, @response)	
	
	@get '/api/provider', bearer, ->
		controller.Provider.list(@request, @response)
		
	@post '/api/provider', bearer, ->
		controller.Provider.create(@request, @response)
		 
	@put '/api/provider/:id', bearer, ->
		controller.Provider.update(@request, @response)
	
	@get '/api/provider/:id', bearer, ->
		controller.Provider.read(@request, @response)

	@get '/api/venue',  ->
		controller.Venue.list(@request, @response)	

	@post '/api/venue', bearer, ->
		controller.Venue.create(@request, @response)
		 
	@put '/api/venue/:id', bearer, ->
		controller.Venue.update(@request, @response)
	
	@get '/api/venue/:id', bearer, ->
		controller.Venue.read(@request, @response)	
	
	@get '/api/district', bearer, ->
		controller.District.list(@request, @response)
		
	@post '/api/district', bearer, ->
		controller.District.create(@request, @response)
		 
	@put '/api/district/:id', bearer, ->
		controller.District.update(@request, @response)
	
	@get '/api/district/:id', bearer, ->
		controller.District.read(@request, @response)										