# Global variables
menuOpen = false

$ ->
  # Checks for token and decides which login button to use
  if localStorage.redditToken
    $('#login-cta').css('display', 'none')
  else
    $('#logout-cta').css('display', 'none')

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
    socket.emit('check_token', token)
    socket.on('check_token', (data) ->
        if data
          localStorage.redditToken = '{"access_token": "' + token + '"}'
          document.location = '/'
        else
          $('#token_auth input').css('border-color', 'indianred')
          $('#token_auth label').css('color', 'indianred').text('Invalid Token')
      )
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

changeMenu = (elem) ->
  $('#login-wrapper').children().each( ->
    if($(this).css('display') != 'none')
      $(this).fadeOut(150, ->
          $('#login-wrapper #' + elem).fadeIn(150)
        )
    );
  false

# Removes redditToken from localStorage
logout = ->
  delete localStorage.redditToken
  document.location = '/'
  false

# Create mailto link to email token
createMailto = ->
  email = prompt 'Please enter your Email to send the token'
  token = JSON.parse(localStorage.redditToken).access_token
  link = "mailto:" + email + "?subject=Open%20Reddit%20Token&body=" + token
  document.location = link
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
        .text JSON.parse(localStorage.redditToken).access_token;
    , 3000
  console.log "Create Email"
  false

copyToken = ->
  dummy = document.createElement 'input'
  document.body.appendChild dummy
  dummy.setAttribute 'id', 'loginToken'
  document.getElementById('loginToken').value = JSON.parse(localStorage.redditToken).access_token
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
        .text JSON.parse(localStorage.redditToken).access_token;
    , 3000
  console.log "Copy token"
  false
