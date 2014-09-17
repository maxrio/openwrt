#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ifneq ($(__inc_netfilter),1)
__inc_netfilter:=1

ifeq ($(NF_KMOD),1)
P_V4:=ipv4/netfilter/
P_V6:=ipv6/netfilter/
P_XT:=netfilter/
P_EBT:=bridge/netfilter/
endif

# 1: variable
# 2: kconfig symbols
# 3: file list
# 4: version dependency
define nf_add
 $(if $(4),ifeq ($$(strip $$(call CompareKernelPatchVer,$$(KERNEL_PATCHVER),$(firstword $(4)),$(lastword $(4)))),1))
  $(1)-$$($(2)) += $(3)
 $(if $(4),endif)
 KCONFIG_$(1) = $(filter-out $(2),$(KCONFIG_$(1))) $(2)
endef


# core

# kernel only
$(eval $(if $(NF_KMOD),$(call nf_add,NF_IPT,CONFIG_IP_NF_IPTABLES, $(P_V4)ip_tables),))
$(eval $(if $(NF_KMOD),$(call nf_add,NF_IPT,CONFIG_NETFILTER_XTABLES, $(P_XT)x_tables),))

$(eval $(if $(NF_KMOD),$(call nf_add,IPT_CORE,CONFIG_NETFILTER_XTABLES, $(P_XT)xt_tcpudp),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_CORE,CONFIG_IP_NF_FILTER, $(P_V4)iptable_filter),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_CORE,CONFIG_IP_NF_MANGLE, $(P_V4)iptable_mangle),))

# userland only
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_CORE,CONFIG_IP_NF_IPTABLES, xt_standard ipt_icmp xt_tcp xt_udp xt_comment xt_id xt_set xt_SET)))

$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MATCH_LIMIT, $(P_XT)xt_limit))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MATCH_MAC, $(P_XT)xt_mac))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MATCH_MULTIPORT, $(P_XT)xt_multiport))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MATCH_COMMENT, $(P_XT)xt_comment))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MATCH_ID, $(P_XT)xt_id))

$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_TARGET_LOG, $(P_XT)xt_LOG, ge 3.4.0))
$(eval $(call nf_add,IPT_CORE,CONFIG_IP_NF_TARGET_LOG, $(P_V4)ipt_LOG, lt 3.4.0))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_TARGET_TCPMSS, $(P_XT)xt_TCPMSS))
$(eval $(call nf_add,IPT_CORE,CONFIG_IP_NF_TARGET_REJECT, $(P_V4)ipt_REJECT))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MATCH_TIME, $(P_XT)xt_time))
$(eval $(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MARK, $(P_XT)xt_mark))

# kernel has xt_MARK.ko merged into xt_mark.ko, userspace is still separate
# userland: xt_MARK.so
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_CORE,CONFIG_NETFILTER_XT_MARK, $(P_XT)xt_MARK)))


# conntrack

# kernel only
$(eval $(if $(NF_KMOD),$(call nf_add,NF_CONNTRACK,CONFIG_NF_CONNTRACK, $(P_XT)nf_conntrack),))
$(eval $(if $(NF_KMOD),$(call nf_add,NF_CONNTRACK,CONFIG_NF_DEFRAG_IPV4, $(P_V4)nf_defrag_ipv4),))
$(eval $(if $(NF_KMOD),$(call nf_add,NF_CONNTRACK,CONFIG_NF_CONNTRACK_IPV4, $(P_V4)nf_conntrack_ipv4),))

$(eval $(call nf_add,IPT_CONNTRACK,CONFIG_NETFILTER_XT_MATCH_STATE, $(P_XT)xt_state))
$(eval $(call nf_add,IPT_CONNTRACK,CONFIG_IP_NF_RAW, $(P_V4)iptable_raw))
$(eval $(call nf_add,IPT_CONNTRACK,CONFIG_NETFILTER_XT_TARGET_NOTRACK, $(P_XT)xt_NOTRACK, lt 3.7.0))
$(eval $(call nf_add,IPT_CONNTRACK,CONFIG_NETFILTER_XT_TARGET_CT, $(P_XT)xt_CT))
$(eval $(call nf_add,IPT_CONNTRACK,CONFIG_NETFILTER_XT_MATCH_CONNTRACK, $(P_XT)xt_conntrack))


