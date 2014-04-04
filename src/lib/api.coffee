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

 
  get: ->
    $.getJSON arguments

  getJSON: ->
    $.getJSON arguments

  post: ->
    $.post arguments
    

  put: ->
    @request 'put', arguments...

  delete: ->
    @request 'delete', arguments...

  select: ->
    @trigger 'select'
    @constructor.current = @

window.zooniverse.Api = Api
module?.exports = Api
