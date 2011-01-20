//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc.
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

module test;

import uvm_pkg::*;

class base_class extends uvm_sequence_item;
  rand int a;

  `uvm_object_utils_begin(base_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
  }

  function new(string name="base_class");
    super.new(name);
  endfunction

endclass

class my_class extends uvm_sequence_item;

  rand int a;
  base_class b;

  `uvm_object_utils_begin(my_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
    `uvm_field_object(b, UVM_ALL_ON|UVM_DEEP)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
  }

  function new(string name="my_class");
    super.new(name);
    b = null;
  endfunction

endclass

class test extends uvm_test;

  `uvm_new_func
  `uvm_component_utils(test)

  task run;
    my_class class_a, class_b;

    class_a = new("class_a");
    class_b = new("class_b");

    assert(class_a.randomize());

    class_b.copy(class_a);

    class_a.print();
    class_b.print();

    if (!class_a.compare(class_b)) begin
       `uvm_error("EPILOG", "Object did not copy or compare");
    end

    global_stop_request();
  endtask

   function void report();
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
      
   endfunction

endclass

initial
  run_test("test");

endmodule
