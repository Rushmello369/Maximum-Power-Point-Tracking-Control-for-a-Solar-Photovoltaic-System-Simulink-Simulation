# MPPT System Report

## Introduction

### 1. The Context: The Need for Smart Renewables

The global transition towards decarbonized energy is a primary engineering challenge of our time. As utilities like National Grid work to achieve Net Zero, the integration of renewable energy sources, particularly Solar Photovoltaic (PV) systems, has become a top priority. However, unlike traditional power plants, the output from a solar panel is intermittent and highly dependent on environmental factors. This creates a complex problem: how do we extract the maximum possible energy from a source that is constantly changing?

### 2. The Problem: The Non-Linearity of Solar Panels

A solar panel is a non-linear device. Its power output is not fixed; it is a complex function of the solar irradiance (sunlight intensity) and the panel's own cell temperature.

For any given set of conditions, a PV panel has a "Power-Voltage" (P-V) curve that shows a single, distinct peak. This peak is the **Maximum Power Point (MPP)**.

* If the system draws too little voltage, power is lost.
* If the system draws too much voltage, power is lost.
* To make matters worse, this peak *moves*. When a cloud passes, the irradiance drops, and the entire P-V curve shifts, establishing a new, lower MPP.



A simple system that just connects a panel directly to a load would be extremely inefficient, as it would almost never be operating at this peak.

### 3. The Solution: Maximum Power Point Tracking (MPPT)

The engineering solution is to "decouple" the panel from the load using a **DC-DC power converter** (like a Boost or Buck-Boost converter). This converter acts as a variable "gearbox" for the electrical energy.

This system is governed by a control algorithm called **Maximum Power Point Tracking (MPPT)**. This algorithm is the "brain" that continuously:
1.  **Measures** the panel's current voltage and current.
2.  **Calculates** the current power.
3.  **Decides** how to change the converter's duty cycle to *search* for a higher power output.
4.  **Repeats** this process thousands of times per second to actively track the MPP, even as it moves.

### 4. Project Objective

This report details the design, simulation, and validation of a complete PV system with a closed-loop MPPT controller, built entirely within the **MATLAB & Simulink** environment.

The primary objective is to build a robust simulation that proves the effectiveness of the **Perturb and Observe (P&O)** algorithm—one of the most common and foundational MPPT techniques.

This project is broken down into four key phases, which this report will detail:
1.  **Component Modeling:** Building and testing the individual `PV Array` and `DC-DC Boost Converter` in Simscape Electrical.
2.  **Control Design:** Implementing the P&O logic in a MATLAB Function block and integrating it with the power electronics.
3.  **System Testing:** Validating the controller's performance under both steady-state and dynamic (variable irradiance) conditions.
4.  **Analysis:** Analyzing the results, including the key engineering trade-off between tracking speed and steady-state efficiency.
---

## 1.1: Model and Test the PV Array

### Goal:

To build a model of a solar panel and understand its fundamental behaviour by tracing its I-V (Current-Voltage) and P-V (Power-Voltage) curves. This step is critical to visually confirm the Maximum Power Point (MPP).

### Step 1: Create the Model File and add essential blocks

1.Solver Configuration
2.PV Array
3.Variable Resistor
4.Voltage Sensor and Current Sensor
5.The "Converter" Blocks (CRITICAL):
-Simulink-PS Converter
-PS-Simulink Converter
6.Electrical Reference

Fig 1.11 Components 

### Step 2: Connect the components

Fig 1.12 Connection of the circuit

connect voltage sensor in parallel to the solar cell
connect current sensor in series with the cell and a variable resistor
use a Ramp and a Simulink-PS converter to control the variable resistor
use two PS-Simulink converter to collect data from the sensors

Step 3: IV Characteristics & PV Characteristics

Fig 1.13

I have added a constant 1000W/m^2   input for the solar cell, two xy graph blocks, and a multiplier.
Here's the results:

fig 1.14 IV-Characteristics



fig 1.15 PV-Characteristics


Plotting Better Graph using Matlab tools

collecting data using to workspace blocks

fig 1.16

fig 1.17 code


fig 1.18 IV


fig 1.19 PV  The maximum power point for a 1000 W/m^2 sunlight is approximately 200W with operating voltage of 30V

## 1.2 Model the DC-DC Converter

### Goal: To build a boost converter and verify its operation using a fixed DC input and a fixed duty cycle. 


### Step 1: Create a New Model & Add Basic Blocks

fig 1.21

Components:
-solver configuration
-voltage reference
-voltage source(input voltage, 30V)
-inductor(1mH)
-capacitor(470uF)
-diode
-MOSFET(Vth = 1V)
-resistor(50Ω)
-Pulse generator(frequency 25kHz, 5V amplitude, 50% Duty cycle)
-Voltage sensor
-scope

