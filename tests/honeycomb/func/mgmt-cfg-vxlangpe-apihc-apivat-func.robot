# Copyright (c) 2016 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Variables ***
# Interface to run tests on.
| ${interface}= | ${node['interfaces']['port1']['name']}

# Parameters to be set on existing interface
| ${vxlan_gpe_existing_if}= | ${interface}
| &{vxlan_gpe_base_wrong_interface_settings}=
| ... | name=${vxlan_gpe_existing_if}
| ... | type=iana-if-type:ethernetCsmacd
| ... | description=for testing purposes
| ... | enabled=true
| ... | link-up-down-trap-enable=enabled
| &{vxlan_gpe_wrong_interface_settings}=
| ... | local=192.168.50.77
| ... | remote=192.168.50.72
| ... | vni=${9}
| ... | next-protocol=wrong_ipv4
| ... | encap-vrf-id=${0}
| ... | decap-vrf-id=${0}

*** Settings ***
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/honeycomb/honeycomb.robot
| Resource | resources/libraries/robot/honeycomb/interfaces.robot
| Resource | resources/libraries/robot/honeycomb/vxlan_gpe.robot
# Import additional VxLAN GPE settings from resource file
| Variables | resources/test_data/honeycomb/vxlan_gpe.py
| ...
| Documentation | *Honeycomb VxLAN-GPE management test suite.*
| ...
| Suite Setup | Set Up Honeycomb Functional Test Suite | ${node}
| ...
| Suite Teardown | Tear Down Honeycomb Functional Test Suite | ${node}

*** Test Cases ***
| TC01: Honeycomb creates VxLAN GPE tunnel
| | [Documentation] | Check if Honeycomb API can configure a VxLAN GPE tunnel.
| | ...
| | [Tags] | HC_FUNC
| | Given interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if1}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${vxlan_gpe_if1}
| | When Honeycomb creates VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_if1}
| | ... | ${vxlan_gpe_base_settings} | ${vxlan_gpe_settings}
| | Then VxLAN GPE Operational Data From Honeycomb Should Be
| | ... | ${node} | ${vxlan_gpe_if1}
| | ... | ${vxlan_gpe_base_settings} | ${vxlan_gpe_settings}
| | And VxLAN GPE Operational Data From VAT Should Be
| | ... | ${node} | ${vxlan_gpe_if1} | ${vxlan_gpe_settings}
| | And VxLAN GPE Interface indices from Honeycomb and VAT should correspond
| | ... | ${node} | ${vxlan_gpe_if1}

| TC02: Honeycomb removes VxLAN GPE tunnel
| | [Documentation] | Check if Honeycomb API can remove VxLAN GPE tunnel.
| | ...
| | [Tags] | HC_FUNC
| | Given VxLAN GPE Operational Data From Honeycomb Should Be
| | ... | ${node} | ${vxlan_gpe_if1}
| | ... | ${vxlan_gpe_base_settings} | ${vxlan_gpe_settings}
| | VxLAN GPE Operational Data From VAT Should Be
| | ... | ${node} | ${vxlan_gpe_if1} | ${vxlan_gpe_settings}
| | When Honeycomb removes VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_if1}
| | Then VxLAN GPE Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if1}
| | And VxLAN GPE Operational Data From VAT Should Be empty
| | ... | ${node}

| TC03: Honeycomb sets wrong interface type while creating VxLAN GPE tunnel
| | [Documentation] | Check if Honeycomb refuses to create a VxLAN GPE tunnel\
| | ... | with a wrong interface type set.
| | ...
| | [Tags] | HC_FUNC
| | Given interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if2}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${vxlan_gpe_if2}
| | When Honeycomb fails to create VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_if2}
| | ... | ${vxlan_gpe_wrong_type_base_settings} | ${vxlan_gpe_settings}
| | Then interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if2}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${vxlan_gpe_if2}

| TC04: Honeycomb sets wrong protocol while creating VxLAN GPE tunnel
| | [Documentation] | Check if Honeycomb refuses to create a VxLAN GPE tunnel\
| | ... | with a wrong next-protocol set.
| | ...
| | [Tags] | HC_FUNC
| | Given interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if3}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${vxlan_gpe_if3}
| | When Honeycomb fails to create VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_if3}
| | ... | ${vxlan_gpe_wrong_protocol_base_settings}
| | ... | ${vxlan_gpe_wrong_protocol_settings}
| | Then interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if3}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${vxlan_gpe_if3}

| TC05: Honeycomb sets VxLAN GPE tunnel on existing interface with wrong type
| | [Documentation] | Check if Honeycomb refuses to create a VxLAN GPE tunnel\
| | ... | on existing interface with wrong type.
| | ...
| | [Tags] | HC_FUNC
| | Given VxLAN GPE Operational Data From VAT Should Be empty
| | ... | ${node}
| | When Honeycomb fails to create VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_existing_if}
| | ... | ${vxlan_gpe_base_wrong_interface_settings}
| | ... | ${vxlan_gpe_wrong_interface_settings}
| | Then VxLAN GPE Operational Data From VAT Should Be empty
| | ... | ${node}

| TC06: Honeycomb creates VxLAN GPE tunnel with ipv6
| | [Documentation] | Check if Honeycomb API can configure a VxLAN GPE tunnel\
| | ... | with IPv6 addresses.
| | ...
| | [Tags] | HC_FUNC
| | Given VxLAN GPE Operational Data From VAT Should Be empty
| | ... | ${node}
| | And VxLAN GPE Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if5}
| | When Honeycomb creates VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_if5}
| | ... | ${vxlan_gpe_base_ipv6_settings} | ${vxlan_gpe_ipv6_settings}
| | Then VxLAN GPE Operational Data From Honeycomb Should Be
| | ... | ${node} | ${vxlan_gpe_if5}
| | ... | ${vxlan_gpe_base_ipv6_settings} | ${vxlan_gpe_ipv6_settings}
| | And Run Keyword And Continue On Failure
| | ... | VxLAN GPE Operational Data From VAT Should Be
| | ... | ${node} | ${vxlan_gpe_if5} | ${vxlan_gpe_ipv6_settings}
| | And VxLAN GPE Interface indices from Honeycomb and VAT should correspond
| | ... | ${node} | ${vxlan_gpe_if5}

| TC07: Honeycomb creates a second VxLAN GPE tunnel with ipv6
| | [Documentation] | Check if Honeycomb API can configure another VxLAN\
| | ... | GPE tunnel with IPv6 addresses.
| | ...
| | [Tags] | HC_FUNC
| | Given interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${vxlan_gpe_if6}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${vxlan_gpe_if6}
| | When Honeycomb creates VxLAN GPE interface
| | ... | ${node} | ${vxlan_gpe_if6}
| | ... | ${vxlan_gpe_base_ipv6_settings2} | ${vxlan_gpe_ipv6_settings2}
| | Then VxLAN GPE Operational Data From Honeycomb Should Be
| | ... | ${node} | ${vxlan_gpe_if6}
| | ... | ${vxlan_gpe_base_ipv6_settings2} | ${vxlan_gpe_ipv6_settings2}
| | And VxLAN GPE Operational Data From VAT Should Be
| | ... | ${node} | ${vxlan_gpe_if6} | ${vxlan_gpe_ipv6_settings2}
| | And VxLAN GPE Interface indices from Honeycomb and VAT should correspond
| | ... | ${node} | ${vxlan_gpe_if6}
