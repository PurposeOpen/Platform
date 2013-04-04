# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Rails.env.production?
  PurposePlatform::Application.config.secret_token = 'a05db3527debffec09383bb3c4c8ec2db8e5d31d03a168b7cfe08b577b48f61af8f008f3d3c25f23fc4c548f3ec45b66684e115809aa862713ea83063e4ac978'
else
  PurposePlatform::Application.config.secret_token = 'abca76af0cc99e8e00904982dab900d9048b7eabeddd7a8312831cbae7287765a4707eded28cd6ef3357518a87b767c5d50d0d8cd9c8dadc1938722e6387dcb4'
end