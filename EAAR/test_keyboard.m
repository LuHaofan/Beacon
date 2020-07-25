ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');
for k = 1:1e6
  disp(k)
  if ~ishandle(ButtonHandle)
    disp('Loop stopped by user');
    break;
  end
pause(0.01); % A NEW LINE
end