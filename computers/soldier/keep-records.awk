BEGIN {
  split("DNSKEY CDS CDNSKEY RRSIG NSEC", _ty)
  for (t in _ty) ty[_ty[t]] = ""
}

$3 in ty || $1 ~ /\._domainkey\./ { print $0 }
