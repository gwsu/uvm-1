//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

`timescale 1ns / 1ns

package lower_pkg;

import uvm_pkg::*;

`include "lower_item.sv"
`include "lower_drv.sv"
`include "lower_mon.sv"

typedef uvm_sequencer#(lower_item) lower_sqr;

`include "lower_agt.sv"

endpackage