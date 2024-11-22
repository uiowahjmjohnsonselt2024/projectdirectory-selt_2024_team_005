require 'spec_helper'
require 'rails_helper'

describe PasswordResetsController, type: :controller do
  before do
    @fake_user = User.create!(username: 'fake_user', email: 'fake_user@uiowa.edu', password: '54321')
  end
  describe 'submitting an email' do
    it 'should call PasswordMailer if there exists a user associated with the email' do
      allow(User).to receive(:find_by).and_return (@fake_user)
      expect(PasswordMailer).to receive_message_chain(:with, :reset, :deliver_later)
      post :create, params: { email: 'fake_user@uiowa.edu' }
    end
    it 'should flash an alert if the email is invalid' do
      post :create, params: { email: 'notAnEmail@123' }
      expect(flash[:alert]).to eq('Invalid email.')
    end
    it 'should flash a notice notifying the user an email has been sent, even if an email was not sent' do
      post :create, params: { email: 'liamwells@uiowa.edu' }
      expect(flash[:notice]).to eq('Email sent. Please check your email.')
    end
  end
  describe 'resetting password' do
    before do
      allow(User).to receive(:find_signed!).and_return (@fake_user)
    end
    it 'should update the user\'s password' do
      expect(@fake_user).to receive(:update).and_return (true)
      post :update, params: {
        token: 'valid_token',
        user: { password: '12345', password_confirmation: '12345' }
      }
    end
    it 'should redirect the user back to the login page after successful password reset' do
      allow(@fake_user).to receive(:update).and_return (true)
      post :update, params: {
        token: 'valid_token',
        user: { password: '12345', password_confirmation: '12345' }
      }
      expect(response).to redirect_to(root_path)
    end
    it 'should flash a notice notifying the user their password has been reset' do
      allow(@fake_user).to receive(:update).and_return (true)
      post :update, params: {
        token: 'valid_token',
        user: { password: '12345', password_confirmation: '12345' }
      }
      expect(flash[:notice]).to eq('Your password was reset successfully. Please sign in again.')
    end
    it 'should flash an alert if password and confirm password fields do not match' do
      post :update, params: {
        token: 'valid_token',
        user: { password: '12345', password_confirmation: '67890' }
      }
      expect(flash[:alert]).to eq('Passwords do not match.')
    end
    it 'should redirect the user back to the login page and flash and alert if the password reset token has expired' do
      allow(User).to receive(:find_signed!).and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
      get :edit, params: { token: 'expired_token' }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Your token has expired. Please try again.')
    end
  end
end
