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
