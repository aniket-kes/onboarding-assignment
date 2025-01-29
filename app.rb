require './key_server'
require 'sinatra'
require 'json'

class KeyGen < Sinatra::Application
    server = KeyServer.new

    post '/key/generate' do
      data = JSON.parse(request.body.read)
      count = data['count']
      
      unless count.is_a?(Integer) || count.to_i.to_s == count
        status 400
        return "Invalid count provided #{count}"
      end

      count = count.to_i
      status 200
      server.generate_keys(count).to_a.to_s
    end

    get '/key' do
      key = server.get_available_key
      if key
          status 200
          key
      else
          status 404
          "No available keys at the moment"
      end
    end    

    patch '/key/unblock' do
      data = JSON.parse(request.body.read)
      key_to_unblock = data['key']

      unblocked_key = server.unblock_key key_to_unblock

      if unblocked_key
        status 200
        "#{key_to_unblock} has been successfully unblocked"
      else
        status 400
        "Failed to unblock the key: #{key_to_unblock}"
      end
    end

    delete '/key/:key' do 
      key_to_delete = params['key']

      if server.delete_key(key_to_delete)
        status 200
        "#{key_to_delete} has been deleted"
      else
        status 400
        "Failed to delete the key: #{key_to_delete}"
      end
    end

    patch '/key/alive' do
      data = JSON.parse(request.body.read)
      key = data['key']
      alive_key = server.keep_alive_key key

      if alive_key
        status 200
        "Sucessfully increased the expiry for #{key}"
      else
        status 400
        "Failed to extend the key: #{key}"
      end
    end

    get '/*' do
      status 200
      content_type :html
      <<-HTML
        <h1>Available Endpoints:</h1>
        <ul>
          <li>POST /key/generate - { "count": number }</li>
          <li>GET /key</li>
          <li>PATCH /key/unblock - { "key": "key_value" }</li>
          <li>PATCH /key/alive - { "key": "key_value" }</li>
          <li>DELETE /key/:key</li>
        </ul>
      HTML
    end
end

KeyGen.run!