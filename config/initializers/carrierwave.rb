CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAIT3OS6IAD6J5S5EQ',
    :aws_secret_access_key  => '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'
  }
  if Rails.env.development?
    config.fog_directory  = 'skaroommusic-dev'
  else
    config.fog_directory  = 'skaroommusic'
  end
  config.fog_public     = false
  config.fog_use_ssl_for_aws     = false
end