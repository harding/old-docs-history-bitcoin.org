## Wallets

{% autocrossref %}

Bitcoin wallets at their core are a collection of private keys. These collections are stored digitally in a file, or can even be physically stored on pieces of paper. 

{% endautocrossref %}

### Private Key Formats

{% autocrossref %}

Private keys are what are used to unlock satoshis from a particular address. In Bitcoin, a private key in standard format is simply a 256-bit number, between the values:

0x1 and 0xFFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFE BAAE DCE6 AF48 A03B BFD2 5E8C D036 4141, effectively representing the entire range of 2<sup>256</sup>-1 values. The range is governed by the secp256k1 ECDSA encryption standard used by Bitcoin. 

{% endautocrossref %}

#### Wallet Import Format (WIF)

{% autocrossref %}

In order to make copying of private keys less prone to error, [Wallet Import Format][]{:#term-wallet-import-format}{:.term} may be utilized. WIF uses base58Check encoding on an private key, greatly decreasing the chance of copying error, much like standard Bitcoin addresses.

1. Take a private key.

2. Add a 0x80 byte in front of it for mainnet addresses or 0xef for testnet addresses.

3. Perform a SHA-256 hash on the extended&nbsp;key.

4. Performa SHA-256 hash on result of SHA-256 hash.

5. Take the first 4 bytes of the second SHA-256 hash; this is the checksum.

6. Add the 4 checksum bytes from point 5 at the end of the extended&nbsp;key from point 2.

7. Convert the result from a byte string into a Base58 string using Base58Check encoding.

The process is easily reversible, using the Base58 decoding function, and removing the padding.

{% endautocrossref %}

#### Mini Private Key Format

{% autocrossref %}

Mini private key format is a method for encoding a private key in under 30 characters, enabling keys to be embedded in a small physical space, such as physical bitcoin tokens, and more damage-resistant QR codes. 

1. The first character of mini keys is 'S'. 

2. In order to determine if a mini private key is well-formatted, a question mark is added to the private key.

3. The SHA256 hash calculated. If the first byte produced is a `00’, it is well-formatted. This key restriction acts as a typo-checking mechanism. A user brute forces the process using random numbers until a well-formatted mini private key is produced. 

4. In order to derive the full private key, the user simply takes a single SHA256 hash of the original mini private key. This process is one-way: it is intractible to compute the mini private key format from the derived key.

Many implementations disallow the character '1' in the mini private key due to its visual similarity to 'l'.

**Resource:** A common tool to create and redeem these keys is the [Casascius Bitcoin Address Utility][casascius
address utility].

{% endautocrossref %}

### Deterministic wallets Formats

{% autocrossref %}

Deterministic wallets are the recommended method of generating and storing private keys, as they allow a simple one-time backup of wallets via mnemonic pass-phrase of a number of short, common English words.

{% endautocrossref %}

#### Type 1: Single Chain Wallets

{% autocrossref %}

Type 1 deterministic wallets are the simpler of the two, which can create a single series of keys from a single seed. A primary weakness is that if the seed is leaked, all funds are compromised, and wallet sharing is extremely limited.

{% endautocrossref %}

#### Type 2: Hierarchical Deterministic (HD) Wallets

{% autocrossref %}

Type 2 wallets, specified in BIP32, are the currently favored format for generating, storing and managing private keys. Hierarchical deterministic wallets allow selective sharing by supporting multiple key-pair chains in a tree structure, derived from a single root. This selective sharing enables many advanced arrangements. An additional goal of the BIP32 standard is to encourage interoperability between wallet software using the same wallet format, rather than having to manually convert wallet types. The suggested minimal interoperability is the ability to import extended [public][public key] and private keys, to give access to the descendants as wallet keys. 

![Overview Of Heirarchical Deterministic Key Derivation](/img/dev/en-hd-overview.svg) <!-- NEW -->

_Seamless interoperability is still a work in progress. It is possible for another implementation to not see non-zero valued addresses, depending on wallet parameters. For safe recovery of wallets, it is recommended to use the same wallet software. Another concern is the saving of HD wallet meta-data such as transaction notes and [labels][label], which has not been standardized._  

<!-- BEGIN The following text largely taken from the BIP0032 specification --> 

Here are a select number of use cases:

1. Audits: In case an auditor needs full access to the list of incoming and outgoing payments, one can share all account public extended keys. This will allow the auditor to see all [transactions][] from and to the wallet, in all accounts, but not a single private key.

2. When a business has several independent offices, they can all use wallets derived from a single seed. This will allow the headquarters to maintain a super-wallet that sees all incoming and outgoing transactions of all offices, and even permit moving money between the offices.

3. In case two business partners often transfer money, one can use the extended public key for the external chain of a specific account as a sort of "super address", allowing frequent transactions that cannot (easily) be associated, but without needing to request a new address for each payment. Such a mechanism could also be used by mining pool operators as variable payout address.

With many more arrangements possible. The following section is an in-depth technical discussion of HD wallets.

{% endautocrossref %}

#### Conventions

{% autocrossref %}

In the rest of this text we will assume the public key cryptography used in Bitcoin, namely elliptic curve cryptography using the field and curve parameters defined by secp256k1. Variables below are either:

* Integers modulo the order of the curve (referred to as n).

* Coordinates of points on the curve.

* Byte sequences.

Addition (+) of two coordinate pair is defined as application of the EC group operation.

Concatenation (\|\|) is the operation of appending one byte sequence onto another.

As standard conversion functions, we assume:

* point(p): returns the coordinate pair resulting from EC point multiplication (repeated application of the EC group operation) of the secp256k1 base point with the integer p.

* ser<sub>32</sub>(i): serialize a 32-bit unsigned integer i as a 4-byte sequence, most significant byte first.

* ser<sub>256</sub>(p): serializes the integer p as a 32-byte sequence, most significant byte first.

* ser<sub>P</sub>(P): serializes the coordinate pair P = (x,y) as a byte sequence using SEC1's compressed form: (0x02 or 0x03) \|\| ser<sub>256</sub>(x), where the header byte depends on the parity of the omitted y coordinate.

* parse<sub>256</sub>(p): interprets a 32-byte sequence as a 256-bit number, most significant byte first.

{% endautocrossref %}

#### Extended Keys

{% autocrossref %}

In what follows, we will define a function that derives a number of [child keys][child key]{:#term-child-key}{:.term} from a [parent key][]{:#term-parent-key}{:.term}. In order to prevent these from depending solely on the key itself, we extend both [private][private keys] and public keys first with an extra 256 bits of entropy. This extension, called the [chain code][]{:#term-chain-code}{:.term}, is identical for corresponding private and public keys, and consists of 32 bytes.

![Creating A Root Extended Key Pair](/img/dev/en-hd-root-keys.svg) <!-- NEW -->

We represent an [extended private key][]{:#term-extended-private-key}{:.term} as (k, c), with k the normal private key, and c the chain code. An [extended public key][]{:#term-extended-public-key}{:.term} is represented as (K, c), with K = point(k) and c the chain code.

Each [extended key][]{:#term-extended-key}{:.term} has 2<sup>31</sup> [normal child keys][normal child key]{:#term-normal-child-key}{:.term}, and 2<sup>31</sup> [hardened child keys][hardened child key]{:#term-hardened-child-key}{:.term}. Each of these child keys has an [index][key index]{:#term-key-index}{:.term}. The normal child keys use indices 0 through 2<sup>31</sup>-1. The hardened child keys use indices 2<sup>31</sup> through 2<sup>32</sup>-1. To ease notation for hardened key indices, a number i<sub>H</sub> represents i+2<sup>31</sup>.

{% endautocrossref %}

#### Child Key Derivation (CKD) Functions

{% autocrossref %}

Given a parent extended key and an index i, it is possible to compute the corresponding [child extended key][]{:#term-child-extended-key}{:.term}. The algorithm to do so depends on whether the child is a hardened key or not (or, equivalently, whether i ≥ 2<sup>31</sup>), and whether we're talking about [private][private key] or public keys.

{% endautocrossref %}

##### Private Parent Key &rarr; Private Child Key

{% autocrossref %}

![Creating Child Public Keys From An Extended Private Key](/img/dev/en-hd-private-parent-to-private-child.svg) <!-- NEW -->

The function CKDpriv((k<sub>par</sub>, c<sub>par</sub>), i) &rarr; (k<sub>i</sub>, c<sub>i</sub>) computes a child extended private key from the parent extended private key:

* Let:
    
    * Key = c<sub>par</sub>.

    * Data = ser<sub>256</sub>(k<sub>par</sub>) \|\| ser<sub>32</sub>(i).

* Check whether i ≥ 2<sup>31</sup> (whether the child is a hardened key).
   
    * If hardened: let I = HMAC-SHA512(Key, 0x00 \|\| Data).(Note: The 0x00 pads the private key to make it 33 bytes long.)

    * If not: let I = HMAC-SHA512(Key, Data).

* Split I into two 32-byte sequences, I<sub>L</sub> and I<sub>R</sub>.

* The returned child key k<sub>i</sub> is parse<sub>256</sub>(I<sub>L</sub>) + k<sub>par</sub> (mod n).

* The returned chain code c<sub>i</sub> is I<sub>R</sub>.

* In case parse<sub>256</sub>(I<sub>L</sub>) ≥ n or k<sub>i</sub> = 0, the resulting key is invalid, and one should proceed with the next value for i. (Note: this has probability lower than 1 in 2<sup>127</sup>.)

The HMAC-SHA512 function is specified in [RFC 4231](http://tools.ietf.org/html/rfc4231).

{% endautocrossref %}

##### Public Parent Key &rarr; Public Child Key

{% autocrossref %}

![Creating Child Public Keys From An Extended Public Key](/img/dev/en-hd-public-child-from-public-parent.svg) <!-- NEW -->

The function CKDpub((K<sub>par</sub>, c<sub>par</sub>), i) &rarr; (K<sub>i</sub>, c<sub>i</sub>) computes a child extended public key from the parent extended public key. It is only defined for non-hardened child keys.

* Check whether i ≥ 2<sup>31</sup> (whether the child is a hardened key).

    * If so (hardened child): return failure

    * If not (normal child): let I = HMAC-SHA512(Key = c<sub>par</sub>, Data = ser<sub>P</sub>(K<sub>par</sub>) \|\| ser<sub>32</sub>(i)).

* Split I into two 32-byte sequences, I<sub>L</sub> and I<sub>R</sub>.

* The returned child key K<sub>i</sub> is point(parse<sub>256</sub>(I<sub>L</sub>)) + K<sub>par</sub>.

* The returned chain code c<sub>i</sub> is I<sub>R</sub>.

* In case parse<sub>256</sub>(I<sub>L</sub>) ≥ n or K<sub>i</sub> is the point at infinity, the resulting key is invalid, and one should proceed with the next value for i.

{% endautocrossref %}

##### Private Parent Key &rarr; Public Child Key

{% autocrossref %}

![Creating Equivalent Public Keys From Either Extended Private Or Extended Public Keys](/img/dev/en-hd-public-child-from-public-or-private-parent.svg) <!-- NEW -->

The function N((k, c)) &rarr; (K, c) computes the extended public key corresponding to an extended private key (the "neutered" version, as it removes the ability to sign transactions).

* The returned key K is point(k).

* The returned chain code c is just the passed chain code.

To compute the public child key of a parent private key:

* N(CKDpriv((k<sub>par</sub>, c<sub>par</sub>), i)) (works always).

* CKDpub(N(k<sub>par</sub>, c<sub>par</sub>), i) (works only for non-hardened child keys).

The fact that they are equivalent is what makes non-hardened keys useful (one can derive [child public keys][child public key]{:#term-child-public-key}{:.term} of a given parent key without knowing any private key), and also what distinguishes them from hardened keys. The reason for not always using non-hardened keys (which are more useful) is security; see further for more information.

{% endautocrossref %}

##### Public Parent Key &rarr; Private Child Key

This is not possible, as is expected.

#### The Key Tree

{% autocrossref %}

The next step is cascading several CKD constructions to build a tree. We start with one root, the master extended key m. By evaluating CKDpriv(m,i) for several values of i, we get a number of level-1 derived nodes. As each of these is again an extended key, CKDpriv can be applied to those as well.

To shorten notation, we will write CKDpriv(CKDpriv(CKDpriv(m,3<sub>H</sub>),2),5) as m/3<sub>H</sub>/2/5. Equivalently for public keys, we write CKDpub(CKDpub(CKDpub(M,3),2,5) as M/3/2/5. This results in the following identities:

* N(m/a/b/c) = N(m/a/b)/c = N(m/a)/b/c = N(m)/a/b/c = M/a/b/c.

* N(m/a<sub>H</sub>/b/c) = N(m/a<sub>H</sub>/b)/c = N(m/a<sub>H</sub>)/b/c.

However, N(m/a<sub>H</sub>) cannot be rewritten as N(m)/a<sub>H</sub>, as the latter is not possible.

Each leaf node in the tree corresponds to an actual key, while the internal nodes correspond to the collections of keys that descend from them. The chain codes of the leaf nodes are ignored, and only their embedded private or public key is relevant. Because of this construction, knowing an extended private key allows reconstruction of all descendant private keys and public keys, and knowing an extended public keys allows reconstruction of all descendant non-hardened public keys.

{% endautocrossref %}

#### Key Identifiers

{% autocrossref %}

Extended keys can be identified by the Hash160 (RIPEMD160 after SHA256) of the serialized public key, ignoring the chain code. This corresponds exactly to the data used in traditional Bitcoin addresses. It is not advised to represent this data in base58 format though, as it may be interpreted as an address that way (and wallet software is not required to accept payment to the chain key itself).

The first 32 bits of the identifier are called the [key fingerprint][]{:#term-key-fingerprint}{:.term}.

{% endautocrossref %}

#### Serialization Format

{% autocrossref %}

Extended public and private keys are serialized as follows:

* 4 byte: version bytes (mainnet: 0x0488B21E public, 0x0488ADE4 private; testnet: 0x043587CF public, 0x04358394 private)

* 1 byte: depth: 0x00 for master nodes, 0x01 for level-1 derived keys, ....

* 4 bytes: the fingerprint of the parent's key (0x00000000 if master key)

* 4 bytes: child number. This is ser<sub>32</sub>(i) for i in x<sub>i</sub> = x<sub>par</sub>/i, with x<sub>i</sub> the key being serialized. (0x00000000 if master key)

* 32 bytes: the chain code

* 33 bytes: the public key or private key data (ser<sub>P</sub>(K) for public keys, 0x00 \|\| ser<sub>256</sub>(k) for private keys)

This 78 byte structure can be encoded like other Bitcoin data in Base58, by first adding 32 checksum bits (derived from the double SHA-256 checksum), and then converting to the Base58 representation. This results in a Base58-encoded string of up to 112 characters. Because of the choice of the version bytes, the Base58 representation will start with "xprv" or "xpub" on mainnet, "tprv" or "tpub" on testnet.

Note that the fingerprint of the parent only serves as a fast way to detect parent and child nodes in software, and software must be willing to deal with collisions. Internally, the full 160-bit identifier could be used.

When importing a serialized extended public key, implementations must verify whether the X coordinate in the public key data corresponds to a point on the curve. If not, the extended public key is invalid.

{% endautocrossref %}

#### Master Key Generation

{% autocrossref %}

The total number of possible extended keypairs is almost 2<sup>512</sup>, but the produced keys are only 256 bits long, and offer about half of that in terms of security. Therefore, [master keys][master key]{:#term-master-key}{:.term} are not generated directly, but instead from a potentially short seed value.

* Generate a [seed][]{:#term-master-key-seed}{:.term} byte sequence S of a chosen length (between 128 and 512 bits; 256 bits is advised) from a (P)RNG.

* Calculate I = HMAC-SHA512(Key = "Bitcoin seed", Data = S)

* Split I into two 32-byte sequences, I<sub>L</sub> and I<sub>R</sub>.

* Use parse<sub>256</sub>(I<sub>L</sub>) as master secret key, and I<sub>R</sub> as master chain code.

In case I<sub>L</sub> is 0 or ≥n, the master key is invalid.

![Example HD Wallet Tree Using "Prime" Notation](/img/dev/en-hd-tree.svg) <!-- NEW -->

{% endautocrossref %}

#### Specification: Wallet structure

{% autocrossref %}

The previous sections specified key trees and their nodes. The next step is imposing a wallet structure on this tree. The layout defined in this section is a default only, though clients are encouraged to mimick it for compatibility, even if not all features are supported.

{% endautocrossref %}

#### The Default Wallet Layout

{% autocrossref %}

An HDW is organized as several [accounts][HD account]{:#term-hd-account}{:.term}. Accounts are numbered, the default account ("") being number 0. Clients are not required to support more than one account - if not, they only use the default account.

Each account is composed of two keypair chains: an [internal chain][]{:#term-internal-chain}{:.term} and an [external chain][]{:#term-external-chain}{:.term}. The external keychain is used to generate new public addresses, while the internal keychain is used for all other operations (change addresses, [coinbase addresses][coinbase transaction], and anything else that doesn't need to be communicated). Clients that do not support separate keychains for these should use the external one for everything.

* m/i<sub>H</sub>/0/k corresponds to the k'th keypair of the external chain of account number i of the HDW derived from master m.

* m/i<sub>H</sub>/1/k corresponds to the k'th keypair of the internal chain of account number i of the HDW derived from master m.

{% endautocrossref %}

#### Security Considerations

{% autocrossref %}

Most of the standard security guarantees afforded the standard key setups such as Type 1 wallets are still in place. 

Note however that the following properties does not exist:

* Given a parent extended public key (K<sub>par</sub>,c<sub>par</sub>) and a child public key (K<sub>i</sub>), it is hard to find child key index (i).

* Given a parent extended public key (K<sub>par</sub>,c<sub>par</sub>) and a non-hardened child private key
(k<sub>i</sub>), it is hard to find the parent private key (k<sub>par</sub>).

Consequently:

1. Private and public keys must be kept safe as usual. Leaking a private key means access to coins - leaking a public key can mean loss of privacy.

2. Somewhat more care must be taken regarding extended keys, as these correspond to an entire (sub)tree of keys.

3. One weakness that may not be immediately obvious, is that knowledge of the extended public key plus any non-[hardened private key][hardened child key] descending from it is equivalent to knowing the extended private key (and thus every private and public key descending from it). This means that extended public keys must be treated more carefully than regular public keys.

*It is also the reason for the existence of hardened keys, and why they are used for the [account][HD account] level in the tree. This way, a leak of account-specific (or below) private key never risks compromising the master key or other accounts.*

<!-- END extended quote from BIP0032 spec --> 

**Resources:** Refer to BIP32 for the full HD Wallet specification.

{% endautocrossref %}

### JBOK (Just A Bunch Of Keys) Wallets Formats

{% autocrossref %}

JBOK-style wallets are a deprecated form of wallet that originated from the Bitcoin Core client wallet. Bitcoin Core client wallet would create 100 private key/public key pairs automatically via a Psuedo-Random-Number Generator (PRNG) for use. Once all these keys are consumed or the RPC call `keypoolrefill` is run, another 100 key pairs would be created. This created considerable difficulty in backing up one’s keys, considering backups have to be run manually to save the newly generated private keys. If a new key pair set had been generated, used, then lost prior to a backup, the stored satoshis are likely lost forever. Many older-style mobile wallets followed a similar format, but only generated a new private key upon user demand.

This wallet type is being actively phased out and strongly discouraged from being used to store significant amounts of satoshis due to the security and backup hassle.

{% endautocrossref %}
