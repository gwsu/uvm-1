//Test: jump phases
//  - During main phase, jump back to reset phase 3 time
//     then jump forward to shutdown phase

module top;
  import uvm_pkg::*;
`include "../common/common.svh"

class test extends test_base;
  static int jump_reset_num = 3;  // Jump to reset phase 3 time

  function new(string name = "03killing", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  `uvm_component_utils(test);

  task main_phase(uvm_phase_schedule phase);
    #20;
    if( jump_reset_num ) begin
      `uvm_info( "JUMP_RESET", $psprintf("Jump backward to reset phase from : main"), UVM_NONE);
      jump_reset_num --;

      jump( uvm_reset_ph );
    end
    #10;
    //now jump to shutdown (skip post_main and pre_shutdown)
    `uvm_info( "JUMP_SHUTDOWN", $psprintf("Jump forward to shutdown phase from : main"), UVM_NONE);
    jump( uvm_shutdown_ph );
  endtask : main_phase

  function void check_phase();
//normal test
//  [top_random_seq]    10
//  [bot_random_seq]    24
//In this jumping test
//  [top_random_seq]    26
//  [bot_random_seq]    56

    uvm_report_server svr = _global_reporter.get_report_server();

    int e_jr_c =3;
    int jr_c   = svr.get_id_count( "JUMP_RESET" );

    int e_js_c =1;
    int js_c   = svr.get_id_count( "JUMP_SHUTDOWN" );

    int e_trs_c=26;
    int trs_c  = svr.get_id_count( "top_random_seq" );

    int e_brs_c=56;
    int brs_c  = svr.get_id_count( "bot_random_seq" );

    int e_pm_c =0;  // Due to jump to shutdown from main, no post_main messages
    int pm_c   = svr.get_id_count( "pre_shutdown" );

    int e_prs_c=0; // Due to jump to shutdown from main, no post_main messages
    int prs_c  = svr.get_id_count( "pre_shutdown" );

    if( jr_c != e_jr_c ) begin
      `uvm_error( "ID_COUNT", $psprintf( "Expected %1d %s message(s).  Got %1d",
                                         e_jr_c, "JUMP_RESET", jr_c));
    end

    if( js_c != e_js_c ) begin
      `uvm_error( "ID_COUNT", $psprintf( "Expected %1d %s message(s).  Got %1d",
                                         e_js_c, "JUMP_SHUTDOWN", js_c));
    end

    if( trs_c != e_trs_c ) begin
      `uvm_error( "ID_COUNT", $psprintf( "Expected %1d [%s] message(s).  Got %1d",
                                         e_trs_c, "top_random_seq", trs_c));
    end

    if( brs_c != e_brs_c) begin
      `uvm_error( "ID_COUNT", $psprintf( "Expected %1d [%s] message(s).  Got %1d",
                                         e_brs_c, "bottom_random_seq", brs_c));
    end

    if( pm_c != e_pm_c) begin
      `uvm_error( "ID_COUNT", $psprintf( "Expected %1d [%s] message(s).  Got %1d",
                                         e_pm_c, "post_main", pm_c));
    end

    if( prs_c != e_prs_c) begin
      `uvm_error( "ID_COUNT", $psprintf( "Expected %1d [%s] message(s).  Got %1d",
                                         e_prs_c, "pre_shutdown", prs_c));
    end
  endfunction : check_phase

endclass : test

  initial begin
    fork
      run_test();
      #3000 begin
        `uvm_error( "TIMEOUT", "TIME OUT OCCURED." );
        uvm_top.stop_request();
      end
    join
  end
endmodule : top