# conntrack-extra

$(eval $(call nf_add,IPT_CONNTRACK_EXTRA,CONFIG_NETFILTER_XT_MATCH_CONNBYTES, $(P_XT)xt_connbytes))
$(eval $(call nf_add,IPT_CONNTRACK_EXTRA,CONFIG_NETFILTER_XT_MATCH_CONNLIMIT, $(P_XT)xt_connlimit))
$(eval $(call nf_add,IPT_CONNTRACK_EXTRA,CONFIG_NETFILTER_XT_CONNMARK, $(P_XT)xt_connmark))
$(eval $(call nf_add,IPT_CONNTRACK_EXTRA,CONFIG_NETFILTER_XT_MATCH_HELPER, $(P_XT)xt_helper))
$(eval $(call nf_add,IPT_CONNTRACK_EXTRA,CONFIG_NETFILTER_XT_MATCH_RECENT, $(P_XT)xt_recent))

$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_CONNTRACK_EXTRA,CONFIG_NETFILTER_XT_CONNMARK, $(P_XT)xt_CONNMARK)))

# extra

$(eval $(call nf_add,IPT_EXTRA,CONFIG_NETFILTER_XT_MATCH_ADDRTYPE, $(if $(NF_KMOD),$(P_XT)xt_addrtype,$(P_XT)ipt_addrtype)))
$(eval $(call nf_add,IPT_EXTRA,CONFIG_NETFILTER_XT_MATCH_OWNER, $(P_XT)xt_owner))
$(eval $(call nf_add,IPT_EXTRA,CONFIG_NETFILTER_XT_MATCH_PHYSDEV, $(P_XT)xt_physdev))
$(eval $(call nf_add,IPT_EXTRA,CONFIG_NETFILTER_XT_MATCH_PKTTYPE, $(P_XT)xt_pkttype))
$(eval $(call nf_add,IPT_EXTRA,CONFIG_NETFILTER_XT_MATCH_QUOTA, $(P_XT)xt_quota))

#$(eval $(call nf_add,IPT_EXTRA,CONFIG_IP_NF_TARGET_ROUTE, $(P_V4)ipt_ROUTE))


# filter

$(eval $(call nf_add,IPT_FILTER,CONFIG_NETFILTER_XT_MATCH_LAYER7, $(P_XT)xt_layer7))
$(eval $(call nf_add,IPT_FILTER,CONFIG_NETFILTER_XT_MATCH_STRING, $(P_XT)xt_string))


# ipopt

$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_DSCP, $(P_XT)xt_dscp))
$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_TARGET_DSCP, $(P_XT)xt_DSCP))
$(eval $(call nf_add,IPT_HASHLIMIT,CONFIG_NETFILTER_XT_MATCH_HASHLIMIT, $(P_XT)xt_hashlimit)) 
$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_LENGTH, $(P_XT)xt_length))
$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_STATISTIC, $(P_XT)xt_statistic))
$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_TCPMSS, $(P_XT)xt_tcpmss))

$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_TARGET_CLASSIFY, $(P_XT)xt_CLASSIFY))
$(eval $(call nf_add,IPT_IPOPT,CONFIG_IP_NF_MATCH_DSCP, $(P_V4)ipt_dscp))
$(eval $(call nf_add,IPT_IPOPT,CONFIG_IP_NF_TARGET_ECN, $(P_V4)ipt_ECN))

$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_ECN, $(P_XT)xt_ecn))

# userland only
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_DSCP, xt_tos)))
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_TARGET_DSCP, xt_TOS)))
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_TARGET_HL, ipt_ttl)))
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_TARGET_HL, ipt_TTL)))

$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_MATCH_HL, $(P_XT)xt_hl))
$(eval $(call nf_add,IPT_IPOPT,CONFIG_NETFILTER_XT_TARGET_HL, $(P_XT)xt_HL))

