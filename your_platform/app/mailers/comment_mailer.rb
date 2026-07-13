class CommentMailer < BaseMailer

  # Parameterized like PostMailer#post_email.
  def comment_email
    post = params[:post]
    recipient = params[:recipient]
    @subject = post.title
    @post_url = post_url(post)
    @current_user = recipient

    @messages = []

    for attachment in post.attachments
      @messages << {
        author: post.author,
        body: view_context.link_to(attachment.title, url_for(attachment)),
        avatar_url: avatar_url_for(post.author)
      }
    end
    if view_context.strip_tags(post.text).present?
      @messages << {
        author: post.author,
        body: view_context.sanitize(post.text),
        avatar_url: avatar_url_for(post.author)
      }
    end
    for comment in post.comments.order(:created_at)
      @messages << {
        author: comment.author,
        body: view_context.sanitize(comment.text),
        avatar_url: avatar_url_for(comment.author)
      }
    end

    @latest_comment = post.comments.order(:created_at).last
    @author = @latest_comment.author
    @recipients = @latest_comment.recipients

    message = mail subject: @subject

    # To pass DMARC checks at the receiving mail servers, the `From:` address
    # must be on our own email domain. The author moves to `Reply-To:`.
    # https://github.com/fiedl/wingolfsplattform/issues/125
    message.from = "\"#{@author.title} via #{AppVersion.app_name}\" <#{Setting.support_email}>"
    message.reply_to = "#{@author.title} <#{@author.email}>"
    message.return_path = BaseMailer.delivery_errors_address
    message.sender = BaseMailer.technical_sender

    message.to = @recipients.collect { |user|
      "#{user.title} <#{user.email}>"
    }.join(", ")
    message.cc = "#{@author.title} <#{@author.email}>"
    message.smtp_envelope_to = recipient.email || raise('no delivery address!')
    message.date = @latest_comment.created_at

    return message
  end

end
