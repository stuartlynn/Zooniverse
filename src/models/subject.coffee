window.zooniverse ?= {}
window.zooniverse.models ?= {}

BaseModel = zooniverse.models.BaseModel || require './base-model'
Api = zooniverse.Api || require '../lib/api'
$ = window.jQuery

class Subject extends BaseModel
  @current: null
  @seenThisSession: []

  @queueMin: 2
  @queueMax: 10

  @group: false

  @fallback: "./offline/subjects.json"

  @path: ->
    groupString = if not @group
      ''
    else if @group is true
      'groups/'
    else
      "groups/#{@group}/"

    "workflows/533cd4dd4954738018030000/subjects"

  @next: (done, fail) ->
    @trigger 'get-next'

    @current?.destroy()
    @current = null

    nexter = new $.Deferred
    nexter.then done, fail

    if @count() is 0
      fetcher = @fetch()

      fetcher.done (newSubjects) =>
        @first()?.select()

        if @current
          nexter.resolve @current
        else
          @trigger 'no-more'
          nexter.reject arguments...

      fetcher.fail =>
        nexter.reject arguments...

    else
      @first().select()
      nexter.resolve @current

      @fetch() if @count() < @queueMin

    nexter.promise()

  @trackSeenSubject: (subject) ->
    @seenThisSession.push subject.id

  @hasSeenSubject: (subject) ->
    console.log "testing ", subject, @seenThisSession
    subject.id in @seenThisSession

  @fetch: (params, done, fail) ->
    [done, fail, params] = [params, done, {}] if typeof params is 'function'

    {limit} = params || {}
    limit ?= @queueMax - @count()

    fetcher = new $.Deferred
    fetcher.then done, fail

    if limit > 0
      request = Api.current.get @path(), {limit}

      request.done (rawSubjects) =>
        console.log "raw subjects ", rawSubjects

        newSubjects = for rawSubject in rawSubjects when not @hasSeenSubject(rawSubject)
          @trackSeenSubject rawSubject
          console.log "here"
          new @ rawSubject

        console.log "new subjects ", newSubjects

        # Keep the "seen" list a reasonable size.
        @seenThisSession.shift() until @seenThisSession.length < 1000

        @trigger 'fetch', [newSubjects]
        fetcher.resolve newSubjects

      request.fail =>
        @trigger 'fetching-fallback'
        getFallback = $.get @fallback

        getFallback.done (rawSubjects) =>

          if @group
            rawGroupSubjects = []
            rawGroupSubjects.push(rawSubject) for rawSubject in rawSubjects when (rawSubject.group_id is @group)
            rawSubjects = rawGroupSubjects

          rawSubjects.sort -> Math.random() - 0.5
          newSubjects = (new @ rawSubject for rawSubject in rawSubjects)
          @trigger 'fetch', [newSubjects]
          fetcher.resolve newSubjects

        getFallback.fail =>
          @trigger 'fetch-fail'
          fetcher.fail arguments...

    else
      fetcher.resolve @instances[0...number]

    fetcher.promise()

  id: ''
  zooniverse_id: ''
  classification_count: null
  coords: null
  location: null
  metadata: null
  project_id: ''
  group_id: ''
  workflow_ids: null
  tutorial: null
  preload: true

  constructor: ->
    super
    console.log "Creating subject (trying)"
    @location ?= {}
    @coords ?= []
    @metadata ?= {}
    @workflow_ids ?= []

  preloadImages: ->
    return unless @preload
    for type, imageSources of @location
      imageSources = [imageSources] unless imageSources instanceof Array
      continue unless @isImage imageSources
      (new Image).src = src for src in imageSources

  select: ->
    @constructor.current = @
    @trigger 'select'

  destroy: ->
    @constructor.current = null if @constructor.current is @
    super

  isImage: (subjectLocation) ->
    for src in subjectLocation
      return false unless (src.split('.').pop() in ['gif', 'jpg', 'png'])

    return true

  talkHref: ->
    domain = @domain || location.hostname.replace /^www\./, ''
    "http://talk.#{domain}/#/subjects/#{@zooniverse_id}"

  socialImage: ->
    image = if @location.standard instanceof Array
      @location.standard[Math.floor @location.standard.length / 2]
    else
      @location.standard

    $("<a href='#{image}'></a>").get(0).href

  socialTitle: ->
    'Zooniverse classification'

  socialMessage: ->
    'Classifying on the Zooniverse!'

  facebookHref: ->
    """
      https://www.facebook.com/sharer/sharer.php
      ?s=100
      &p[url]=#{encodeURIComponent @talkHref()}
      &p[title]=#{encodeURIComponent @socialTitle()}
      &p[summary]=#{encodeURIComponent @socialMessage()}
      &p[images][0]=#{@socialMessage()}
    """.replace '\n', '', 'g'

  twitterHref: ->
    status = "#{@socialMessage()} #{@talkHref()}"
    "http://twitter.com/home?status=#{encodeURIComponent status}"

  pinterestHref: ->
    """
      http://pinterest.com/pin/create/button/
      ?url=#{encodeURIComponent @talkHref()}
      &media=#{encodeURIComponent @socialImage()}
      &description=#{encodeURIComponent @socialMessage()}
    """.replace '\n', '', 'g'

window.zooniverse.models.Subject = Subject
module?.exports = Subject
