module WebToPayHelper
  def macro_form(params, &block)
    fields = {
        :orderid => "1", :lang => 'LIT', :amount => 0, :currency => 'LTL',
        :projectid => WebToPay.config.project_id,
        :sign_password => WebToPay.config.sign_password,
        :test => 0
    }

    fields.merge!(params)

    request = WebToPay::Api.build_request(fields)

    html = "<form action=\"https://www.mokejimai.lt/pay/\" method=\"post\" style=\"padding:0px;margin:0px\">"
    request.each_pair do |field_name, field_value|
      html << hidden_field_tag(field_name, field_value) unless field_value.nil?
    end
    html << capture(&block) if block_given?

    html << "</form>"
    html.html_safe
  end
end

