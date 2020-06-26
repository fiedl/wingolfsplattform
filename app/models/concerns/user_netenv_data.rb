concern :UserNetenvData do

  def netenv_data
    @netenv_data ||= CSV.read(netenv_file, headers: true, col_sep: ";", row_sep: :auto).find { |row| row['uid'] == w_nummer } if w_nummer
  end

  def netenv_file
    "import/netenv_data/users.csv"
  end

  def netenv_leibbursch_entry
    netenv_data['epdwingolfmutterverbindleibbursch'] if netenv_data
  end

  def netenv_leibbursch_w_nummer
    netenv_leibbursch_entry.split(",").first.split("uid=").last if netenv_leibbursch_entry
  end

  def netenv_leibbursch
    User.find_by_w_nummer netenv_leibbursch_w_nummer if netenv_leibbursch_w_nummer
  end

end