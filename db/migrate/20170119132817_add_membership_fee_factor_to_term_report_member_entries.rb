class AddMembershipFeeFactorToTermReportMemberEntries < ActiveRecord::Migration
  def change
    add_column :term_report_member_entries, :membership_fee_factor, :float
  end
end