### Step 2: Measure the output voltage

fig 1.22

50% Duty cycle

 V_out/V_in =1/(1−D)

Set the Duty Cycle to 90%


fig 1.23

Gain is slightly less than 10x

The circuit is losing power (as heat) due to three "parasitic" elements:

1.  MOSFET Resistance : Your "on" switch isn't a perfect 0 Omega wire. It has a small resistance.
2.  Inductor Resistance : Your inductor is a long wire with its own resistance.
3.  Diode Voltage Drop : Your diode "taxes" the voltage (0.7V) every time energy passes through it.

At high duty cycles like 90%, the current  becomes extremely high. Since power loss in the resistors is I^2R, these small resistances create massive power losses, "stealing" voltage from your output.


What causes the spike:
The spike is the natural behaviour of your $LC$ circuit. You have two energy storage elements:
The Inductor and the Capacitor. Think of it like a spring ($C$) and a bowling ball ($L$).At the start, you "pull" the bowling ball back (storing energy in the inductor).When you "release" it (the MOSFET turns off), the energy is dumped into the capacitor.

The capacitor voltage doesn't just stop perfectly at 60V; the "momentum" of the inductor's energy ($L$) pushes it past the 60V mark, causing the overshoot. The voltage is now too high, so the energy sloshes back and forth between the $L$ and $C$. This is the ringing. The Resistor ($R$) acts as the "friction" or "damping" that burns off this extra energy, allowing the circuit to finally settle at its target 60V.

## 2.1 Integrate the System (Open-Loop Test)

### Step 1: Integrate the components

fig 2.11

Replaced the voltage source with the PV array
Remove unnecessary sensor blocks

### Step two: Measure the input power

fig 2.12

Add the current and voltage sensor to the input, and find their product to calculate the input power.
Set the values of the components:
R = 18.5
Duty cycle = 20%


fig 2.13

power = 100

Duty Cycle = 30%

fig 2.14

power = 125

Duty Cycle = 40%

fig 2.15

Power = 170

Duty Cycle = 50%

fig 2.16

Power = 200
Close to the maximum power point



## 2.2. Design the MPPT Algorithm (Closed-Loop)

Goal: To replace the manual Pulse Generator with an algorithm that automatically searches for the duty cycle that produces maximum power.

We will use the Perturb and Observe (P&O) algorithm. Its logic is simple:
Perturb: Nudge the duty cycle (D) in one direction (e.g., increase it).
Observe: Did the power (P) go up or down? If P went up, you moved in the right direction. Keep going. If P went down, you moved in the wrong direction. Turn around.

### Step 1: Create New Model

fig 2.21

Replace the pulse generator with a MatLab Function block, implementing the MPPT-controlling system

Code:
 
function dutyCycle = MPPT_PO(v, i)
    %#codegen
    % MPPT Perturb & Observe (P&O) Algorithm for Simscape PV System
    % Inputs: v = PV panel voltage (V), i = PV panel current (A)
    % Output: dutyCycle = Optimal duty cycle for Boost converter (0.1~0.8)
    
    % Persistent variables (store previous values between simulation steps)
    persistent P_prev V_prev D_prev;
    delta_D = 0.001;  % Small duty cycle step (balances speed/ stability)
    D_min = 0.1;      % Minimum duty cycle (avoid instability)
    D_max = 0.8;      % Maximum duty cycle (avoid inductor saturation)
    
    % Initialize persistent variables (first simulation step)
    if isempty(P_prev) || isempty(V_prev) || isempty(D_prev)
        P_prev = 0;       % Previous PV power
        V_prev = 0;       % Previous PV voltage
        D_prev = 0.5;     % Initial duty cycle (middle of safe range)
    end
    
    % Calculate current PV power
    P_curr = v * i;
    
    % Calculate changes in power and voltage
    delta_P = P_curr - P_prev;
    delta_V = v - V_prev;
    
    % P&O Logic: Adjust duty cycle based on power/voltage changes
    if delta_P > 1e-6  % Power increased → continue perturbation direction
        if delta_V > 1e-6  % Voltage increased → decrease duty cycle (Boost: Vout = Vin/(1-D))
            D_curr = D_prev - delta_D;
        else  % Voltage decreased → increase duty cycle
            D_curr = D_prev + delta_D;
        end
    else  % Power decreased → reverse perturbation direction
        if delta_V > 1e-6  % Voltage increased → increase duty cycle
            D_curr = D_prev + delta_D;
        else  % Voltage decreased → decrease duty cycle
            D_curr = D_prev - delta_D;
        end
    end
    
    % Limit duty cycle to safe range (0.1~0.8)
    D_curr = max(D_min, min(D_max, D_curr));
    
    % Update persistent variables for next simulation step
    P_prev = P_curr;
    V_prev = v;
    D_prev = D_curr;
    
    % Output optimal duty cycle to PWM Generator
    dutyCycle = D_curr;
