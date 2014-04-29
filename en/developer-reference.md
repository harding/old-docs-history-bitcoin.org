---
layout: base
lang: en
id: developer-reference
title: "Developer Reference - Bitcoin"
---

# Bitcoin Developer Reference

<p class="summary">Find technical specifications and API documentation.</p>

<div markdown="1" id="toc" class="toc"><div markdown="1">

* Table of contents
{:toc}

</div></div>
<!--#md#<div markdown="1" class="toccontent">#md#-->

## Transaction Reference

The following subsections briefly document core transaction details.

#### OP Codes

{% autocrossref %}

The op codes used in standard transactions are,

* Various data pushing op codes from 0x00 to 0x4e (1--78). These haven't
  been shown in the examples above, but they must be used to push
  signatures and public keys onto the stack. See the link below this list
  for a description.

* `OP_1NEGATE` (0x4f), `OP_TRUE`/`OP_1` (0x51), and `OP_2` through
  `OP_16` (0x52--0x60), which (respectively) push the values -1, 1, and
  2--16 to the stack.

* [`OP_CHECKSIG`][op_checksig]{:#term-op-checksig}{:.term} consumes a signature and a full public key, and returns
  true if the the transaction data specified by the SIGHASH flag was
  converted into the signature using the same ECDSA private key that
  generated the public key.  Otherwise, it returns false.

* [`OP_DUP`][op_dup]{:#term-op-dup}{:.term} returns a copy of the item on the stack below it.

* [`OP_HASH160`][op_hash160]{:#term-op-hash160}{:.term} consumes the item on the stack below it and returns with
  a RIPEMD-160(SHA256()) hash of that item.

* [`OP_EQUAL`][op_equal]{:#term-op-equal}{:.term} consumes the two items on the stack below it and returns
  true if they are the same.  Otherwise, it returns false.

* [`OP_VERIFY`][op_verify]{:#term-op-verify}{:.term} consumes one value and returns nothing, but it will
  terminate the script in failure if the value consumed is zero (false).

* [`OP_EQUALVERIFY`][op_equalverify]{:#term-op-equalverify}{:.term} runs `OP_EQUAL` and then `OP_VERIFY` in sequence.

* [`OP_CHECKMULTISIG`][op_checkmultisig]{:#term-op-checkmultisig}{:.term} consumes the value (n) at the top of the stack,
  consumes that many of the next stack levels (public keys), consumes
  the value (m) now at the top of the stack, and consumes that many of
  the next values (signatures) plus one extra value. Then it compares
  each of public keys against each of the signatures looking for ECDSA
  matches; if n of the public keys match signatures, it returns true.
  Otherwise, it returns false.

    The "one extra value" it consumes is the result of an off-by-one
    error in the Bitcoin Core implementation. This value is not used, so
    scriptSigs prefix the signatures with a single OP_0 (0x00).

* [`OP_RETURN`][op_return]{:#term-op-return}{:.term} terminates the script in failure. However, this will not
  invalidate a [null-data-type][null data] transaction which contains no more than 40
  bytes following `OP_RETURN` no more than once per transaction.

A complete list of OP codes can be found on the Bitcoin Wiki [Script
Page][wiki script], with an authoritative list in the `opcodetype` enum
of the Bitcoin Core [script header file][core script.h]

Note: non-standard transactions can add non-data-pushing op codes to
their scriptSig, but scriptSig is run separately from the script (with a
shared stack), so scriptSig can't use arguments such as `OP_RETURN` to
prevent the script from working as expected.

{% endautocrossref %}

#### Address Conversion

{% autocrossref %}

The hashes used in P2PH and P2SH outputs are commonly encoded as Bitcoin
addresses.  This is the procedure to encode those hashes and decode the
addresses.

First, get your hash.  For P2PH, you RIPEMD-160(SHA256()) hash a ECDSA
public key derived from your 256-bit ECDSA private key (random data).
For P2SH, you RIPEMD-160(SHA256()) hash a redeemScript serialized in the
format used in raw transactions (described in a [following
sub-section][raw transaction format]).  Taking the resulting hash:

1. Add an address version byte in front of the hash.  The version
bytes commonly used by Bitcoin are:

    * 0x00 for P2PH addresses on the main Bitcoin network (mainnet)

    * 0x6f for P2PH addresses on the Bitcoin testing network (testnet)

    * 0x05 for P2SH addresses on mainnet

    * 0xc4 for P2SH addresses on testnet

2. Create a copy of the version and hash; then hash that twice with SHA256: `SHA256(SHA256(version . hash))`

3. Extract the four most significant bytes from the double-hashed copy.
   These are used as a checksum to ensure the base hash gets transmitted
   correctly.

4. Append the checksum to the version and hash, and encode it as a base58
   string: <!--[-->`BASE58(version . hash . checksum)`<!--]-->
 
Bitcoin's base58 encoding, called [Base58Check][]{:#term-base58check}{:.term} may not match other implementations. Tier
Nolan provided the following example encoding algorithm to the Bitcoin
Wiki [Base58Check
encoding](https://en.bitcoin.it/wiki/Base58Check_encoding) page:

{% endautocrossref %}

{% highlight c %}
code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
x = convert_bytes_to_big_integer(hash_result)

output_string = ""

while(x > 0) 
   {
       (x, remainder) = divide(x, 58)
       output_string.append(code_string[remainder])
   }

repeat(number_of_leading_zero_bytes_in_hash)
   {
   output_string.append(code_string[0]);
   }

output_string.reverse();
{% endhighlight %}

{% autocrossref %}

Bitcoin's own code can be traced using the [base58 header
file][core base58.h].

To convert addresses back into hashes, reverse the base58 encoding, extract
the checksum, repeat the steps to create the checksum and compare it
against the extracted checksum, and then remove the version byte.

{% endautocrossref %}

#### Raw Transaction Format

{% autocrossref %}

Bitcoin transactions are broadcast between peers and stored in the
block chain in a serialized byte format, called [raw format][]{:#term-raw-format}{:.term}. Bitcoin Core
and many other tools print and accept raw transactions encoded as hex.

A sample raw transaction is the first non-coinbase transaction, made in
[block 170][block170].  To get the transaction, use the `getrawtransaction` RPC with
that transaction's txid (provided below):

{% endautocrossref %}

~~~
> getrawtransaction \
  f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16

0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423e\
dce25857fcd3704000000004847304402204e45e16932b8af514961a1d3\
a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07d\
e4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff\
0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f71\
59b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7\
303b8a0626f1baded5c72a704f7e6cd84cac00286bee000000004341041\
1db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a690\
9a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f\
656b412a3ac00000000
~~~

A byte-by-byte analysis by Amir Taaki (Genjix) of this transaction is
provided below.  (Originally from the Bitcoin Wiki
[OP_CHECKSIG page](https://en.bitcoin.it/wiki/OP_CHECKSIG); Genjix's
text has been updated to use the terms used in this document.)

~~~
01 00 00 00              version number
01                       number of inputs (var_uint)

input 0:
c9 97 a5 e5 6e 10 41 02  previous tx hash (txid)
fa 20 9c 6a 85 2d d9 06 
60 a2 0b 2d 9c 35 24 23 
ed ce 25 85 7f cd 37 04
00 00 00 00              previous output index

48                       size of script (var_uint)
47                       push 71 bytes to stack
30 44 02 20 4e 45 e1 69
32 b8 af 51 49 61 a1 d3
a1 a2 5f df 3f 4f 77 32
e9 d6 24 c6 c6 15 48 ab
5f b8 cd 41 02 20 18 15
22 ec 8e ca 07 de 48 60
a4 ac dd 12 90 9d 83 1c
c5 6c bb ac 46 22 08 22
21 a8 76 8d 1d 09 01
ff ff ff ff              sequence number

02                       number of outputs (var_uint)

output 0:
00 ca 9a 3b 00 00 00 00  amount = 10.00000000 BTC
43                       size of script (var_uint)
script for output 0:
41                       push 65 bytes to stack
04 ae 1a 62 fe 09 c5 f5 
1b 13 90 5f 07 f0 6b 99 
a2 f7 15 9b 22 25 f3 74 
cd 37 8d 71 30 2f a2 84 
14 e7 aa b3 73 97 f5 54 
a7 df 5f 14 2c 21 c1 b7 
30 3b 8a 06 26 f1 ba de 
d5 c7 2a 70 4f 7e 6c d8 
4c 
ac                       OP_CHECKSIG

output 1:
00 28 6b ee 00 00 00 00  amount = 40.00000000 BTC
43                       size of script (var_uint)
script for output 1:
41                       push 65 bytes to stack
04 11 db 93 e1 dc db 8a  
01 6b 49 84 0f 8c 53 bc 
1e b6 8a 38 2e 97 b1 48 
2e ca d7 b1 48 a6 90 9a
5c b2 e0 ea dd fb 84 cc 
f9 74 44 64 f8 2e 16 0b 
fa 9b 8b 64 f9 d4 c0 3f 
99 9b 86 43 f6 56 b4 12 
a3                       
ac                       OP_CHECKSIG

00 00 00 00              locktime
~~~


## Bitcoin Core APIs

<!-- TODO, Relevant links:
-- * https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_Calls_list
-- * https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)
-->

### Remote Procedure Calls (RPCs)

#### addmultisigaddress

~~~
addmultisigaddress <num required> <addresses|pubkeys> [account]
~~~
{:.rpc-prototype}

{% autocrossref %}
Add a P2SH multisig address to the wallet. 

Related RPCs: `createmultisig`
{% endautocrossref %}

**Argument #1: Number Of Signatures Required**

{% autocrossref %}
*Number; required:* the *minimum* (*m*) number of signatures required to
spend satoshis sent to this m-of-n P2SH multisig script.
{% endautocrossref %}

~~~
<m>
~~~

**Argument #2: Full Public Keys, Or Addresses For Known Public Keys**

{% autocrossref %}
*String; required:* A JSON array of hex-encoded public *keys* or *addresses*
for public keys known to this Bitcoin Core instance.  The multisig
script can only use full (unhashed) public keys, so you generally must
provide public keys for any address not known to this wallet.
{% endautocrossref %}

~~~
[
  "<address|pubkey>"
  ,[...]
]
~~~

**Argument #3: Account Name**

{% autocrossref %}
*String; optional:* The name of an *account* in the wallet which will
store the address.
{% endautocrossref %}

~~~
"<account>"
~~~


**Result: A P2SH Address Printed And Stored In The Wallet**

{% autocrossref %}
*String:* a hash of the P2SH multisig redeemScript, which is also stored
in the wallet so Bitcoin Core can monitor the network and block chain
for transactions sent to that address (which will be displayed in the
wallet as spendable balances).
{% endautocrossref %}


**Example**

{% autocrossref %}
Adding a 2-of-3 P2SH multisig address to the "test account" by mixing
two P2PH addresses and one full public key:
{% endautocrossref %}

~~~
> bitcoin-cli --testnet addmultisigaddress \
  2 \
  '''
    [ 
      "mjbLRSidW1MY8oubvs4SMEnHNFXxCcoehQ", 
      "02ecd2d250a76d204011de6bc365a56033b9b3a149f679bc17205555d3c2b2854f", 
      "mt17cV37fBqZsnMmrHnGCm9pM28R1kQdMG" 
    ]
  ''' \
  'test account'
~~~

Output:

~~~
2MyVxxgNBk5zHRPRY2iVjGRJHYZEp1pMCSq
~~~

{% autocrossref %}
(New P2SH multisig address also stored in wallet.)
{% endautocrossref %}

#### createmultisig

~~~
createmultisig <num required> <addresses|pubkeys>
~~~

{% autocrossref %}
Creates a multi-signature address with n signature of m keys required.
It returns a json object with the address and redeemScript.

Related RPCs: `addmultisigaddress`
{% endautocrossref %}

**Argument #1: Number Of Signatures Required**

{% autocrossref %}
*Number; required:* the *minimum* (*m*) number of signatures required to
spend satoshis sent to this m-of-n multisig script.
{% endautocrossref %}

~~~
<m>
~~~

**Argument #2: Full Public Keys, Or Addresses For Known Public Keys**

{% autocrossref %}
*String; required:* A JSON array of hex-encoded public *keys* or *addresses*
for public keys known to this Bitcoin Core instance.  The multisig
script can only use full (unhashed) public keys, so you generally must
provide public keys for any address not known to this wallet.
{% endautocrossref %}

~~~
[
  "<address|pubkey>"
  ,[...]
]
~~~

**Result: Address And Hex-Encoded RedeemScript**

{% autocrossref %}
*String:* JSON object with the P2SH *address* and hex-encoded *redeemScript*.
{% endautocrossref %}

~~~
{
  "address":"<P2SH address>",
  "redeemScript":"<hex redeemScript>"
}
~~~

**Example**

{% autocrossref %}
Creating a 2-of-3 P2SH multisig address by mixing two P2PH addresses and
one full public key:
{% endautocrossref %}

~~~
> bitcoin-cli --testnet createmultisig 2 '''
  [ 
    "mjbLRSidW1MY8oubvs4SMEnHNFXxCcoehQ", 
    "02ecd2d250a76d204011de6bc365a56033b9b3a149f679bc17205555d3c2b2854f", 
    "mt17cV37fBqZsnMmrHnGCm9pM28R1kQdMG" 
  ]
  '''
~~~

{% autocrossref %}
Output (redeemScript wrapped):
{% endautocrossref %}

~~~
{
  "address" : "2MyVxxgNBk5zHRPRY2iVjGRJHYZEp1pMCSq",
  "redeemScript" : "522103ede722780d27b05f0b1169efc90fa15a601a32\
	    fc6c3295114500c586831b6aaf2102ecd2d250a76d20\
	    4011de6bc365a56033b9b3a149f679bc17205555d3c2\
	    b2854f21022d609d2f0d359e5bc0e5d0ea20ff9f5d33\
	    96cb5b1906aa9c56a0e7b5edc0c5d553ae"
}
~~~




#### createrawtransaction

~~~
createrawtransaction <previous output(s)> <new output(s)>
~~~
{:.rpc-prototype}

{% autocrossref %}
Create an unsigned transaction in hex rawtransaction format that spends a
previous output to an new output with a P2PH or P2SH address. The
transaction is not stored in the wallet or transmitted to the network.


**Argument #1: References To Previous Outputs**

*String; required:* A JSON array of JSON objects. Each object in the
array references a previous output by its *txid* (string; required) and
output index number, called *vout* (number; required).
{% endautocrossref %}

~~~
[
  {
    "txid":"<previous output txid>",
    "vout":<previous output index number>
  }
  ,[...]
]
~~~
{:.rpc-argument}

**Argument #2: P2PH Or P2SH Addresses For New Outputs**

{% autocrossref %}
*String; required:* A JSON object with P2PH or P2SH addresses to pay as
keys and the amount to pay each address as its value (numeric; required)
in decimal bitcoins.
{% endautocrossref %}

~~~
{
  "<address>": <bitcoins>.<decimal bitcoins>
  ,[...]
}
~~~
{:.rpc-argument}

**Result: Unsigned Raw Transaction (In Hex)**

{% autocrossref %}
*String:* The resulting unsigned transaction in hex-encoded
rawtransaction format, or a JSON error if any value provided was invalid.
{% endautocrossref %}

**Example**

~~~
> bitcoin-cli -testnet createrawtransaction '''
  [
    { 
      "txid":"5a7d24cd665108c66b2d56146f244932edae4e2376b561b3d396d5ae017b9589", 
      "vout":0 
    } 
  ]
  ''' '''
  { 
    "mgnucj8nYqdrPFh2JfZSB1NmUThUGnmsqe": 0.1 
  }
''''
~~~
{:.rpc-cli-example}

Result:

~~~
010000000189957b01aed596d3b361b576234eaeed3249246f14562d6bc60851\
66cd247d5a0000000000ffffffff0180969800000000001976a9140dfc8bafc8\
419853b34d5e072ad37d1a5159f58488ac00000000
~~~
{:.rpc-output-example}



#### getblocktemplate

~~~
getblocktemplate [client capabilities]
~~~

{% autocrossref %}
Get a block template or proposal which mining software can use to
construct a block and hash its header, as defined by BIP22.
{% endautocrossref %}

**Argument: Client Capabilities**

{% autocrossref %}
*String; optional:* a JSON object containing an optional *mode* (of which *template*
is both the default and only currently-allowed option) and an optional
*capabilities* JSON array of elements describing capabilities supported
by the client.  Known capabilites include (but are not limited to):
longpoll, coinbasetxn, coinbasevalue, proposal, serverlist, and workid. 
{% endautocrossref %}

~~~
{
  "mode":"template"
  "capabilities":[
      "<supported capability>"
      ,[...]
    ]
}
~~~

**Result: Information Necessary To Construct The Next Block**

{% autocrossref %}
A JSON object containing all the information necessary to construct a
block which can be added to the block chain.  This is a considerable
amount of information, so the JSON object is described below in parts.
{% endautocrossref %}

~~~
{
  "version" : <version number>,
  "previousblockhash" : "<hex block header hash>",
~~~

{% autocrossref %}
The block *version* number and the *hash of the previous block* header, both of
which must be added to this block's header.
{% endautocrossref %}


~~~
  "transactions" : [
~~~

{% autocrossref %}
An array of *transactions* in [transaction object format][]{:#term-transaction-object-format}{:.term}.  
{% endautocrossref %}

~~~
      {
         "data" : "<hex transaction data> ",
         "hash" : "<hex txid>",
~~~

{% autocrossref %}
Each object in the array contains the
rawtransaction *data* in hex and the *hash* of the data in little-endian
hex.  
{% endautocrossref %}

~~~
         "depends" : [
             <index number>
             ,[...]
         ],
~~~

{% autocrossref %}
If the transaction depends on one or more transaction in the array,
the dependent transactions are listed in the *depends* array by their
index number in the transactions array (starting from 1).
{% endautocrossref %}


~~~
         "fee": <number in satoshis>,
         "sigops" : <sigops number>
         "required" : <true|false>
      }
~~~

{% autocrossref %}
The *fee* paid by the transaction and the number of signature operations
(*sigops*) it uses which count towards the 20,000 maximum in blocks.
Also whether or not the transaction is *required* to be in the block
produced in order for that block to be accepted by Bitcoin Core (this is
mainly used by mining pools).  Note: if *required* is omitted, it is
false.
{% endautocrossref %}

~~~
      ,[...]
  ],
~~~

(More transactions.)

~~~
  "coinbaseaux" : {
      "<flag>" : "<data>"
  },
~~~

{% autocrossref %}
Hex-encoded *data* identified by *flag* which should be included in the
coinbase field of the coinbase transaction.  The flag is for the
benefit of mining software---only the data is included.
{% endautocrossref %}

~~~
  "coinbasevalue" : <number in satoshis>
~~~

{% autocrossref %}
The *coinbasevalue*, the maximum number of satoshis which the coinbase
transaction can spend (including the block reward) if all the transactions provided in
the transaction array are included in the block. 
{% endautocrossref %}

~~~
  "coinbasetxn" : { <coinbase transaction> },
~~~

{% autocrossref %}
The *coinbasetxn* is a JSON object in transaction object format
which describes the coinbase transaction.
{% endautocrossref %}

~~~
  "target" : "<target hash>",
~~~

{% autocrossref %}
The *target* threshold for the block.  In solo mining, this may be the
network target (difficulty).  In pooled mining, this is the target to
generate a share.
{% endautocrossref %}

~~~
  "mintime" : <epoch time>,
~~~

{% autocrossref %}
The minimum *time* the for the block header time in Unix epoch time
format (number of seconds elapsed since 1970-01-01T00:00 UTC.
{% endautocrossref %}

~~~
  "mutable" : [
     "<value>"
     ,[...]
  ],
~~~

{% autocrossref %}
An array of values which describe how the client can modify the block
template.  For example, "time" to change the block header time or
"transactions" to add or remove transactions.
{% endautocrossref %}

~~~
  "noncerange" : "<min nonce hex><max nonce hex>",
~~~

{% autocrossref %}
Two 32-bit integers, concatenated in big-endian hexadecimal, which
represent the valid ranges of block header nonces the miner may scan.
{% endautocrossref %}

~~~
  "sigoplimit" : <number of sigops>,
  "sizelimit" : <number of bytes>,
~~~

{% autocrossref %}
The limitations of block signature operations (*sigoplimit*) in number
and block size (*sizelimit*) in bytes.
{% endautocrossref %}

~~~
  "curtime" : <epoch time>,
  "bits" : "<compressed target>",
  "height" : <number of previous blocks>
}
~~~

{% autocrossref %}
The current time in Unix epoch format (*curtime*), the compressed network
target (difficulty) of the block being worked on (*bits*), and the *height* of the
block being worked on.
{% endautocrossref %}

**Example**

{% autocrossref %}
Getting the block template from a default Bitcoin Core 0.9.1 with the
optional parameters "longpoll" and "workid" (which have no effect on
default Bitcoin Core).
{% endautocrossref %}

~~~
> bitcoin-cli -testnet getblocktemplate '{"capabilities":["longpoll", "workid"]}'
~~~

Result (long lines have been wrapped (\\) and some data has been omitted
([...]):


~~~
{
    "version" : 2,
    "previousblockhash" : "000000005767babc38ebd1807def40cb47dfe\
                           f29ef712de9d85c77ad8e039b9d",
    "transactions" : [
        {
            "data" : "0100000001438a4d7a2333c3579b81d59f562d2af8\
                      69c142f697546465339c67028f44aa65000000006b\
                      483045022100eb31779b1e162e27825c5f52a1378f\
                      8d90994999df58706cf29bd78c80f6920a022063c0\
                      4eb627166eab60d36caacaa68a0fd805923442a3cd\
                      db6babacb6b4706cc90121031a2761284af7f291e8\
                      0f061f6eace13e3ea9b2aa3b0ac5407b7a21a5d43f\
                      3174ffffffff0200e1f505000000001976a914a11b\
                      66a67b3ff69671c8f82254099faf374b800e88ace0\
                      5c9041000000001976a91406e1c288b96002df7442\
                      bb1ec6c43419a1f1e74988ac00000000",
            "hash" : "d471fda51e1d7284add729e44b5d8d8a462e5d4151\
                      6f0a1efda712cfa76e310e",
            "depends" : [
            ],
            "fee" : 20000,
            "sigops" : 2
        },
        {
            "data" : "[...]",
            "hash" : "5c1e046ec13bd1fad71153aa28811ecad241233960\
                      efca32f5554d233ff29f7f",
            "depends" : [
            ],
            "fee" : 0,
            "sigops" : 2
        },
        [...]
    ],
    "coinbaseaux" : {
        "flags" : "062f503253482f"
    },
    "coinbasevalue" : 2500320000,
    "target" : "000000000001968c00000000000000000000000000000000\
                0000000000000000",
    "mintime" : 1398693714,
    "mutable" : [
        "time",
        "transactions",
        "prevblock"
    ],
    "noncerange" : "00000000ffffffff",
    "sigoplimit" : 20000,
    "sizelimit" : 1000000,
    "curtime" : 1398698437,
    "bits" : "1b01968c",
    "height" : 227051
}
~~~


#### lockunspent

~~~
lockunspent <true|false> <outputs>
~~~

{% autocrossref %}
Updates list of temporarily unspendable outputs.

Temporarily lock or unlock specified transaction outputs. A locked
transaction output will not be chosen by automatic coin selection when
spending bitcoins. Locks are stored in memory only, so nodes start with
zero locked outputs and the locked output list is always cleared when a
node stops or fails.

{% endautocrossref %}

**Argument #1: Lock (True) Or Unlock (False)**

{% autocrossref %}
*Boolean; required:* whether to lock (*true*) or unlock (*false*) the
outputs.
{% endautocrossref %}

**Argument #2: The Outputs To Lock Or Unlock**

{% autocrossref %}
*String; required:* A JSON array of JSON objects.  Each object has a
transaction identifier (*txid*) and output index number (*vout*) for the
output to lock or unlock.
{% endautocrossref %}

~~~
[
  {
    "txid":"<transaction identifier (hash)>",
    "vout": <output index number>
  }
  ,...
]
~~~

**Result**

{% autocrossref %}
*Boolean:* true if the command was successful; false if it was not.
{% endautocrossref %}

**Example**

{% autocrossref %}
Lock two outputs:
{% endautocrossref %}

~~~
> bitcoin-cli -testnet lockunspent true '''
  [ 
    { 
      "txid": "5a7d24cd665108c66b2d56146f244932edae4e2376b561b3d396d5ae017b9589",
      "vout": 0 
    }, 
    { 
      "txid": "6c5edd41a33f9839257358ba6ddece67df9db7f09c0db6bbea00d0372e8fe5cd", 
      "vout": 0 
    } 
  ]
'''
~~~

Result: 

~~~
true
~~~

{% autocrossref %}
Unlock one of the above outputs:
{% endautocrossref %}


~~~
bitcoin-cli -testnet lockunspent false '''
[ 
  { 
    "txid": "5a7d24cd665108c66b2d56146f244932edae4e2376b561b3d396d5ae017b9589",
    "vout": 0
  } 
]
'''
~~~

Result:

~~~
true
~~~

#### sendmany

~~~
sendmany <account> <addresses & amounts> [min. confirmations] [memo]
~~~

{% autocrossref %}
Create and broadcast a transaction which spends outputs to multiple addresses.
{% endautocrossref %}

**Argument #1: Account From Which The Satoshis Should Be Sent**

{% autocrossref %}
*String; required:* the wallet account from which the funds should be
withdrawn.  Can be "" for the default account.
{% endautocrossref %}

**Argument #2: The Output Address/Amount Pairs**

{% autocrossref %}
*String; required:* a JSON object with addresses as keys (string) and amounts as values
(number, decimal bitcoins).
{% endautocrossref %}

~~~
{
  "<address>":<amount in decimal bitcoins>
  ,[...]
}
~~~

**Argument #3: The Minimum Number Of Confirmations For Inputs**

{% autocrossref %}
*Number; optional:* the minimum number of confirmations an previously-received
output must have before it will be spent.  The default is 1
confirmation.
{% endautocrossref %}

**Argument #4: A Memo**

{% autocrossref %}
*String, optional:* a memo to be recorded with this transaction for
record-keeping purposes.  The memo is not included in the transaction.
{% endautocrossref %}

**Result: A Transaction Identifier**

{% autocrossref %}
*String:* a transaction identifier (txid) for the transaction created
and broadcast to the peer-to-peer network.  
{% endautocrossref %}

**Example**

{% autocrossref %}
From the account *test1*, send 0.1 bitcoins to the first address and 0.2
bitcoins to the second address, with a memo of "Example Transaction".
{% endautocrossref %}

~~~
> bitcoin-cli -testnet sendmany \
  "test1" \
  '''
    { 
      "mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN": 0.1,
      "mgnucj8nYqdrPFh2JfZSB1NmUThUGnmsqe": 0.2
    } ''' \
  6       \
  "Example Transaction"
~~~

Result:

~~~
ef7c0cbf6ba5af68d2ea239bba709b26ff7b0b669839a63bb01c2cb8e8de481e
~~~

#### signrawtransaction

~~~
signrawtransaction <raw transaction hex> [previous transactions] [private keys] [sighashtype]
~~~

{% autocrossref %}
Sign inputs of a transaction in rawtransaction format using private keys
stored in the wallet or provided in the call.

{% endautocrossref %}

**Argument #1: The Transaction To Sign**

{% autocrossref %}
*String; required:* the transaction to sign in raw transaction format
(hex).
{% endautocrossref %}

**Argument #2: P2SH Transaction Dependencies**

{% autocrossref %}
*String; optional:* A JSON array of JSON objects. Each object contains
details about an unknown-to-this-node P2SH transaction that this transaction
depends upon.

Each previous P2SH transaction must include its *txid* in hex, output
index number (*vout*), public key (*scriptPubKey*) in hex, and
*redeemScript* in hex.
{% endautocrossref %}

~~~
[
  {
    "txid":"<txid>",
    "vout":<output index number>,
    "scriptPubKey": "<scriptPubKey in hex>",
    "redeemScript": "<redeemScript in hex>"
  }
  ,...
]
~~~

**Argument #3: Private Keys For Signing**

{% autocrossref %}
*String; optional:* A JSON array of base58check-encoded private keys to use
for signing.  If this argument is used, only the keys provided will be
used to sign even if the wallet has other matching keys.  If this
argument is omitted, keys from the wallet will be used.
{% endautocrossref %}

~~~
[
  "<private key in base58check hex>"
  ,[...]
]
~~~

**Argument #4: Sighash Type**

{% autocrossref %}
*String, optional:* The type of signature hash to use for all of the
signatures performed.  (You must use separate calls to
`signrawtransaction` if you want to use different sighash types for
different signatures.)

The allowed values are *ALL*, *NONE*,
*SINGLE*, *ALL|ANYONECANPAY*, *NONE|ANYONECANPAY*,
and *SINGLE|ANYONECANPAY*.
{% endautocrossref %}


**Result: Signed Transaction**

{% autocrossref %}
*String:* a JSON object containing the transaction in *hex* with as many
signatures as could be applied and a *complete* key indicating whether
or not the the transaction is fully signed (0 indicates it is not
complete).
{% endautocrossref %}

~~~
{
  "hex": "value",   (string) The raw transaction with signature(s) (hex-encoded string)
  "complete": n       (numeric) if transaction has a complete set of signature (0 if not)
}
~~~

**Example**

{% autocrossref %}
Sign the hex generated in the example section for the `rawtransaction`
RPC:
{% endautocrossref %}

~~~
> bitcoin-cli -testnet signrawtransaction 010000000189957b01aed5\
              96d3b361b576234eaeed3249246f14562d6bc6085166cd247d\
              5a0000000000ffffffff0180969800000000001976a9140dfc\
              8bafc8419853b34d5e072ad37d1a5159f58488ac00000000
~~~

Result:

~~~
{
  "hex" : "010000000189957b01aed596d3b361b576234eaeed3249246f145\
           62d6bc6085166cd247d5a000000006b483045022100c7a034fd7d\
           990b8a2bfba45fde44cae40b5ffbe42c5cf7d8143bfe317bdef3f\
           10220584e52f59b6a46d688322d65178efe83972a8517c9479630\
           6d40083af5b807c901210321eeeb46fd878ce8e62d5e0f408a0ea\
           b41d7c3a7872dc836ce360439536e423dffffffff018096980000\
           0000001976a9140dfc8bafc8419853b34d5e072ad37d1a5159f58\
           488ac00000000",
  "complete" : true
}
~~~


#### submitblock

~~~
submitblock <new block>  [extra parameters]
~~~

Attempts to broadcast a new block to network.  Extra parameters are ignored
by Bitcoin Core but may be used by mining pools or other programs.

**Argument #1: The New Block In Hex**

*String; required:* the hex-encoded block data to broadcast to the
peer-to-peer network.

**Argument #2: Extra Parameters**

*String; optional:*  A JSON object containing extra parameters for
mining pools and other software, such as a work identifier (workid).
The extra parameters will not be broadcast to the network.

~~~
{
  "<key>" : "<value>"
}
~~~

**Result: None**

No output if successful.  An error message if failed.

**Example**

Submit the following block with the workid, "test".

~~~
> bitcoin-cli -testnet submitblock 0b110907be0000000200000099f5a\
              66370b9958f7d382f7269b9d3ab9bc387237a34f236af9a000\
              00000000021e9af375b9ef13ba5bfb843afb99527b19689d30\
              df3e251e5c0ce9557436820d7b42f53122f061bbaddaf71010\
              10000000100000000000000000000000000000000000000000\
              00000000000000000000000ffffffff0e03e12b03024e05062\
              f503253482fffffffff0100f2052a01000000232103f0daa9e\
              2ea23c3cb07a36dbf1151b2da02897463428d30aa254fa3efc\
              a898a62ac00000000  '{ "workid": "test" }'
~~~



### FIXME: Other Bitcoin Core APIs

## Other APIs
   
<!--#md#</div>#md#-->
{% include references.md %}
<script>updateToc();</script>
