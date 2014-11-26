module WebToPayHelper
  def webtopay_confirm_button(text, params_or_payment, button_options = {}, form_options = {}, sign_password = nil)
    fields = { :lang => 'LIT', :currency => 'LTL', :projectid => WebToPay.config.project_id, :test => 0 }

    if params_or_payment.is_a?(Hash)
      fields = fields.merge(params_or_payment)
      payment = WebToPay::Payment.new(fields, sign_password: sign_password || WebToPay.config.sign_password)
    else
      payment = params_or_payment
      fields.each_pair do |field, value|
        payment.public_send("#{field}=", value) if payment.public_send(field).nil?
      end
    end

    content_tag(:form, {action: 'https://www.mokejimai.lt/pay/', method: :post}.merge(form_options)) do
      html = ''
      html << hidden_field_tag(:data, payment.data)
      html << hidden_field_tag(:sign, payment.sign)
      html << submit_tag(text, button_options)
      html.html_safe
    end
  end
end
