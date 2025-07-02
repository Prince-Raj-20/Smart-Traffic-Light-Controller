// Testbench: queue_tb.v
// Purpose: Tests the queue simulation by toggling car_detected multiple times

module tb_queue;
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

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    $dumpfile("queue_tb.vcd");
    $dumpvars(0, queue_tb);

    $monitor("Time=%0t | Lights=%b | Queue=%d", $time, lights, queue_count);

    // Apply reset
    rst = 1; #10; rst = 0;

    // Simulate cars arriving in bursts
    repeat (3) begin
      car_detected = 1; #20;  // Car present
      car_detected = 0; #10;  // No car
    end

    // Allow time for green light to decrement queue
    #100;

    $finish;
  end
endmodule