# Global variables
menuOpen = false

$ ->
  # Login Button Press
  $('#login-cta').click ->
    menuOpen = !menuOpen

    if menuOpen
      openMenu()
    else
      closeMenu()


  # On back arrow press
  $('.back-arrow').click ->
    changeMenu 'main'


  # On form#login-help submit
  $('form#token_auth').submit (e) ->
    token = $(this).serializeArray()[0].value
    $.post('authorize_callback', {token: token});
    e.preventDefault()
    false


# Toggle Menu Open
openMenu = ->
  $('#login-wrapper').addClass('transitioning')
  $('#login-wrapper').stop().fadeIn(150, ->
      $('#login-wrapper').removeClass 'transitioning'
    )
  false

# Toggle Menu Closed
closeMenu = ->
  $('#login-wrapper').addClass('transitioning')
  $('#login-wrapper').stop().fadeOut(150, ->
      $('#login-wrapper').removeClass 'transitioning'
    )
  changeMenu('main')
  false

# Change login menu
changeMenu = (elem) ->
  $('#login-wrapper').children().each( ->
    if($(this).css('display') != 'none')
      $(this).fadeOut(150, ->
          $('#login-wrapper #' + elem).fadeIn(150)
        )
    );
  false

# Sends post request to server to logout
logout = ->
  $.post('/logout');
  document.location = '/'
  false

# Create mailto link to email token
createMailto = ->
  email = prompt 'Please enter your Email to send the token'
  token = $('#modal-text').text()
  link = "https://mail.google.com/mail/?view=cm&ui=2&tf=0&fs=1&to=" + email + "&su=Open%20Reddit%20Token&body=" + token
  window.open link, 'Reddit Token - Email', 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,scrollbars=no,width=400,height=350'
  $('#modal-text')
    .css({
      'width': $('#modal-text').width()
      'color': $('body').css('background-color')
      'font-weight': 'bold'
      })
    .text 'Email Created';
  setTimeout ->
      $('#modal-text')
        .css({
          'width': 'auto'
          'color': $('#title #main').css('color')
          'font-weight': 'normal'
          })
        .text token
    , 3000
  console.log "Created Email"
  false

# Copy token to clipboard
copyToken = ->
  token = $('#modal-text').text()
  dummy = document.createElement 'input'
  document.body.appendChild dummy
  dummy.setAttribute 'id', 'loginToken'
  document.getElementById('loginToken').value = token
  dummy.select()
  document.execCommand 'copy'
  document.body.removeChild dummy
  $('#modal-text')
    .css({
      'width': $('#modal-text').width()
      'color': $('body').css('background-color')
      'font-weight': 'bold'
      })
    .text 'Copied Token to Clipboard';
  setTimeout ->
      $('#modal-text')
        .css({
          'width': 'auto'
          'color': $('#title #main').css('color')
          'font-weight': 'normal'
          })
        .text token
    , 3000
  console.log "Copied token"
  false

# Close overlay modal on background click
$('#modal-overlay').click( ->
    $('#modal-overlay').remove()
  ).children().click ->
    false
