function SomeComponentFunction(){ alert('Woohoo'); };
(function() {
  window.Amazing = function() {
    alert('amazing!');
    return console.log('We are in the development environment.');
  };

}).call(this);


//

;
