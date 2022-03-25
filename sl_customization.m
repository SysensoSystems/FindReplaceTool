function sl_customization(cm)
% Simulink Customization for the FindReplaceTool.
%
% Developed by: Sysenso Systems, https://sysenso.com/
% Contact: contactus@sysenso.com
%

%% Register custom menu item in the tool menu
cm.addCustomMenuFcn('Simulink:ToolsMenu', @setToolsMenuItems);
cm.addCustomMenuFcn('Simulink:PreContextMenu', @setModelContextMenuItems);

end

%% Define the custom menu function.
function schemaFcns = setToolsMenuItems(callbackInfo)
% Define the Item in Menu
schemaFcns = {@setFindReplaceToolMenu};
end
function schemaFcns = setModelContextMenuItems(callbackInfo)
% Define the Item in Menu
schemaFcns = {@setFindReplaceToolMenu};
end

%%
function schema = setFindReplaceToolMenu(callbackInfo)
schema = sl_action_schema;
schema.label = 'FindReplaceTool';
schema.callback = @FindReplaceTool_Callback;
end

function FindReplaceTool_Callback(callbackInfo)
% Launch the FindReplaceTool.

FindReplaceTool(gcs);

end