<!-- Links to terms used in this document (case-insensitive alphabetic order)
---- * Link text is case insensitive in markdown so [Block Chain] and
----   [block chain] are equivalent
---- * If nothing uses one of the below reference links, the reference
----   link must be commented out or it will appear in the rendered page
-->

[51 percent attack]: /en/developer-guide#term-51-attack "The ability of someone controlling a majority of hashing power to revise transactions history and prevent new transactions from confirming"
[accidental fork]: /en/developer-guide#term-accidental-fork "When two or more blocks have the same block height, forking the block chain.  Happens occasionally by accident"
[addresses]: /en/developer-guide#term-address "A 20-byte hash formatted as a P2PH or P2SH Bitcoin Address"
[address]: /en/developer-guide#term-address "A 20-byte hash formatted as a P2PH or P2SH Bitcoin Address"
[base58Check]: /en/developer-guide#term-base58check "The method used in Bitcoin for converting 160-bit hashes into Bitcoin addresses"
[bitcoin URI]: /en/developer-guide#term-bitcoin-uri "A URI which allows receivers to encode payment details so spenders don't have to manually enter addresses and other details"
[bitcoins]: /en/developer-guide#term-bitcoins "A primary accounting unit used in Bitcoin; 100 million satoshis"
[block]: /en/developer-guide#term-block "A block of transactions protected by proof of work"
[blocks]: /en/developer-guide#term-block "Blocks of transactions protected by proof of work"
[block chain]: /en/developer-guide#block-chain "A chain of blocks with each block linking to the block that preceded; the most-difficult-to-recreate chain is The Block Chain"
[block header]: /en/developer-guide#block-header "An 80-byte header belonging to a single block which is hashed repeatedly to create proof of work"
[block header magic]: /en/developer-guide#term-block-header-magic "A magic number used to separate block data from transaction data on the P2P network"
[block height]: /en/developer-guide#term-block-height "The number of chained blocks preceding this block"
[block reward]: /en/developer-guide#term-block-reward "New satoshis given to a miner for creating one of the first 6,929,999 blocks"
[block time]: /en/developer-guide#term-block-time "The time field in the block header"
[block version]: /en/developer-guide#term-block-version "The version field in the block header"
[broadcast]: /en/developer-guide#FIXME-P2P "Sending transactions or blocks to all other peers on the Bitcoin network (compare to privately transmitting to a single peer or partner"
[broadcasts]: /en/developer-guide#FIXME-P2P "Sending transactions or blocks to all other peers on the Bitcoin network (compare to privately transmitting to a single peer or partner"
[broadcasting]: /en/developer-guide#FIXME-P2P "Sending transactions or blocks to all other peers on the Bitcoin network (compare to privately transmitting to a single peer or partner)"
[certificate chain]: /en/developer-guide#term-certificate-chain "A chain of certificates connecting a individual's leaf certificate to the certificate authority's root certificate"
[chain code]: /en/developer-guide#term-chain-code "In HD wallets, 32 bytes of entropy added to the master public and private keys to help them generate secure child keys; the chain code is usually derived from a seed along with the master private key"
[change address]: /en/developer-guide#term-change-output "An output used by a spender to send back to himself some of the satoshis from the inputs"
[change output]: /en/developer-guide#term-change-output "An output used by a spender to send back to himself some of the satoshis from the inputs"
[child extended key]: /en/developer-guide#term-child-extended-key "A child key extended so that it can become a parent key and derive its own child keys"
[child key]: /en/developer-guide#term-child-key "In HD wallets, a key derived from a parent key"
[child public key]: /en/developer-guide#term-child-public-key "In HD wallets, a public key derived from a parent public key or a child private key"
[coinbase field]: /en/developer-guide#term-coinbase-field "A special input-like field for coinbase transactions"
[coinbase transaction]: /en/developer-guide#term-coinbase-tx "A special transaction which miners must create when they generate a block"
[confirm]: /en/developer-guide#term-confirmation "A transaction included in a block currently on the block chain"
[confirmed]: /en/developer-guide#term-confirmation "A transaction included in a block currently on the block chain"
[confirmed transactions]: /en/developer-guide#term-confirmation "Transactions included in a block currently on the block chain"
[confirmation]: /en/developer-guide#term-confirmation "The number of blocks which would need to be modified to remove or modify a transaction"
[confirmations]: /en/developer-guide#term-confirmation "The number of blocks which would need to be modified to remove or modify a transaction"
[denomination]: /en/developer-guide#term-denomination "bitcoins (BTC), bitcents (cBTC), millibits (mBTC), microbits (uBTC), or satoshis"
[difficulty]: /en/developer-guide#term-difficulty "A number corresponding to the target threshold which indicates how difficult it will be to find the next block"
[double spend]: /en/developer-guide#term-double-spend "Attempting to spend the same satoshis which were spent in a previous transaction"
[extended key]: /en/developer-guide#term-extended-key "A public or private key extended with the chain code, which adds an extra 32 bytes of entropy"
[extended private key]: /en/developer-guide#term-extended-private-key "A private key extended with the chain code, which adds an extra 32 bytes of entropy"
[extended public key]: /en/developer-guide#term-extended-public-key "A public key extended with the chain code, which adds an extra 32 bytes of entropy "
[external chain]: /en/developer-guide#term-external-chain "A default subdivision in HD wallet accounts used for public P2PH addresses and other public keys used by other people"
[escrow contract]: /en/developer-guide#term-escrow-contract "A contract in which the spender and receiver store satoshis in a multisig output until both parties agree to release the satoshis"
[fiat]: /en/developer-guide#term-fiat "National currencies such as the dollar or euro"
[genesis block]: /en/developer-guide#term-genesis-block "The first block created; also called block 0"
[hardened child key]: /en/developer-guide#term-hardened-child-key "In an HD wallet, a child key which can only be derived from a parent private key; it cannot be derived from a parent public key"
[HD account]: /en/developer-guide#term-hd-account "A sub-chain of the master chain in an HD wallet"
[header nonce]: /en/developer-guide#term-header-nonce "Four bytes of arbitrary data in a block header used to let miners create headers with different hashes for proof of work"
[high-priority transactions]: /en/developer-guide#term-high-priority-transactions "Transactions which don't pay a transaction fee; only transactions spending long-idle outputs are eligible"
[input]: /en/developer-guide#term-input "The input to a transaction linking to the output of a previous transaction which permits spending of satoshis"
[inputs]: /en/developer-guide#term-input "The input to a transaction linking to the output of a previous transaction which permits spending of satoshis"
[internal chain]: /en/developer-guide#term-internal-chain "A default subdivision in HD wallet accounts used for change addresses and other self-created transactions"
[intermediate certificate]: /en/developer-guide#term-intermediate-certificate "A intermediate certificate authority certificate which helps connect a leaf (receiver) certificate to a root certificate authority"
[key fingerprint]: /en/developer-guide#term-key-fingerprint "The first 32 bits of an extended key (not including the chain code) used to identify the extended key" 
[key index]: /en/developer-guide#term-key-index "An index number used in the HD wallet formula to generate child keys from a parent key" 
[key pair]: /en/developer-guide#term-key-pair "A private key and its derived public key"
[label]: /en/developer-guide#term-label "The label parameter of a bitcoin: URI which provides the spender with the receiver's name (unauthenticated)" 
[leaf certificate]: /en/developer-guide#term-leaf-certificate "The end-node in a certificate chain; in the payment protocol, it is the certificate belonging to the receiver of satoshis"
[locktime]: /en/developer-guide#term-locktime "Part of a transaction which indicates the earliest time or earliest block when that transaction can be added to the block chain"
[long-term fork]: /en/developer-guide#term-long-term-fork "When a series of blocks have corresponding block heights, indicating a possibly serious problem"
[mainnet]: /en/developer-guide#FIXME-Intro "The Bitcoin main network used to transfer satoshis (compare to testnet, the test network)"
[master key]: /en/developer-guide#term-master-key "In an HD wallet, top-level private key extended by the chaincode; master keys are usually generated by a seed"
[merge]: /en/developer-guide#term-merge "Spending, in the same transaction, multiple outputs which can be traced back to different previous spenders, leaking information about how many satoshis you control"
[merge avoidance]: /en/developer-guide#term-merge-avoidance "A strategy for selecting which outputs to spend that avoids merging outputs with different histories that could leak private information"
[message]: /en/developer-guide#term-message "A parameter of bitcoin: URIs which allows the receiver to optionally specify a message to the spender"
[Merkle root]: /en/developer-guide#term-merkle-root "The root node of a Merkle tree descended from all the hashed pairs in the tree"
[Merkle tree]: /en/developer-guide#term-merkle-tree "A tree constructed by hashing paired data, then pairing and hashing the results until a single hash remains, the Merkle root"
[micropayment channel]: /en/developer-guide#term-micropayment-channel
[millibits]: /en/developer-guide#term-millibits "0.001 bitcoins (100,000 satoshis)"
[mine]: /en/developer-guide#term-miner "Creating Bitcoin blocks which solve proof-of-work puzzles in exchange for block rewards and transaction fees"
[miner]: /en/developer-guide#term-miner "Creators of Bitcoin blocks who solve proof-of-work puzzles in exchange for block rewards and transaction fees"
[miners]: /en/developer-guide#term-miner "Creators of Bitcoin blocks who solve proof-of-work puzzles in exchange for block rewards and transaction fees"
[minimum fee]: /en/developer-guide#term-minimum-fee "The minimum fee a transaction must pay in must circumstances to be mined or broadcast by peers across the network"
[multisig]: /en/developer-guide#term-multisig "An output script using OP_CHECKMULTISIG to check for multiple signatures"
[network]: /en/developer-guide#FIXME-P2P "The Bitcoin P2P network which broadcasts transactions and blocks"
[normal child key]: /en/developer-guide#term-normal-child-key "A standard public or private Bitcoin key which was derived from an extended key"
[Null data]: /en/developer-guide#term-null-data "A standard transaction type which allows adding 40 bytes of arbitrary data to the block chain up to once per transaction"
[op_checkmultisig]: /en/developer-guide#term-op-checkmultisig "Op code which returns true if one or more provided signatures (m) sign the correct parts of a transaction and match one or more provided public keys (n)"
[op_checksig]: /en/developer-guide#term-op-checksig "Op code which returns true if a signature signs the correct parts of a transaction and matches a provided public key"
[op code]: /en/developer-guide#op-codes "Operation codes which run functions within a script"
[op_dup]: /en/developer-guide#term-op-dup "Operation which duplicates the entry below it on the stack"
[op_equal]: /en/developer-guide#term-op-equal "Operation which returns true if the two entries below it on the stack are equivalent"
[op_equalverify]: /en/developer-guide#term-op-equalverify "Operation which terminates the script in failure unless the two entries below it on the stack are equivalent"
[op_hash160]: /en/developer-guide#term-op-hash160 "Operation which converts the entry below it on the stack into a RIPEMD(SHA256()) hashed version of itself"
[op_return]: /en/developer-guide#term-op-return "Operation which terminates the script in failure"
[op_verify]: /en/developer-guide#term-op-verify "Operation which terminates the script if the entry below it on the stack is non-true (zero)"
[orphan]: /en/developer-guide#term-orphan "Blocks which were successfully mined but which aren't included on the current valid block chain"
[output]: /en/developer-guide#term-output "The output of a transaction which transfers value to a script"
[output index]: /en/developer-guide#term-output-index "The sequentially-numbered index of outputs in a single transaction starting from 0"
[outputs]: /en/developer-guide#term-output "The outputs of a transaction which transfer value to scripts"
[P2PH]: /en/developer-guide#term-p2ph "A script which Pays To Pubkey Hashes (P2PH), allowing spending of satoshis to anyone with a Bitcoin address"
[P2SH]: /en/developer-guide#term-p2sh "A script which Pays To Script Hashes (P2SH), allowing convenient spending of satoshis to an address referencing a script"
[P2SH multisig]: /en/developer-guide#term-p2sh-multisig "A multisig script embedded in the redeemScript of a pay-to-script-hash (P2SH) transaction"
[parent key]: /en/developer-guide#term-parent-key "An extended private or public key capable of forming child keys"
[payment protocol]: /en/developer-guide#term-payment-protocol "The protocol defined in BIP70 which lets spenders get signed payment details from receivers"
[PaymentACK]: /en/developer-guide#term-paymentack "The PaymentACK of the payment protocol which allows the receiver to indicate to the spender that the payment is being processed"
[PaymentDetails]: /en/developer-guide#term-paymentdetails "The PaymentDetails of the payment protocol which allows the receiver to specify the payment details to the spender"
[PaymentRequest]: /en/developer-guide#term-paymentrequest "The PaymentRequest of the payment protocol which contains and allows signing of the PaymentDetails"
[PaymentRequests]: /en/developer-guide#term-paymentrequest "The PaymentRequest of the payment protocol which contains and allows signing of the PaymentDetails"
[peer]: /en/developer-guide#FIXME-P2P "Peer on the P2P network who receives and broadcasts transactions and blocks"
[peers]: /en/developer-guide#FIXME-P2P "Peers on the P2P network who receive and broadcast transactions and blocks"
[PKI]: /en/developer-guide#term-pki "Public Key Infrastructure; usually meant to indicate the X.509 certificate system used for HTTP Secure (https)."
[private key]: /en/developer-guide#term-private-key "The private portion of a keypair which can create signatures which other people can verify using the public key"
[private keys]: /en/developer-guide#term-private-key "The private portion of a keypair which can create signatures which other people can verify using the public key"
[pubkey hash]: /en/developer-guide#term-pubkey-hash "The hash of a public key which can be included in a P2PH output"
[public key]: /en/developer-guide#term-public-key "The public portion of a keypair which can be safely distributed to other people so they can verify a signature created with the corresponding private key"
[public keys]: /en/developer-guide#term-public-key "The public portion of a keypair which can be safely distributed to other people so they can verify a signature created with the corresponding private key"
[pp amount]: /en/developer-guide#term-pp-amount "Part of the Output part of the PaymentDetails part of a payment protocol where receivers can specify the amount of satoshis they want paid to a particular output script"
[pp expires]: /en/developer-guide#term-pp-expires "The expires field of a PaymentDetails where the receiver tells the spender when the PaymentDetails expires"
[pp memo]: /en/developer-guide#term-pp-memo "The memo fields of PaymentDetails, Payment, and PaymentACK which allow spenders and receivers to send each other memos"
[pp merchant data]: /en/developer-guide#term-pp-merchant-data "The merchant_data part of PaymentDetails and Payment which allows the receiver to send arbitrary data to the spender in PaymentDetails and receive it back in Payments"
[pp Payment]: /en/developer-guide#term-pp-payment "The Payment message of the PaymentProtocol which allows the spender to send payment details to the receiver"
[pp PKI data]: /en/developer-guide#term-pp-pki-data "The pki_data field of a PaymentRequest which provides details such as certificates necessary to validate the request"
[pp pki type]: /en/developer-guide#term-pp-pki-type "The PKI field of a PaymentRequest which tells spenders how to validate this request as being from a specific recipient"
[pp refund to]: /en/developer-guide#term-pp-refund-to "The refund_to field of a Payment where the spender tells the receiver what outputs to send refunds to"
[pp script]: /en/developer-guide#term-pp-script "The script field of a PaymentDetails where the receiver tells the spender what output scripts to pay"
[pp transactions]: /en/developer-guide#term-pp-transactions "The transactions field of a Payment where the spender provides copies of signed transactions to the receiver"
[pp payment url]: /en/developer-guide#term-pp-payment-url "The payment_url of the PaymentDetails which allows the receiver to specify where the sender should post payment"
[proof of work]: /en/developer-guide#term-proof-of-work "Proof that computationally-difficult work was performed which helps secure blocks against modification, protecting transaction history"
[Pubkey]: /en/developer-guide#term-pubkey "A standard output script which specifies the full public key to match a signature; used in coinbase transactions"
[r]: /en/developer-guide#term-r-parameter "The payment request parameter in a bitcoin: URI" 
[raw format]: /en/developer-guide#term-raw-format "Complete transactions in their binary format; often represented using hexidecimal"
[receipt]: /en/developer-guide#term-receipt "A cryptographically-verifiable receipt created using parts of a payment request and a confirmed transaction"
[recurrent rebilling]: /en/developer-guide#rebilling-recurring-payments "Billing a spender on a regular schedule"
[redeemScript]: /en/developer-guide#term-redeemscript "A script created by the recipient, hashed, and given to the spender for use in a P2SH output"
[refund]: /en/developer-guide#issuing-refunds "A transaction which refunds some or all satoshis received in a previous transaction"
[root certificate]: /en/developer-guide#term-root-certificate "A certificate belonging to a certificate authority (CA)"
[satoshi]: /en/developer-guide#term-satoshi "The smallest unit of Bitcoin value; 0.00000001 bitcoins.  Also used generically for any value of bitcoins"
[satoshis]: /en/developer-guide#term-satoshi "The smallest unit of Bitcoin value; 0.00000001 bitcoins.  Also used generically for any value of bitcoins"
[sequence number]: /en/developer-guide#term-sequence-number "A number intended to allow time locked transactions to be updated before being finalized; not currently used except to disable locktime in a transaction"
[script]: /en/developer-guide#term-script "The part of an output which sets the conditions for spending of the satoshis in that output"
[scripts]: /en/developer-guide#term-script "The part of an output which sets the conditions for spending of the satoshis in that output"
[scriptSig]: /en/developer-guide#term-scriptsig "Data generated by a spender which is almost always used as variables to satisfy an output script"
[script hash]: /en/developer-guide#term-script-hash "The hash of a redeemScript used to create a P2SH output"
[seed]: /en/developer-guide#term-master-key-seed "A potentially-short value used as a seed to generate a master private key and chain code for an HD wallet"
[sha_shacp]: /en/developer-guide#term-sighash-all-sighash-anyonecanpay "Signature hash type which allows other people to contribute satoshis without changing the number of satoshis sent nor where they go"
[shacp]: /en/developer-guide#term-sighash-anyonecanpay "A signature hash type which modifies the behavior of other signature hash types"
[shn_shacp]: /en/developer-guide#term-sighash-none-sighash-anyonecanpay "Signature hash type which allows unfettered modification of a transaction"
[shs_shacp]: /en/developer-guide#term-sighash-single-sighash-anyonecanpay "Signature hash type which allows modification of the entire transaction except the signed input and the output with the same index number"
[sighash_all]: /en/developer-guide#term-sighash-all "Default signature hash type which signs the entire transaction except any scriptSigs, preventing modification of the signed parts"
[sighash_none]: /en/developer-guide#term-sighash-none "Signature hash type which only signs the inputs, allowing anyone to change the outputs however they'd like"
[sighash_single]: /en/developer-guide#term-sighash-single "Signature hash type which only signs its input and the output with the same index value, allowing modification of other inputs and outputs"
[signature]: /en/developer-guide#term-signature "The result of combining a private key and some data in an ECDSA signature operation which allows anyone with the corresponding public key to verify the signature"
[signature hash]: /en/developer-guide#term-signature-hash "A byte appended onto signatures generated in Bitcoin which allows the signer to specify what data was signed, allowing modification of the unsigned data"
[spv]: /en/developer-guide#FIXME-OM "A method for verifying particular transactions were included in blocks without downloading the entire contents of the block chain"
[ssl signature]: /en/developer-guide#term-ssl-signature "Signatures created and recognized by major SSL implementations such as OpenSSL"
[stack]: /en/developer-guide#term-stack "An evaluation stack used in Bitcoin's script language"
[standard script]: /en/developer-guide#standard-transactions "An output script which matches the isStandard() patterns specified in Bitcoin Core---or a transaction containing only standard outputs. Only standard transactions are mined or broadcast by peers running the default Bitcoin Core software"
[target]: /en/developer-guide#term-target "The threshold below which a block header hash must be in order for the block to be added to the block chain"
[testnet]: /en/developer-guide#FIXME-Intro "A Bitcoin-like network where the satoshis have no real-world value to allow risk-free testing"
[transaction fee]: /en/developer-guide#term-transaction-fee "The amount remaining when all outputs are subtracted from all inputs in a transaction; the fee is paid to the miner who includes that transaction in a block"
[transaction fees]: /en/developer-guide#term-transaction-fee "The amount remaining when all outputs are subtracted from all inputs in a transaction; the fee is paid to the miner who includes that transaction in a block"
[transaction malleability]: /en/developer-guide#transaction-malleability "The ability of an attacker to change the transaction identifier (txid) of unconfirmed transactions, making dependent transactions invalid"
[txid]: /en/developer-guide#term-txid "A hash of a completed transaction which allows other transactions to spend its outputs"
[transaction]: /en/developer-guide#transactions "A transaction spending satoshis"
[transaction version number]: /en/developer-guide#term-transaction-version-number "A version number prefixed to transactions to allow upgrading""
[transactions]: /en/developer-guide#transactions "A transaction spending satoshis"
[unconfirmed]: /en/developer-guide#term-unconfirmed-transactions "A transaction which has not yet been added to the block chain"
[unconfirmed transactions]: /en/developer-guide#term-unconfirmed-transactions "A transaction which has not yet been added to the block chain"
[unique addresses]: /en/developer-guide#term-unique-address "Address which are only used once to protect privacy and increase security"
[URI QR Code]: /en/developer-guide#term-uri-qr-code "A QR code containing a bitcoin: URI"
[utxo]: /en/developer-guide#term-utxo "Unspent Transaction Output (UTXO) holding satoshis which have not yet been spent"
[verified payments]: /en/developer-guide#verifying-payment "Payments which the receiver believes won't be double spent"
[v2 block]: /en/developer-guide#term-v2-block "The current version of Bitcoin blocks"
[wallet]: /en/developer-guide#wallets "Software which stores private keys to allow users to spend and receive satoshis"
[Wallet Import Format]: /en/developer-guide#term-wallet-import-format "A private key specially formatted to allow easy import into a wallet"
[wallets]: /en/developer-guide#wallets "Software which stores private keys to allow users to spend and receive satoshis"
[X509Certificates]: /en/developer-guide#term-x509certificates

