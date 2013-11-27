
$( document ).ready( function() {
  var scheme   = "wss://";
  var uri      = scheme + window.document.location.host + "/";
  var ws       = new WebSocket(uri);
  ws.onmessage = function(message) {
    var data = JSON.parse(message.data);
    $("#chat_text").append("<div><strong>" + data.handle + "</strong>: " + data.text + "</div>");
    $("#chat_text").stop().animate({
      scrollTop: $('#chat_text')[0].scrollHeight
    }, 800);
  };

  $( "#chat_form" ).submit( function( event ) {
    event.preventDefault();
    var text = $( "#chat_message" ).val();
    ws.send( JSON.stringify( { text: text } ) );
    $( "#chat_message" ).val( '' );
  } );
} );