require 'rails_helper'

RSpec.describe ChatChannel, type: :channel do
  let(:user) { create(:user) }
  let(:character) { create(:character, user: user) }
  let(:room_id) { 1 }

end