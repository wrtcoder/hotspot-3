controller = require "../controller/hotspot.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })

ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
middleware = require '../../../middleware.coffee'
#ensurePermission = middleware.ensurePermission
 

bearer = middleware.rest.user
 
@include = ->
		
	@post '/api/hotspot', ->
		controller.Hotspot.create(@request, @response)
		 
	@put '/api/hotspot/:id', ->
		controller.Hotspot.update(@request, @response)	

	@get '/api/hotspot', ->
		controller.Hotspot.list(@request, @response)
				
	@get '/api/hotspot/:id', ->
		controller.Hotspot.read(@request, @response)
		
	@del '/api/hotspot/:id', ->
		controller.Hotspot.delete(@request, @response)	
	
	@get '/api/venue',  ->
		controller.Venue.list(@request, @response)
		
	@get '/api/district', ->
		controller.District.list(@request, @response)
	
	@get '/api/provider', ->
		controller.Provider.list(@request, @response)	