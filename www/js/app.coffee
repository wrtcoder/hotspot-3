module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'angularFileUpload', 'ngTouch', 'ngAnimate', 'ui.bootstrap', 'angular.filter'])

module.run ($ionicPlatform, $location, $http, authService) ->
	$ionicPlatform.ready ->
		if (window.cordova && window.cordova.plugins.Keyboard)
			cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
		if (window.StatusBar)
			StatusBar.styleDefault()
		
	# set authorization header once browser authentication completed
	if $location.url().match /access_token/
			data = $.deparam $location.url().split("/")[1]
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
		
module.config ($stateProvider, $urlRouterProvider) ->
	    
	$stateProvider.state 'app',
		url: ""
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"
		
	$stateProvider.state 'app.search',
		url: "/search"
		views:
			'menuContent':
				templateUrl: "templates/search.html"
	
	$stateProvider.state 'app.permission',
		url: "/permission"
		views:
			'menuContent':
				templateUrl: "templates/permission/list.html"
				controller: "AclCtrl"

	$stateProvider.state 'app.file',
		url: "/file?path"
		views:
			'menuContent':
				templateUrl: "templates/file/list.html"
				controller: 'FileCtrl'

	$stateProvider.state 'app.hotspot',
		url: "/hotspot"
		views:
			'menuContent':
				templateUrl: "templates/hotspot/list.html"
				controller: 'HotspotListCtrl'
	
	$stateProvider.state 'app.readHotspot',
		url: "/hotspot/read"
		views:
			'menuContent':
				templateUrl: "templates/hotspot/read.html"
				controller: 'readHotspotCtrl'
		params:		{'data': null}

	$stateProvider.state 'app.editHotspot',
		url: "/hotspot/edit"
		views:
			'menuContent':
				templateUrl: "templates/hotspot/edit.html"
				controller: 'editHotspotCtrl'
		params:		{'data': null}

				
	$stateProvider.state 'app.createHotspot',
		url: "/hotspot/create"
		views:
			'menuContent':
				templateUrl: "templates/hotspot/create.html"
				controller: "createHotspotCtrl"			
									
	$urlRouterProvider.otherwise('/hotspot')