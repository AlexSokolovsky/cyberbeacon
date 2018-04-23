class DeviceActionsController < ApplicationController
  layout 'dashboard'

  def new
    @device = Device.find(params[:device_id])
    @device_action = @device.device_actions.build
  end

  def create
    device = Device.find(params[:device_id])
    device.device_actions.build(device_action_params)
    device.save
    redirect_to device_path(device)
  end

  def destroy
    device = Device.find(params[:device_id])
    device_action = device.device_actions.find(params[:id])
    device_action.destroy

    redirect_back(fallback_location: root_path)
  end

  private

  def device_action_params
    params.require(:device_action).permit(:name, :code)
  end
end
