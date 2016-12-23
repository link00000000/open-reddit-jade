$ ->

  # Toggles favorite
  $('.favorite').click ->
    if $(this).hasClass 'ion-android-star-outline'
      $(this).removeClass 'ion-android-star-outline'
      $(this).addClass 'ion-android-star'
    else
      $(this).removeClass 'ion-android-star'
      $(this).addClass 'ion-android-star-outline'

  # Toggle upvote
  $('.upvote').click ->
    if $(this).parent().hasClass 'upvoted'
      $(this).parent().removeClass 'upvoted'
      $(this).siblings('.score').text commaSeperators(parseInt($(this).siblings('.score').text().replace(',', '')) - 1)
    else if $(this).parent().hasClass 'downvoted'
      $(this).parent().removeClass 'downvoted'
      $(this).parent().addClass 'upvoted'
      $(this).siblings('.score').text commaSeperators(parseInt($(this).siblings('.score').text().replace(',', '')) + 2)
    else
      $(this).parent().addClass 'upvoted'
      $(this).siblings('.score').text commaSeperators(parseInt($(this).siblings('.score').text().replace(',', '')) + 1)

  # Toggle downvote
  $('.downvote').click ->
    if $(this).parent().hasClass 'downvoted'
      $(this).parent().removeClass 'downvoted'
      $(this).siblings('.score').text commaSeperators(parseInt($(this).siblings('.score').text().replace(',', '')) + 1)
    else if $(this).parent().hasClass 'upvoted'
      $(this).parent().removeClass 'upvoted'
      $(this).parent().addClass 'downvoted'
      $(this).siblings('.score').text commaSeperators(parseInt($(this).siblings('.score').text().replace(',', '')) - 2)
    else
      $(this).parent().addClass 'downvoted'
      $(this).siblings('.score').text commaSeperators(parseInt($(this).siblings('.score').text().replace(',', '')) - 1)

  # Toggle subs
  $('#sub-list, #show-subs').click ->

    if $('#show-subs').hasClass 'hide'
      console.log 'Closing'
      $('#subs').css('height', '36px')
    else
      console.log 'Opening'
      $('#subs').css('height', $('#sub-list').height() + 'px')

    $('#show-subs, #subs').toggleClass 'hide'

# Removes redditToken from localStorage
logout = ->
  delete localStorage.redditToken
  document.location = '/'
  false

commaSeperators = (num) ->
  num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
