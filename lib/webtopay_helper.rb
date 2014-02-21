module WebToPayHelper
  def webtopay_form(params_or_request, form_options = {}, &block)
    fields = { :lang => 'LIT', :currency => 'LTL', :projectid => WebToPay.config.project_id, :test => 0 }

    if params_or_request.is_a(Hash)
      fields = fields.merge(params_or_request)
      request = WebToPay::ApiRequest.new(fields, sign_password: WebToPay.config.sign_password)
    else
      request = params_or_request
    end

    content_tag(:form, {action: webtopay_url, method: :post}.merge(form_options)) do
      html = ''
      WebToPay::ApiRequest::ATTRIBUTES.each do |field_name|
        field_value = request.public_send(field_name)
        html << hidden_field_tag(field_name, field_value) unless field_value.nil?
      end
      html << hidden_field_tag(:sign, request.sign)
      html << capture(&block) if block_given?
      html.html_safe
    end
  end

  def webtopay_url
    'https://www.mokejimai.lt/pay/'
  end
end

