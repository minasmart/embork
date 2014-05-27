import Resolver from 'embork/resolver';
import loadInitializers from 'ember/load-initializers';

var App = Ember.Application.extend({
  namespace: "<%= namespace %>",
  Resolver: Resolver
});

loadInitializers(App, "<%= namespace %>");

export default App;
