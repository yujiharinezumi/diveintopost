class AgendaMailer < ApplicationMailer
  default from: 'from@example.com'

  def agenda_mail(email)
    @email = email
    mail to:email , subject: "agenda削除の通知"
  end
end
