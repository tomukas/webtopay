# WebToPay

It is a gem which could be very useful on working with https://www.webtopay.com/ (https://www.mokejimai.lt/) billing system.
The main function of this gem is protection against forgeries that could be done by sending required parameters to the application and getting services without paying for free.
This gem could be integrated with both billing types - MACRO (VISA, MasterCard, banks etc.) and MICRO (SMS, phone calls etc.).

*It works with OpenSSL so be sure that you have installed all necessary libs or modules on your system.

## Installation

Add to your gemfile:

```ruby
gem "webtopay", github: 'bloomrain'
```

## Configuration

Create initializer
config/initializers/webtopay.rb

```ruby
WebToPay.configure do |config|
  config.project_id     = 00000
  config.sign_password  = 'your sign password'
end
```

## Usage

Add this to your controller:
```ruby
  webtopay :controller_method1, :controller_method2 ...
```

Or you can add this (it does the same as above):
```ruby
  before_filter :webtopay, only:[:controller_method1, :controller_method2] ...
```

## Examples

These code slices will protect your controller actions, which work with webtopay.com billing, against forgeries.

### Usage for MICRO and MACRO billing on controller.

```ruby
  webtopay :activate_user, :confirm_cart # You can add here as many actions as you want

  def activate_user
    # write here code which do some stuff
    render :text => "Your user has been successfully activated. Thank you!" # it sends SMS answer
  end
  
  def confirm_cart
    # write here code which do some stuff
    render :text => "ok" # it sends successful answer to webtopay.com crawler
  end
```

### Payment form

You can generate payment form like this

```erb
<%= form_for WebToPay::Payment.new, url: order_products_path do |f| %>
  <%= f.text_field :p_name %>
  <%= f.text_field :p_surname %>
  <%= f.text_field :p_email %>
  ... any other fields you like (for complete field list please read mokejimai.lt api specification) ...
  <%= f.submit "test paying" %>
<% end %>
```

Then in your controller
```ruby
  class ProductsController < ApplicationController
    def order
      # do some order stuff here ...
      @payment = WebToPay::Payment(params[:web_to_pay_payment])
      redirect_to @payment.url
    end
  end
```


TODO
===========

1. Write more clear documentation with real examples
2. Write unit tests for each billing method (requires some testing data from https://www.webtopay.com/)
3. Validate Api request by ss2 param

===========
Copyright (c) 2009 Kristijonas Urbaitis, released under the MIT license
