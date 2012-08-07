// Generated by CoffeeScript 1.3.3
(function() {
  var Api, User;

  User = require('./models/user');

  Api = require('./api');

  describe('User', function() {
    describe('Not logged in', function() {
      return it('should not fetch a user', function() {
        var userCheck;
        userCheck = false;
        User.fetch().always(function() {
          return userCheck = true;
        });
        waitsFor(function() {
          return userCheck;
        });
        return runs(function() {
          return expect(User.current).toBe(null);
        });
      });
    });
    return describe('Logged in', function() {
      beforeEach(function() {
        var loggedIn;
        loggedIn = false;
        Api.getJSON('/login', function() {
          return loggedIn = true;
        });
        return waitsFor(function() {
          return loggedIn;
        });
      });
      afterEach(function() {
        var loggedOut;
        loggedOut = false;
        Api.getJSON('/logout', function() {
          return loggedOut = true;
        });
        return waitsFor(function() {
          return loggedOut;
        });
      });
      return it('should fetch a user', function() {
        User.fetch().always(function() {
          return expect(User.current.id).toBe('4fff22b8c4039a0901000002');
        });
        return waitsFor(function() {
          return User.current;
        });
      });
    });
  });

}).call(this);
