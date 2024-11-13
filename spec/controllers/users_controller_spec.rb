require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #show' do
    let(:user) { User.create!(username: 'awesomehawkeye', email: 'awesome@uiowa.edu', password_digest: '12345') }

    context 'when the user exists' do
      it 'returns a successful response' do
        get :show, params: { username: user.username }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested user to @user' do
        get :show, params: { username: user.username }
        expect(assigns(:user)).to eq(user)
      end

      it 'renders the show template' do
        get :show, params: { username: user.username }
        expect(response).to render_template(:show)
      end
    end

    context 'when the user does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect {
          get :show, params: { username: 'nonexistentuser' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
