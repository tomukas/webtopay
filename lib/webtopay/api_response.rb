class WebToPay::ApiResponse
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
          [ :_ss2,            0,      true,   false,  true,  '' ],
          [ :_ss1,            0,      false,  false,  true,  '' ],
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

  attr_reader :query, :user_data

  def initialize(query, user_data = {})
    @query = query
    @user_data = user_data.symbolize_keys!
  end

  def validate!

    resp_keys = []

    specs.each do |spec|
      name, maxlen, required, mustcheck, is_response, regexp = spec

      if required && data[name].nil?
        e             = WebToPay::Exception.new("'#{name}' is required but missing.")
        e.code        = WebToPay::Exception::E_MISSING
        e.field_name  = name
        raise e
      end

      if mustcheck
        if user_data[name].nil?
          e             = WebToPay::Exception.new("'#{name}' must exists in array of second parameter of checkResponse() method.")
          e.code        = WebToPay::Exception::E_USER_PARAMS
          e.field_name  = name
          raise e
        end

        if is_response
          if data[name].to_s != user_data[name].to_s
            e = WebToPay::Exception.new("'#{name}' yours and requested value is not equal ('#{user_data[name]}' != '#{data[name]}') ")
            e.code        = WebToPay::Exception::E_INVALID
            e.field_name  = name
            raise e
          end
        end
      end

      if data[name].to_s.present?
        if maxlen > 0 && data[name].to_s.length > maxlen
          e = WebToPay::Exception.new("'#{name}' value '#{data[name]}' is too long, #{maxlen} characters allowed.")
          e.code        = WebToPay::Exception::E_MAXLEN
          e.field_name  = name
          raise e
        end

        if '' != regexp && !data[name].to_s.match(regexp)
          e = new WebToPayException("'#{name}' value '#{data[name]}' is invalid.")
          e.code        = WebToPay::Exception::E_REGEXP
          e.field_name  = name
          raise e
        end
      end

      resp_keys << name unless data[name].nil?
    end

    # *check* data
    if macro? && data[:version] !=
      e = WebToPay::Exception.new("Incompatible library and data versions: libwebtopay #{WebToPay::Api::VERSION}, data #{data[:version]}",)
      e.code = WebToPay::Exception::E_INVALID
      raise e
    end

    orderid   = macro? ? data[:orderid] : data[:id]
    password  = user_data[:sign_password]

    # *check* status
    if macro? && data[:status].to_i != 1
      e = WebToPay::Exception.new("Returned transaction status is #{data[:status]}, successful status should be 1.")
      e.code = WebToPay::Exception::E_INVALID
      raise e
    end

    true
  end

  def data
    @data ||= begin
      response = {}
      query.split(/&/).each do |item|
        key, val = item.split(/\=/)
        response[key] = CGI.unescape(val.to_s)
      end
      prefix_data(response).symbolize_keys!
    end
  end

  def type
    @type ||= if data[:to] && data[:from] && data[:sms] && data[:projectid].nil?
      :mikro
    else
      :makro
    end
  end

  def specs
    WebToPay::ApiResponse::SPECS_BY_TYPE[type]
  end

  def mikro?
    type == :mikro
  end

  def makro?
    type == :makro
  end

  private
  def prefix_data(data, prefix = WebToPay::ApiResponse::PREFIX)
    return data if prefix.to_s.blank?

    ret = {}
    reg = /^#{prefix}/

    data.stringify_keys!

    data.each_pair do |key, val|
      if key.length > prefix.length && key.match(reg)
        ret[key.gsub(reg, '')] = val
      end
    end

    ret
  end
end