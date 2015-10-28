Rails.application.config.middleware.use OmniAuth::Builder do
  opts = {
    scope: 'email,public_profile',
    image_size: 'large',
  }
  provider :facebook, FACEBOOK_KEY, FACEBOOK_SECRET, opts
end
