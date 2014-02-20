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
      # * required   – is this item is required in response.
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

      if required && response[name].nil?
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
          if response[name].to_s != user_data[name].to_s
            e = WebToPay::Exception.new("'#{name}' yours and requested value is not equal ('#{user_data[name]}' != '#{response[name]}') ")
            e.code        = WebToPay::Exception::E_INVALID
            e.field_name  = name
            raise e
          end
        end
      end

      if response[name].to_s.present?
        if maxlen > 0 && response[name].to_s.length > maxlen
          e = WebToPay::Exception.new("'#{name}' value '#{response[name]}' is too long, #{maxlen} characters allowed.")
          e.code        = WebToPay::Exception::E_MAXLEN
          e.field_name  = name
          raise e
        end

        if '' != regexp && !response[name].to_s.match(regexp)
          e = new WebToPayException("'#{name}' value '#{response[name]}' is invalid.")
          e.code        = WebToPay::Exception::E_REGEXP
          e.field_name  = name
          raise e
        end
      end

      resp_keys << name unless response[name].nil?
    end

    # *check* response
    if macro? && response[:version] !=
      e = WebToPay::Exception.new("Incompatible library and response versions: libwebtopay #{WebToPay::Api::VERSION}, response #{response[:version]}",)
      e.code = WebToPay::Exception::E_INVALID
      raise e
    end

    orderid   = macro? ? response[:orderid] : response[:id]
    password  = user_data[:sign_password]

    # *check* status
    if macro? && response[:status].to_i != 1
      e = WebToPay::Exception.new("Returned transaction status is #{response[:status]}, successful status should be 1.")
      e.code = WebToPay::Exception::E_INVALID
      raise e
    end

    true
  end

  def response
    @response ||= begin
      resp = {}
      query.split(/&/).each do |item|
        key, val = item.split(/\=/)
        resp[key] = CGI.unescape(val.to_s)
      end
      prefix_response(resp).symbolize_keys!
    end
  end

  def type
    @response_type ||= if response[:to] && response[:from] && response[:sms] && response[:projectid].nil?
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
  def prefix_response(data, prefix = WebToPay::ApiResponse::PREFIX)
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