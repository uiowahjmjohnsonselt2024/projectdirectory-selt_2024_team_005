require 'open_exchange_rates'
class User < ApplicationRecord
  has_one :character, foreign_key: "username", primary_key: "username",  dependent: :destroy
  OpenExchangeRates.configure do |config|
    config.app_id = "541c6dbbdf244c82bd71151575e47f27"
  end
  def get_exchange_rate(currency)
    fx = OpenExchangeRates::Rates.new
    fx.convert(1, from: "USD", to: currency)
  end
end
