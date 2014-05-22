module UserMixins::Bvs
  extend ActiveSupport::Concern
  
  # This method returns the bv (Bezirksverband) the user is associated with.
  #
  def bv
    (Bv.all & self.groups).try(:first).try(:becomes, Bv)
  end
  
  def bv_membership
    UserGroupMembership.find_by_user_and_group(self, bv) if bv
  end
  
  # Diese Methode gibt die BVs zurück, denen der Benutzer zugewiesen ist. In der Regel
  # ist jeder Philister genau einem BV zugeordnet. Durch Fehler kann es jedoch dazu kommen,
  # dass er mehreren BVs zugeordnet ist.
  #
  def bv_memberships
    (Bv.all & self.groups).collect do |bv|
      UserGroupMembership.find_by_user_and_group(self, bv)
    end - [nil]
  end
  
  def bv_beitrittsdatum
    bv_membership.valid_from if bv
  end
  
  # Diese Methode gibt den BV zurück, dem der Benutzer aufgrund seiner Postanschrift
  # zugeordnet sein sollte. Der eingetragene BV kann und darf davon abweisen, da er
  # in Sonderfällen auch händisch zugewiesen werden kann.
  #
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # gibt diese Methode `nil` zurück.
  #
  def correct_bv
    if self.philister? 
      if postal_address_field_or_first_address_field.try(:value).try(:present?)
        postal_address_field_or_first_address_field.bv
      else
        # Wenn keine Adresse gegeben ist, in den BV 00 (Unbekannt Verzogen) verschieben.
        Bv.find_by_token("BV 00")
      end
    end
  end
  
  # Diese Methode passt den BV des Benutzers der aktuellen Postanschrift an.
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # tut diese Methode nichts.
  #
  def adapt_bv_to_postal_address
    self.groups(true) # reload groups
    new_bv = correct_bv
    
    # Fall 0: Es konnte kein neuer BV identifiziert werden.
    # In diesem Fall wird aus Konsistenzgründen die aktuelle BV-Mitgliedschaft
    # zurückgegeben, da der BV dann nicht verändert werden soll.
    #
    if not new_bv
      new_membership = self.bv_membership
    
    # Fall 1: Es ist noch kein BV zugewiesen. Es wird schlicht der neue zugewiesen.
    #
    elsif new_bv and not bv
      new_membership = new_bv.assign_user self

    # Fall 2: Es ist bereits ein BV zugewiesen. Der neue BV ist auch der alte
    # BV. Die Mitgliedschaft muss also nicht geändert werden.
    #
    elsif new_bv and (new_bv == bv)
      new_membership = self.bv_membership

    # Fall 3: Es ist bereits ein BV zugewiesen. Der neue BV weicht davon ab.
    # Die Mitgliedschaft muss also geändert werden.
    #
    elsif new_bv and bv and (new_bv != bv)

      # FIXME: For the moment, DagLinks have to be unique. Therefore, the old 
      # membership has to be destroyed if the user previously had been a member
      # of the new bv. When DagLinks are allowed to exist several times, remove
      # this hack:
      #
      if old_membership = UserGroupMembership.now_and_in_the_past.find_by_user_and_group(self, new_bv)
        if old_membership != self.bv_membership
          old_membership.destroy
        end
      end

      new_membership = self.bv_membership.move_to new_bv
    end
    
    # Korrekturlauf: Durch einen Fehler kann es sein, dass ein Benutzer mehreren
    # BVs zugeordnet ist. Deshalb werden hier die übrigen BV-Mitgliedschaften
    # deaktiviert, damit er nur noch dem neuen BV zugeordnet ist.
    #
    for membership in self.bv_memberships
      membership.invalidate at: 1.minute.ago if membership != new_membership
    end

    self.groups(true) # reload groups
    return new_membership
  end
  
end
  