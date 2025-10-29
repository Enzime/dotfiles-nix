{ config, self', lib, ... }:

let
  phi-nixos = {
    ipv4 = "100.102.87.29";
    ipv6 = "fd7a:115c:a1e0:ab12:4843:cd96:6266:571d";
  };

  eris = {
    ipv4 = "139.99.238.120";
    ipv6 = "2402:1f00:8100:400::1028";
  };

  styx = {
    ipv4 = "194.195.254.56";
    ipv6 = "2400:8907::f03c:92ff:fe04:4f40";
  };
in {
  terraform.required_providers.desec.source = "Valodim/desec";

  data.external.desec-api-key = {
    program = [ (lib.getExe self'.packages.get-clan-secret) "desec-api-key" ];
  };

  provider.desec.api_token = config.data.external.desec-api-key "result.secret";

  resource.desec_domain.enzim_ee = { name = "enzim.ee"; };

  resource.desec_rrset.A_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "";
    type = "A";
    records = [ styx.ipv4 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.AAAA_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "";
    type = "AAAA";
    records = [ styx.ipv6 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.A_matrix_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "matrix";
    type = "A";
    records = [ styx.ipv4 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.AAAA_matrix_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "matrix";
    type = "AAAA";
    records = [ styx.ipv6 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.A_nextcloud_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "nextcloud";
    type = "A";
    records = [ phi-nixos.ipv4 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.AAAA_nextcloud_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "nextcloud";
    type = "AAAA";
    records = [ phi-nixos.ipv6 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.A_reflector_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "reflector";
    type = "A";
    records = [ eris.ipv4 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.AAAA_reflector_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "reflector";
    type = "AAAA";
    records = [ eris.ipv6 ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_fm1__domainkey_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "fm1._domainkey";
    type = "CNAME";
    records = [ "fm1.enzim.ee.dkim.fmhosted.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_fm2__domainkey_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "fm2._domainkey";
    type = "CNAME";
    records = [ "fm2.enzim.ee.dkim.fmhosted.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_fm3__domainkey_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "fm3._domainkey";
    type = "CNAME";
    records = [ "fm3.enzim.ee.dkim.fmhosted.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_fm1__domainkey_m_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "fm1._domainkey.m";
    type = "CNAME";
    records = [ "fm1.m.enzim.ee.dkim.fmhosted.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_fm2__domainkey_m_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "fm2._domainkey.m";
    type = "CNAME";
    records = [ "fm2.m.enzim.ee.dkim.fmhosted.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_fm3__domainkey_m_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "fm3._domainkey.m";
    type = "CNAME";
    records = [ "fm3.m.enzim.ee.dkim.fmhosted.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_element_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "element";
    type = "CNAME";
    records = [ "matrix.enzim.ee." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.CNAME_stats_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "stats";
    type = "CNAME";
    records = [ "matrix.enzim.ee." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.MX_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "";
    type = "MX";
    records =
      [ "10 in1-smtp.messagingengine.com." "20 in2-smtp.messagingengine.com." ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.MX___enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "*";
    type = "MX";
    inherit (config.resource.desec_rrset.MX_enzim_ee) records;
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.MX_m_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "m";
    type = "MX";
    inherit (config.resource.desec_rrset.MX_enzim_ee) records;
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.TXT_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "";
    type = "TXT";
    records = [ ''"v=spf1 include:spf.messagingengine.com ?all"'' ];
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };

  resource.desec_rrset.TXT_m_enzim_ee = {
    domain = config.resource.desec_domain.enzim_ee "name";
    subname = "m";
    type = "TXT";
    inherit (config.resource.desec_rrset.TXT_enzim_ee) records;
    ttl = config.resource.desec_domain.enzim_ee "minimum_ttl";
  };
}
