//----------------------------------------------------------------------
//   Copyright 2013 Freescale Semiconductor, Inc.
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_dynamic_range_constraint extends uvm_dynamic_range_constraint;
  constraint my_constraint
  { value inside {[1:5]};}
endclass: my_dynamic_range_constraint

class rnd_class extends uvm_component;
  rand uvm_dynamic_range_constraint drc1;
  rand uvm_dynamic_range_constraint drc2;
  rand uvm_dynamic_range_constraint drc3;
  rand uvm_dynamic_range_constraint drc5;
  `uvm_component_utils_begin(rnd_class)
    `uvm_field_object(drc1, UVM_DEFAULT)
    `uvm_field_object(drc2, UVM_DEFAULT)
    `uvm_field_object(drc3, UVM_DEFAULT)
    `uvm_field_object(drc5, UVM_DEFAULT)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drc1 = uvm_dynamic_range_constraint::type_id::create("RANDINT1");
    drc2 = uvm_dynamic_range_constraint::type_id::create("RANDINT2");
    drc3 = uvm_dynamic_range_constraint::type_id::create("RANDINT3");
    drc5 = uvm_dynamic_range_constraint::type_id::create("RANDINT5");
    apply_config_settings();
  endfunction
endclass: rnd_class

class test extends uvm_test;
   rnd_class rnd;
   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual task run();
      uvm_top.stop_request();
   endtask: run

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     rnd = rnd_class::type_id::create("top.@us", this);
   endfunction

   virtual function void report();
     int unsigned weight[string][int unsigned];
     int unsigned check_weight[string][int unsigned];
     string check_param[3];

     int unsigned temp;
     int unsigned index;
     int unsigned error = 0;

     const int unsigned NUM_ITERATIONS = 100000;

     // Weights are not exact promises of statistical balance,
     // so give a little (7%) slack.
     // 7% is the smallest amount of slack we can tolerate and still
     // pass on all 3 simulators
     const int unsigned WEIGHT_MARGIN  = NUM_ITERATIONS * 0.07;

     // Set the hardcoded check weight for "0xF:0x10:1; 2:3:2"
     check_param[0] = "RANDINT1";
     check_weight["RANDINT1"]['hF]  = (NUM_ITERATIONS / 6);  // i.e. ((1/6) * NUM_ITERATIONS)
     check_weight["RANDINT1"]['h10] = (NUM_ITERATIONS / 6);
     check_weight["RANDINT1"][2]    = (NUM_ITERATIONS / 3);  // i.e. (2/6) * NUM_ITERATIONS)
     check_weight["RANDINT1"][3]    = (NUM_ITERATIONS / 3);

     // Set the hardcoded check weight for "5"
     check_param[1] = "RANDINT2";
     check_weight["RANDINT2"][5] = NUM_ITERATIONS;

     // Set the hardcoded check weight for "1:4"
     check_param[2] = "RANDINT3";
     check_weight["RANDINT3"][1] = NUM_ITERATIONS / 4;
     check_weight["RANDINT3"][2] = NUM_ITERATIONS / 4;
     check_weight["RANDINT3"][3] = NUM_ITERATIONS / 4;
     check_weight["RANDINT3"][4] = NUM_ITERATIONS / 4;

     for(int unsigned index = 0; index != NUM_ITERATIONS; ++index)
     begin
       void'(rnd.randomize());
       weight["RANDINT1"][rnd.drc1.value]++;
       weight["RANDINT2"][rnd.drc2.value]++;
       weight["RANDINT3"][rnd.drc3.value]++;
     end
     
     foreach(check_param[param_index])
     begin
       string param = check_param[param_index];
       int unsigned u_index;

       $write("\n\nStatistics for %0d randomizations of constraint %s:", NUM_ITERATIONS, param);
       if (weight[param].first(index))
         do
         begin
           $cast(u_index, index);
           $write("\n  %0d was chosen %0d times", u_index, weight[param][index]);
           if (!check_weight[param].exists(index))
           begin
             $write(", outside the range of expected times: [0,0]");
             error = 1;
           end

           else if (weight[param][index] < check_weight[param][index] - WEIGHT_MARGIN || weight[param][index] > check_weight[param][index] + WEIGHT_MARGIN)
           begin
             $write(", outside the range of expected times: [%0d, %0d]", check_weight[param][index] - WEIGHT_MARGIN, check_weight[param][index] + WEIGHT_MARGIN );
             error = 1;
           end
         end
         while(weight[param].next(index));
      end

     // Check the correctness
     if (error)
        $write("\n** UVM TEST FAILED **\n");
     else
        $write("\n** UVM TEST PASSED **\n");
   endfunction: report

endclass: test

initial run_test();

endprogram: top