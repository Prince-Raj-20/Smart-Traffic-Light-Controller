// Testbench: basic_tb.v
// Purpose: Simulates normal traffic operation with car detection and verifies FSM transitions

module basic_tb;
  reg clk = 0, rst = 0, car_detected = 0, emergency = 0;
  wire [2:0] lights;           // Output traffic lights: [Red, Yellow, Green]
  wire [3:0] queue_count;      // Simulated queue counter

  // Instantiate the DUT (Device Under Test)
  smart_traffic_light dut (
    .clk(clk), .rst(rst),
    .car_detected(car_detected),
    .emergency(emergency),
    .lights(lights),
    .queue_count(queue_count)
  );

  // Clock generation: 10 time units period (5 high, 5 low)
  always #5 clk = ~clk;

  initial begin
    // GTKWave setup
    $dumpfile("basic_tb.vcd");
    $dumpvars(0, basic_tb);

    // Monitor signals in console
    $monitor("Time=%0t | Lights=%b | Queue=%d | Emergency=%b", $time, lights, queue_count, emergency);

    // Initial reset pulse
    rst = 1; #10;
    rst = 0;

    // Simulate car detected for 100 time units
    car_detected = 1;
    #100;
    car_detected = 0;

    // Continue running to allow FSM to complete a few cycles
    #100;

    $finish;
  end
endmodule