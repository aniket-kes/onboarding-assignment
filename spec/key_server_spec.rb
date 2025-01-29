require 'rspec'
require_relative '../key_server'

RSpec.describe KeyServer do
  let(:server) { KeyServer.new }

  describe '#initialize' do
    it 'initializes with empty keys, available_keys, and deleted_keys' do
      expect(server.keys).to be_empty
      expect(server.available_keys).to be_empty
      expect(server.deleted_keys).to be_empty
    end
  end

  describe '#random_key' do
    it 'returns a string of the specified size' do
      expect(server.random_key.length).to eq(20)
    end
  end

  describe '#generate_keys' do
    it 'generates the specified number of unique keys' do
      count = 5
      server.generate_keys(count)
      expect(server.keys.size).to eq(count)
      expect(server.available_keys.size).to eq(count)
    end

    it 'does not generate duplicate keys' do
      count = 5
      server.generate_keys(count)
      keys = server.keys.keys
      expect(keys.uniq.size).to eq(count)
    end

    it 'sets expiry time in the future for each generated key' do
      server.generate_keys(5)
      current_time = Time.now
      all_keys_have_future_expiry = server.keys.values.all? { |value| value['expiry'] > current_time }
      expect(all_keys_have_future_expiry).to be true
    end

    

  end

  describe '#get_available_key' do
    it 'returns nil if no keys are available' do
      expect(server.get_available_key).to be_nil
    end

    it 'returns a key if keys are available' do
      server.generate_keys(1)
      key = server.get_available_key
      expect(key).to be_a(String)
      expect(server.keys[key]).not_to be_nil
    end

    it 'marks the key as blocked' do
      server.generate_keys(1)
      key = server.get_available_key
      expect(server.keys[key]['blocked_till']).to be > Time.now
    end

    it 'removes the key from available_keys' do
      server.generate_keys(1)
      key = server.get_available_key
      expect(server.available_keys).not_to include(key)
    end
  end

  describe '#unblock_key' do
    it 'unblocks a blocked key' do
      server.generate_keys(1)
      key = server.get_available_key
      server.unblock_key(key)
      expect(server.keys[key]['blocked_till']).to be_nil
      expect(server.available_keys).to include(key)
    end

    it 'returns nil for non-existent keys' do
      expect(server.unblock_key('non_existent_key')).to be_nil
    end
  end

  describe '#delete_key' do
    it 'deletes a key and makes it unavailable' do
      server.generate_keys(1)
      key = server.get_available_key
      server.unblock_key(key)
      server.delete_key(key)
      expect(server.keys).not_to have_key(key)
      expect(server.available_keys).not_to include(key)
      expect(server.deleted_keys).to include(key)
    end

    it 'returns nil for non-existent keys' do
      expect(server.delete_key('non_existent_key')).to be_nil
    end
  end

  describe '#keep_alive_key' do
    it 'extends the expiry time of a key' do
      server.generate_keys(1)
      key = server.get_available_key
      previous_expiry_time = server.keys[key]['expiry']
      server.keep_alive_key(key)
      new_expiry_time = server.keys[key]['expiry']
      expect(new_expiry_time).to be > previous_expiry_time
    end
  end

  describe '#utility' do
    it 'unblocks keys that are blocked and expired' do
      server.generate_keys(1)
      key = server.get_available_key
      server.keys[key]['blocked_till'] = Time.now - 1
      server.utility
      expect(server.keys[key]['blocked_till']).to be_nil
      expect(server.available_keys).to include(key)
    end

    it 'deletes keys that are expired' do
      server.generate_keys(1)
      key = server.get_available_key
      server.keys[key]['expiry'] = Time.now - 1
      server.utility
      expect(server.keys).not_to have_key(key)
      expect(server.available_keys).not_to include(key)
      expect(server.deleted_keys).to include(key)
    end
  end
end