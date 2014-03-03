require 'webtopay/exception'
require 'webtopay/configuration'
require 'webtopay/payment'
require 'webtopay/response'
require 'webtopay_controller'
require 'webtopay_helper'

module WebToPay
  API_VERSION = '1.6'

  class << self
    attr_accessor :config

    def configure
      self.config ||= Configuration.new
      yield(config)
    end
  end
end

ActionController::Base.send(:include, WebToPayController)
ActionView::Base.send(:include, WebToPayHelper)