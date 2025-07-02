// Description: Verilog implementation of a Smart Traffic Light Controller with car detection,
// emergency override, and a simple queue management system.
//
// Features:
// - FSM-based control of traffic light (Green, Yellow, Red)
// - Pedestrian button or car sensor input (car_detected)
// - Emergency override for ambulances, fire trucks, etc.
// - Queue count increments with each detected car
// - FSM transitions based on queue and emergency state

module smart_traffic_light (
  input wire clk,              // Clock signal
  input wire rst,              // Reset signal (active high)
  input wire car_detected,     // Input from sensor or pedestrian button
  input wire emergency,        // Emergency override input
  output reg [2:0] lights,     // Output light signal: [Red, Yellow, Green]
  output reg [3:0] queue_count // Queue count for basic traffic estimation
);

  // FSM state encoding
  localparam RED         = 3'd0;
  localparam RED_YELLOW  = 3'd1;
  localparam GREEN       = 3'd2;
  localparam YELLOW      = 3'd3;
  localparam EMERGENCY   = 3'd4;

  reg [2:0] state, next_state;
  reg [3:0] count;

  // FSM state transition
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= RED;
      count <= 0;
      queue_count <= 0;
    end else begin
      // Emergency override priority
      if (emergency) begin
        state <= EMERGENCY;
        count <= 0;
      end else begin
        // Queue update logic
        if (car_detected && state != GREEN && queue_count < 15)
          queue_count <= queue_count + 1;
        else if (state == GREEN && queue_count > 0 && count == 1)
          queue_count <= queue_count - 1;

        // Normal FSM timing logic
        if ((state == RED && count >= 5) ||
            (state == RED_YELLOW && count >= 2) ||
            (state == GREEN && count >= (queue_count >= 3 ? 6 : 3)) ||
            (state == YELLOW && count >= 2) ||
            (state == EMERGENCY && !emergency)) begin
          state <= next_state;
          count <= 0;
        end else begin
          count <= count + 1;
        end
      end
    end
  end

  // FSM next state logic
  always @(*) begin
    case (state)
      RED:         next_state = RED_YELLOW;
      RED_YELLOW:  next_state = (queue_count > 0) ? GREEN : RED;
      GREEN:       next_state = YELLOW;
      YELLOW:      next_state = RED;
      EMERGENCY:   next_state = RED;
      default:     next_state = RED;
    endcase
  end

  // Output logic
  always @(*) begin
    case (state)
      RED:        lights = 3'b100;
      RED_YELLOW: lights = 3'b110;
      GREEN:      lights = 3'b001;
      YELLOW:     lights = 3'b010;
      EMERGENCY:  lights = 3'b100;  // All RED or custom pattern
      default:    lights = 3'b000;
    endcase
  end

endmodule