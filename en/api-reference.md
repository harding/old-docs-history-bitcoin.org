---
layout: base
lang: en
id: api-reference
title: "API Reference - Bitcoin"
---

# Bitcoin API Reference

<p class="summary">Find Bitcoin API references and code samples.</p>

<div markdown="1" id="toc" class="toc"><div markdown="1">

* Table of contents
{:toc}

</div></div>
<!--#md#<div markdown="1" class="toccontent">#md#-->

## Bitcoin Core

<!-- TODO, Relevant links:
-- * https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_Calls_list
-- * https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)
-->

### Remote Procedure Calls (RPCs)


#### `createrawtransaction`

~~~
createrawtransaction <previous output(s)> <new output(s)>
~~~
{:.rpc-prototype}

{% autocrossref %}
Create an unsigned transaction in hex rawtransaction format that spends a
previous output to an new output with a P2PH or P2SH address. The
transaction is not stored in the wallet or transmitted to the network.

{% endautocrossref %}

##### Argument: Previous Output

{% autocrossref %}
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

##### Argument: New Output 

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

##### Result

{% autocrossref %}
*String:* The resulting unsigned transaction in hex-encoded
rawtransaction format, or a JSON error if any value provided was invalid.
{% endautocrossref %}

##### Example

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
010000000189957b01aed596d3b361b576234eaeed3249246f14562d6bc60851
66cd247d5a0000000000ffffffff0180969800000000001976a9140dfc8bafc8\
419853b34d5e072ad37d1a5159f58488ac00000000
~~~
{:.rpc-output-example}

### FIXME: Other Bitcoin Core APIs

## Other APIs
   

<!--#md#</div>#md#-->
{% include references.md %}
<script>updateToc();</script>
