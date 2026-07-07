# user wallet
## signer
A signer is a cryptographic identity authorized to approve actions on a Crossmint wallet. Signers are the control layer of the dual-layer architecture — they determine who can authorize transactions, add new signers, or recover a wallet.
Every wallet has at least one signer, and most wallets have two: one for day-to-day operations and one for recovery.

## recovery
ecovery is the process of regaining signing access to a wallet when the original signer is no longer available. The most common trigger is a user switching to a new device — the device signer on the old phone or laptop cannot be transferred, so the user must authenticate with their recovery signer and enroll a new device key.

* we user sever side signer for transaction
    user can not signed transaction

* signer_secret and recovery_secret are sever side signer

## custody models
Custody determines who holds the cryptographic keys that control a wallet. In traditional finance, custody is binary — either the institution holds the assets or the customer does. In blockchain-based systems, custody is more nuanced because key management, transaction authorization, and asset storage can be separated across multiple parties.

* user wallet: non custodial :user point of view. - quicksend has acces and is the owner of the wallet , so quicksend point of view: wallet is custodial. QuickSend is  the custodian not crossmint

## wallet locator
A wallet locator is a string that identifies a specific wallet across all Crossmint APIs and SDKs. Instead of tracking raw blockchain addresses, you reference wallets by a user identity (email, user ID, phone number, or social handle) combined with chain and wallet type information.

* we use user id
### User Type
The user type specifies how the wallet owner is identified. You can use an email, your app’s internal user ID, a phone number, a social handle, or the me shorthand for client-side contexts. You can also pass a raw wallet address directly.

User type	Description	Example
email	Email address	email:alice@example.com
userId	Your app’s internal user ID or a DID	userId:507f1f77bcf86cd799439011
phoneNumber	Phone number in E.164 format	phoneNumber:+12125551234
twitter	Twitter/X handle	twitter:johndoe
x	Alias for twitter	x:johndoe
me	Authenticated user (client-side only)	me

* we use userId type