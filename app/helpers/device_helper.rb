module DeviceHelper
  def shared?(device_id)
    current_user.has_shared_device?(device_id)
  end
end