# iprange
$(eval $(call nf_add,IPT_IPRANGE,CONFIG_NETFILTER_XT_MATCH_IPRANGE, $(P_XT)xt_iprange))


# ipsec
$(eval $(call nf_add,IPT_IPSEC,CONFIG_IP_NF_MATCH_AH, $(P_V4)ipt_ah))
$(eval $(call nf_add,IPT_IPSEC,CONFIG_NETFILTER_XT_MATCH_ESP, $(P_XT)xt_esp))
$(eval $(call nf_add,IPT_IPSEC,CONFIG_NETFILTER_XT_MATCH_POLICY, $(P_XT)xt_policy))


# IPv6

# kernel only
$(eval $(if $(NF_KMOD),$(call nf_add,NF_IPT6,CONFIG_IP6_NF_IPTABLES, $(P_V6)ip6_tables),))

$(eval $(if $(NF_KMOD),$(call nf_add,NF_CONNTRACK6,CONFIG_NF_DEFRAG_IPV6, $(P_V6)nf_defrag_ipv6),))
$(eval $(if $(NF_KMOD),$(call nf_add,NF_CONNTRACK6,CONFIG_NF_CONNTRACK_IPV6, $(P_V6)nf_conntrack_ipv6),))

$(eval $(if $(NF_KMOD),$(call nf_add,IPT_IPV6,CONFIG_IP6_NF_FILTER, $(P_V6)ip6table_filter),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_IPV6,CONFIG_IP6_NF_MANGLE, $(P_V6)ip6table_mangle),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_IPV6,CONFIG_IP6_NF_QUEUE, $(P_V6)ip6_queue),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_IPV6,CONFIG_IP6_NF_RAW, $(P_V6)ip6table_raw),))

$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_IPV6,CONFIG_IP6_NF_IPTABLES, ip6t_icmp6)))


$(eval $(call nf_add,IPT_IPV6,CONFIG_IP6_NF_TARGET_LOG, $(P_V6)ip6t_LOG))
$(eval $(call nf_add,IPT_IPV6,CONFIG_IP6_NF_TARGET_REJECT, $(P_V6)ip6t_REJECT))

# ipv6 extra
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_IPV6HEADER, $(P_V6)ip6t_ipv6header))
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_AH, $(P_V6)ip6t_ah))
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_MH, $(P_V6)ip6t_mh))
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_EUI64, $(P_V6)ip6t_eui64))
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_OPTS, $(P_V6)ip6t_hbh))
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_FRAG, $(P_V6)ip6t_frag))
$(eval $(call nf_add,IPT_IPV6_EXTRA,CONFIG_IP6_NF_MATCH_RT, $(P_V6)ip6t_rt))

# nat

# kernel only
$(eval $(if $(NF_KMOD),$(call nf_add,NF_NAT,CONFIG_NF_NAT, $(P_XT)nf_nat, ge 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NF_NAT,CONFIG_NF_NAT_IPV4, $(P_V4)nf_nat_ipv4, ge 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NF_NAT6,CONFIG_NF_NAT_IPV6, $(P_V6)nf_nat_ipv6, ge 3.7.0),))

$(eval $(if $(NF_KMOD),$(call nf_add,IPT_NAT,CONFIG_NF_NAT, $(P_XT)xt_nat, ge 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_NAT,CONFIG_NF_NAT, $(P_V4)iptable_nat, lt 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_NAT,CONFIG_NF_NAT_IPV4, $(P_V4)iptable_nat, ge 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_NAT6,CONFIG_NF_NAT_IPV6, $(P_V6)ip6table_nat, ge 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_NAT6,CONFIG_IP6_NF_TARGET_MASQUERADE, $(P_V6)ip6t_MASQUERADE, ge 3.7.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,IPT_NAT6,CONFIG_IP6_NF_TARGET_NPT, $(P_V6)ip6t_NPT, ge 3.7.0),))

# userland only
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_NAT,CONFIG_NF_NAT, ipt_SNAT ipt_DNAT)))
$(eval $(if $(NF_KMOD),,$(call nf_add,IPT_NAT6,CONFIG_IP6_NF_TARGET_NPT, ip6t_DNPT ip6t_SNPT)))

