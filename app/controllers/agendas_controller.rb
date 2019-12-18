class AgendasController < ApplicationController
   before_action :set_agenda, only: %i[show edit update destroy]
   before_action :authenticate_user, only:[:destroy]
  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end

  def destroy
    assign = @agenda.team.assigns
  
    @agenda.destroy

    assign.each do |assign|
      AgendaMailer.agenda_mail(assign.user.email).deliver
    end
    redirect_to dashboard_path

  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end

  def authenticate_user
    user_id = @agenda.user_id
    owner_id = @agenda.team.owner_id

    if not current_user.id == user_id || current_user.id == owner_id
        redirect_to dashboard_url,notice:"権限がありません"
      end
  end

end
