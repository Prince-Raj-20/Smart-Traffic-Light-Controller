// Testbench: emergency_tb.v
// Purpose: Tests emergency override logic during normal traffic operation

module emergency_tb;
  reg clk = 0, rst = 0, car_detected = 0, emergency = 0;
  wire [2:0] lights;
  wire [3:0] queue_count;

  // Instantiate DUT
  smart_traffic_light dut (
    .clk(clk), .rst(rst),
    .car_detected(car_detected),
    .emergency(emergency),
    .lights(lights),
    .queue_count(queue_count)
  );

  // Generate 10ns clock period
  always #5 clk = ~clk;

  initial begin
    $dumpfile("emergency_tb.vcd");
    $dumpvars(0, emergency_tb);

    $monitor("Time=%0t | Lights=%b | Queue=%d | Emergency=%b", $time, lights, queue_count, emergency);

    // Reset and normal flow start
    rst = 1; #10; rst = 0;
    car_detected = 1;           // Simulate car presence
    #30;

    // Trigger emergency override
    emergency = 1;
    #30;
    emergency = 0;              // Emergency ends

    #50;                        // Observe return to normal operation

    $finish;
  end
endmodule