end

Explanation:

The core control logic of the system is a Perturb and Observe (P and O) algorithm implemented within a MATLAB Function block. This algorithm continuously adjusts the operating point of the PV panel to maximize power extraction.

### Algorithm Overview
The P and O method works by introducing a small perturbation (change) to the duty cycle of the DC to DC converter and observing the resulting change in PV power.

If an increase in duty cycle leads to an increase in power, the algorithm continues to increase the duty cycle in the next step.

If an increase in duty cycle leads to a decrease in power, the algorithm reverses direction and decreases the duty cycle in the next step. This process repeats indefinitely, causing the operating point to oscillate around the true Maximum Power Point (MPP).

### Code Structure and Logic
The MATLAB code is structured to be efficient and compatible with code generation for real-time hardware.

Persistent Variables: Variables such as P_prev (previous power), V_prev (previous voltage), and D_prev (previous duty cycle) are declared as persistent. This allows the function to remember the state of the system from the previous simulation time step, which is essential for calculating the change in power and voltage.

Initialization: A conditional block checks if the persistent variables are empty (which occurs only at the very first simulation step). If they are, they are initialized to safe starting values. The initial duty cycle is set to 0.5.

Power Calculation: The current PV power is calculated by multiplying the instantaneous voltage and current inputs.

Perturbation Logic: A series of conditional statements compare the current power and voltage to their previous values. Based on these comparisons, the duty cycle is either incremented or decremented by a fixed step size (delta_D, set to 0.001).

Saturation: To prevent the duty cycle from reaching extreme values that could cause instability or component damage, it is limited between a minimum of 0.1 (10 percent) and a maximum of 0.8 (80 percent).

Update: Finally, the current values of power, voltage, and duty cycle are saved as the previous values for the next iteration.

Output Power & Operating Voltage


fig 2.22

### Explanation:

The scope displays the dynamic performance of the MPPT system over time. It plots two key signals: PV Power (yellow trace) and PV Voltage (blue trace).

#### Steady-State Performance
The simulation results confirm that the MPPT controller successfully tracks the maximum power point.

PV Power (Yellow Trace): The power signal settles at approximately 200 W. This matches the theoretical maximum power determined during the initial component characterization phase. The trace appears as a thick band rather than a thin line. This thickness represents the steady-state oscillation inherent to the P and O algorithm. The controller constantly steps the duty cycle up and down by 0.001, causing the power to fluctuate slightly around the absolute peak.

PV Voltage (Blue Trace): The voltage signal settles at approximately 30 V. This corresponds to the Voltage at Maximum Power (Vmpp) for the simulated PV panel under standard irradiance. Similar to the power trace, it shows a small, continuous oscillation as the controller actively maintains the operating point.

#### Dynamic Behavior
Start-up Transient: At the beginning of the simulation (time zero), the power starts at zero. The algorithm quickly ramps up the duty cycle, causing the power to rise. It may briefly overshoot the maximum point before settling into its steady-state oscillation pattern.

Tracking Speed vs Stability: The thickness of the signal bands and the time taken to reach steady state are determined by the algorithm step size (delta_D) and sample time. A larger step size would result in faster tracking but larger steady-state oscillations (thicker bands). The current settings (step size of 0.001 and sample time of 0.01 seconds) provide a good balance between tracking speed and steady-state efficiency.

## 3.1 Variable Weather Simulation
Goal: To simulate a passing cloud and verify that your MPPT algorithm can find the new maximum power point after a sudden change in sunlight.

### Step 1: Modify the Irradiance Input

Replace the Constant (1000 W/m²) block with a Step block to simulate a sudden drop in sunlight.

fig 3.11

Setup:
step time 1s
Initial value 1000
Final value 500

### Step 2: Run the simulation

The run time is now set to 3, which should include 1s of sunlight = 1000 W/m^2 and 2s of sunlight = 500 W/m^2.

First attempt:


fig 3.12

error occurs at t = 1s

Caused by:
    Solver was unable to reduce the step size without violating the minimum step size value of 3.55278E-15 for 1 consecutive times at time 1.00002. 

Quick fix:

Loosen the solver tolerance

fig 3.13

Second Attempt:


fig 3.14

the glitch is smaller but still exists

Final Fix:

Change the solver to fix-step, with sample time 1e-6.

