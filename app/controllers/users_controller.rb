class UsersController < ApplicationController
  layout 'dashboard'

  def index
    if current_user.admin?
      @users = User.all
    else
      flash[:alert] = 'You don\'t have permissions.'
      redirect_to root_path
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    user = User.find(params[:id])
    user.destroy

    redirect_back(fallback_location: root_path)
  end
end
