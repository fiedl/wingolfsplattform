$(document).on 'click', '.destroy_wbl_abo_address_caches', ->
  $(this).button("loading")
  # Der Rest wird remote per Ajax erledigt vom
  # WblAboAddressCachesController.
