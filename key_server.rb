require 'securerandom'

class KeyServer

    attr_reader :keys, :available_keys, :deleted_keys

    def initialize
        @KEY_SIZE = 20
        @keys = {}
        @available_keys = Set.new
        @deleted_keys = Set.new
        @mutex = Mutex.new
        start_utility
    end

    def start_utility
      Thread.new do
        loop do
          sleep 1
          utility
        end
      end
    end

    def generate_keys(count)
      new_keys = Set.new
      while new_keys.size < count
        key = random_key
        unless @keys[key] || @deleted_keys.include?(key) || new_keys.include?(key)
          new_keys.add(key)
        end
      end

      @mutex.synchronize do
        new_keys.each do |key|
          @keys[key] = { 'expiry' => Time.now + (5 * 60) }
          @available_keys.add(key)
        end
      end

      @available_keys
    end

    def get_available_key
      @mutex.synchronize do
        return nil if @available_keys.empty?
    
        key = @available_keys.first
        @keys[key]['blocked_till'] = Time.now + 60
        @available_keys.delete(key)
    
        key
      end
    end

    def random_key
      SecureRandom.alphanumeric(@KEY_SIZE)
    end

    def unblock_key(key)
        out = nil
        if @keys[key] && @keys[key]['blocked_till']
            @keys[key] = {
                'expiry' => Time.now + (5 * 60)
            }
            @keys[key].delete('blocked_till')
            
            @available_keys.add key
            out = key
        end
        out
    end

    def delete_key(key)
        deleted_key = nil
        if @keys[key]
            @keys.delete key
            @available_keys.delete key
            @deleted_keys.add key
            deleted_key = key
        end
        deleted_key
    end

    def keep_alive_key(key)
        out = nil
        if @keys[key]
            @keys[key]['expiry'] = Time.now + (5 * 60)
            out = key
        end
        out
    end

    def utility
      current_time = Time.now
      @keys.each do |key, data|
        if data['blocked_till'] && data['blocked_till'] < current_time
          unblock_key(key)
        end
    
        if data['expiry'] < current_time
          delete_key(key)
        end
      end
    end

end