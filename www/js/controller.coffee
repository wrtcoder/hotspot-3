env = require './env.coffee'
	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator

createHotspotCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->

	class ListView
	
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
	
	$scope.venueList = new model.VenueList()
	$scope.venueList.$fetch()
	$scope.venueController = new ListView collection: $scope.venueList

	$scope.providerList = new model.ProviderList()
	$scope.providerList.$fetch()
	$scope.providerController = new ListView collection: $scope.providerList
	
	$scope.districtList = new model.DistrictList()
	$scope.districtList.$fetch()	
	$scope.districtController = new ListView collection: $scope.districtList
	
	$scope.areaList = []
	$scope.areaController = new ListView collection: $scope.areaList
		
	class HotspotView
	
		constructor: (opts = {}) ->
			$scope.model = {venueType: {name:'', code:''}, serviceProvider: {name:'', code:''}, hotspotName: '', district: {district:'', districtCode:''}, area: {area:'', areaCode:''}, address: ''}

			
		add: ->
			@model = new model.Hotspot
			@model.venueType = $scope.model.venueType
			
			@model.serviceProvider = $scope.model.serviceProvider
			@model.hotspotName = $scope.model.hotspotName
			
			#@model.district = { district: $scope.model.district.district, districtCode: $scope.model.district.districtCode, area: $scope.model.area.area, areaCode: $scope.model.area.areaCode }
			@model.district = $scope.model.area
			@model.address = $scope.model.address
			
			@model.$save().catch alert
			
			$rootScope.$broadcast 'hotspot:listChanged'
			$state.go 'app.hotspot', {}, { reload: true, cache: false }
			$scope.model = new model.Hotspot	

		selectChange: ->
			if _.isEmpty ($scope.model.district) or _.isNull ($scope.model.district) or _.isUndefined ($scope.model.district)
				$scope.areaList = []
			else
				$scope.model.area = {area:'', areaCode:''}
				$scope.areaList = new model.DistrictList()
				$scope.areaList.$fetch()
			
			$scope.areaController = new ListView collection: $scope.areaList
			$scope.selDistrict = $scope.model.district.districtCode
			
	$scope.controller = new HotspotView model: $scope.model
	$scope.selDistrict = ""

VenueCtrl = ($rootScope, $scope, $ionicModal, model) ->
	class VenueView  			
		modelEvents:
			name:	'update'
			code:	'update'
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
		update: (event, value) =>
			@model[event.name] = value		
			
	$scope.controller = new VenueView model: $scope.model

VenueListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->

	class VenueListView
	
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			

	$scope.venueList = new model.VenueList()
	$scope.venueList.$fetch()
	$scope.venueController = new VenueListView collection: $scope.venueList


readHotspotCtrl = ($rootScope, $scope, $state, $stateParams, $ionicHistory, model) ->
		
	class HotspotView  			
		modelEvents:
			venueType:			'update'
			serviceProvider:	'update'
			hotspotName:		'update'
			district:			'update'
			address:			'update'
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
		update: (event, value) =>
			@model[event.name] = value		
		
		edit: (selectedModel) ->
			$state.go 'app.editHotspot', {'data': selectedModel}, { reload: true,cache: false }
		
	$scope.model = $stateParams.data
	$scope.controller = new HotspotView model: $scope.model

