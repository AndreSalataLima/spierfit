RSpec.shared_examples 'forbidden request' do |request_block|
  it 'returns 403 forbidden with standard error message' do
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)).to include('error' => 'Ação não autorizada.')
  end
end

RSpec.shared_examples 'unauthorized request' do |request_block|
  it 'returns 401 unauthorized' do
    expect(response).to have_http_status(:unauthorized)
  end
end
