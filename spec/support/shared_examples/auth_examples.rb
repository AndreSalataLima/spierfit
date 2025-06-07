RSpec.shared_examples 'requires_authentication' do |method, path, params = {}|
  it 'returns 401 unauthorized when not authenticated' do
    request_path = path.respond_to?(:call) ? path.call : path
    request_params = params.respond_to?(:call) ? params.call : params

    send(method, request_path, params: request_params)
    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.shared_examples 'forbids_non_superadmin' do |method, path, user, params = {}|
  it 'returns 403 forbidden when authenticated as non-superadmin' do
    request_path = path.respond_to?(:call) ? path.call : path
    request_user = user.respond_to?(:call) ? user.call : user
    request_params = params.respond_to?(:call) ? params.call : params

    send(method, request_path, params: request_params, headers: request_user.create_new_auth_token)
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)).to include('error' => 'Ação não autorizada.')
  end
end
