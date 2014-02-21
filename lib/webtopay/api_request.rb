class WebToPay::ApiRequest
  VERSION = '1.6'

  ATTRIBUTES = [:projectid, :orderid, :lang, :amount, :currency, :accepturl, :cancelurl, :callbackurl,
                :country, :paytext, :p_email, :p_name, :p_surname, :payment, :test, :version]
  attr_accessor *ATTRIBUTES

  def initialize(params, user_params = {})
    self.version = WebToPay::ApiRequest::VERSION
    self.projectid = WebToPay.config.project_id
    @sign_password = user_params[:sign_password] || WebToPay.config.sign_password

    params.each_pair do |field, value|
      self.public_send("#{field}=", value)
    end
  end

  def query
    @query ||= begin
      query = []
      (ATTRIBUTES - [:version]).each do |field|
        value = self.public_send(field)
        next if value.blank?
        query << "#{field}=#{ CGI::escape value.to_s}"
      end
      query.join('&')
    end
  end

  def encoded_query
    @encoded_query ||= Base64.encode64(query).gsub("\n", '').gsub('/', '+').gsub('_', '-')
  end

  def sign
    Digest::MD5.hexdigest(encoded_query + @sign_password)
  end
end