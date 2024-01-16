class EmailService
  def send_reset_password_instructions(user, token)
    # Localize the subject using I18n
    subject = I18n.t('devise.mailer.reset_password_instructions.subject')

    # Prepare the email content using the provided template and locale
    mail_body = ApplicationController.render(
      template: 'devise/mailer/reset_password_instructions',
      locals: { '@resource': user, '@token': token }
    )

    # Send the email
    ActionMailer::Base.mail(
      from: 'noreply@example.com',
      to: user.email,
      subject: subject,
      body: mail_body
    ).deliver_now
  end
end
