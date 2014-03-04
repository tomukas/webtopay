module WebToPayController  
  module ClassMethods
    def webtopay(*actions)
      options = actions.any? ? { only: actions } : {}
      before_filter :webtopay, options
      
      attr_reader :webtopay_response
    end
  end
  
  def self.included(controller)
    controller.extend(ClassMethods)
  end
  
  def webtopay
    api_response = WebToPay::Response.new( params.slice(:data, :ss1, :ss2) )
    expected_params = webtopay_expected_params( api_response.query_params.clone )
    if not api_response.valid?(expected_params)
      webtopay_failed_validation_response(api_response)
    end
  end

  def webtopay_expected_params(webtopay_params)
    {}
  end

  def webtopay_failed_validation_response(api_response)
    raise api_response.errors.first
  end
end
