%% *|Find and Replace Tool|*
%
% FindReplaceTool helps to search a string in a Simulink model and also
% replace it with another string.
%
% Developed by: Sysenso Systems, https://sysenso.com/
%
% Contact: contactus@sysenso.com
%
% Version:
%
% * 2.0 - Added support to do Find and Replace for block dialog parameters. Extended Replace action inside model reference blocks.
% * 1.0 - Initial Version.
%
%
%%
% *|Launching the tool|*
%
% * Before launching the tool, add the FindReplaceTool folder to the MATLAB path.
%
% <<\images\path.png>>
%
%%
%
% * The tool can be launched by typing following the command as below in the MATLAB command window.
%
% * >> FindReplaceTool('<SystemPath>')
% * >> FindReplaceTool
%
% <<\images\commandWindow.png>>
%
% * FindReplaceTool can be launched from Tools/FindReplaceTool menu or from the model context menu.
% If the menu is not available, run the following command in the MATLAB
% command window and then start using Simulink.
% >> sl_refresh_customizations
%
% <<\images\modelMenu.png>>
%
% * Find and Replace Tool GUI launches with the current system path
%
% <<\images\findAndReplaceTool.png>>
%
%%
% *|Find|*
%
% * On clicking the GCS button on top of the GUI, it sets the full path name
% of the current Simulink system.
%
% <<\images\gcsButton.png>>
%%
% * Enter the word or a regular expression that you want to search in the Find what field
% and a replacement string in the Replace with field.
%
% <<\images\findWhat.png>>
%%
% * On clicking the Find button near the Find what field, a table at the
% bottom of the GUI will be populated with all the Simulink and Stateflow
% objects that matches the search string.
%
% <<\images\findClickedAction.png>>
%%
% * To replace the specific object from the table, select the checkbox in
% the first column corresponding to the object to be replaced.
%
% <<\images\checkboxSelection.png>>
%%
% * Select/Unselect All checkbox near the top of the table, is used
% to select/Unselect all the checkbox in the first column of the table.
%
% <<\images\selectOrUnselectCheckbox.png>>
%%
%
% * On clicking any cell in the table, the object corresponding to the
% cell will be highlighted in the model.
%
% <<\images\selectedCell.png>>
%
%%
% *|Replace|*
%
% * On clicking the Replace button, the objects in the table with checkbox
% selected will be replaced.
%
% * Checkbox in the status column of the table will be marked for the
% objects that are replaced.
%
% <<\images\replaceButton.png>>
%%
% * The Refresh button on top of the table is used to remove the replaced
% objects from the table.(Refresh Table Data)
%
% <<\images\refreshButton.png>>
%%
% * The Close button on bottom of the table is used to close the
% FindReplaceTool GUI.
%
% <<\images\closeButton.png>>
%%
% * On clicking the Help button on bottom of the table, the user guide document
% for the FindReplaceTool GUI opens.
%
% <<\images\helpButton.png>>
%%
%
% *|Options|*
%
% <<\images\options.png>>
%%
% 1. *Filter Options* - Filter options is used to limit the search of
% within the selected Simulink/Stateflow objects.
%
% 2. *Search Criteria\Search Mode* - Search Mode is a drop-down menu with 3 options.
% Matches String - Matches the whole word given in the "Find What", in an object property.
% Contains String - Searches the given word present in an object property.
% Regular Expression - Considers the given word as a regular expression and searches it.
%
% 3. *Search Criteria\Search Depth* - Search Depth is a drop-down menu with 2 options.
% All Levels(default) - Searches under given system path to all the levels available.
% Current Level - Searches for all objects in the system path and excludes its children levels.
%
% 4. *Search Criteria\Search Block Dialog Parameters* - If this checkbox is
% selected, then the specified Find string is searched inside the block
% dialog box parameters as well.
%
% 5. *Search Criteria\Match Case* - If the Match case box is checked, then Find and Replace becomes
% case-sensitive. For example, checking the Match Case button and then
% searching for 'Transmission' will find 'Transmission' but NOT 'transmission' and so on.
%
% 6. *Look Inside\Masked Systems* - If the Masked System checkbox is checked, then the
% tool has the access to look inside the masked system in the model.
%
% 7. *Look Inside\Linked Systems* - If the Linked System checkbox is checked, then the
% tool has the access to look inside the library linked system.
%
% 8. *Look Inside\Referenced Systems* - If the Referenced system checkbox is checked,
% the tool has the access to look inside the referenced models.
% Note: Replace action is not supported within the referenced models.
%
%%
% *|Application Development - FindReplaceTool|*
%
% To avoid "adding FindReplaceTool to MATLAB path" before launching it,
% this code can be packaged as a MATLAB App and install within MATLAB.
% Refer Help> Package and Share Apps
%
% <<\images\packageApp.png>>
%
% Apps can be launched from Apps Toolstrip.
%
% <<\images\appLaunch.png>>
%
%%
% *|API Support - find_replace_system|*
%
% Refer the file exchange submission: find_replace_system which can be
% considered as an equivalent API for this tool.
%
% In fact with this API, the user can replace almost any property in the
% Simulink model.
%
%
% <https://mathworks.com/matlabcentral/fileexchange/41404-simunlink-api-find_replace_system>
%
% <<\images\find_replace_system.png>>
%