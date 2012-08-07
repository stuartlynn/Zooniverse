User = require './models/user'
Api = require './api'

describe 'User', ->
  describe 'Not logged in', ->
    it 'should not fetch a user', ->
      userCheck = false
      User.fetch().always -> userCheck = true
      waitsFor -> userCheck
      runs -> expect(User.current).toBe null
  
  describe 'Logged in', ->
    beforeEach ->
      loggedIn = false
      Api.getJSON '/login', -> loggedIn = true
      waitsFor -> loggedIn
    
    afterEach ->
      loggedOut = false
      Api.getJSON '/logout', -> loggedOut = true
      waitsFor -> loggedOut
    
    it 'should fetch a user', ->
      User.fetch().always ->
        expect(User.current.id).toBe '4fff22b8c4039a0901000002'
      
      waitsFor -> User.current
