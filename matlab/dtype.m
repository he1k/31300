classdef dtype
   properties
       label
       data
       name
       
   end
   methods
       function obj = dtype(Label, Name, Data)
           obj.label = Label;
           obj.name = Name;
           obj.data = Data;
       end
   end 
end