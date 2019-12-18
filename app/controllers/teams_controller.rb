class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy change_owner]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def change_owner
    # params = {"authenticity_token"=>"DtA+aRJ61+zXzu4tD8KPpZtRZLIWDWFzngNUxlFVAMji8s6Bw4gvCw8qB/4iLo5i6gYmSphlpS5uYRkauXqS3A==", "user_id"=>"3", "id"=>"1"}
    if @team.update(owner_id: params[:user_id])
        ChangeOwnerMailer.change_owner_mail(@team.owner.email, @team.name).deliver
        # binding.pry
      # @team.update(name: params[:team_name])
      redirect_to team_url, notice:"オーナーの権限を移動しました"
    else
      redirect_to team_url,notice: "オーナー権限の移動に失敗しました"
    end
  end

  private

  def set_team
    # params = {"authenticity_token"=>"DtA+aRJ61+zXzu4tD8KPpZtRZLIWDWFzngNUxlFVAMji8s6Bw4gvCw8qB/4iLo5i6gYmSphlpS5uYRkauXqS3A==", "user_id"=>"3", "id"=>"1"}
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

end
