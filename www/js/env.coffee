module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if @isNative() then 'mobile' else 'browser'
	#authUrl:	'https://mob.myvnc.com'
	authUrl:	'https://mppsrc.ogcio.hksarg'
	imUrl: () ->
		#"https://mob.myvnc.com/im"
		"https://mppsrc.ogcio.hksarg/im"
	serverUrl: (path = @path) ->
		#"https://mob.myvnc.com/#{path}"
		"http://localhost:3000/#{path}"
	serverUrl2: (path = @path) ->
		"http://localhost:3000/#{path}"	
	path: 'file'		
	oauth2: ->
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			response_type:	"token"
			#scope:			"https://mob.myvnc.com/org/users https://mob.myvnc.com/file https://mob.myvnc.com/xmpp"
			scope:			"https://mppsrc.ogcio.hksarg/org/users https://mppsrc.ogcio.hksarg/file https://mppsrc.ogcio.hksarg/xmpp"			
			client_id:		if @isNative() then 'fileappPRD' else 'fileDEV'
			redirectUrl:	if @isNative() then 'http://localhost/callback' else 'http://localhost:3000/file/'