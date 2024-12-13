require "rails_helper"

RSpec.describe PasswordMailer, type: :mailer do
  describe "reset" do
    let(:user) { create(:user, email: "to@example.org", username: "testuser") } # Assuming you have a factory for user
    let(:token) { user.signed_id(purpose: "password_reset", expires_in: 15.minutes) }
    let(:mail) { PasswordMailer.with(user: user).reset }

    it "renders the headers" do
      expect(mail.subject).to eq("Password Reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["shardsofthegrid@gmail.com"])
    end

    it "renders the HTML body" do
      # Pattern for the reset link (we don't need to match the token exactly, just the URL structure)
      reset_link_pattern = /http:\/\/www.example.com\/forgot-password\/edit\?token=[a-zA-Z0-9\-_]+/

      # Check if the body includes the username and matches the reset link pattern
      expect(mail.body.encoded).to include("Hi #{user.username}")
      expect(mail.body.encoded).to match(reset_link_pattern)
      expect(mail.body.encoded).to include("We received your request to reset your Shards of the Grid password.")
      expect(mail.body.encoded).to include("To reset your Shards of the Grid Password, please click the following link:")
      expect(mail.body.encoded).to include("If you did not make this request, you may ignore this email.")
    end
  end
end
