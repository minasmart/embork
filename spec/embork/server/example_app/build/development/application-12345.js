define("some/component",
  ["exports"],
  function(__exports__) {
    "use strict";
    __exports__["default"] = function SomeComponentFunction(){ alert('Woohoo'); };
  });define("app",
  ["my-app/some_component","exports"],
  function(__dependency1__, __exports__) {
    "use strict";
    var SomeComponent = __dependency1__["default"];

    __exports__["default"] = Ember.Application.create("development");
  });

//

;
