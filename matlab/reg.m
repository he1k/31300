classdef reg
   properties
       file         % Filename 
       data         % Regbot data
       param = [];  % Collect all parameters above
       figcnt       % Under development
   end
   methods
       %{
           Basic constructor
               Calling: myObject = myObject("AbsoluteDestinationToFile")
       %}
       function obj = reg(File)
           obj.file = File;
           obj.figcnt = 1;
           obj.data = table2array(readtable(obj.file));
           obj.param = dtype("t [sec]","Time",obj.data(:, 1));
           obj.param(end+1) = dtype("v [m/s]","Left motor velocity",obj.data(:, 6));
           obj.param(end+1) = dtype("v [m/s]","Rigt motor velocity",obj.data(:, 7));
           obj.param(end+1) = dtype("U [V]","Left motor voltage",obj.data(:, 8));
           obj.param(end+1) = dtype("U [V]","Right motor voltage",obj.data(:, 9));
           obj.param(end+1) = dtype("I [A]","Left motor current",obj.data(:, 10));
           obj.param(end+1) = dtype("I [A]","Rigt motor current",obj.data(:, 11));
           obj.param(end+1) = dtype("v [m/s]","Left wheel velocity",obj.data(:, 12));
           obj.param(end+1) = dtype("v [m/s]","Rigt wheel velocity",obj.data(:, 13));
           obj.param(end+1) = dtype("l [m]","Position x",obj.data(:, 14));
           obj.param(end+1) = dtype("l [m]","Position y",obj.data(:, 15));
           obj.param(end+1) = dtype("\theta [rad]","Heading",obj.data(:, 16));
           obj.param(end+1) = dtype("\theta [rad]","Tilt",obj.data(:, 17));
           obj.param(end+1) = dtype("U [V]","Battery voltage",obj.data(:, 18));
           
           
       end
       %{
           Setter method for setting file and loading in new measurements.
               Calling: myObject.setfile("AbsoluteDestinationToFile")
       %}
       function setfile(obj, File)
          obj = reg(File); 
       end
       %{
           Subfunction for converting caller mnemonic into array index.
           This is never called directly by user.
       %}
       function index = str2index(obj,str)
           switch str
               case "mvel" % Motor velocity
                   index = 2;
               case "mvol" % Motor voltage
                   index = 4;
               case "mcur" % Motor current
                   index = 6;
               case "wvel" % Wheel velocity
                   index = 8;
               case "xpos" % X position
                   index = 10;
               case "ypos" % Y position
                   index = 11;
               case "head" % Heading
                   index = 12;
               case "tilt" % Tilt
                   index = 13;
               case "bvol" % Battery voltage
                   index = 14;
               otherwise
                   fprintf("ERROR: Can't find the datatype\n"); 
                   index = 1; % This error can only happen if class is
                              % written incorrect.
           end
       end
       %{
           Subfunction for doing one plot. If dual is true, the function
           will plot two measurements in one plot. Only used for plotting
           right+left, x+y or head+tilt together. 
           This is never called directly by user.
       %}
       function singleplot(obj, name, meas, dual)
           hold off
           i= obj.str2index(meas);
           plot(obj.param(1).data, obj.param(i).data, "r","LineWidth", 1)
           grid on
           grid minor
           [t,s] = title("REGBOT: ELLA",name);
           t.FontSize = 16;
           s.FontSize = 12;
           s.FontAngle = "italic";
           x = xlabel(obj.param(1).label);
           y = ylabel(obj.param(i).label);
           x.FontSize = 13;
           y.FontSize = 13;
           if(dual && i < 14)
               hold on
               plot(obj.param(1).data, obj.param(i+1).data,"b","LineWidth", 1)
               legend(obj.param(i).name, obj.param(i+1).name,"FontSize",13,"Location","southoutside")
           else
               legend(obj.param(i).name,"FontSize",13,"Location","southoutside")
           end
       end
       %{
           Function called by user to plot measurements. All parameters are
           given as either arrays or single values. Name is what will be
           written as the title, meas is the kind of measurement that will
           be plotted and dual states whether not there will be two graphs
           in one plot.
       
           Example of input:
           name = ["Motor velocity", "Motor current"], meas =
           ["mvel","mcur"], dual = [true, false].
       
           General layout of figure:
           %{
               1 plot => 1*1 plot
               2 plot => 2*1 plot
               3 plot => 2*2 plot
               4 plot => 2*2 plot
               5 plot => 2*3 plot
               6 plot => 2*3 plot
               7 plot => 3*3 plot
               8 plot => 3*3 plot
           %}
       %}
       function multiplot(obj, name, meas, dual)
           n = length(name);
           if n == 0 % Nothing to plot
               return
           end
           figure
           row = 3;
           col = 3;
           if n < 7
               row = 2;
           end
           if n < 3
               col = 1;
           elseif n < 5
               col = 2;
           end
           if n == 1 % 1*1 plot
               obj.singleplot(name(1), meas(1), dual(1))
           elseif mod(n,2) == 0 % Even amount of plots to make
               for i = 1:n
                  subplot(row,col,i)
                  obj.singleplot(name(i), meas(i), dual(i))
               end
           else % Uneven amount of plots to make
               for i = 1:n-1
                   subplot(row,col,i)
                   obj.singleplot(name(i), meas(i), dual(i))
               end
               subplot(row,col,n-1:row*col)
               subplot(row,col,i)
               obj.singleplot(name(n), meas(n), dual(n))
           end
           obj.figcnt = obj.figcnt + 1;
       end
       % Function that user can call to see what mnemonics the plot
       % functions understands.
       function showmnemonics(obj)
           fprintf("mvel, mvol, mcur, wvel, xpos, ypos, head, tilt, bvol\n")
       end
   end
end