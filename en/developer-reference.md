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

{% include ref_block_chain.md %}
{% include ref_transactions.md %}
{% include ref_contracts.md %}
{% include ref_wallets.md %}
{% include ref_payment_processing.md %}
{% include ref_operating_modes.md %}
{% include ref_p2p_network.md %}
{% include ref_mining.md %}

## Bitcoin Core APIs

<!-- TODO, Relevant links:
-- * https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_Calls_list
-- * https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)
-->

### Remote Procedure Calls (RPCs)

{% include ref_core_rpcs-abcdefg.md %}
{% include ref_core_rpcs-hijklmn.md %}
{% include ref_core_rpcs-opqrst.md %}
{% include ref_core_rpcs-uvwxyz.md %}

<!--#md#</div>#md#-->
{% include references.md %}
<script>updateToc();</script>
