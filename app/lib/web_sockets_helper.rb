module WebSocketsHelper
  def self.open_websocket(request_env, key)
    ws = Faye::WebSocket.new(request_env)

    WebSocketsStorage.set(key, ws)

    ws.on(:open) do
      puts "Web socket with id #{key} connected."
    end

    ws.on(:message) do |msg|
      puts "--Message received--"
      puts msg.data
      puts "----"
      
      ids = key.split(':')
      if ids.count == 1
        # appliance -> client
        appliance = Appliance.find(key)
        if msg.data == 'button 1 is pressed!'
          # save timestamp 
          WebSocketsStorage.set("#{key}_verified", Time.now)
        else
          user_id = appliance.user.id
          puts "Attempt to find socket with id #{user_id}:#{key}."
          if socket = WebSocketsStorage.get("#{user_id}:#{key}")
            puts "Sending message '#{msg.data}' from socket #{key} to socket #{user_id}:#{key}"
            socket.send(msg.data.map(&:to_s).join(','))
          else
            puts "Socket with id #{user_id}:#{key} not found."
          end
        end
      else
        # client -> appliance
        puts "Sending message '#{msg.data}' from socket #{key} to socket #{ids.last}"
        WebSocketsStorage.get(ids.last).send(msg.data)
      end
    end

    ws.on(:close) do |event|
      puts "Web socket with id #{key} disconnected."
    end

    ws.rack_response
  end
end