# spec/support/auth_helpers.rb
module AuthHelpers
  def create_access_token_for(user)
    application = Doorkeeper::Application.create!(
      name: "Test Client",
      redirect_uri: "https://example.com/callback"
    )

    Doorkeeper::AccessToken.create!(
      application: application,
      resource_owner_id: user.id,
      scopes: 'public'
    )
  end
end
