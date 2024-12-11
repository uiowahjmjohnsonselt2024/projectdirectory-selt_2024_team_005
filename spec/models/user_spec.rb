require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(username: "testuser", email: "test@example.com", password_digest: "somehash", shard_balance: 100) }

  describe "validations" do
    it "validates shard_balance is non-negative" do
      user.shard_balance = -1
      expect(user).not_to be_valid
      expect(user.errors[:shard_balance]).to include("must be greater than or equal to 0")
    end
  end

  describe "#get_exchange_rate" do
    it "returns the exchange rate from USD to a given currency" do
      # Mock the OpenExchangeRates::Rates instance
      rates_double = instance_double("OpenExchangeRates::Rates")
      allow(OpenExchangeRates::Rates).to receive(:new).and_return(rates_double)
      # Stub the convert method to return a fixed rate
      allow(rates_double).to receive(:convert).with(1, from: "USD", to: "EUR").and_return(0.85)

      expect(user.get_exchange_rate("EUR")).to eq(0.85)
      expect(OpenExchangeRates::Rates).to have_received(:new)
      expect(rates_double).to have_received(:convert).with(1, from: "USD", to: "EUR")
    end
  end

  describe "#visibility_for" do
    let(:grid) { instance_double("Grid", grid_id: 1, name: "TestGrid") }
    let(:user_grid_visibilities_relation) { double("user_grid_visibilities_relation") }

    before do
      allow(user).to receive(:user_grid_visibilities).and_return(user_grid_visibilities_relation)
    end

    context "when visibility exists" do
      it "returns the existing visibility" do
        ugv_double = double("UserGridVisibility", visibility: 4)
        allow(user_grid_visibilities_relation).to receive(:find_or_create_by).and_return(ugv_double)

        expect(user.visibility_for(grid)).to eq(4)
        expect(user_grid_visibilities_relation).to have_received(:find_or_create_by).with(grid_id: grid.grid_id)
      end
    end

    context "when visibility does not exist and is created" do
      it "sets default visibility to 6 for new record" do
        # Simulate the block passed to find_or_create_by
        allow(user_grid_visibilities_relation).to receive(:find_or_create_by).and_yield(double("new_ugv").as_null_object).and_return(double("UserGridVisibility", visibility: 6))

        expect(user.visibility_for(grid)).to eq(6)
      end
    end
  end

  describe "#set_visibility_for" do
    let(:grid) { instance_double("Grid", grid_id: 2) }
    let(:user_grid_visibilities_relation) { double("user_grid_visibilities_relation") }

    before do
      allow(user).to receive(:user_grid_visibilities).and_return(user_grid_visibilities_relation)
    end

    context "when user_grid_visibility already exists" do
      it "updates the visibility" do
        ugv = double("UserGridVisibility")
        allow(user_grid_visibilities_relation).to receive(:find_or_initialize_by).with(grid_id: grid.grid_id).and_return(ugv)
        allow(ugv).to receive(:visibility=)
        allow(ugv).to receive(:save).and_return(true)

        user.set_visibility_for(grid, 10)
        expect(ugv).to have_received(:visibility=).with(10)
        expect(ugv).to have_received(:save)
      end
    end

    context "when user_grid_visibility does not exist" do
      it "creates a new record and sets the visibility" do
        new_ugv = double("UserGridVisibility", visibility: nil)
        allow(user_grid_visibilities_relation).to receive(:find_or_initialize_by).and_return(new_ugv)
        allow(new_ugv).to receive(:visibility=)
        allow(new_ugv).to receive(:save).and_return(true)

        user.set_visibility_for(grid, 8)
        expect(new_ugv).to have_received(:visibility=).with(8)
        expect(new_ugv).to have_received(:save)
      end
    end
  end

  describe "after_create #initialize_grid_visibilities" do
    let(:grid1) { double("Grid", grid_id: 1, name: "Earth") }
    let(:grid2) { double("Grid", grid_id: 2, name: "Mars") }

    before do
      # Mock Grid.find_each
      allow(Grid).to receive(:find_each).and_yield(grid1).and_yield(grid2)
      allow(user).to receive(:user_grid_visibilities).and_return(double("user_grid_visibilities_relation"))
      allow(user.user_grid_visibilities).to receive(:create!)
    end

    it "creates user_grid_visibilities with 6 for Earth and 0 for others" do
      # The callback runs after create, so we must save the user
      user.save!
      expect(Grid).to have_received(:find_each)
      expect(user.user_grid_visibilities).to have_received(:create!).with(grid_id: grid1.grid_id, visibility: 6)
      expect(user.user_grid_visibilities).to have_received(:create!).with(grid_id: grid2.grid_id, visibility: 0)
    end
  end
end
