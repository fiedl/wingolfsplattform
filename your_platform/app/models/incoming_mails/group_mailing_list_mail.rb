# This class handles the direct forwarding of an incoming
# group mailing list message to the members of the group.
#
class IncomingMails::GroupMailingListMail < IncomingMail

  def process(options = {})
    if recipient_group && authorized?
      # create_post_later  # TODO: Bring this back when the database supports it. https://trello.com/c/L29imOT9/1013-e-mails-utf-8-pizza-🍕, https://trello.com/c/08q1iHFm/1469-e-mail-verteiler-anhänge-in-app-anzeigen
      deliver_message_to_earch_user_later
    else
      []
    end
  end

  # Transport and authentication headers of the original message.
  # The forwarded copies must not keep them: The original DKIM signature
  # breaks when we rewrite headers and substitute the greeting placeholders,
  # and a broken signature scores worse at spam filters than none. The
  # remaining ones are classic forwarding-spam fingerprints.
  #
  STALE_TRANSPORT_HEADERS = %w(
    DKIM-Signature X-Google-DKIM-Signature
    ARC-Seal ARC-Message-Signature ARC-Authentication-Results
    Authentication-Results Received Return-Path Delivered-To X-Original-To
  )

  def deliver_message_to_earch_user_later
    deliveries = recipient_group.members.with_account.collect do |user|

      # Create a copy of the original message.
      # `self.message.clone` and `self.message.dup` would keep certain references,
      # such that modifying the body would modify the body for all further messages
      # in the loop.
      new_message = Mail::Message.new self.message.to_s

      STALE_TRANSPORT_HEADERS.each { |header| remove_header new_message, header }

      replace_header new_message, 'X-Original-From', sender_string
      new_message.from = formatted_from
      new_message.reply_to = formatted_reply_to
      new_message.return_path = BaseMailer.delivery_errors_address
      new_message.sender = BaseMailer.technical_sender
      new_message.to = formatted_to_field
      new_message.cc = formatted_cc_field
      replace_header new_message, 'List-Id', "\"#{recipient_group.name}\" <#{list_address.tr('@', '.')}>"
      replace_header new_message, 'List-Post', "<mailto:#{list_address}>"
      replace_header new_message, 'List-Unsubscribe', "<mailto:#{Setting.support_email}?subject=unsubscribe%20#{list_address}>"
      replace_header new_message, 'Precedence', 'list'
      new_message.smtp_envelope_to = user.email
      fill_in_placeholders new_message, from_user: sender_user, to_user: user
      new_message.deliver_with_action_mailer_later
    end
    deliveries
  end

  # Assigning `nil` removes all occurrences of a header — but only if the
  # header is present. Otherwise, `Mail::Message#[]=` would add an empty
  # header field instead.
  #
  def remove_header(message, name)
    message[name] = nil if message[name]
  end

  # For header fields that are not limited to a single occurrence,
  # `Mail::Message#[]=` appends rather than replaces. Remove existing
  # occurrences first, e.g. list headers of an upstream mailing list.
  #
  def replace_header(message, name, value)
    remove_header message, name
    message[name] = value
  end

  def create_post_later
    CreatePostFromEmailMessageJob.perform_later(raw_message: message.to_s)
  end

  def create_post
    post = recipient_group.posts.new
    if sender_user
      post.author_user_id = sender_user.id
    else
      post.external_author = sender_string
    end
    post.sent_at = message.date || Time.zone.now
    post.subject = message.subject
    post.content_type = message.content_type
    post.text = message.text
    post.message_id = message.message_id
    post.sent_via = destination
    post.save
    if message.has_attachments?
      message.attachments.each do |attachment|
        file = StringIO.new(attachment.decoded)
        file.class.class_eval { attr_accessor :original_filename, :content_type }
        file.original_filename = attachment.filename
        file.content_type = attachment.mime_type
        post_attachment = post.attachments.create(file: file)
        post_attachment.save
      end
    end
    post
  end

  def subject_with_group_name
    if subject.include? recipient_group.name
      subject
    else
      "[#{recipient_group.name}] #{subject}"
    end
  end

  # To pass DMARC checks at the receiving mail servers, the `From:` address
  # must be on our own email domain (From-rewriting, as mailman does it):
  # DMARC requires SPF or DKIM to validate for the `From:` domain, and
  # neither can when we send the author's address through our own SMTP
  # server. The author moves to `Reply-To:` so that replies still reach them.
  #
  # https://github.com/fiedl/wingolfsplattform/issues/125
  #
  def formatted_from
    "\"#{author_display_name} via #{recipient_group.name}\" <#{list_address}>"
  end

  def author_display_name
    if sender_user
      sender_user.title
    elsif sender_name.present? && sender_name != sender_email
      sender_name.gsub("\"", "")
    else
      sender_email
    end
  end

  # The address used in the rewritten `From:` field. It must always be on
  # our own email domain; a foreign domain would recreate the DMARC
  # misalignment.
  #
  def list_address
    if on_own_email_domain?(destination)
      destination
    else
      # The message reached us through a foreign-domain alias that forwards
      # to us (see `IncomingMail#x_original_to`). Use the group's own
      # list address on our domain instead.
      own_list = recipient_group.mailing_lists.detect { |field| on_own_email_domain?(field.value) }
      own_list.try(:value) || "#{recipient_group.title.parameterize}-#{recipient_group.id}.noreply@#{AppVersion.domain}"
    end
  end

  def on_own_email_domain?(address)
    address.to_s.split("@").last.to_s.ends_with? AppVersion.email_domain
  end

  # https://trello.com/c/s94OXzul/1371-e-mails-554-570-reject
  # https://stackoverflow.com/q/57173606/2066546
  #
  def formatted_reply_to
    if sender_user
      "\"#{sender_user.title}\" <#{sender_email}>"
    else
      if message[:from].value.include?("\"") && message[:from].value.include?("<")
        message[:from].value
      else
        "\"#{sender_email}\" <#{sender_email}>"
      end
    end
  end

  def formatted_to
    "\"#{recipient_group.title}\" <#{destination}>"
  end

  def formatted_field(header_key)
    if message[header_key]
      # `element` is mail >= 2.8 for the removed `address_list`.
      parts = message[header_key].element.addresses.collect do |part|
        part = formatted_to if part.address == destination
        part.to_s
      end
      parts.join(", ")
    end
  end

  def formatted_to_field
    formatted_field("To")
  end

  def formatted_cc_field
    formatted_field("CC")
  end

  PERSONAL_GREETING_PLACEHOLDERS = ["{{anrede}}", "{{greeting}}"]

  def fill_in_placeholders(message, options = {})
    PERSONAL_GREETING_PLACEHOLDERS.each do |placeholder|
      message.replace placeholder, personal_greeting(options[:from_user], options[:to_user])
    end
  end

  def personal_greeting(from_user, to_user)
    if to_user
      to_user.personal_greeting(current_user: from_user)
    else
      I18n.t(:good_day).to_s.gsub(",", "").gsub("!", "")
    end
  end

end
