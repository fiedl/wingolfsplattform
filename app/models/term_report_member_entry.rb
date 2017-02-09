require_dependency YourPlatform::Engine.root.join( 'app/models/term_report_member_entry' ).to_s

module TermReportMemberEntryAdditions
  module ClassMethods
    def create_from_user(user, options = {})
      entry = super(user, options)
      term_report = TermReport.find entry.term_report_id

      entry.w_nummer = user.w_nummer
      entry.klammerung = user.klammerung

      if user.primary_corporation(at: term_report.end_of_term) == term_report.corporation
        entry.membership_fee_factor = 1.0
      else
        entry.membership_fee_factor = 0.0
      end

      entry.save
      return entry
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

class TermReportMemberEntry
  prepend TermReportMemberEntryAdditions
end