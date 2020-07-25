function mykeyfun(~,event)
   global ready_to_type;
   global key;
   global total_time;
   global key_stroke_time;
   disp('Key Stroke');
   key = event.Key;
   if key=='g'
       ready_to_type=true;
       key_stroke_time = [key_stroke_time, total_time];
   end
   %disp('Debug');
end