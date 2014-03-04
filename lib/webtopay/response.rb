class WebToPay::Response
  PREFIX = "wp_"
  SPECS_BY_TYPE = {
      # Array structure:
      # * name       – request item name.
      # * maxlen     – max allowed value for item.
      # * required   – is this item is required in response.
      # * mustcheck  – this item must be checked by user.
      # * isresponse – if false, item must not be included in response array.
      # * regexp     – regexp to test item value.
      makro: [
          [ :projectid,       11,     true,   true,   true,  /^\d+$/ ],
          [ :orderid,         40,     false,  false,  true,  '' ],
          [ :lang,            3,      false,  false,  true,  /^[a-z]{3}$/i ],
          [ :amount,          11,     false,  false,  true,  /^\d+$/ ],
          [ :currency,        3,      false,  false,  true,  /^[a-z]{3}$/i ],
          [ :payment,         20,     false,  false,  true,  '' ],
          [ :country,         2,      false,  false,  true,  /^[a-z]{2}$/i ],
          [ :paytext,         0,      false,  false,  true,  '' ],
          [ :ss2,             0,      true,   false,  true,  '' ],
          [ :ss1,             0,      false,  false,  true,  '' ],
          [ :name,            255,    false,  false,  true,  '' ],
          [ :surename,        255,    false,  false,  true,  '' ],
          [ :status,          255,    false,  false,  true,  '' ],
          [ :error,           20,     false,  false,  true,  '' ],
          [ :test,            1,      false,  false,  true,  /^[01]$/ ],
          [ :p_email,         0,      false,  false,  true,  '' ],
          [ :payamount,       0,      false,  false,  true,  '' ],
          [ :paycurrency,     0,      false,  false,  true,  '' ],
          [ :version,         9,      true,   false,  true,  /^\d+\.\d+$/ ],
          [ :sign_password,   255,    false,  true,   false, '' ]
      ],

      # Specification array for mikro response.
      #
      # Array structure:
      # * name       – request item name.
      # * maxlen     – max allowed value for item.
      # * required   – is this item is required in data.
      # * mustcheck  – this item must be checked by user.
      # * isresponse – if false, item must not be included in response array.
      # * regexp     – regexp to test item value.
      mikro: [
        [ :to,              0,      true,   false,  true,  '' ],
        [ :sms,             0,      true,   false,  true,  '' ],
        [ :from,            0,      true,   false,  true,  '' ],
        [ :operator,        0,      true,   false,  true,  '' ],
        [ :amount,          0,      true,   false,  true,  '' ],
        [ :currency,        0,      true,   false,  true,  '' ],
        [ :country,         0,      true,   false,  true,  '' ],
        [ :id,              0,      true,   false,  true,  '' ],
        [ :_ss2,            0,      true,   false,  true,  '' ],
        [ :_ss1,            0,      true,   false,  true,  '' ],
        [ :test,            0,      true,   false,  true,  '' ],
        [ :key,             0,      true,   false,  true,  '' ],
        #[ :version,         9,      true,   false,  true,  /^\d+\.\d+$/ ]
      ]
  }

  attr_reader :query, :user_data, :errors, :project_id
  attr_accessor :data, :ss1, :ss2

  def initialize(params, user_params = {})
    params.each_pair do |field, value|
      self.public_send("#{field}=", value)
    end
    @sign_password = user_params[:sign_password] || WebToPay.config.sign_password
    @project_id = user_params[:projectid] || WebToPay.config.project_id
    @errors = []
  end

  def query
    @query ||= begin
      data = self.data || ''
      Base64.decode64( data.gsub('-', '+').gsub('_', '/') )
    end
  end

  def query_params
    @query_params ||= begin
      params = CGI::parse(query)
      params.each_pair do |key, value|
        params[key] = value.first
      end
      params.merge(ss1: ss1, ss2: ss2).with_indifferent_access
    end
  end

  def valid?(params = {})
    @errors = []
    params = {
        projectid: @project_id
    }.merge(params)

    valid = custom_params_valid?(params)
    valid &&= ss1_valid?
    valid &&= all_required_fields_included?
    valid &&= no_blacklisted_fields_included?
    valid &&= payment_status_valid?
    valid
  end

  def validate!(params = {})
    raise errors.first unless valid?(params)
  end

  def type
    @type ||= if query_params[:to] && query_params[:from] && query_params[:sms] && query_params[:projectid].nil?
      :mikro
    else
      :makro
    end
  end

  def specs
    SPECS_BY_TYPE[type]
  end

  def mikro?
    type == :mikro
  end

  def makro?
    type == :makro
  end

  private
  def custom_params_valid?(params)
    valid = true
    params.each_pair do |key, expected_value|
      query_value = query_params[key].presence
      if query_value.is_a?(String)
        if expected_value.is_a?(Integer)
          query_value = query_value.to_i
        elsif expected_value.is_a?(Float)
          query_value = query_value.to_f
        end
      end
      if query_value != expected_value
        @errors << WebToPay::Exception.new("\"#{key}\" is invalid. Expected \"#{expected_value}\", but was \"#{query_value}\"")
        valid = false
      end
    end
    valid
  end

  def required_response_fields
    specs.select{|s| s[2]}.map(&:first).map(&:to_sym)
  end

  def blacklisted_response_fields
    specs.reject{|s| s[4]}.map(&:first).map(&:to_sym)
  end

  def all_required_fields_included?
    fields = query_params.keys.map(&:to_sym)
    if (required_response_fields & fields).size != required_response_fields.size
      @errors << WebToPay::Exception.new("\"#{(required_response_fields - fields).join('" , "')}\" parameter(s) not found in response query")
      return false
    end
    true
  end

  def no_blacklisted_fields_included?
    fields = query_params.keys.map(&:to_sym)
    if (blacklisted_response_fields & fields).size != 0
      @errors << WebToPay::Exception.new("\"#{(fields & blacklisted_response_fields).join('" , "')}\" blacklisted parameter(s) found in response query")
      return false
    end
    true
  end

  def ss1_valid?
    if self.ss1 != expected_ss1
      @errors << WebToPay::Exception.new("ss1 param is invalid. Expected \"#{expected_ss1}\", but was \"#{self.ss1}\"")
      return false
    end
    true
  end

  def payment_status_valid?
    if makro? && query_params[:status].to_i != 1
      e = WebToPay::Exception.new("Returned transaction status is #{query_params[:status]}, successful status should be 1.")
      e.code = WebToPay::Exception::E_INVALID
      @errors << e
      return false
    end
    return true
  end

  def expected_ss1
    Digest::MD5.hexdigest(expected_data + @sign_password)
  end

  def expected_data
    Base64.encode64(query).gsub("\n", '').gsub('/', '+').gsub('_', '-')
  end
end