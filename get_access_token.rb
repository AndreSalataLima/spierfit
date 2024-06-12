require 'httparty'
require 'json'

client_id = 'V8YjaN9Ob9eTUAEMYzSdi6NnhogLYlyz'       # Substitua pelo seu Client ID
client_secret = '2ZQH1Z7lg56d9IOntFATQieg8LTy275wa5m4VUTdrwWkD36kecBDMnOKDjNUhqwm' # Substitua pelo seu Client Secret

response = HTTParty.post('https://api2.arduino.cc/iot/v1/clients/token',
  body: {
    grant_type: 'client_credentials',
    client_id: client_id,
    client_secret: client_secret,
    audience: 'https://api2.arduino.cc/iot'
  },
  headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
)

if response.code == 200
  parsed_response = JSON.parse(response.body)
  access_token = parsed_response['access_token']
  puts "Your Access Token: #{access_token}"
else
  puts "Failed to get access token. Response code: #{response.code}"
  puts "Response body: #{response.body}"
end
