class PostMailer < BaseMailer

  def post_email(post:, recipient:)
    @subject = post.title
    @post_url = post_url(post)
    @body = post.text.html_safe
    @author = post.author
    @recipient = recipient
    @sender_avatar_url = avatar_url_for(post.author)
    @recipient_groups = post.parent_groups

    post.attachments.each do |attachment|
      attachments[attachment.filename] = File.read(attachment.file.path)
    end

    message = mail subject: @subject

    # To pass DMARC checks at the receiving mail servers, the `From:` address
    # must be on our own email domain: DMARC requires SPF or DKIM to validate
    # for the `From:` domain, and neither can when we send the author's
    # address through our own SMTP server. The author moves to `Reply-To:`
    # so that replies still reach them.
    #
    # https://github.com/fiedl/wingolfsplattform/issues/125
    #
    primary_group = post.parent_groups.first
    message.from = "\"#{post.author.title} via #{primary_group.name}\" <#{list_address(primary_group)}>"
    message.reply_to = "#{post.author.title} <#{post.author.email}>"
    message.return_path = BaseMailer.delivery_errors_address
    message.sender = BaseMailer.technical_sender
    message.to = post.parent_groups.collect { |group|
      "#{group.name_with_corporation} <#{list_address(group)}>"
    }.join(", ")
    message.cc = "#{post.author.title} <#{post.author.email}>"
    message.smtp_envelope_to = recipient.email || raise('no delivery address!')
    message.date = post.sent_at

    message['List-Id'] = "\"#{primary_group.name}\" <#{list_address(primary_group).tr('@', '.')}>"
    message['List-Post'] = "<mailto:#{list_address(primary_group)}>"
    message['List-Unsubscribe'] = "<mailto:#{Setting.support_email}?subject=unsubscribe%20#{list_address(primary_group)}>"
    message['Precedence'] = 'list'

    return message
  end

  private

  def list_address(group)
    group.mailing_lists.first.try(:value) ||
      "#{group.title.parameterize}-#{group.id}.noreply@#{AppVersion.domain}"
  end

end
