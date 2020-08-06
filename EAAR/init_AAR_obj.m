function obj = init_AAR_obj(obj,i)
obj.LIR = []; % Left impulse
obj.RIR = []; % Right impulse
obj.ptr = i; % position in the loc array
obj.aptr = 1; % audio ptr to annotate clip
obj.iptr = 1; % audio ptr to indicator sound
obj.active = 0;
obj.A = 0;
obj.LF = dsp.FIRFilter('NumeratorSource','Input port');
obj.RF = dsp.FIRFilter('NumeratorSource','Input port');
end