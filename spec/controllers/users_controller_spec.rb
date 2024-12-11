require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:mock_user) do
    double(
      'User',
      username: 'testuser',
      shard_balance: 100,
      get_exchange_rate: 1.2 # Stub the exchange rate for testing
    )
  end

  let(:mock_character) { double('Character') }

  before do
    # Default stubs for finders
    allow(User).to receive(:find_by!).with(username: 'testuser').and_return(mock_user)
    allow(Character).to receive(:find_by).with(username: 'testuser').and_return(mock_character)
    allow(mock_user).to receive(:save).and_return(true)
  end

  describe "GET #show" do
    context "when user and character exist" do
      it "assigns the user and character" do
        get :show, params: { username: 'testuser' }

        expect(assigns(:user)).to eq(mock_user)
        expect(assigns(:character)).to eq(mock_character)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user does not exist" do
      before do
        allow(User).to receive(:find_by!).and_raise(ActiveRecord::RecordNotFound)
      end

      it "raises RecordNotFound" do
        expect {
          get :show, params: { username: 'nonexistent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when character does not exist" do
      before do
        allow(Character).to receive(:find_by).with(username: 'testuser').and_return(nil)
      end

      it "assigns @character as nil" do
        get :show, params: { username: 'testuser' }
        expect(assigns(:character)).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #buy_shards" do
    context "when user exists" do
      before do
        allow(mock_user).to receive(:get_exchange_rate).and_return(1.2)
      end

      it "assigns user, character, currencies and exchange_rates" do
        get :buy_shards, params: { username: 'testuser' }
        expect(assigns(:user)).to eq(mock_user)
        expect(assigns(:character)).to eq(mock_character)
        expect(assigns(:currencies)).to eq(%w[USD EUR GBP JPY AUD CAD CHF CNY SEK NZD])
        expect(assigns(:exchange_rates)).to be_a(Hash)
        expect(assigns(:exchange_rates).keys).to match_array(%w[USD EUR GBP JPY AUD CAD CHF CNY SEK NZD])
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user not found" do
      before do
        allow(User).to receive(:find_by!).and_raise(ActiveRecord::RecordNotFound)
      end

      it "raises RecordNotFound" do
        expect {
          get :buy_shards, params: { username: 'nonexistent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #process_payment" do
    before do
      allow(mock_user).to receive(:shard_balance=)
    end

    context "with valid parameters" do
      it "updates shard balance and redirects" do
        post :process_payment, params: {
          username: 'testuser',
          amount: '10',
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: '12/24',
          cc_cvv: '123'
        }

        expect(response).to redirect_to(user_path('testuser'))
        expect(flash[:notice]).to match(/Successfully purchased/)
      end
    end

    context "with invalid amount" do
      it "redirects with an alert" do
        post :process_payment, params: {
          username: 'testuser',
          amount: '0',
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: '12/24',
          cc_cvv: '123'
        }

        expect(response).to redirect_to(buy_shards_user_path('testuser'))
        expect(flash[:alert]).to eq("Please enter a valid amount.")
      end
    end

    context "with missing credit card info" do
      it "redirects with an alert" do
        post :process_payment, params: {
          username: 'testuser',
          amount: '10',
          currency: 'USD',
          cc_number: '',
          cc_expiration: '12/24',
          cc_cvv: '123'
        }

        expect(response).to redirect_to(buy_shards_user_path('testuser'))
        expect(flash[:alert]).to eq("Please fill in all credit card information.")
      end
    end

    context "with invalid credit card number" do
      it "redirects with an alert" do
        post :process_payment, params: {
          username: 'testuser',
          amount: '10',
          currency: 'USD',
          cc_number: 'invalid',
          cc_expiration: '12/24',
          cc_cvv: '123'
        }

        expect(response).to redirect_to(buy_shards_user_path('testuser'))
        expect(flash[:alert]).to eq("Invalid credit card number.")
      end
    end

    context "when character not found" do
      before do
        allow(Character).to receive(:find_by).with(username: 'testuser').and_return(nil)
      end

      it "redirects with an alert" do
        post :process_payment, params: {
          username: 'testuser',
          amount: '10',
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: '12/24',
          cc_cvv: '123'
        }

        expect(response).to redirect_to(user_path('testuser'))
        expect(flash[:alert]).to eq("Character not found.")
      end
    end

    context "when user save fails" do
      before do
        allow(mock_user).to receive(:save).and_return(false)
      end

      it "redirects with an alert" do
        post :process_payment, params: {
          username: 'testuser',
          amount: '10',
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: '12/24',
          cc_cvv: '123'
        }

        expect(response).to redirect_to(user_path('testuser'))
        expect(flash[:alert]).to eq("Unable to update shard balance.")
      end
    end
  end

  describe "GET #new" do
    it "assigns a new user object" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    let(:user_params) do
      {
        email: 'test@example.com',
        username: 'newuser',
        password: 'password',
        password_confirmation: 'password'
      }
    end

    context "with valid params" do
      before do
        # Stub existence checks
        allow(User).to receive(:exists?).with(username: 'newuser').and_return(false)
        allow(User).to receive(:exists?).with(email: 'test@example.com').and_return(false)
        # Stub user creation
        mock_new_user = instance_double(User, username: 'newuser', email: 'test@example.com', shard_balance: 0, save: true)
        allow(User).to receive(:new).and_return(mock_new_user)
        allow(Inventory).to receive(:maximum).with(:inv_id).and_return(0)
        mock_inventory = double('Inventory', inv_id: 1)
        allow(Inventory).to receive(:create!).and_return(mock_inventory)
        mock_grid = double('Grid', grid_id: 1, cells: double('CellAssociation', order: [ double('Cell', cell_id: 1) ]))
        allow(Grid).to receive(:find).with(1).and_return(mock_grid)
        allow(Character).to receive(:create!)

        post :create, params: { user: user_params }
      end

      it "redirects to the login path with a notice" do
        expect(response).to redirect_to(login_path)
        expect(flash.now[:notice]).to match(/Account and a default character successfully created!/)
      end
    end

    context "when username or email already taken" do
      before do
        allow(User).to receive(:exists?).with(username: 'newuser').and_return(true)
        allow(User).to receive(:exists?).with(email: 'test@example.com').and_return(false)
      end

      it "rerenders the new template with a notice" do
        post :create, params: { user: user_params }
        expect(response).to render_template(:new)
        expect(flash.now[:notice]).to eq("Email/Username is already taken")
      end
    end

    context "when user save fails" do
      before do
        mock_new_user = instance_double(User, username: 'newuser', email: 'test@example.com', shard_balance: 0, save: false, errors: double(full_messages: [ "Something went wrong" ]))
        allow(User).to receive(:new).and_return(mock_new_user)
        allow(User).to receive(:exists?).and_return(false)
      end

      it "rerenders the new template with error messages" do
        post :create, params: { user: user_params }
        expect(response).to render_template(:new)
        expect(flash.now[:notice]).to eq("Something went wrong")
      end
    end
  end
end