<!-- Non-terminology links which may be used multiple times (case-insensitive alphabetical order) -->
[BFGMiner]: https://github.com/luke-jr/bfgminer
[BIP21]: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
[BIP32]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
[BIP70]: https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki
[bitcoin-documentation mailing list]: https://groups.google.com/forum/?hl=en#!forum/bitcoin-documentation
[bitcoinpdf]: http://bitcoin.org/bitcoin.pdf
[block170]: http://blockexplorer.com/block/00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee
[casascius address utility]: https://github.com/casascius/Bitcoin-Address-Utility
[core base58.h]: https://github.com/bitcoin/bitcoin/blob/master/src/base58.h
[core executable]: /en/download
[core git]: https://github.com/bitcoin/bitcoin
[core script.h]: https://github.com/bitcoin/bitcoin/blob/master/src/script.h
[DER]: https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One
[docs issue]: https://github.com/saivann/bitcoin.org/issues
[ECDSA]: https://en.wikipedia.org/wiki/Elliptic_Curve_DSA
[Eloipool]: https://gitorious.org/bitcoin/eloipool
[forum tech support]: https://bitcointalk.org/index.php?board=4.0
[HTTP longpoll]: https://en.wikipedia.org/wiki/Push_technology#Long_polling
[irc channels]: https://en.bitcoin.it/wiki/IRC_channels
[MIME]: https://en.wikipedia.org/wiki/Internet_media_type
[Merge Avoidance subsection]: #merge-avoidance
[mozrootstore]: https://www.mozilla.org/en-US/about/governance/policies/security-group/certs/
[Piotr Piasecki's testnet faucet]: https://tpfaucet.appspot.com/
[protobuf]: https://developers.google.com/protocol-buffers/
[raw transaction format]: #raw-transaction-format
[regression test mode]: https://code.google.com/p/bitcoinj/wiki/Testing
[rpc decoderawtransaction]: /en/api-reference#TK#FIXME
[rpc getblock]: /en/api-reference#TK#FIXME
[rpc getblockhash]: /en/api-reference#TK#FIXME
[rpc getrawtransaction]: /en/api-reference#TK#FIXME
[rpc keypoolrefill]: /en/api-reference#TK#FIXME
[rpc listunspent]: /en/api-reference#TK#FIXME
[RPC]: /en/api-reference#FIXME
[RPCs]: /en/api-reference#FIXME
[secp256k1]: http://www.secg.org/index.php?action=secg,docs_secg
[section bitcoin URI]: #requesting-payment-using-the-bitcoin-uri
[SHA256]: https://en.wikipedia.org/wiki/SHA-2
[Stratum mining protocol]: http://mining.bitcoin.cz/stratum-mining
[URI encoded]: https://tools.ietf.org/html/rfc3986
[Verification subsection]: #verifying-payment
[wiki script]: https://en.bitcoin.it/wiki/Script
[x509]: https://en.wikipedia.org/wiki/X.509