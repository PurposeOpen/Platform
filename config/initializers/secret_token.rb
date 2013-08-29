# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

PurposePlatform::Application.config.secret_token = if Rails.env.development? or Rails.env.test?
  'abca76af0cc99e8e00904982dab900d9048b7eabeddd7a8312831cbae7287765a4707eded28cd6ef3357518a87b767c5d50d0d8cd9c8dadc1938722e6387dcb4'
else
  ENV['SECRET_TOKEN']
end