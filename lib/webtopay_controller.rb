module WebToPayController  
  module ClassMethods
    def webtopay(*actions)
      options = actions.any? ? { only: actions } : {}
      before_filter :webtopay_check, options
      
      attr_reader :webtopay_response
    end
  end
  
  def self.included(controller)
    controller.extend(ClassMethods)
  end
  
  def webtopay_check
    begin
      
      @webtopay_response = WebToPay::Api.check_response(request.query_string, {
        :projectid      => WebToPay.config.project_id,
        :sign_password  => WebToPay.config.sign_password
      })
      
    rescue WebToPay::Exception => e
      render :text => e.message, :status => 500
    end 
  end
end
