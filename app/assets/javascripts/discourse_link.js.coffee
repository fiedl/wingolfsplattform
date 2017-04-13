# This does a short animation to show where the feature
# can be found later, when the feature spotlight has
# been removed.
#
# Example: http://codepen.io/fiedl/pen/JNjmjM
#
$(document).on 'click', '#feature_spotlight .discourse.btn', (e)->
  btn = $(this)
  $(this).effect 'transfer', {
    to: '#site-links .discourse',
    className: "ui-effects-transfer",
    complete: ->
      window.open btn.data('href')
  }
  false
