$(document).ready ->
  $('body.greifenstein-layout')
      .find('.box#public-root-events-box, .box.group_map_box')
      .closest('.col')
      .addClass('grey_background')
