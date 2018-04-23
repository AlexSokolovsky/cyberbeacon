module WebSocketsStorage
  STORAGE = {}

  def self.set(key, value)
    STORAGE[key] = value
  end

  def self.get(key)
    STORAGE[key]
  end
end