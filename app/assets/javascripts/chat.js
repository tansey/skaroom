
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

  $( "#upload_music_link" ).click( function( event ) {
    event.preventDefault();
    $( '#upload_music' ).click();
  } );
  
  $( "#upload_music" ).fileupload( {
    dataType: 'json',
    done: function ( e, data ) {
      $( '#queue_uploading' ).hide();
      $( '#queue_upload_form' ).show();
      $.each( data.result.files, function ( index, file ) {
        mp3  = '<p id="' + file.id + '">';
        mp3 += '  "' + file.title + '"<br />';
        mp3 += '  ' + file.artist
        mp3 += '</p>';
        $( "#queue_list" ).append( mp3 );
      } );
    },
    add: function ( e, data ) {
      $( '#queue_upload_form' ).hide();
      $( '#queue_uploading' ).show();
      data.submit();
    }
  } );

  $( "#search_music_link" ).click( function( event ) {
    event.preventDefault();
  } );

  dispatcher.bind( 'music.playing', function( what ) {
    var duration = what.song.duration - what.song.position;
    setTimeout( updateCountdown, 1000 );

    function updateCountdown() {
      duration--;
      if ( duration > 0 ) {
        var time = getTime( duration );
        $( "#now_playing_duration" ).text( time );
        setTimeout( updateCountdown, 1000 );
      //} else {
         //submitForm();
      }
    }
    var time = getTime( duration );
    mp3  = '<div class="pull-right" id="now_playing_duration">' + time + '</div>';
    mp3 += '<div id="now-' + what.song.id + '">';
    mp3 += '  "' + what.song.title + '" by ';
    mp3 += '  ' + what.song.artist
    mp3 += '</div>';
    mp3 += '<audio id="now_playing_audio">';
    mp3 += '  <source src="' + what.song.song + '" type="audio/mp3" />';
    mp3 += '</audio>';
    $( "#now_playing" ).html( mp3 );
    now_playing_audio = $( "#now_playing_audio" );
    now_playing_audio.bind( 'canplay', function() {
      this.currentTime = what.song.position;
    } );
    now_playing_audio.trigger( "play" );
  } );

  function getTime( duration ) {
    var minutes = Math.floor( duration / 60 );
    var seconds = duration - minutes * 60;
    if ( seconds < 10 ) {
      seconds = "0" + seconds
    }
    return minutes + ":" + seconds
  }

} );