$(eval $(call nf_add,IPT_NAT,CONFIG_IP_NF_TARGET_MASQUERADE, $(P_V4)ipt_MASQUERADE))
$(eval $(call nf_add,IPT_NAT,CONFIG_IP_NF_TARGET_REDIRECT, $(P_XT)xt_REDIRECT, ge 3.7.0))
$(eval $(call nf_add,IPT_NAT,CONFIG_IP_NF_TARGET_REDIRECT, $(P_V4)ipt_REDIRECT, lt 3.7.0))


# nat-extra

$(eval $(call nf_add,IPT_NAT_EXTRA,CONFIG_IP_NF_TARGET_NETMAP, $(P_XT)xt_NETMAP, ge 3.7.0))
$(eval $(call nf_add,IPT_NAT_EXTRA,CONFIG_IP_NF_TARGET_NETMAP, $(P_V4)ipt_NETMAP, lt 3.7.0))


# nathelper

$(eval $(call nf_add,NF_NATHELPER,CONFIG_IP_NF_NAT_FTP, $(P_V4)ip_nat_ftp))
$(eval $(call nf_add,NF_NATHELPER,CONFIG_NF_CONNTRACK_FTP, $(P_XT)nf_conntrack_ftp))
$(eval $(call nf_add,NF_NATHELPER,CONFIG_NF_CONNTRACK_IRC, $(P_XT)nf_conntrack_irc))
$(eval $(call nf_add,NF_NATHELPER,CONFIG_NF_NAT_FTP, $(P_XT)nf_nat_ftp, ge 3.7.0))
$(eval $(call nf_add,NF_NATHELPER,CONFIG_NF_NAT_IRC, $(P_XT)nf_nat_irc, ge 3.7.0))
$(eval $(call nf_add,NF_NATHELPER,CONFIG_NF_NAT_FTP, $(P_V4)nf_nat_ftp, lt 3.7.0))
$(eval $(call nf_add,NF_NATHELPER,CONFIG_NF_NAT_IRC, $(P_V4)nf_nat_irc, lt 3.7.0))


# nathelper-extra

$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_BROADCAST, $(P_XT)nf_conntrack_broadcast))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_AMANDA, $(P_XT)nf_conntrack_amanda))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_AMANDA, $(P_XT)nf_nat_amanda, ge 3.7.0))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_AMANDA, $(P_V4)nf_nat_amanda, lt 3.7.0))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CT_PROTO_GRE, $(P_XT)nf_conntrack_proto_gre))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_PROTO_GRE, $(P_V4)nf_nat_proto_gre))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_H323, $(P_XT)nf_conntrack_h323))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_H323, $(P_V4)nf_nat_h323))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_PPTP, $(P_XT)nf_conntrack_pptp))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_PPTP, $(P_V4)nf_nat_pptp))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_SIP, $(P_XT)nf_conntrack_sip))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_SIP, $(P_XT)nf_nat_sip, ge 3.7.0))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_SIP, $(P_V4)nf_nat_sip, lt 3.7.0))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_SNMP, $(P_XT)nf_conntrack_snmp))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_SNMP_BASIC, $(P_V4)nf_nat_snmp_basic))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_CONNTRACK_TFTP, $(P_XT)nf_conntrack_tftp))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_TFTP, $(P_XT)nf_nat_tftp, ge 3.7.0))
$(eval $(call nf_add,NF_NATHELPER_EXTRA,CONFIG_NF_NAT_TFTP, $(P_V4)nf_nat_tftp, lt 3.7.0))


# queue

$(eval $(call nf_add,IPT_QUEUE,CONFIG_IP_NF_QUEUE, $(P_V4)ip_queue, lt 3.5.0))


# ulog

$(eval $(call nf_add,IPT_ULOG,CONFIG_IP_NF_TARGET_ULOG, $(P_V4)ipt_ULOG))


# nflog

$(eval $(call nf_add,IPT_NFLOG,CONFIG_NETFILTER_XT_TARGET_NFLOG, $(P_XT)xt_NFLOG))


