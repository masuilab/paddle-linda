var print = function(msg) {
  $('#log').prepend($('<p>').text(msg));
};

var socket = io.connect(location.protocol + "//" + location.host);
var linda = new Linda().connect(socket);
var ts = linda.tuplespace("paddle");

socket.on('connect', function() {
  print("connect!!!");

  ts.watch({type: "paddle"}, function(err, tuple){
    print( JSON.stringify(tuple.data) );
  });

});
