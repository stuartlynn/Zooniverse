window.zooniverse ?= {}

EventEmitter = window.zooniverse.EventEmitter || require './event-emitter'
$ = window.jQuery

class Api extends EventEmitter
  @current: null

  project: '.'

  headers: {}
  proxyFrame: null

  constructor: ({@project, host, path, loadTimeout} = {}) ->
    super
    @trigger "ready"
    @select()

 
  get: (url, args)->
    console.log "url is #{url} arguments are ", args
    $.getJSON url, args

  getJSON: (url,args)->
    console.log "url is #{url} args are ", args
    $.getJSON url, args

  post: ->
    console.log "args are ", args
    $.post args[0], args[1..-1]
    

  put: ->
    @request 'put', args...

  delete: ->
    @request 'delete', args...

  select: ->
    @trigger 'select'
    @constructor.current = @

window.zooniverse.Api = Api
module?.exports = Api
