class DevicesController < ApplicationController
  layout 'dashboard'

  before_filter :check_owner!, except: %i(create index new)
  before_filter :ensure_appliances_passed!, only: %i(create)

  def new
    @device = Device.new
  end

  def show
    @device = Device.find(params[:id])
  end

  def create
    appliance_ids = params[:device][:appliance_ids]
    appliances = current_user.appliances.find(appliance_ids)
    Device.create(device_params.merge(user: current_user, appliances: appliances))
    redirect_to devices_path
  end

  def index
    @devices = current_user.all_devices
  end

  def destroy
    device = Device.find(params[:id])
    device.destroy

    respond_to {|format| format.js { render layout: false } }
  end

  def forward
    device = Device.find(params[:id])
    device.appliances.each do |appliance|
      ws = WebSocketsStorage.get(appliance.id)
      ws.send(params[:code].split(",").map(&:to_i))
    end
    @state = 'success'
    respond_to {|format| format.js { render layout: false } }
  rescue => e
    logger.error e.message
    respond_to {|format| format.js { render layout: false } }
  end

  def share
    user = User.find_by(email: params[:email])
    device = Device.find(params[:id])
    if user
      if user.has_shared_device?(params[:id])
        @message = 'User already can manage this device.'
        respond_to {|format| format.js { render layout: false } }
        return
      end
      user.shared_devices_ids << device.id
      user.save
      @state = 'success'
      respond_to {|format| format.js { render layout: false } }
    else
      #TODO: send invitation and save that device was shared
      @message = "User with email #{params[:email]} is not registered in the system."
      respond_to {|format| format.js { render layout: false } }
    end
  end

  def custom
    device = Device.find(params[:id])
    device.appliances.each do |appliance|
      ws = WebSocketsStorage.get(appliance.id)
      puts "Web socket found"
      a3 = device.device_actions.first
      code = a3.code.split(",").map(&:to_i)
      ws.send(code)
      sleep(3)
      a2 = device.device_actions.last
      puts "A2 found"
      code = a2.code.split(",").map(&:to_i)
      ws.send(code)
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def device_params
    params.require(:device).permit(:name, :description)
  end

  def ensure_appliances_passed!
    unless params[:device][:appliance_ids]
      flash[:alert] = 'Please, select at least one appliance.'
      redirect_to new_device_path
    end
  end

  def check_owner!
    return if current_user.can_manage_device?(params[:id])
    flash[:alert] = 'You don\'t have permissions.'
    redirect_to root_path
  end
end
