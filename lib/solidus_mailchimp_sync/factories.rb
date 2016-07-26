FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'solidus_mailchimp_sync/factories'
end


FactoryGirl.modify do
  factory :order do
    factory :order_with_line_items do
      # This custom factory is from Solidus master at:
      # https://github.com/solidusio/solidus/blob/3a0bbb63338b31c308a7d26205c4b21f9baed85a/core/lib/spree/testing_support/factories/order_factory.rb#L55
      # But was not yet included in a solidus release, and we need it.
      factory :order_ready_to_complete do
        state 'confirm'
        payment_state 'checkout'

        transient do
          payment_type :credit_card_payment
        end

        after(:create) do |order, evaluator|
          create(evaluator.payment_type, {
            amount: order.total,
            order: order,
            state: order.payment_state
          })

          order.payments.reload
        end
      end
    end
  end
end
