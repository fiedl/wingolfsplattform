ready = ->
  $( "#site_tools .edit_button" ).hide()
  # This button is hidden by javascript, since it should be shown as a fallback if javascript
  # is not available.
  #

$(document).ready(ready)
$(document).on('page:load', ready)