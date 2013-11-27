
$( document ).ready( function() {

  var dispatcher = new WebSocketRails( '/websocket' );

  dispatcher.bind( 'who_is_connected', function( who ) {
    for ( var i in who.rudies ) {
      $( "#rudy_list" ).append( "<li id='rudy-" + who.rudies[ i ].id + "'>" + who.rudies[ i ].name + "</li>" );
    }
  } );

  dispatcher.bind( 'connected', function( who ) {
    $( "#rudy_list" ).append( "<li id='rudy-" + who.rudy.id + "'>" + who.rudy.name + "</li>" );
  } );

  dispatcher.bind( 'disconnected', function( who ) {
    $( "#rudy-" + who.rudy.id ).remove();
  } );


  dispatcher.bind( 'chat.new_toast', function( message ) {
    $("#chat_text").append( "<div><strong>" + message.rudy + "</strong>: " + message.toast + "</div>" );
    $("#chat_text").stop().animate({
      scrollTop: $('#chat_text')[0].scrollHeight
    }, 800);
  } );
  $( "#chat_form" ).submit( function( event ) {
    event.preventDefault();
    var text = $( "#chat_message" ).val();
    // ws.send( JSON.stringify( { text: text } ) );
    dispatcher.trigger( 'chat.message', { message: text } );
    $( "#chat_message" ).val( '' );
  } );
} );