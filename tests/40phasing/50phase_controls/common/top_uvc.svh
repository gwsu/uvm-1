typedef enum { TOP_WRITE, TOP_READ } top_cmd_t;

class top_item extends uvm_sequence_item;
  rand top_cmd_t cmd;
  rand int unsigned addr; constraint c1 { addr < 16'h1500; }
  rand int unsigned data; constraint c2 { data < 16'h2500; }

  `uvm_object_utils_begin( top_item)
    `uvm_field_enum (top_cmd_t, cmd, UVM_ALL_ON);
  `uvm_object_utils_end

  function new( string name = "top_item" );
    super.new( name );
  endfunction : new

endclass : top_item

class top_sequencer extends uvm_sequencer #(top_item);
  `uvm_sequencer_utils_begin(top_sequencer)
  `uvm_sequencer_utils_end

  // new - constructor
  function new (string name="top_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(top_item);
    count = 0;
  endfunction : new
endclass : top_sequencer

class top_sequence extends uvm_sequence #(top_item);
  `uvm_sequence_utils_begin(top_sequence, top_sequencer)
    `uvm_field_object ( req, UVM_ALL_ON )
  `uvm_sequence_utils_end

endclass : top_sequence

class top_driver extends uvm_driver#(top_item);
  `uvm_component_utils_begin(top_driver)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual task run_phase();
    fork
      get_and_drive();
      reset_signals();
    join;
  endtask : run_phase

  // get_and_drive
  virtual protected task get_and_drive();
    top_item  this_item;

    forever begin
      seq_item_port.get_next_item(this_item); // Get the next data item the sequencer
      drive_item(this_item);                  // Drive it to the pins
      seq_item_port.item_done();              // Give the control back the the sequencer
    end
  endtask : get_and_drive

  // reset_signals
  virtual protected task reset_signals();
    //forever begin
    //Wait for the reset events (pre_reset_phase, reset_phase, post_reset_phase)
    //disable drive_item;
    //end
  endtask : reset_signals

  // drive_item
  virtual protected task drive_item (top_item item);
    void'(item.begin_tr( $time ));
    #(3);
    `uvm_info( "TOP_DRIVE", $sformatf("Done driving item %s, addr=%X, data=%X ",
                                      item.cmd.name(), item.addr, item.data), UVM_NONE);
  endtask : drive_item

  task stop_driving();
    disable get_and_drive;
    disable reset_signals;
  endtask : stop_driving

  task post_shutdown_phase();
    stop_driving();
  endtask : post_shutdown_phase

endclass : top_driver

class top_agent extends uvm_agent;
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;

  top_driver    driver;
  top_sequencer sequencer;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(top_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build
  function void build_phase();
    super.build();
    if(is_active == UVM_ACTIVE) begin
      sequencer  = top_sequencer::type_id::create( {get_name(), "_sequencer"}, this);
      driver = top_driver::type_id::create( {get_name(), "_driver"}, this);
    end
  endfunction : build_phase

  // connect_phase
  function void connect_phase();
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : top_agent

class top_env extends uvm_env;
  top_agent agent;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(top_env)
  `uvm_component_utils_end

  // new - constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build
  function void build_phase();
    agent  = top_agent::type_id::create( get_name(), this);
  endfunction : build_phase

endclass : top_env