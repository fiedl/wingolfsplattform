require 'spec_helper'

# type: :model — the rspec mailer-type setup (ActionMailer::TestCase)
# clashes with the `content_type` override in core_ext/mail/message.rb.
describe CommentMailer, type: :model do
  describe "#comment_email" do
    let(:group) { create :group, name: "Developers" }
    let(:author) { create :user_with_account, email: 'john@example.com' }
    let(:commenter) { create :user_with_account, email: 'jane@example.com' }
    let(:recipient) { create :user_with_account }
    let(:post) { group.create_post author_user_id: author.id, subject: "Great news", text: "Free drinks this evening!", sent_at: 1.hour.ago }

    before { post.comments.create author_user_id: commenter.id, text: "Can't wait!" }

    # The production template lives in the private additions repo
    # (see PrivateViews); the specs bring their own minimal one.
    before { CommentMailer.prepend_view_path File.expand_path("../../support/views", __FILE__) }

    subject(:message) { CommentMailer.with(post:, recipient:).comment_email }

    # DMARC requires SPF or DKIM to validate for the `From:` domain,
    # which neither can when we send the author's address through our
    # own SMTP server. https://github.com/fiedl/wingolfsplattform/issues/125
    it "sends from our own support address to keep DMARC alignment" do
      message.from.should == [Setting.support_email]
      message[:from].to_s.should include "#{commenter.title} via"
    end
    it "keeps the comment author as Reply-To" do
      message.reply_to.should == ['jane@example.com']
    end
    it "delivers to the recipient via the smtp envelope" do
      message.smtp_envelope_to.should == [recipient.email]
    end
  end
end
