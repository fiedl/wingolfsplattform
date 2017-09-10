$(document).ready ->

  if $('body').hasClass('public-website')
    App.scrollreveal '.box', {reset: true}
    App.scrollreveal '#group-map-box', {origin: 'left', beforeReveal: App.hide_group_map_items, afterReveal: App.animate_group_map_items}
    App.scrollreveal '.box.pages-wohnen_im_wingolf', {origin: 'right'}

    $('ul.website-events li').each ->
      $(this).find('.event.info').before("<span class='event-icon glyphicon glyphicon-calendar'></span>")
