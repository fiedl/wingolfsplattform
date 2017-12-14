process_public_website_elements = (element)->

  if $('body').hasClass('wingolf-layout') || $('body').hasClass('greifenstein-layout')
    if $('body').hasClass('public-website')
      App.scrollreveal '.box', {reset: true, viewFactor: 0.005, delay: 50}
      App.scrollreveal '.group_map_box', {reset: false, origin: 'left', beforeReveal: App.hide_group_map_items, afterReveal: App.animate_group_map_items}
      App.scrollreveal '.box.pages-wohnen_im_wingolf', {reset: false, origin: 'right'}
      App.scrollreveal '#goto_start_page', {reset: true}

      $(element).find('ul.website-events li').each ->
        if $(this).find('.event-icon').count() == 0
          $(this).find('.event.info').before("<span class='event-icon glyphicon glyphicon-calendar'></span>")

      $(element).find('#horizontal_nav li a').each ->
        link = $(this)
        if (link.text() == "Mitglieder-Start") || (link.text() == "Mitgliederbereich")
          link.text("Mitgliederbereich")
          link.addClass 'mitgliederbereich'

      # E-Mail-Links sollen Buttons sein.
      $(element).find('.box.page .box_content a[href^="mailto:"]').addClass('btn btn-default')

      # In großen Gallery-Boxen keine Light-Box verwenden.
      App.no_lightbox_for_large_boxes = true

$(document).ready ->
  process_public_website_elements($('body'))

$(document).on 'process', 'div', (e)->
  e.stopPropagation()
  process_public_website_elements($(this))
