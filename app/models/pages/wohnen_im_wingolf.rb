# Dies ist die "Wohnen"-Seite der öffentlichen Homepage wingolf.org.
# Diese Seite ist mit allen Wingolfshäusern bebildert. Um dies zu automatisieren,
# überschreibt diese Sub-Klasse die Attachments-Methode.
#
class Pages::WohnenImWingolf < Page

  def attachments
    Attachment.wingolfshaus
  end

  # To save us from managing separate routes and controllers for this
  # subclass, override the model name.
  #
  def self.model_name
    Page.model_name
  end

  def to_partial_path
    'pages/page'
  end

end