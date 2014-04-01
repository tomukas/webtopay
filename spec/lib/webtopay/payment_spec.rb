require 'spec_helper'

describe WebToPay::Payment do
  subject{ WebToPay::Payment.new(payment_data, sign_password: sign_password) }
  let(:sign_password){ 'a1b2c3d4e5a1b2c3d4e5a1b2c3d4e5'}
  let(:payment_data) {
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
        'test' => 1,
        'version' => 1.6
    }
  }
  
  its(:query){ should == 'projectid=123456&orderid=654321&lang=LIT&amount=2000&currency=LTL&accepturl=http%3A%2F%2Fexample.com%2Faccept&cancelurl=http%3A%2F%2Fexample.com%2Fcancel&callbackurl=http%3A%2F%2Fexample.com%2Fcallback&country=lt&paytext=Billing+for+XX+at+the+website+XXX&p_email=petras%40example.com&p_name=Jonas&p_surname=Jonaitis&payment=vb2&test=1&version=1.6' }
  its(:data) { should == 'cHJvamVjdGlkPTEyMzQ1NiZvcmRlcmlkPTY1NDMyMSZsYW5nPUxJVCZhbW91bnQ9MjAwMCZjdXJyZW5jeT1MVEwmYWNjZXB0dXJsPWh0dHAlM0ElMkYlMkZleGFtcGxlLmNvbSUyRmFjY2VwdCZjYW5jZWx1cmw9aHR0cCUzQSUyRiUyRmV4YW1wbGUuY29tJTJGY2FuY2VsJmNhbGxiYWNrdXJsPWh0dHAlM0ElMkYlMkZleGFtcGxlLmNvbSUyRmNhbGxiYWNrJmNvdW50cnk9bHQmcGF5dGV4dD1CaWxsaW5nK2ZvcitYWCthdCt0aGUrd2Vic2l0ZStYWFgmcF9lbWFpbD1wZXRyYXMlNDBleGFtcGxlLmNvbSZwX25hbWU9Sm9uYXMmcF9zdXJuYW1lPUpvbmFpdGlzJnBheW1lbnQ9dmIyJnRlc3Q9MSZ2ZXJzaW9uPTEuNg==' }
  its(:sign) { should == '51f7a63b3e43fde47daa0afdb02cdb8f' }

  context 'with underscored attribute names' do
    let(:payment_data) {
      {
          'project_id' => 123456,
          'ord_er_id' => 654321,
          'lang_'    => 'LIT',
          'amo_unt' => 2000,
          'currency' => 'LTL',
          'accept_url' => 'http://example.com/accept',
          'cancel__url' => 'http://example.com/cancel',
          'callback_url' => 'http://example.com/callback',
          '_country' => 'lt',
          'paytext' => 'Billing for XX at the website XXX',
          'pemail' => 'petras@example.com',
          'pname' => 'Jonas',
          'psurname' => 'Jonaitis',
          'pay_ment' => 'vb2',
          'test' => 1,
          'version' => 1.6
      }
    }

    its(:query){ should == 'projectid=123456&orderid=654321&lang=LIT&amount=2000&currency=LTL&accepturl=http%3A%2F%2Fexample.com%2Faccept&cancelurl=http%3A%2F%2Fexample.com%2Fcancel&callbackurl=http%3A%2F%2Fexample.com%2Fcallback&country=lt&paytext=Billing+for+XX+at+the+website+XXX&p_email=petras%40example.com&p_name=Jonas&p_surname=Jonaitis&payment=vb2&test=1&version=1.6' }
    its(:data) { should == 'cHJvamVjdGlkPTEyMzQ1NiZvcmRlcmlkPTY1NDMyMSZsYW5nPUxJVCZhbW91bnQ9MjAwMCZjdXJyZW5jeT1MVEwmYWNjZXB0dXJsPWh0dHAlM0ElMkYlMkZleGFtcGxlLmNvbSUyRmFjY2VwdCZjYW5jZWx1cmw9aHR0cCUzQSUyRiUyRmV4YW1wbGUuY29tJTJGY2FuY2VsJmNhbGxiYWNrdXJsPWh0dHAlM0ElMkYlMkZleGFtcGxlLmNvbSUyRmNhbGxiYWNrJmNvdW50cnk9bHQmcGF5dGV4dD1CaWxsaW5nK2ZvcitYWCthdCt0aGUrd2Vic2l0ZStYWFgmcF9lbWFpbD1wZXRyYXMlNDBleGFtcGxlLmNvbSZwX25hbWU9Sm9uYXMmcF9zdXJuYW1lPUpvbmFpdGlzJnBheW1lbnQ9dmIyJnRlc3Q9MSZ2ZXJzaW9uPTEuNg==' }
    its(:sign) { should == '51f7a63b3e43fde47daa0afdb02cdb8f' }
  end

end