fig 3.15

Result:

fig 3.16

Before 1s (Yellow line at ~200W): Your solar panel is receiving full sunlight (1000 W/m²). The MPPT controller has found the maximum power point, which is around 200W.

At t=1s (The Drop): This is where your Step block activates. It instantly changes the irradiance from 1000 W/m² down to 500 W/m².

After 1s (Yellow line at ~100W): With half the sunlight, the panel can only produce roughly half the power. The graph shows the power instantly dropping and then settling at the new maximum power point of around 100W.

## 3.2. Tune the Algorithm (Exploring Trade-offs)
Goal: To experimentally determine the best balance between tracking speed (how fast it finds the new peak after a cloud passes) and steady-state efficiency (how much it oscillates when sunny) by running three distinct experiment.

### Experiment 1: The "Balanced" Case (Baseline)

Settings:

MATLAB Function sample time: 0.01

Code delta_D: 0.002
sample time = 0.01 s

Result:

fig 3.21

Explanations


### Experiment 2: The Aggressive Case

delta_D = 0.02 (x10)


fig 3.22

explanations



### Experiment 3: Lazy Controller

delta_D = 0.002
sample time = 0.1


fig 3.33

## 4.Conclusion

This project successfully demonstrated the complete design, simulation, and validation of a closed-loop Maximum Power Point Tracking (MPPT) system for a solar photovoltaic (PV) array. Using MATLAB, Simulink, and the Simscape Electrical toolbox, a high-fidelity model was built from the component level up. This model accurately simulated a digital controller's ability to find and maintain the peak power output of a solar panel, even under dynamic, real-world conditions.

### The Design Process
The project followed a methodical, four-phase engineering process:

Component Characterization: The Solar Cell and DC-DC Boost Converter were built and tested in isolation. This "unit testing" was critical. It established the "ground truth" for the panel's P-V curve (a ~205W peak at ~30V) and validated the open-loop behavior of the converter, proving that its Duty Cycle was a viable control "knob."

System Integration: The components were combined into a full system. The core control "brain" was implemented using a MATLAB Function block.

Controller Tuning: The final, working system was subjected to a series of experiments to explore its performance trade-offs.

Documentation: All findings were consolidated.

### The Final System Algorithm
The complete system operates as a multi-rate digital control system.

The Physical Circuit (the Simscape components) runs with a very fast, fixed-step solver (1e-6 s) to accurately model the 25,000 Hz switching of the MOSFET.

The Digital Controller (the MATLAB Function block) runs at a much slower, discrete sample time (0.01 s, or 100 Hz), emulating a real-world microcontroller.

The controller's logic is a Perturb and Observe (P&O) algorithm. At each 0.01-second "tick," it:

Reads the panel's Voltage (V) and Current (I).

Calculates the current Power (P = V * I).

Compares this P to the P_prev (power from the last tick) stored in its persistent memory.

If power has increased, it keeps "nudging" the duty cycle in the same direction.

If power has decreased, it knows it "overshot" the peak and reverses the direction of its "nudge."

### Exploring Key Engineering Trade-Offs
The most important finding of this project was the validation of the central MPPT trade-off, discovered in Phase 3. The delta_D (step size) and Sample time parameters were tuned to observe their real-world effects:

Aggressive Tuning (Large delta_D): This controller showed a very fast dynamic response (it found the new peak almost instantly after a simulated cloud pass). However, it was extremely inefficient, suffering from huge, wasteful oscillations at steady-state as it constantly "jumped" over the peak.

Cautious Tuning (Slow Sample time): This controller was highly efficient at steady-state, with almost zero oscillation. However, it was unacceptably sluggish, taking a very long time to react to the "cloud" and losing significant energy during this slow "hunting" period.

This experiment proves that the "optimal" controller is a compromise. The final parameters (delta_D = 0.002, Sample time = 0.01s) were chosen as a good balance, providing high efficiency while still being fast enough to track moderate weather changes.

### Real-World Effects and Future Work
This simulation successfully modeled the key challenges of a real-world power electronics system. The non-ideal behavior of the converter at 90% duty cycle (due to resistive losses) and the steady-state oscillations of the P&O algorithm are not simulation errors; they are real, physical effects that engineers must design for.

The logical "next steps" to improve this design would be:

Implement an Adaptive P&O: A "smarter" algorithm where the delta_D step size automatically becomes smaller as the controller gets closer to the peak, providing the "best of both worlds": fast tracking and high efficiency.

Implement an Incremental Conductance (INC) Algorithm: A more advanced method that uses the mathematical slope of the P-V curve to find the peak and can, in theory, stop oscillating entirely once the peak is found, increasing overall energy capture.