# nfqueue

$(eval $(call nf_add,IPT_NFQUEUE,CONFIG_NETFILTER_XT_TARGET_NFQUEUE, $(P_XT)xt_NFQUEUE))


# debugging

$(eval $(call nf_add,IPT_DEBUG,CONFIG_NETFILTER_XT_TARGET_TRACE, $(P_XT)xt_TRACE))

# tproxy

$(eval $(call nf_add,IPT_TPROXY,CONFIG_NETFILTER_XT_MATCH_SOCKET, $(P_XT)xt_socket))
$(eval $(call nf_add,IPT_TPROXY,CONFIG_NETFILTER_XT_TARGET_TPROXY, $(P_XT)xt_TPROXY))

# led
$(eval $(call nf_add,IPT_LED,CONFIG_NETFILTER_XT_TARGET_LED, $(P_XT)xt_LED))

# tee

$(eval $(call nf_add,IPT_TEE,CONFIG_NETFILTER_XT_TARGET_TEE, $(P_XT)xt_TEE))

# u32 

$(eval $(call nf_add,IPT_U32,CONFIG_NETFILTER_XT_MATCH_U32, $(P_XT)xt_u32))


# netlink

$(eval $(call nf_add,NFNETLINK,CONFIG_NETFILTER_NETLINK, $(P_XT)nfnetlink))

# nflog

$(eval $(call nf_add,NFNETLINK_LOG,CONFIG_NETFILTER_NETLINK_LOG, $(P_XT)nfnetlink_log))

# nfqueue

$(eval $(call nf_add,NFNETLINK_QUEUE,CONFIG_NETFILTER_NETLINK_QUEUE, $(P_XT)nfnetlink_queue))

#
# ebtables
#

$(eval $(if $(NF_KMOD),$(call nf_add,EBTABLES,CONFIG_BRIDGE_NF_EBTABLES, $(P_EBT)ebtables),))

# ebtables: tables
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_BROUTE, $(P_EBT)ebtable_broute))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_T_FILTER, $(P_EBT)ebtable_filter))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_T_NAT, $(P_EBT)ebtable_nat))

# ebtables: matches
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_802_3, $(P_EBT)ebt_802_3))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_AMONG, $(P_EBT)ebt_among))
$(eval $(call nf_add,EBTABLES_IP4,CONFIG_BRIDGE_EBT_ARP, $(P_EBT)ebt_arp))
$(eval $(call nf_add,EBTABLES_IP4,CONFIG_BRIDGE_EBT_IP, $(P_EBT)ebt_ip))
$(eval $(call nf_add,EBTABLES_IP6,CONFIG_BRIDGE_EBT_IP6, $(P_EBT)ebt_ip6))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_LIMIT, $(P_EBT)ebt_limit))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_MARK, $(P_EBT)ebt_mark_m))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_PKTTYPE, $(P_EBT)ebt_pkttype))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_STP, $(P_EBT)ebt_stp))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_VLAN, $(P_EBT)ebt_vlan))

# targets
$(eval $(call nf_add,EBTABLES_IP4,CONFIG_BRIDGE_EBT_ARPREPLY, $(P_EBT)ebt_arpreply))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_MARK_T, $(P_EBT)ebt_mark))
$(eval $(call nf_add,EBTABLES_IP4,CONFIG_BRIDGE_EBT_DNAT, $(P_EBT)ebt_dnat))
$(eval $(call nf_add,EBTABLES,CONFIG_BRIDGE_EBT_REDIRECT, $(P_EBT)ebt_redirect))
$(eval $(call nf_add,EBTABLES_IP4,CONFIG_BRIDGE_EBT_SNAT, $(P_EBT)ebt_snat))

# watchers
$(eval $(call nf_add,EBTABLES_WATCHERS,CONFIG_BRIDGE_EBT_LOG, $(P_EBT)ebt_log))
$(eval $(call nf_add,EBTABLES_WATCHERS,CONFIG_BRIDGE_EBT_ULOG, $(P_EBT)ebt_ulog))
$(eval $(call nf_add,EBTABLES_WATCHERS,CONFIG_BRIDGE_EBT_NFLOG, $(P_EBT)ebt_nflog))
$(eval $(call nf_add,EBTABLES_WATCHERS,CONFIG_BRIDGE_EBT_NFQUEUE, $(P_EBT)ebt_nfqueue))

