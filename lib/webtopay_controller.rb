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
    begin
      api_response = WebToPay::ApiResponse.new(request.query_string, {
          :projectid      => WebToPay.config.project_id,
          :sign_password  => WebToPay.config.sign_password
      })

      api_response.validate!

    rescue WebToPay::Exception => e
      render :text => e.message, :status => 500
    end 
  end
end
