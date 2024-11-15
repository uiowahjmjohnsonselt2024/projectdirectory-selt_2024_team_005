require 'spec_helper'
require 'rails_helper'

describe PasswordResetsController, type: :controller do
  describe 'submitting an email' do
    it 'should call PasswordMailer if there exists a user associated with the email' do

    end
    it 'should flash a warning if the email is invalid' do

    end
    it 'should flash a notice notifying the user an email has been sent, even if an email was not sent' do

    end
  end
end