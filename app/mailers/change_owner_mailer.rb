class ChangeOwnerMailer < ApplicationMailer
  default from: 'from@example.com'


  def change_owner_mail(email,team)
    @team = team
    @email = email


    mail to: @email, subject: "オーナーの権限の移動しました"

  end
end
