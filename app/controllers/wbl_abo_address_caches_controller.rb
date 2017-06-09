class WblAboAddressCachesController < ApplicationController

  # Hiermit können die Caches der gespeicherten
  # Adressen händisch gelöscht werden, um eine möglichst
  # aktuelle Wbl-Abo-Liste zu exportieren, ohne den
  # kompletten Cache-Renew der Abo-Gruppe abzuwarten.
  #
  # Siehe:
  # https://trello.com/c/9aTq3Q0w/1142-caching-wbl-adressen
  #
  # DELETE /wbl_abo_address_caches
  #
  def destroy
    authorize! :manage, Group.wbl_abo

    Rails.cache.delete_matched '*address_label*'
    Group.wbl_abo.delete_cached :export_list

    redirect_to wbl_path, notice: "Die Adress-Caches wurden gelöscht. Der Export kann nun erneut ausgelöst werden, wird dann aber ca. 12min dauern."
  end

end