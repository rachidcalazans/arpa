require "ar/version"
require "ar/entities/resource"
require "ar/entities/action"
require "ar/entities/role"
require "ar/entities/profile"

module Ar
  I18n.config.enforce_available_locales = true
  I18n.load_path << File.expand_path('../config/locales/ar.en.yml', __FILE__)
  I18n.reload!
end
