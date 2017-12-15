process_grey_boxes = ->
  $('body.greifenstein-layout')
      .find('.box#public-root-events-box, .box.group_map_box')
      .closest('.col')
      .addClass('grey_background')

$(document).on 'process', 'div', ->
  process_grey_boxes()

$(document).ready ->
  process_grey_boxes()