# nftables
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NF_TABLES, $(P_XT)nf_tables, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NF_TABLES_INET, $(P_XT)nf_tables_inet, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_EXTHDR, $(P_XT)nft_exthdr, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_META, $(P_XT)nft_meta, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_CT, $(P_XT)nft_ct, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_RBTREE, $(P_XT)nft_rbtree, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_HASH, $(P_XT)nft_hash, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_COUNTER, $(P_XT)nft_counter, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_LOG, $(P_XT)nft_log, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_LIMIT, $(P_XT)nft_limit, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_REJECT, $(P_XT)nft_reject $(P_V4)nft_reject_ipv4 $(P_V6)nft_reject_ipv6, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_REJECT_INET, $(P_XT)nft_reject_inet, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NF_TABLES_IPV4, $(P_V4)nf_tables_ipv4, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_CHAIN_ROUTE_IPV4, $(P_V4)nft_chain_route_ipv4, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NF_TABLES_IPV6, $(P_V6)nf_tables_ipv6, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_CORE,CONFIG_NFT_CHAIN_ROUTE_IPV6, $(P_V6)nft_chain_route_ipv6, ge 3.14.0),))

$(eval $(if $(NF_KMOD),$(call nf_add,NFT_NAT,CONFIG_NFT_NAT, $(P_XT)nft_nat, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_NAT,CONFIG_NFT_CHAIN_NAT_IPV4, $(P_V4)nft_chain_nat_ipv4, ge 3.14.0),))
$(eval $(if $(NF_KMOD),$(call nf_add,NFT_NAT6,CONFIG_NFT_CHAIN_NAT_IPV6, $(P_V6)nft_chain_nat_ipv6, ge 3.14.0),))

# userland only
IPT_BUILTIN += $(NF_IPT-y) $(NF_IPT-m)
IPT_BUILTIN += $(IPT_CORE-y) $(IPT_CORE-m)
IPT_BUILTIN += $(NF_CONNTRACK-y)
IPT_BUILTIN += $(NF_CONNTRACK6-y)
IPT_BUILTIN += $(IPT_CONNTRACK-y)
IPT_BUILTIN += $(IPT_CONNTRACK_EXTRA-y)
IPT_BUILTIN += $(IPT_EXTRA-y)
IPT_BUILTIN += $(IPT_FILTER-y)
IPT_BUILTIN += $(IPT_IPOPT-y)
IPT_BUILTIN += $(IPT_IPRANGE-y)
IPT_BUILTIN += $(IPT_IPSEC-y)
IPT_BUILTIN += $(IPT_IPV6-y) $(IPT_IPV6-m)
IPT_BUILTIN += $(NF_NAT-y)
IPT_BUILTIN += $(NF_NAT6-y)
IPT_BUILTIN += $(IPT_NAT-y)
IPT_BUILTIN += $(IPT_NAT6-y)
IPT_BUILTIN += $(IPT_NAT_EXTRA-y)
IPT_BUILTIN += $(NF_NATHELPER-y)
IPT_BUILTIN += $(NF_NATHELPER_EXTRA-y)
IPT_BUILTIN += $(IPT_ULOG-y)
IPT_BUILTIN += $(IPT_DEBUG-y)
IPT_BUILTIN += $(IPT_TPROXY-y)
IPT_BUILTIN += $(NFNETLINK-y)
IPT_BUILTIN += $(NFNETLINK_LOG-y)
IPT_BUILTIN += $(NFNETLINK_QUEUE-y)
IPT_BUILTIN += $(EBTABLES-y)
IPT_BUILTIN += $(EBTABLES_IP4-y)
IPT_BUILTIN += $(EBTABLES_IP6-y)
IPT_BUILTIN += $(EBTABLES_WATCHERS-y)

endif # __inc_netfilter
