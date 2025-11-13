% --- Plotting Script for I-V and P-V Curves ---
%
% Run this script AFTER you have run your Simulink model.
% This script assumes your data is in a structure named 'out'.

% --- 1. Get Data from the 'out' Structure ---
V = out.Vout;
I = out.Iout;
P = out.Pout;

% --- 2. Plot the I-V Curve ---
figure(1); % Opens a new window (Figure 1)
plot(V, I, 'b-', 'LineWidth', 2); % 'b-' is a blue line

title('I-V Curve at 1000 W/m^2', 'FontSize', 14);
xlabel('Voltage (V)', 'FontSize', 12);
ylabel('Current (A)', 'FontSize', 12);
grid on;
axis tight; % Sets axes to fit the data

% --- 3. Plot the P-V Curve ---
figure(2); % Opens a second window (Figure 2)
plot(V, P, 'r-', 'LineWidth', 2); % 'r-' is a red line

title('P-V Curve at 1000 W/m^2', 'FontSize', 14);
xlabel('Voltage (V)', 'FontSize', 12);
ylabel('Power (W)', 'FontSize', 12);
grid on;
axis tight; % Sets axes to fit the data

disp('I-V and P-V plots generated successfully.');