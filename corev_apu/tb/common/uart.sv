// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Unknown
// Date: Unknown
// Description: This module takes data over UART and prints them to the console
//              A string is printed to the console as soon as a '\n' character is found

import uvm_pkg::*;

`include "uvm_macros.svh"

interface uart_bus #(
    parameter int unsigned BAUD_RATE = 115200,
    parameter int unsigned PARITY_EN = 0
)(
    input  logic rx,
    output logic tx,
    input  logic rx_en
);

/* pragma translate_off */
`ifndef VERILATOR
  localparam time BIT_PERIOD = (1000000000 / BAUD_RATE) * 1ns;

  logic [7:0]       character;
  logic [256*8-1:0] stringa;
  logic             parity;
  integer           charnum;
  integer           file;

  string binary = "";
  string litmus;
  string litmus_file;
  static uvm_cmdline_processor uvcl = uvm_cmdline_processor::get_inst();

  initial begin
    tx   = 1'bZ;
    void'(uvcl.get_arg_value("+PRELOAD=", binary));
    if (binary != "") begin
      litmus = litmus_name();
      litmus_file = {"./log/",litmus,".log"};
      file = $fopen(litmus_file,"w");
      $fwrite(file, "Test %s Allowed\n",litmus);
      $fwrite(file, "Histogram\n");
    end else begin
      file = $fopen("uart", "w");
    end 
  end

  always begin
    if (rx_en) begin
      @(negedge rx);
      #(BIT_PERIOD/2);
      for (int i = 0; i <= 7; i++) begin
        #BIT_PERIOD character[i] = rx;
      end

      if (PARITY_EN == 1) begin
        // check parity
        #BIT_PERIOD parity = rx;

        for (int i=7;i>=0;i--) begin
          parity = character[i] ^ parity;
        end

        if (parity == 1'b1) begin
          $display("Parity error detected");
        end
      end

      // STOP BIT
      #BIT_PERIOD;

      $fwrite(file, "%c", character);
      stringa[(255-charnum)*8 +: 8] = character;
      if (character == 8'h0A || charnum == 254) begin // line feed or max. chars reached
        if (character == 8'h0A) begin
          stringa[(255-charnum)*8 +: 8] = 8'h0; // null terminate string, replace line feed
        end else begin
          stringa[(255-charnum-1)*8 +: 8] = 8'h0; // null terminate string
        end

        $write("[UART]: %s\n", stringa);

        if (stringa[(255-charnum+1)*8 +: 8*4] == "Time") begin
          $display("[UART] Finish test");
          #1000
          $finish;
        end
        charnum = 0;
        stringa = "";
      end else begin
        charnum = charnum + 1;
      end
    end else begin
      charnum = 0;
      stringa = "";
      #10;
    end
  end

  task send_char(input logic [7:0] c);
    int i;

    // start bit
    tx = 1'b0;

    for (i = 0; i < 8; i++) begin
      #(BIT_PERIOD);
      tx = c[i];
    end

    // stop bit
    #(BIT_PERIOD);
    tx = 1'b1;
    #(BIT_PERIOD);
  endtask
`endif

  function string litmus_name(); 

    for (int i = binary.len()-1; i > -1; i--) begin
      if(binary[i] == "/") begin
        return binary.substr(i+1,binary.len()-5);
      end
    end
  endfunction : litmus_name
/* pragma translate_on */
endinterface
