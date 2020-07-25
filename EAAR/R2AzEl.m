function [Az, El] = R2AzEl(R, look_down_vec)
% Az: Front 30d right = 30
% El: Down positive
Az = wrapTo360(atan2d(-R(2,1),R(1,1)));
axang = vrrotmat2vec(myrotz(Az)*R);
El = axang(4)/pi*180*sign(dot(axang(1:3),look_down_vec));
%disp(axang(1:3));
end