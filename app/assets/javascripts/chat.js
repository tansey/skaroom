
$( document ).ready( function() {

  var dispatcher = new WebSocketRails( 'www.skaroom.com/websocket' );
  //var dispatcher = new WebSocketRails( 'localhost:3000/websocket' );

  dispatcher.bind( 'who_is_connected', function( who ) {
    for ( var i in who.rudies ) {
      display  = "<div class='label label-default' id='rudy-" + who.rudies[ i ].id + "'>";
      display +=    who.rudies[ i ].name;
      display += "</div>&nbsp;";
      $( "#rudy_list" ).append( display );
    }
  } );

  dispatcher.bind( 'connected', function( who ) {
      display  = "<div class='label label-default' id='rudy-" + who.rudy.id + "'>";
      display +=    who.rudy.name;
      display += "</div>&nbsp;";
    $( "#rudy_list" ).append( display );
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

  dispatcher.bind( 'walt.welcome', function( who ) {
    $("#chat_text").append( "<div><strong>Walt</strong>: Hey, " + who.rudy.name + "!</div>" );
    $("#chat_text").stop().animate({
      scrollTop: $('#chat_text')[0].scrollHeight
    }, 800);
  } );

  $( "#chat_tab a" ).click( function( event ) {
    event.preventDefault();
    if ( ! $( "#chat_tab" ).hasClass( 'active' ) ) {
      $( "#chat_tab" ).addClass( 'active' );
      $( "#queue_tab" ).removeClass( 'active' );
      $( "#chat_panel" ).show();
      $( "#queue_panel" ).hide();
    }
  } );

  $( "#queue_tab a" ).click( function( event ) {
    event.preventDefault();
    if ( ! $( "#queue_tab" ).hasClass( 'active' ) ) {
      $( "#queue_tab" ).addClass( 'active' );
      $( "#chat_tab" ).removeClass( 'active' );
      $( "#queue_panel" ).show();
      $( "#chat_panel" ).hide();
    }
  } );

} );