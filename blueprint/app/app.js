import Resolver from 'ember/resolver';
import loadInitializers from 'ember/load-initializers';

var App = Ember.Application.extend({
  modulePrefix: "<%= namespace %>",
  Resolver: Resolver
});

loadInitializers(App, "<%= namespace %>");

export default App;
