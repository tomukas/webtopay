require 'spec_helper'

describe WebToPay::Api do
  subject{ WebToPay::Api }
  let(:request_data) {
    {
        'projectid' => 123456,
        'orderid' => 654321,
        'lang'    => 'LIT',
        'amount' => 2000,
        'currency' => 'LTL',
        'accepturl' => 'http://example.com/accept',
        'cancelurl' => 'http://example.com/cancel',
        'callbackurl' => 'http://example.com/callback',
        'country' => 'lt',
        'paytext' => 'Billing for XX at the website XXX',
        'p_email' => 'petras@example.com',
        'p_name' => 'Jonas',
        'p_surname' => 'Jonaitis',
        'payment' => 'vb2',
        'test' => 1
    }
  }
  let(:password) { 'a1b2c3d4e5a1b2c3d4e5a1b2c3d4e5'}

  describe '.build_query' do
    it 'should be correct' do
      subject.build_query(request_data).should == 'projectid=123456&orderid=654321&lang=LIT&amount=2000&currency=LTL&accepturl=http%3A%2F%2Fexample.com%2Faccept&cancelurl=http%3A%2F%2Fexample.com%2Fcancel&callbackurl=http%3A%2F%2Fexample.com%2Fcallback&country=lt&paytext=Billing+for+XX+at+the+website+XXX&p_email=petras%40example.com&p_name=Jonas&p_surname=Jonaitis&payment=vb2&test=1'
    end
  end

  describe '.base64_encode' do
    let(:query){
      subject.build_query(request_data)
    }
    it 'should be correct' do
      subject.base64_encode(query).should == 'cHJvamVjdGlkPTEyMzQ1NiZvcmRlcmlkPTY1NDMyMSZsYW5nPUxJVCZhbW91bnQ9MjAwMCZjdXJyZW5jeT1MVEwmYWNjZXB0dXJsPWh0dHAlM0ElMkYlMkZleGFtcGxlLmNvbSUyRmFjY2VwdCZjYW5jZWx1cmw9aHR0cCUzQSUyRiUyRmV4YW1wbGUuY29tJTJGY2FuY2VsJmNhbGxiYWNrdXJsPWh0dHAlM0ElMkYlMkZleGFtcGxlLmNvbSUyRmNhbGxiYWNrJmNvdW50cnk9bHQmcGF5dGV4dD1CaWxsaW5nK2ZvcitYWCthdCt0aGUrd2Vic2l0ZStYWFgmcF9lbWFpbD1wZXRyYXMlNDBleGFtcGxlLmNvbSZwX25hbWU9Sm9uYXMmcF9zdXJuYW1lPUpvbmFpdGlzJnBheW1lbnQ9dmIyJnRlc3Q9MQ=='
    end
  end

  describe '.sign' do
    let(:query){
      subject.build_query(request_data)
    }

    let(:encoded_query) {
      subject.base64_encode(query)
    }

    it 'should be correct' do
      subject.sign(encoded_query, password).should == '723363940189b2b0536fa5adbda044de'
    end
  end
end