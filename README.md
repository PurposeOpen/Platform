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

`SPREEDLY_501C3_ENV_KEY`
`SPREEDLY_501C3_APP_ACCESS_SECRET`
`SPREEDLY_501C4_ENV_KEY`
`SPREEDLY_501C4_APP_ACCESS_SECRET`

The Spreedly account should be built with 2 environments: one for 501-c-3 gateways and
transactions and one for 501-c-4s. On the donation form, we check the
`content_module.classification` attribute, and pass that value
(`501-c-3` or `501-c-4`) to Spreedly as
an additional parameter on the transaparent redirect.

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
