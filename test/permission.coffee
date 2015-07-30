_ = require 'underscore'
env = require '../env.coffee'
model = require '../model.coffee'

logger = env.log4js.getLogger('permission')

# possesedPerm, requiredPerm
perms = [
	['file:read:*',				'file:read:*'],
	['file:read:%home',			'file:read:%home'],
	['file:read:%home',			'file:read:%home/'],
	['file:read:%home',			'file:read:%home/abc/def'],
	['file:read:%home/',		'file:read:%home'],
	['file:read:%home/abc/def',	'file:read:%home']
]

_.each perms, (perm) ->
	possessedPerm = new model.Permission(perm[0])
	requiredPerm = new model.Permission(perm[1])
	logger.info "#{perm[0]} implies #{perm[1]}: #{possessedPerm.implies(requiredPerm)}"