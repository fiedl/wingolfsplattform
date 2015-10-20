$(document).ready ->
  setTimeout ->
    $('.row-eq-height').each ->
      cols = $(this).find('.col')
      col_heights = []
      for col in cols
        h = 0
        $(col).find('.box').each -> 
          h += $(this).height()
        col_heights.push h
      max_height = Math.max.apply(Math, col_heights)
      for col in cols
        $(col).find('.box').first().css('height', "#{max_height}px")
  , 500
  
  $('.public_root_elements .edit_button').hide()
  $('.public_root_elements .box.upload_attachment').hide()