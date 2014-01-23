## The Purpose Platform

The Purpose Platform is a global open source project committed to building multilingual campaigning and organizing tools for social good.

### [Getting Started](https://github.com/PurposeOpen/Platform/wiki/Getting-Started)

### [How to Contribute](https://github.com/PurposeOpen/Platform/wiki/How-to-Contribute)

### [License](https://github.com/PurposeOpen/Platform/wiki/License)


### Community
- [Developer Discussion Group](http://groups.google.com/group/purpose-platform-dev)
- [General Discussion Group](http://groups.google.com/group/purpose-platform-general)

## Spreedly
Spreedly vaults credit card information, simplifies PCI compliance, and
supports international payment gateways.

### Environment variables
Spreedly expects the following environment variables to be set:

```
SPREEDLY_501C3_ENV_KEY
SPREEDLY_501C3_APP_ACCESS_SECRET
SPREEDLY_501C4_ENV_KEY
SPREEDLY_501C4_APP_ACCESS_SECRET
```

The Spreedly account should be built with 2 environments: one for 501-c-3 gateways and
transactions and one for 501-c-4s. On the donation form, we check the
`content_module.classification` attribute, and pass that value
(`501-c-3` or `501-c-4`) to Spreedly as
an additional parameter on the [transaparent
redirect](http://docs.spreedly.com/payment-methods/adding-with-redirect#using-the-redirect-url) to determine which Spreedly environment to use.

### Payment Gateways
Spreedly allows for multiple payment gateways. Each gateway has a token,
which must me passed when making purchases.

The gateway tokens are currently stored with other application constants in
`config/constants.yml`. The application determines which gateway gets
used in `SpreedlyClient#get_gateway_token` via the donation currency.

Each gateway requires different credentials. Spreedly provides
[documentation](http://docs.spreedly.com/gateways/adding) for adding a new gateway to the
application. The `gateway_token` that gets returned should be added to the
`config/constants.yml` for the given currency.

## Post-Recurly Migration
Per Spreedly, when the credit cards are transferred from Recurly to
Spreedly, the recurly_id will be retained and mapped to the Spreedly
payment_method_token. This relationship will be made available via a
JSON file that Spreedly will provide.

All active, recurring donations should be updated with their respective
Spreedly payment_method_tokens. 

**Active, recurring donations for which you'd like to enqueue recurring
payments for must have the following attributes set:**
* `classification` - (`501-c-3` or `501-c-4`) is required by `SpreedlyClient#initialize` to create the correct Spreedly environment.
* `currency` - will be required when the purchase is attempted on
  Spreedly
* `frequency` - `one_off`, `weekly`, `monthly`, `annual`
* `last_donated_at` - will be used to que up the next recurring payment for the given donation.
* `payment_method_token` - will be used to pull down the credit card
  details and execute purchases
* `subscription_amount` - the `amount_in_cents` of each recurring
  payment


### Donation#update_credit_card_via_spreedly
Once the donation's `classification`, `last_updated_at`, and
`payment_method_token` attributes are set, the donation's credit card
information (which is required to execute a payment on a recurring
donation) can be set via `Donation#update_credit_card_via_spreedly`.
Once this is complete, a donation is ready to be enqueued for recurring
payments.

### Donation.enqueue_recurring_payments_from_recurly
`Donation.enqueue_recurring_payments_from_recurly` is a temporary class
method which can be called to schedule the next payment for donations
which have been migrated from Recurly to Spreedly. For the donation to
be enqueued for payment, it must be:
* active
* recurring
* have `last_donated_at` set
* have `payment_method_token` set