editHotspotCtrl = ($rootScope, $scope, $state, $stateParams, $ionicModal, $ionicHistory,model) ->
	
	class HotspotView  		
		modelEvents:
			venueType:			'update'
			serviceProvider:	'update'
			hotspotName:		'update'
			district:			'update'
			address:			'update'
			
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: (event, value) =>
			@model[event.name] = value
			
		
		read: (selectedModel) ->
			$state.go 'app.readHotspot', {'data': selectedModel}, { reload: true, cache: false }

		edit: ->
			
			@model= $scope.model
			@model.district = {district:$scope.model.district.district, districtCode:$scope.model.district.districtCode, area: $scope.model.area.area, areaCode: $scope.model.area.areaCode}
			@model.$save().catch alert
			$rootScope.$broadcast 'hotspot:listChanged'
			$state.go 'app.hotspot', {}, { reload: true, cache: false }
			$scope.model = new model.Hotspot

		selectChange: ->
			if _.isEmpty ($scope.model.district) or _.isNull ($scope.model.district) or _.isUndefined ($scope.model.district)
				$scope.areaList = []
			else
				$scope.model.area = {area:'', areaCode:''}
				$scope.areaList = new model.DistrictList()
				$scope.areaList.$fetch()
			
			$scope.areaController = new ListView collection: $scope.areaList
			$scope.selDistrict = $scope.model.district.districtCode
		
		
	class ListView
	
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
	
	$scope.venueList = new model.VenueList()
	$scope.venueList.$fetch()
	$scope.venueController = new ListView collection: $scope.venueList

	$scope.providerList = new model.ProviderList()
	$scope.providerList.$fetch()
	$scope.providerController = new ListView collection: $scope.providerList
	
	$scope.districtList = new model.DistrictList()
	$scope.districtList.$fetch()	
	$scope.districtController = new ListView collection: $scope.districtList
	
	$scope.areaList = new model.DistrictList()
	$scope.areaList.$fetch()
	$scope.areaController = new ListView collection: $scope.areaList
	$scope.selDistrict = ""
			
	datamodel = $stateParams.data	
	
	if (!_.isUndefined($stateParams.data))
		$scope.model = $stateParams.data
		$scope.selDistrict = $scope.model.district.districtCode
		$scope.model.area = {area:$stateParams.data.district.area, areaCode:$stateParams.data.district.areaCode}
		
	$scope.controller = new HotspotView model: $scope.model


	
HotspotCtrl = ($rootScope, $scope, $state, $stateParams, $ionicModal, $ionicHistory, model) ->
	
	class HotspotView  		
		modelEvents:
			venueType:			'update'
			serviceProvider:	'update'
			hotspotName:		'update'
			district:			'update'
			address:			'update'
			
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: (event, value) =>
			@model[event.name] = value
			
		
		read: (selectedModel) ->
			$state.go 'app.readHotspot', {'data': selectedModel}, { reload: true, cache: false }
		
		edit: (selectedModel) ->
			$state.go 'app.editHotspot', {'data': selectedModel}, { reload: true, cache: false }
			
		
	$scope.controller = new HotspotView model: $scope.model
	

HotspotListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, $ionicViewSwitcher, model) ->
	class HotspotListView
	
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
	
		$rootScope.$on 'hotspot:listChanged', ->
				
				$scope.collection = new model.HotspotList()
				$scope.controller = new HotspotListView collection: $scope.collection
				$scope.collection.$fetch()
				
				$ionicViewSwitcher.nextDirection('back');  
				$ionicHistory.nextViewOptions({historyRoot: true});
				$ionicHistory.clearCache()
				#$state.go 'app.hotspot', {}, { reload: true, cache: false }

		remove: (model) ->
			@collection.remove model
	
		
	$scope.collection = new model.HotspotList()
	$scope.collection.$fetch()
	$scope.controller = new HotspotListView collection: $scope.collection
	

config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'VenueCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', VenueCtrl]
angular.module('starter.controller').controller 'VenueListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', VenueListCtrl]
angular.module('starter.controller').controller 'createHotspotCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', createHotspotCtrl]
angular.module('starter.controller').controller 'HotspotCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$ionicModal', '$ionicHistory', 'model', HotspotCtrl]
angular.module('starter.controller').controller 'editHotspotCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$ionicModal', '$ionicHistory','model', editHotspotCtrl]
angular.module('starter.controller').controller 'readHotspotCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$ionicHistory','model', readHotspotCtrl]
angular.module('starter.controller').controller 'HotspotListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory','$ionicViewSwitcher','model', HotspotListCtrl]
