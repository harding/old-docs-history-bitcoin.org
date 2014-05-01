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

{% autocrossref %}
Attempts to broadcast a new block to network.  Extra parameters are ignored
by Bitcoin Core but may be used by mining pools or other programs.
{% endautocrossref %}

**Argument #1: The New Block In Hex**

{% autocrossref %}
*String; required:* the hex-encoded block data to broadcast to the
peer-to-peer network.
{% endautocrossref %}

**Argument #2: Extra Parameters**

{% autocrossref %}
*String; optional:*  A JSON object containing extra parameters for
mining pools and other software, such as a work identifier (workid).
The extra parameters will not be broadcast to the network.
{% endautocrossref %}

~~~
{
  "<key>" : "<value>"
}
~~~

**Result: None**

No output if successful.  An error message if failed.

**Example**

{% autocrossref %}
Submit the following block with the workid, "test".
{% endautocrossref %}

~~~
> bitcoin-cli -testnet submitblock 02000000df11c014a8d798395b505\
              9c722ebdf3171a4217ead71bf6e0e99f4c7000000004a6f6a2\
              db225c81e77773f6f0457bcb05865a94900ed11356d0b75228\
              efb38c7785d6053ffff001d005d43700101000000010000000\
              00000000000000000000000000000000000000000000000000\
              0000000ffffffff0d03b477030164062f503253482ffffffff\
              f0100f9029500000000232103adb7d8ef6b63de74313e0cd4e\
              07670d09a169b13e4eda2d650f529332c47646dac00000000\
              '{ "workid": "test" }'
~~~

