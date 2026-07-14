module StringOverrides

  # The `to_datetime` method is patched to support converting
  # years like "2005", which are interpreted as "2005-01-01".
  #
  # No in-place mutation: rails 5.2 hands out frozen strings for
  # attributes read from the database.
  #
  def to_datetime
    normalized = normalize_bare_year
    return nil if normalized == "-"
    normalized == self ? super : normalized.to_datetime
  end

  def to_date
    normalized = normalize_bare_year
    return nil if normalized == "-"
    normalized == self ? super : normalized.to_date
  end

  private

  def normalize_bare_year
    gsub(/^[ ]*([12][019][0-9][0-9])[ ]*$/, '01.01.\1')
  end

end

class String
  prepend StringOverrides
end
