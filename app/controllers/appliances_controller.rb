class AppliancesController < ApplicationController
  layout 'dashboard'

  skip_before_action :authenticate_user!, only: %i(connect)
  before_action      :check_owner!, except: %i(create index new connect)

  def new
    @appliance = Appliance.new
  end

  def show
    @appliance = Appliance.find(params[:id])
  end

  def create
    #TODO: handle duplicate id correctly
    Appliance.create(appliances_params.merge(user: current_user))
    redirect_to appliances_path
  end

  def destroy
    appliance = Appliance.find(params[:id])
    appliance.destroy

    redirect_back(fallback_location: root_path)
  end

  def connect
    if params['user_id'] #it should be current_user
      WebSocketsHelper.open_websocket(request.env, "#{params['user_id']}:#{params[:id]}")
    else
      puts "Device #{params[:id]} opens web socket"
      WebSocketsHelper.open_websocket(request.env, params[:id])
    end
    head :no_content
  end

  def verify
    appliance = Appliance.find(params[:id])
    if (time = WebSocketsStorage.get("#{appliance.id}_verified")) && ((Time.now - time) < 5.seconds)
      appliance.verified = true
      appliance.save
    else
      #return error
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def appliances_params
    params.require(:appliance).permit(:id, :name, :description)
  end

  def check_owner!
    return true if current_user.owns_appliance?(params[:id])
    flash[:alert] = 'You don\'t have permissions.'
    redirect_to root_path
  end
end
