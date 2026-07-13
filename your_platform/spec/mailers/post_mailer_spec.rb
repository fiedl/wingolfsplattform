require 'spec_helper'

# type: :model — the rspec mailer-type setup (ActionMailer::TestCase)
# clashes with the `content_type` override in core_ext/mail/message.rb.
describe PostMailer, type: :model do
  describe "#post_email" do
    let(:group) {
      group = create :group, name: "Developers"
      group.mailing_lists.create label: "Mailing list", value: "all-developers@example.com"
      group
    }
    let(:author) { create :user_with_account, email: 'john@example.com' }
    let(:recipient) { create :user_with_account }
    let(:post) { group.create_post author_user_id: author.id, subject: "Great news", text: "Free drinks this evening!", sent_at: 1.hour.ago }

    subject(:message) { PostMailer.with(post:, recipient:).post_email }

    # DMARC requires SPF or DKIM to validate for the `From:` domain,
    # which neither can when we send the author's address through our
    # own SMTP server. https://github.com/fiedl/wingolfsplattform/issues/125
    it "sends from the group's list address to keep DMARC alignment" do
      message.from.should == ['all-developers@example.com']
      message[:from].to_s.should include "#{author.title} via Developers"
    end
    it "keeps the author as Reply-To" do
      message.reply_to.should == ['john@example.com']
    end
    it "addresses the group's mailing list" do
      message.to.should == ['all-developers@example.com']
    end
    it "adds the list headers" do
      message['List-Id'].to_s.should include 'all-developers.example.com'
      message['List-Post'].to_s.should == '<mailto:all-developers@example.com>'
      message['List-Unsubscribe'].to_s.should include 'unsubscribe'
      message['Precedence'].to_s.should == 'list'
    end
    it "delivers to the recipient via the smtp envelope" do
      message.smtp_envelope_to.should == [recipient.email]
    end

    describe "when the group has no mailing list" do
      let(:group) { create :group, name: "Developers" }
      it "falls back to a generated noreply address on our domain" do
        message.from.first.should include ".noreply@"
      end
    end
  end
end
