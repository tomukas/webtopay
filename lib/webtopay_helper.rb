module WebToPayHelper
  def webtopay_confirm_button(text, params_or_request, button_options = {}, form_options = {})
    fields = { :lang => 'LIT', :currency => 'LTL', :projectid => WebToPay.config.project_id, :test => 0 }

    if params_or_request.is_a?(Hash)
      fields = fields.merge(params_or_request)
      request = WebToPay::Payment.new(fields, sign_password: WebToPay.config.sign_password)
    else
      request = params_or_request
      fields.each_pair do |field, value|
        request.public_send("#{field}=", value) if request.public_send(field).nil?
      end
    end

    content_tag(:form, {action: 'https://www.mokejimai.lt/pay/', method: :post}.merge(form_options)) do
      html = ''
      WebToPay::Payment::ATTRIBUTES.each do |field_name|
        field_value = request.public_send(field_name)
        html << hidden_field_tag(field_name, field_value) unless field_value.nil?
      end
      html << hidden_field_tag(:data, request.data)
      html << hidden_field_tag(:sign, request.sign)
      html << submit_tag(text, button_options)
      html.html_safe
    end
  end
end