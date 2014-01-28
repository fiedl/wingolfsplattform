class String
  
  alias old_to_datetime to_datetime
  
  def to_datetime
    
    # In manchen Fällen wurde ein nicht existentes Datum angegeben. 
    # Beispielsweise der 31. November. Das muss hier korrigiert werden, da sonst ein Fehler 
    # erzeugt wird.
    #
    self.gsub!("1131", "1130") if self[4..7] == "1131"
    self.gsub!(/^6110000000000Z/, "20061101000000Z")   # W64492. Sonst wird das als Jahr 6110 erkannt.
    self.gsub!(/^061020000000Z/,  "20061020000000Z")   # W64720
    self.gsub!(/^061108000000Z/,  "20061108000000Z")   # W64720

    if self.blank?
      return nil
    
    elsif (self[4..8] == "00000") || (self.length == 4)  # 20030000 || 2003
      str = self[0..3] + "-01-01" # 2003-01-01
      return str.to_datetime

    elsif (self[6..8] == "000")  # 20011000000000Z (no day, but month)
      str = "#{self[0..3]}-#{self[4..5]}-01"  # 2001-10-01
      return str.to_datetime

    else
      old_to_datetime.in_time_zone

    end
  end
  
end