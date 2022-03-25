function varargout = FindReplaceTool(varargin)
% Helps to search a string in a model and replace it with another string.
%
% Syntax:
% * >> FindReplaceTool('<SystemPath>')
% * >> FindReplaceTool
%
% Developed by: Sysenso Systems, https://sysenso.com/
% Contact: contactus@sysenso.com
%
% Version:
% 2.0 - Added support to do Find and Replace for block dialog parameters. Extended Replace action inside model reference blocks.
% 1.0 - Initial Version.
%

%--------------------------------------------------------------------------
% Input validation
if isempty(varargin)
    currentSystem = gcs;
    if ~isempty(currentSystem)
        systemPath = bdroot(currentSystem);
    else
        systemPath = '';
    end
else
    systemPath = varargin{1};
    modelName = bdroot(systemPath);
    % Load model into to the memory
    load_system(modelName);
end

%--------------------------------------------------------------------------
% Icons for Tool
filePath = fileparts(mfilename('fullpath'));
toolIconsPath = [filePath filesep 'toolIcons'];
checkIcon = [toolIconsPath '\check.png'];
unCheckIcon = [toolIconsPath '\unCheck.png'];
indetermidiateCheck = [toolIconsPath '\indeterminateCheck.png'];
simulinkIcon = [toolIconsPath '\simulinkicon.gif'];
refreshButtonImage = [toolIconsPath '\refreshButton.png'];

% Convert Icon to Java Icon
javaImageChecked = java.awt.Toolkit.getDefaultToolkit.createImage(checkIcon);
javaImageunChecked = java.awt.Toolkit.getDefaultToolkit.createImage(unCheckIcon);
javaimageIntermidiate = java.awt.Toolkit.getDefaultToolkit.createImage(indetermidiateCheck);
javaImageSimulink = java.awt.Toolkit.getDefaultToolkit.createImage(simulinkIcon);
iconWidth = javaImageChecked.getWidth;
refreshButtonData = imread(refreshButtonImage);

% Get screen size to fit Find and replace Figure
screenSize = get(0,'ScreenSize');
screenSizeFactor = 0.4;
screensize_factor_1 = 0.7;
figureSize = [(screenSize(3)*(1-screenSizeFactor))/2 (screenSize(4)*(1-screensize_factor_1))/2 ...
    screenSize(3)*screenSizeFactor screenSize(4)*screensize_factor_1];

%--------------------------------------------------------------------------
% GUI Creation

% Create Find and Replace Figure
handles.findReplaceFigure = figure('Toolbar','none','MenuBar','none','Position',figureSize);
set(handles.findReplaceFigure,'Name','FindReplaceTool','Numbertitle','off','Visible','off');
mainLayout = uiflowcontainer('v0','parent',handles.findReplaceFigure);
set(mainLayout,'FlowDirection','TopDown');
systemPathMainLayout = uiflowcontainer('v0','parent',mainLayout);
set(systemPathMainLayout,'FlowDirection','LeftToRight');
searchOptionsLayout = uiflowcontainer('v0','parent',mainLayout);
set(searchOptionsLayout,'FlowDirection','LeftToRight');
searchForlayout = uiflowcontainer('v0','parent',mainLayout);
set(searchForlayout,'FlowDirection','TopDown');
tableLayout = uiflowcontainer('v0','parent',mainLayout);
set(tableLayout,'FlowDirection','TopDown');
helpLayout = uiflowcontainer('v0','parent',mainLayout);
set(helpLayout,'FlowDirection','TopDown');

% System Path Panel
systemPathPanel = uipanel('parent',systemPathMainLayout,'Title','');
systemPathLayout = uiflowcontainer('v0','Parent',systemPathPanel);
set(systemPathLayout,'FlowDirection','LeftToRight');
systemPathLabel = uicontrol('style','checkbox','CData',nan(1,1,3),'string','System Path','HorizontalAlignment','Left','parent',systemPathLayout);
handles.systemPathEditField = uicontrol('style','edit','string',systemPath,'enable','inactive','parent',systemPathLayout);
set(handles.systemPathEditField,'Background','white','HorizontalAlignment','left');
handles.gcsButton = uicontrol('style','pushButton','string','GCS','parent',systemPathLayout,'TooltipString','Get path name of Current System');

% Search options Panel
filterOptionsPanel = uipanel('parent',searchOptionsLayout,'Title','Filter Options');
filterOptionsLayout = uiflowcontainer('v0','parent',filterOptionsPanel);
set(filterOptionsLayout,'FlowDirection','TopDown');
searchSettingsLayout = uiflowcontainer('v0','parent',searchOptionsLayout);
set(searchSettingsLayout,'FlowDirection','TopDown');
searchCriteriaPanel = uipanel('parent',searchSettingsLayout,'Title','Search Criteria');
lookInsidePanel = uipanel('parent',searchSettingsLayout,'Title','Look Inside');

% Filter Options Tree
handles.simulinkNode = uitreenode('v0',1,'Simulink',[],false);
handles.simulinkNode.setIcon(javaImageChecked)
handles.annotationNode = uitreenode('v0',1,'Annotation',[],true);
handles.annotationNode.setIcon(javaImageChecked)
handles.simulinkNode.add(handles.annotationNode)
handles.lineNode = uitreenode('v0',1,'Line',[],true);
handles.lineNode.setIcon(javaImageChecked)
handles.simulinkNode.add(handles.lineNode)
handles.blockNode = uitreenode('v0',1,'Block',[],true);
handles.blockNode.setIcon(javaImageChecked)
handles.simulinkNode.add(handles.blockNode)
handles.stateflowNode = uitreenode('v0',1,'Stateflow',[],false);
handles.stateflowNode.setIcon(javaImageChecked)
handles.annotationNode_2 = uitreenode('v0',1,'Annotation',[],true);
handles.annotationNode_2.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.annotationNode_2)
handles.boxNode = uitreenode('v0',1,'Box',[],true);
handles.boxNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.boxNode)
handles.chartNode = uitreenode('v0',1,'Chart',[],true);
handles.chartNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.chartNode)
handles.eventNode = uitreenode('v0',1,'Event',[],true);
handles.eventNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.eventNode)
handles.functionNode = uitreenode('v0',1,'Function',[],true);
handles.functionNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.functionNode)
handles.stateNode = uitreenode('v0',1,'State',[],true);
handles.stateNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.stateNode)
handles.transitionNode = uitreenode('v0',1,'Transition',[],true);
handles.transitionNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.transitionNode)
handles.truthTableNode = uitreenode('v0',1,'TruthTable',[],true);
handles.truthTableNode.setIcon(javaImageChecked)
handles.stateflowNode.add(handles.truthTableNode)
root = uitreenode('v0', '', '', [], false);
root.setIcon(javaImageSimulink);
root.add(handles.simulinkNode);
root.add(handles.stateflowNode);
[handles.tree,handles.treehandle] = uitree('v0','Root',root,'Parent',filterOptionsLayout);
set(handles.treehandle,'parent',filterOptionsLayout);
handles.tree.expand(root);
handles.jtree = handle(handles.tree.getTree,'CallbackProperties');

% Search Criteria Panel
searchCriteriaLayout = uiflowcontainer('v0','Parent',searchCriteriaPanel);
set(searchCriteriaLayout,'FlowDirection','TopDown','Margin',5);
searchModeLayout = uiflowcontainer('v0','Parent',searchCriteriaLayout);
set(searchModeLayout,'FlowDirection','LeftToRight');
searchModeLabel = uicontrol('style','Text','string','Search Mode','HorizontalAlignment','Left','parent',searchModeLayout);
handles.searchModeMenu = uicontrol('style','popupmenu','string',{'Matches String','Contains String','Regular Expression'},'Value',2,'parent',searchModeLayout);
set(handles.searchModeMenu,'BackgroundColor','White','HorizontalAlignment','Center');
searchDepthLayout = uiflowcontainer('v0','Parent',searchCriteriaLayout);
set(searchDepthLayout,'FlowDirection','LeftToRight');
searchDepthLabel = uicontrol('style','Text','string','Search Depth','HorizontalAlignment','Left','parent',searchDepthLayout);
handles.searchDepthDropDown = uicontrol('style','popupmenu','string',{'All Levels','Current Level'},'parent',searchDepthLayout);
set(handles.searchDepthDropDown,'BackgroundColor','White','HorizontalAlignment','Center');
searchDialogLayout = uiflowcontainer('v0','Parent',searchCriteriaLayout);
set(searchDialogLayout,'FlowDirection','LeftToRight');
handles.serchDialogCheckBox = uicontrol('style','checkbox','string','Search Block Dialog Parameters','Value',1,'parent',searchDialogLayout);
matchCaseLayout = uiflowcontainer('v0','Parent',searchCriteriaLayout);
set(matchCaseLayout,'FlowDirection','LeftToRight');
handles.matchCaseCheckBox = uicontrol('style','checkbox','string','Match Case','parent',matchCaseLayout);
uicontainer('parent',matchCaseLayout);

% Look Inside Panel
lookInsideLayout = uiflowcontainer('v0','Parent',lookInsidePanel);
set(lookInsideLayout,'FlowDirection','TopDown','Margin',3);
maskedSystemLayout = uiflowcontainer('v0','Parent',lookInsideLayout);
set(maskedSystemLayout,'FlowDirection','LeftToRight');
handles.maskedSystemCheckBox = uicontrol('style','checkbox','string','Masked System','parent',maskedSystemLayout);
uicontainer('parent',maskedSystemLayout);
linkedSystemLayout = uiflowcontainer('v0','Parent',lookInsideLayout);
set(linkedSystemLayout,'FlowDirection','LeftToRight');
handles.linkedSystemCheckBox = uicontrol('style','checkbox','string','Linked System','parent',linkedSystemLayout);
uicontainer('parent',linkedSystemLayout);
referencedModelLayout = uiflowcontainer('v0','Parent',lookInsideLayout);
set(referencedModelLayout,'FlowDirection','LeftToRight');
handles.referencedModelCheckBox = uicontrol('style','checkbox','string','Referenced Model','parent',referencedModelLayout);
uicontainer('parent',referencedModelLayout);

% Search For Panel
searchForPanel = uipanel('parent',searchForlayout,'Title','Search For');
findReplaceLayout = uiflowcontainer('v0','Parent',searchForPanel);
set(findReplaceLayout,'FlowDirection','TopDown');
findWhatLayout = uiflowcontainer('v0','Parent',findReplaceLayout);
set(findWhatLayout,'FlowDirection','LeftToRight','Margin',5);
findWhatLabel = uicontrol('style','checkbox','CData',nan(1,1,3),'string','Find What','HorizontalAlignment','Center','parent',findWhatLayout);
handles.findWhatEditField = uicontrol('style','edit','string','','HorizontalAlignment','left','parent',findWhatLayout);
set(handles.findWhatEditField,'Background','white');
handles.findButton = uicontrol('style','pushButton','string','Find','parent',findWhatLayout);
replaceWithLayout = uiflowcontainer('v0','Parent',findReplaceLayout);
set(replaceWithLayout,'FlowDirection','LeftToRight','Margin',5);
replaceWithLabel = uicontrol('style','checkbox','CData',nan(1,1,3),'string','Replace With','HorizontalAlignment','Center','parent',replaceWithLayout);
handles.replaceWithEditField = uicontrol('style','edit','string','','HorizontalAlignment','left','parent',replaceWithLayout);
set(handles.replaceWithEditField,'Background','white');
handles.replaceButton = uicontrol('style','pushButton','string','Replace','parent',replaceWithLayout);

% Table Panel
tablePanel = uipanel('parent',tableLayout,'Title','');
tablePanelLayout = uiflowcontainer('v0','Parent',tablePanel);
set(tablePanelLayout,'FlowDirection','TopDown');
selectAllCheckBoxLayout = uiflowcontainer('v0','Parent',tablePanelLayout);
set(selectAllCheckBoxLayout,'FlowDirection','LeftToRight');
handles.selectAllCheckBox = uicontrol('parent',selectAllCheckBoxLayout,'style','checkbox','string','Select / Unselect All');
uicontainer('parent',selectAllCheckBoxLayout);
handles.refreshButton = uicontrol('style','pushButton','string','','CData',refreshButtonData,'parent',selectAllCheckBoxLayout);
set(handles.refreshButton,'Tooltip','Refresh Table Data','Backgroundcolor','white');
handles.table = uitable('parent',tablePanelLayout,'BackgroundColor',[1 1 1]);

% Help Panel
helpPanel = uipanel('parent',helpLayout,'Title','');
helpPanelLayout = uiflowcontainer('v0','Parent',helpPanel);
set(helpPanelLayout,'FlowDirection','LeftToRight');
uicontainer('parent',helpPanelLayout);
handles.closeButton = uicontrol('style','pushButton','string','Close','parent',helpPanelLayout);
handles.helpButton = uicontrol('style','pushButton','string','Help','parent',helpPanelLayout);
uicontainer('parent',helpPanelLayout);

%--------------------------------------------------------------------------
% Set Height Limits and Width Limits For Layouts
set(systemPathMainLayout,'HeightLimits',[35,35]);
set(searchOptionsLayout,'HeightLimits',[260,260]);
set(searchForlayout,'HeightLimits',[90,90]);
set(tableLayout,'HeightLimits',[2,inf]);
set(selectAllCheckBoxLayout,'HeightLimits',[25,25]);
set(helpLayout,'HeightLimits',[35,35]);
set(searchCriteriaPanel,'HeightLimits',[135,135]);

% Set Height Limits and Width Limits For Labels
set(systemPathLabel,'WidthLimits',[100 100]);
set(handles.gcsButton,'WidthLimits',[100 100]);
set(findWhatLabel,'WidthLimits',[100 100]);
set(replaceWithLabel,'WidthLimits',[100 100]);
set(searchModeLabel,'WidthLimits',[100 100]);
set(searchDepthLabel,'WidthLimits',[100 100]);

% Set Height Limits and Width Limits For buttons
set(handles.findButton,'WidthLimits',[100 100]);
set(handles.replaceButton,'WidthLimits',[100 100]);
set(handles.closeButton,'WidthLimits',[100 100]);
set(handles.helpButton,'WidthLimits',[100 100]);
set(handles.refreshButton,'WidthLimits',[30 30]);

% Set Height Limits and Width Limits For CheckBoxes
set(handles.selectAllCheckBox,'WidthLimits',[150 150]);
set(handles.matchCaseCheckBox,'WidthLimits',[100 100]);
set(handles.serchDialogCheckBox,'WidthLimits',[200 200]);
set(handles.maskedSystemCheckBox,'WidthLimits',[150 150]);
set(handles.linkedSystemCheckBox,'WidthLimits',[150 150]);
set(handles.referencedModelCheckBox,'WidthLimits',[150 150]);

% Set Find and Replace Figure Visible
set(handles.findReplaceFigure,'Visible','on');

%--------------------------------------------------------------------------
% Set Callbacks for uicontrols
set(handles.gcsButton,'CallBack',@(src,event)gcsButtonCallback(src,event,handles))
set(handles.closeButton,'CallBack',@(src,event)closeButtonCallback(src,event,handles))
set(handles.helpButton,'CallBack',@(src,event)helpButtonCallback(src,event))
set(handles.findButton,'CallBack',@(src,event)findButtonCallback(src,event,handles))
set(handles.jtree,'MousePressedCallback',@(src,event)nodechangeCallBack(src,event,handles.jtree,javaImageChecked,javaImageunChecked,javaimageIntermidiate,iconWidth,handles))
set(handles.selectAllCheckBox,'Callback',@(src,event)selectAllCheckBoxCallback(src,event,handles))
set(handles.table,'CellSelectionCallback',@(src,event)selectedCellCallback(src,event,handles))
set(handles.replaceButton,'CallBack',@(src,event)replaceButtonCallback(src,event,handles))
set(handles.table,'CellEditCallback',@(src,event)cellCheckBoxCallback(src,event,handles))
set(handles.refreshButton,'CallBack',@(src,event)refreshButtonCallback(src,event,handles))
set(handles.searchDepthDropDown,'Callback',@(src,event)searchDepthDropDownCallback(src,event,handles))

% Set the resize callback
set(handles.findReplaceFigure,'ResizeFcn',@(src,event)findAndReplaceGuiResizeCallback(src,event,handles))
set(handles.findReplaceFigure,'DeleteFcn',@(src,event)findAndReplaceGuiDeleteCallback(src,event,handles))

% Handling the return argument.
if nargout == 1
    varargout{1} = handles;
end

end
%--------------------------------------------------------------------------
function gcsButtonCallback(src,event,handles)
% GCS Button Callback

systemPath = gcs;
set(handles.systemPathEditField,'String',systemPath);

end
%--------------------------------------------------------------------------
function closeButtonCallback(src,event,handles)
% Close Button Callback

% Unhighlight the block before closing the GUI.
figureUserData = get(handles.findReplaceFigure,'UserData');
if ~isempty(figureUserData)
    try
        removeHighlightedSystem(figureUserData);
    catch
        % Model might be already closed.
    end
end
close(handles.findReplaceFigure);

end
%--------------------------------------------------------------------------
function helpButtonCallback(src,event)
% Help Button Callback

open('FindReplaceTool_Doc.pdf');

end
%--------------------------------------------------------------------------
function findButtonCallback(src,event,handles)
% Find Button Callback

% Get system path to search
systemPath = get(handles.systemPathEditField,'String');
if isempty(systemPath)
    return;
end
% Get Search Name
searchName = get(handles.findWhatEditField,'String');
if isempty(searchName)
    set(handles.replaceButton,'UserData',[]);
    set(handles.selectAllCheckBox,'Value',0);
    set(handles.table,'UserData',[]);
    set(handles.table,'Data',[]);
    return;
end

% Get Drop Down Menu Index
dropDownIndex = get(handles.searchModeMenu,'Value');
% Set Search Flag Value
if isequal(dropDownIndex,1)
    searchModeFlag = 1;
elseif isequal(dropDownIndex,2)
    searchModeFlag = 2;
else
    searchModeFlag = 3;
end

% Set Match Case Flag
matchCaseValue = get(handles.matchCaseCheckBox,'Value');
matchCaseFlag = false;
if matchCaseValue
    matchCaseFlag = true;
end

% Set Search Dialog Param Flag
searchDialogParamValue = get(handles.serchDialogCheckBox,'Value');
searchDialogParamFlag = false;
if searchDialogParamValue
    searchDialogParamFlag = true;
end

set(handles.replaceButton,'UserData',{searchName;matchCaseValue;dropDownIndex})

% Get All Simulink Objects
simulinkObjects = getSimulinkObjects(handles,systemPath);
simulinkParameterObjects = [];
properties = [];
if searchDialogParamFlag
    simulinkParameterObjects = getSimulinkParameterObjects(handles,systemPath,searchModeFlag,searchName,matchCaseFlag);
    if ~isempty(simulinkParameterObjects)
        [simulinkParameterObjects,properties] = searchSimulinkParameter(simulinkParameterObjects,searchModeFlag,matchCaseFlag,searchName);
    end
end

% Get Simulink Objects that matches the Search Name
simulinkObjects = searchSimulinkObjects(simulinkObjects,searchModeFlag,matchCaseFlag,searchName,systemPath);

% Get All Simulink Objects Inside Model Referenced Blocks
blocksInsideReferencedModels = [];
referencedBlockProperties = [];
if get(handles.referencedModelCheckBox,'Value')
    [blocksInsideReferencedModels,referencedBlockProperties] = getBlocksInsideReferencedModels(handles,...
        searchModeFlag,searchDialogParamFlag,matchCaseFlag,systemPath,searchName);
end
simulinkObjects = [simulinkObjects;simulinkParameterObjects;blocksInsideReferencedModels];
properties = [properties;referencedBlockProperties];

% Get StateFlow Charts From the System
blockDiagramObject = get_param(systemPath,'object');
stateFlowObjects = blockDiagramObject.find('-isa','Stateflow.Chart');

% Get State Flow Objects that matches the Search Name
stateFlowObjects = searchStateFlowObjects(stateFlowObjects,searchModeFlag,matchCaseFlag,searchName);

% Sorting Simulink Objects
simulinkObjects = sortSimulinkObjects(simulinkObjects);

% Filtering Simulink objects based on Filter Options
simulinkObjects = filterSimulinkObjects(simulinkObjects,handles);

% Filtering Stateflow objects based on Filter Options
if ~isempty(fieldnames(stateFlowObjects))
    stateFlowObjects = filterStateFlowObjects(stateFlowObjects,handles);
end

% Set User Data
set(handles.serchDialogCheckBox,'UserData',properties);

% Set Table Data
setTableData(simulinkObjects,stateFlowObjects,searchDialogParamFlag,handles);
set(handles.selectAllCheckBox,'Value',0);

end
%--------------------------------------------------------------------------
function nodechangeCallBack(src,event,jtree,checkIcon,unCheckIcon,indetermidiateCheck,iconWidth,handles)
% Tree Node Selection Callback

% Get the clicked node
clickX = event.getX;
clickY = event.getY;
treePath = jtree.getPathForLocation(clickX, clickY);
if ~isempty(treePath)
    % Check if the checkbox was clicked
    if clickX <= (jtree.getPathBounds(treePath).x+iconWidth)
        selectedNode = treePath.getLastPathComponent;
        ChildrenNodesCount = selectedNode.getChildCount;
        nodeData = selectedNode.getValue;
        nodeName = selectedNode.getName;
        % Check If Block Node is clicked
        if nodeData == 1
            if strcmpi(nodeName,'Simulink') || strcmpi(nodeName,'Block')
                data = get(handles.serchDialogCheckBox,'Value');
                set(handles.serchDialogCheckBox,'Enable','off','Value',0);
                set(handles.serchDialogCheckBox,'UserData',data);
            end
        else
            if strcmpi(nodeName,'Simulink') || strcmpi(nodeName,'Block')
                data = get(handles.serchDialogCheckBox,'UserData');
                if isempty(data)
                    data = 1;
                end
                set(handles.serchDialogCheckBox,'Enable','on','Value',data);
                set(handles.serchDialogCheckBox,'UserData',data);
            end
        end
        tempCheck = 0;
        % Check if Parent Node is clicked
        if ChildrenNodesCount > 0
            currentNode = selectedNode;
            % Check Parent Node value
            if nodeData == 1
                % Set children nodes value based on parent node value
                for ii = 1:ChildrenNodesCount
                    currentNode = get(currentNode,'NextNode');
                    currentNode.setIcon (unCheckIcon);
                    currentNode.setValue (0);
                end
                selectedNode.setIcon(unCheckIcon);
                selectedNode.setValue(0);
                jtree.treeDidChange();
            elseif nodeData == 0 || nodeData == 0.5
                for ii = 1:ChildrenNodesCount
                    currentNode = get(currentNode,'NextNode');
                    currentNode.setIcon(checkIcon);
                    currentNode.setValue(1);
                end
                selectedNode.setIcon(checkIcon);
                selectedNode.setValue(1);
                jtree.treeDidChange();
            end
            % Check if Child Node is clicked
        else
            % Get Parent Node
            parentNode = selectedNode.getParent;
            childrenNodes = parentNode.getChildCount;
            currentNode = parentNode;
            if nodeData == 1
                selectedNode.setIcon(unCheckIcon);
                selectedNode.setValue(0);
                jtree.treeDidChange();
            elseif nodeData == 0 || nodeData == 0.5
                selectedNode.setIcon(checkIcon);
                selectedNode.setValue(1);
                jtree.treeDidChange();
            end
            % Iterate Through Children Nodes value
            % set Parent Node value
            for ii = 1:childrenNodes
                currentNode = get(currentNode,'NextNode');
                if currentNode.getValue == 0
                    parentNode.setIcon(indetermidiateCheck);
                    parentNode.setValue(0.5);
                    tempCheck = tempCheck+1;
                    jtree.treeDidChange();
                    break
                end
            end
            if tempCheck == 0
                parentNode.setIcon(checkIcon);
                parentNode.setValue(1);
                jtree.treeDidChange();
            end
        end
    end
end

end
%--------------------------------------------------------------------------
function selectAllCheckBoxCallback(src,event,handles)
% Select / Unselect All CheckBox Callback

% Get Checkbox value
selectAllCheckBoxValue = get(handles.selectAllCheckBox,'Value');
% Get table data
tableData = get(handles.table,'Data');
% Set Select column value of table based on checkbox value(true or false)
if selectAllCheckBoxValue
    % Iterate through each objects
    for ii = 1:size(tableData,1)
        tableData{ii,1} = true;
    end
else
    for ii = 1:size(tableData,1)
        tableData{ii,1} = false;
    end
end
% Set table data
set(handles.table,'Data',tableData);

end
%--------------------------------------------------------------------------
function selectedCellCallback(src,event,handles)
% Table cell selection Callback

% Check for empty selection
if isempty(event.Indices)
    return;
end
% Get Selected Row
selectedRow = event.Indices(1);
selectedColumn = event.Indices(2);
tableUserData = get(handles.table,'UserData');
object = cell2mat(tableUserData(selectedRow,1));
figureUserData = get(handles.findReplaceFigure,'UserData');
objectType = cell2mat(tableUserData(selectedRow,2));
if selectedColumn == 1
    return
end

% To Check whether figureUserData is empty
if isempty(figureUserData)
    % To Highlight the object
    figureUserData = highlightSystem(object,objectType);
else
    try
        % To remove previously highlighted object
        removeHighlightedSystem(figureUserData);
    catch
    end
    
    % To Highlight the object
    figureUserData = highlightSystem(object,objectType);
end

% Store the highlighted object
set(handles.findReplaceFigure,'UserData',figureUserData);

end
%--------------------------------------------------------------------------
function replaceButtonCallback(src,event,handles)
% Replace Button Callback

replaceName = get(handles.replaceWithEditField,'string');
if isempty(replaceName)
    return;
end

% Check if changes made in Find parameter values
settingsChangeFlag = checkFindParamValues(handles);
if settingsChangeFlag
    return;
end

% Removing Replaced Data from Table
refreshTableData(handles);

% Replace Selected Data
searchName = get(handles.findWhatEditField,'string');
tableData = get(handles.table,'Data');
objectsData = get(handles.table,'UserData');
matchCaseFlag = get(handles.matchCaseCheckBox,'Value');
searchModeFlag = get(handles.searchModeMenu,'Value');

% If no item selected for replace, then warn the user.
continueReplaceFlag = false;
for ind = 1:size(tableData,1)
    checkStatus = tableData{ind,1};
    % Check if checkbox is selected
    if checkStatus
        continueReplaceFlag = true;
    end
end
if ~continueReplaceFlag
    helpdlg('Please select table items to continue the Replace action.','Select Replace Items');
    return;
end

for ind = 1:size(objectsData,1)
    checkStatus = tableData{ind,1};
    object = objectsData{ind,1};
    replaceValue = objectsData{ind,3};
    % Check if checkbox is selected
    if checkStatus
        if isnumeric(object)
            % Typically for Simulink elements
            parentName = bdroot(object);
            load_system(parentName);
            % Name & Parameter related changes.
            if strcmpi(replaceValue,'Name')
                parameterName = 'Name';
            else
                parameterName = tableData{ind,5};
            end
            objectName = get_param(object,parameterName);
            if searchModeFlag == 1
                newName = strrep(objectName,searchName,replaceName);
                set_param(object,parameterName,newName);
            elseif searchModeFlag == 2 || searchModeFlag == 3
                if matchCaseFlag
                    newName = regexprep(objectName,searchName,replaceName);
                else
                    newName = regexprep(objectName,searchName,replaceName,'ignorecase');
                end
                set_param(object,parameterName,newName);
            end
            tableData{ind,end} = true;
        else
            % For Stateflow elements.
            if isprop(object,'Name')
                parameterName = 'Name';
            elseif isprop(object,'LabelString')
                parameterName = 'LabelString';
            end
            objectName = get(object,parameterName);
            if searchModeFlag == 1
                newName = strrep(objectName,searchName,replaceName);
                set(object,parameterName,newName);
            elseif searchModeFlag == 2 || searchModeFlag == 3
                if matchCaseFlag
                    newName = regexprep(objectName,searchName,replaceName);
                else
                    newName = regexprep(objectName,searchName,replaceName,'ignorecase');
                end
                set(object,parameterName,newName);
            end
            tableData{ind,end} = true;
        end
    end
end

% Check If Objects with tag 'Property' exists
additionalColumns = {};
searchDialogParamFlag = get(handles.serchDialogCheckBox,'Value');
if searchDialogParamFlag
    check = checkPropertyTag(objectsData);
    if check
        additionalColumns = {'Property Name','Property Value'};
    end
end

simulinkParams = [{'Name','Path'} additionalColumns {'LabelString','SrcBlockHandle','DstBlockHandle'}];
stateFlowParams = [{'Name','Path'} additionalColumns {'LabelString','Source','Destination'}];
for ind = 1:size(objectsData,1)
    object = objectsData{ind,1};
    replaceValue = objectsData{ind,3};
    updateTableData{ind,1} = tableData{ind,1};
    updateTableData{ind,2} = tableData{ind,2};
    for jj = 1:length(simulinkParams)
        if isnumeric(object)
            try
                if strcmpi(replaceValue,'Property')
                    parameter = tableData{ind,5};
                    if strcmpi(simulinkParams{jj},'Property Name')
                        value = parameter;
                    elseif strcmpi(simulinkParams{jj},'Property Value')
                        value = get(object,parameter);
                    else
                        value = get(object,simulinkParams{jj});
                    end
                else
                    value = get(object,simulinkParams{jj});
                end
            catch
                value = '';
            end
            if isnumeric(value)
                handleName = get(value,'Name');
                if iscell(handleName)
                    value = handleName{1};
                else
                    value = handleName;
                end
            end
            updateTableData{ind,jj+2} = value;
        else
            try
                value = get(object,stateFlowParams{jj});
            catch
                value = '';
            end
            if ~ischar(value)
                try
                    value = get(value,'Name');
                catch
                    value = '';
                end
            end
            updateTableData{ind,jj+2} = value;
        end
    end
    updateTableData{ind,jj+3} = tableData{ind,end};
end
% Update Table Data
set(handles.table,'Data',updateTableData);

end
%--------------------------------------------------------------------------
function cellCheckBoxCallback(src,event,handles)
% Tabel Cell edit callback

rowIndex = event.Indices(1);
columnIndex = event.Indices(2);
tableData = get(handles.table,'Data');
tempCheck = 0;
% Get Status column value
cellStatusValue = tableData{rowIndex,end};
% Check Status Column Value from table
if cellStatusValue
    return;
end

if columnIndex == 1
    % Get All selected checbox value from table and update select all chechbox
    for ii = 1:size(tableData,1)
        checkBoxStatus = tableData{ii,1};
        if ~checkBoxStatus
            set(handles.selectAllCheckBox,'Value',0)
            tempCheck = tempCheck+1;
            break
        end
    end
    if tempCheck == 0
        set(handles.selectAllCheckBox,'Value',1)
    end
end

end
%--------------------------------------------------------------------------
function refreshButtonCallback(src,event,handles)
% Refresh Button Callabck

refreshTableData(handles)

end
%--------------------------------------------------------------------------
function searchDepthDropDownCallback(src,event,handles)
% SearchDepthDropDown menu Callback

% Get Drop Down index
searchDepthIndex = get(handles.searchDepthDropDown,'Value');

if searchDepthIndex == 2
    userData = {};
    userData{1} = get(handles.maskedSystemCheckBox,'Value');
    userData{2} = get(handles.linkedSystemCheckBox,'Value');
    userData{3} = get(handles.referencedModelCheckBox,'Value');
    set(handles.searchDepthDropDown,'UserData',userData);
    set(handles.maskedSystemCheckBox,'Enable','off','Value',0)
    set(handles.linkedSystemCheckBox,'Enable','off','Value',0)
    set(handles.referencedModelCheckBox,'Enable','off','Value',0)
else
    userData = get(handles.searchDepthDropDown,'UserData');
    if isempty(userData)
        value = [0 0 0];
    else
        value = [userData{1} userData{2} userData{3}];
    end
    set(handles.maskedSystemCheckBox,'Enable','on','Value',value(1))
    set(handles.linkedSystemCheckBox,'Enable','on','Value',value(2))
    set(handles.referencedModelCheckBox,'Enable','on','Value',value(3))
end

end
%--------------------------------------------------------------------------
function findAndReplaceGuiResizeCallback(src,event,handles)
% Find and Replace figure Resize callback
noOfColumns = length(get(handles.table,'ColumnName'));
figureSize = get(handles.findReplaceFigure,'Position');
column = ones(1,(noOfColumns-3));
Width = round(((figureSize(3)-50- 220)/(noOfColumns-3)));
columnWidth = num2cell(Width*column);
set(handles.table,'ColumnWidth',{60,100,columnWidth{:},60});

end
%--------------------------------------------------------------------------
function findAndReplaceGuiDeleteCallback(src,event,handles)
% Find and Replace figure Resize callback

figureUserData = get(handles.findReplaceFigure,'UserData');
if ~isempty(figureUserData)
    try
        removeHighlightedSystem(figureUserData)
    catch
        % Model might be already closed.
    end
end

end
%--------------------------------------------------------------------------
function [blocksInsideReferencedModels,properties] = getBlocksInsideReferencedModels(handles,...
    searchModeFlag,searchDialogParamFlag,matchCaseFlag,systemPath,searchName)
% Get Simulink Objects from Model Referenced Block

blocksInsideReferencedModels = [];
properties = [];
% Get Model Referenced Blocks
[referencedModels,~] = find_mdlrefs(systemPath,...
    'ReturnTopModelAsLastElement',false,'Variants','AllVariants');

% Get Objects inside Model referenced Blocks
for ii = 1:length(referencedModels)
    modelName = referencedModels{ii};
    load_system(modelName);
    modelObjects = getSimulinkObjects(handles,modelName);
    parameterObjects = [];
    if searchDialogParamFlag
        parameterObjects = getSimulinkParameterObjects(handles,modelName,searchModeFlag,searchName,matchCaseFlag);
        if ~isempty(parameterObjects)
            [parameterObjects,properties] = searchSimulinkParameter(parameterObjects,searchModeFlag,matchCaseFlag,searchName);
        end
    end
    newObjects = searchSimulinkObjects(modelObjects,searchModeFlag,matchCaseFlag,searchName,modelName);
    blocksInsideReferencedModels = [blocksInsideReferencedModels newObjects parameterObjects];
end

end
%--------------------------------------------------------------------------
function simulinkObjects = getSimulinkObjects(handles,modelName)
% Get Simulink Objects

searchDepthIndex = get(handles.searchDepthDropDown,'Value');

searchProperties = {};
% Set Search Properties  Value
if searchDepthIndex == 2
    property = {'SearchDepth',1};
    searchProperties = [searchProperties property];
end

if get(handles.maskedSystemCheckBox,'Value')
    property = {'LookUnderMasks','all'};
    searchProperties = [searchProperties property];
else
    property = {'LookUnderMasks','none'};
    searchProperties = [searchProperties property];
end

if get(handles.linkedSystemCheckBox,'Value')
    property = {'FollowLinks', 'on'};
    searchProperties = [searchProperties property];
end

% Get Simulink Objects using Search flag and Search properties.
load_system(modelName);
simulinkObjects = find_system(modelName,'FindAll','on',searchProperties{1:end},'Variants','All');

end
%--------------------------------------------------------------------------
function simulinkParameterObjects = getSimulinkParameterObjects(handles,modelName,searchModeFlag,searchName,matchCaseFlag)

searchDepthIndex = get(handles.searchDepthDropDown,'Value');

searchProperties = {};
% Set Search Properties  Value
if searchDepthIndex == 2
    property = {'SearchDepth',1};
    searchProperties = [searchProperties property];
end

if get(handles.maskedSystemCheckBox,'Value')
    property = {'LookUnderMasks','all'};
    searchProperties = [searchProperties property];
else
    property = {'LookUnderMasks','none'};
    searchProperties = [searchProperties property];
end

if get(handles.linkedSystemCheckBox,'Value')
    property = {'FollowLinks', 'on'};
    searchProperties = [searchProperties property];
end

if matchCaseFlag
    property = {'CaseSensitive','on'};
    searchProperties = [searchProperties property];
else
    property = {'CaseSensitive','off'};
    searchProperties = [searchProperties property];
end

if searchModeFlag == 1
    simulinkParameterObjects = find_system(modelName,'FindAll','on',searchProperties{1:end},'Variants','All','BlockDialogParams',searchName);
else
    simulinkParameterObjects = find_system(modelName,'FindAll','on',searchProperties{1:end},'Variants','All','Regexp','on','BlockDialogParams',searchName);
end

simulinkParameterObjects = unique(simulinkParameterObjects);

newObjects = [];
for ii = 1:length(simulinkParameterObjects)
    object = simulinkParameterObjects(ii);
    newObjects = [newObjects;{object,'Property'}];
end
simulinkParameterObjects = newObjects;

end
%--------------------------------------------------------------------------
function newObjects = searchSimulinkObjects(objects,searchModeFlag,matchCaseFlag,searchName,modelName)
% Search Simulink Objects

if ~matchCaseFlag
    searchName = lower(searchName);
end
newObjects = [];
for ii = 1:length(objects)
    objectName = get_param(objects(ii),'Name');
    if ~matchCaseFlag
        objectName = lower(objectName);
    end
    if searchModeFlag == 1
        if strcmp(searchName,objectName) && ~(isequal(objectName,modelName))
            newObjects = [newObjects;{objects(ii),'Name'}];
        end
    elseif searchModeFlag == 2
        if ~isempty(strfind(objectName,searchName)) && ~(isequal(objectName,modelName))
            newObjects = [newObjects;{objects(ii),'Name'}];
        end
    elseif searchModeFlag == 3
        if ~isempty(regexp(objectName,searchName)) && ~(isequal(objectName,modelName))
            newObjects = [newObjects;{objects(ii),'Name'}];
        end
    end
end

end
%--------------------------------------------------------------------------
function [simulinkParameterObjects,properties] = searchSimulinkParameter(objects,searchModeFlag,matchCaseFlag,searchName)

if ~matchCaseFlag
    searchName = lower(searchName);
end
properties = {};
for ii = 1:size(objects,1)
    object = objects{ii,1};
    dialogStrcut = get_param(object,'DialogParameters');
    parameterNames = fieldnames(dialogStrcut);
    parameters = {};
    index = 1;
    for jj = 1:length(parameterNames)
        parameterValue = get_param(object,parameterNames{jj});
        if ~matchCaseFlag
            parameterValue = lower(parameterValue);
        end
        if searchModeFlag == 1
            if strcmp(searchName,parameterValue)
                parameters{index} = parameterNames{jj};
                index = index+1;
            end
        elseif searchModeFlag == 2
            if ~isempty(strfind(parameterValue,searchName))
                parameters{index} = parameterNames{jj};
                index = index+1;
            end
        elseif searchModeFlag == 3
            if ~isempty(regexp(parameterValue,searchName))
                parameters{index} = parameterNames{jj};
                index = index+1;
            end
        end
    end
    properties{ii} = parameters;
end

index = [];
for ii = 1:length(properties)
    property = properties{ii};
    if ~isempty(property)
        index = [index ii];
    end
end
simulinkParameterObjects = [objects(index,1) objects(index,2)];
end
%--------------------------------------------------------------------------
function [stateFlowChart] = searchStateFlowObjects(stateFlowObjects,searchModeFlag,matchCaseFlag,searchName)
% Search State Flow Objects

stateFlowChart = struct();
objectType = {'Annotation','AtomicBox','Box','Charts','EMFunction','Event','Function',...
    'SimulinkBasedState','SLFunction','State','Transition','TruthTable'};
if ~matchCaseFlag
    searchName = lower(searchName);
end
objectIndex = 1;
% Get Objects that matches Search Name
% Iterating Through each Chart
for ii = 1:length(stateFlowObjects)
    for jj = 1:length(objectType)
        objectValues = stateFlowObjects(ii).find('-isa',['Stateflow.' objectType{jj}]);
        for index = 1:length(objectValues)
            try
                objectValueName = get(objectValues(index),'Name');
            catch
                objectValueName = '';
            end
            try
                objectValueLabelString = get(objectValues(index),'LabelString');
            catch
                objectValueLabelString = '';
            end
            if ~matchCaseFlag
                objectValueName = lower(objectValueName);
                objectValueLabelString = lower(objectValueLabelString);
            end
            if searchModeFlag == 1
                if strcmp(searchName,objectValueName) || strcmp(searchName,objectValueLabelString)
                    stateFlowChart.objects(objectIndex) = objectValues(index);
                    stateFlowChart.objectType(objectIndex) = objectType(jj);
                    objectIndex = objectIndex+1;
                end
            elseif searchModeFlag == 2
                if ~isempty(strfind(objectValueName,searchName)) || ~isempty(strfind(objectValueLabelString,searchName))
                    stateFlowChart.objects(objectIndex) = objectValues(index);
                    stateFlowChart.objectType(objectIndex) = objectType(jj);
                    objectIndex = objectIndex+1;
                end
            elseif searchModeFlag == 3
                if ~isempty(regexp(objectValueName,searchName)) || ~isempty(regexp(objectValueLabelString,searchName))
                    stateFlowChart.objects(objectIndex) = objectValues(index);
                    stateFlowChart.objectType(objectIndex) = objectType(jj);
                    objectIndex = objectIndex+1;
                end
            end
        end
    end
end

end
%--------------------------------------------------------------------------
function sortedobjects = sortSimulinkObjects(objects)
% Sort Simulink Objects

annotationObject = [];
signalObjects = [];
blockObjects = [];
sortedobjects = [];
for ii = 1:size(objects,1)
    type = get_param(objects{ii,1},'type');
    if strcmp(type,'annotation')
        annotationObject = [annotationObject;{objects{ii,1},objects{ii,2}}];
    elseif strcmp(type,'line')
        signalObjects = [signalObjects;{objects{ii,1},objects{ii,2}}];
    elseif strcmp(type,'block')
        blockObjects = [blockObjects;{objects{ii,1},objects{ii,2}}];
    end
end
% Filtering Signal Objects based on number of receiving
signalObjects = filterSignalObjects(signalObjects);
sortedobjects = [sortedobjects;annotationObject;signalObjects;blockObjects];

end
%--------------------------------------------------------------------------
function signalObjects = filterSignalObjects(signalObjects)
% Filtering Signal Objects - to avoid duplications

if isempty(signalObjects)
    signalObjects = [];
    return
end
index = [];
uniqueHandles = [];
for ii = 1:size(signalObjects,1)
    % Get Source Block Handles
    sourceHandleA = get_param(signalObjects{ii,1},'SrcBlockHandle');
    if ~any(uniqueHandles==sourceHandleA)
        % Store source block handles in unique handles
        uniqueHandles = [uniqueHandles sourceHandleA];
        checkParam = 0;
        tempIndex = 0;
        for jj = 1:size(signalObjects,1)
            % Get simulink signal objects having same source block handle
            sourceHandleB = get_param(signalObjects{jj,1},'SrcBlockHandle');
            if isequal(sourceHandleA,sourceHandleB)
                numberOfDestPorts = length(get_param(signalObjects{jj,1},'DstBlockHandle'));
                if numberOfDestPorts > checkParam
                    checkParam = numberOfDestPorts;
                    tempIndex = jj;
                end
            end
        end
        % Get index of each signal objects with more number of destination
        % block handles
        index = [index tempIndex];
    end
end
signalObjects = [signalObjects(index,1) signalObjects(index,2)];

end
%--------------------------------------------------------------------------
function simulinkObjects = filterSimulinkObjects(simulinkObjects,handles)
% Filter Simulink Objects based on Selected Nodes in tree

if isempty(simulinkObjects)
    return;
end
% Get Parent Node(Simulink Node)
index = [];
rootNode = get(handles.tree,'Root');
parentNode = rootNode.getFirstChild;
childCount = get(parentNode,'ChildCount');

% Check parent Node Value
if parentNode.getValue == 0
    simulinkObjects = [];
    return
elseif parentNode.getValue == 0.5
    currentNode = parentNode;
    for ii = 1:childCount
        % Iterate through each child and filter
        currentNode = get(currentNode,'NextNode');
        if currentNode.getValue == 1
            for jj = 1:size(simulinkObjects,1)
                type = get_param(simulinkObjects{jj,1},'type');
                childrenNodeText = currentNode.getName;
                if strcmpi(childrenNodeText,type)
                    index = [index jj];
                end
            end
        end
    end
else
    return;
end
simulinkObjects = [simulinkObjects(index,1) simulinkObjects(index,2)];

end
%--------------------------------------------------------------------------
function stateFlowObjects = filterStateFlowObjects(stateFlowObjects,handles)
% Filter State Flow Objects

% Get parent node(StateFlow node)
index = [];
rootNode = get(handles.tree,'Root');
parentNode = rootNode.getLastChild;
childCount = get(parentNode,'ChildCount');

% Check parent node value
if parentNode.getValue == 0
    stateFlowObjects.objectType = [];
    stateFlowObjects.objects = [];
    return
elseif parentNode.getValue == 0.5
    currentNode = parentNode;
    for ii = 1:childCount
        % Iterate through each child node and filter
        currentNode = get(currentNode,'NextNode');
        if currentNode.getValue == 1
            for jj = 1:length(stateFlowObjects.objects)
                type = stateFlowObjects.objectType{jj};
                childrenNodeText = lower(currentNode.getName);
                childrenNodeText = childrenNodeText.toCharArray';
                if ~isempty(strfind(type,childrenNodeText))
                    index = [index jj];
                end
            end
        end
    end
else
    return;
end
stateFlowObjects.objectType = stateFlowObjects.objectType(index);
stateFlowObjects.objects = stateFlowObjects.objects(index);

end
%--------------------------------------------------------------------------
function setTableData(simulinkObjects,stateFlowObjects,searchDialogParamFlag,handles)
% Set Table Data

% Check If Objects with tag 'Property' exists
additionalColumns = {};
if searchDialogParamFlag
    check = checkPropertyTag(simulinkObjects);
    if check
        additionalColumns = {'Property Name','Property Value'};
    end
end

% Set Column Name for the table
columnName = [{'Select','Type','Name','Path'} additionalColumns {'LabelString','Source','Destionation','Status'}];
set(handles.table,'ColumnName',columnName);
editableValue = logical(1:length(columnName));
editableValue(2:end) = false;
set(handles.table,'ColumnEditable',editableValue);
userData = {};
set(handles.table,'UserData',{});

rowIndex = 1;
if isempty(fieldnames(stateFlowObjects))
    stateFlowObjectsLength = 0;
else
    stateFlowObjectsLength = length(stateFlowObjects.objects);
end
if isempty(simulinkObjects)
    simulinkObjectsLength = 0;
else
    simulinkObjectsLength = size(simulinkObjects,1);
end

totalObjects = simulinkObjectsLength+stateFlowObjectsLength;
% Set dimension for data variable
data = cell(totalObjects,length(columnName));

% Get User Data
properties = get(handles.serchDialogCheckBox,'UserData');

simulinkParams = [{'Type','Name','Path'} additionalColumns {'LabelString','SrcBlockHandle','DstBlockHandle'}];
% Check if simulink objects are empty
if ~isempty(simulinkObjects)
    propertyIndex = 1;
    for ii = 1:size(simulinkObjects,1)
        object = simulinkObjects{ii,1};
        replaceValue = simulinkObjects{ii,2};
        if strcmpi(replaceValue,'Name')
            data{rowIndex,1} = false;
            for columnIndex = 1:length(simulinkParams)
                simulinkParam = simulinkParams{columnIndex};
                if columnIndex == 1
                    try
                        value = get(object,'SFBlockType');
                    catch
                        value = get(object,simulinkParam);
                    end
                    if ~strcmpi(value,'chart')
                        value = get(object,simulinkParam);
                    end
                    value(1) = upper(value(1));
                    objectType = value;
                else
                    try
                        value = get(object,simulinkParam);
                    catch
                        value = '';
                    end
                end
                if isnumeric(value)
                    handleName = get(value,'Name');
                    if iscell(handleName)
                        value = handleName{1};
                    else
                        value = handleName;
                    end
                end
                data{rowIndex,columnIndex+1} = value;
            end
            % Get simulink param value from each object and store in data
            % variable
            data{rowIndex,end} = false;
            userData{rowIndex,1} = object;
            userData{rowIndex,2} = objectType;
            userData{rowIndex,3} = replaceValue;
            rowIndex = rowIndex+1;
        else
            parameters = properties{propertyIndex};
            for jj  = 1:length(parameters)
                parameter = parameters{jj};
                data{rowIndex,1} = false;
                for columnIndex = 1:length(simulinkParams)
                    simulinkParam = simulinkParams{columnIndex};
                    if columnIndex == 1
                        try
                            value = get(object,'SFBlockType');
                        catch
                            value = get(object,simulinkParam);
                        end
                        if ~strcmpi(value,'chart')
                            value = get(object,simulinkParam);
                        end
                        value(1) = upper(value(1));
                        objectType = value;
                    else
                        try
                            if strcmpi(simulinkParam,'Property Name')
                                value = parameter;
                            elseif strcmpi(simulinkParam,'Property Value')
                                value = get(object,parameter);
                            else
                                value = get(object,simulinkParam);
                            end
                        catch
                            value = '';
                        end
                    end
                    if isnumeric(value)
                        handleName = get(value,'Name');
                        if iscell(handleName)
                            value = handleName{1};
                        else
                            value = handleName;
                        end
                    end
                    data{rowIndex,columnIndex+1} = value;
                end
                % Get simulink param value from each object and store in data
                % variable
                data{rowIndex,end} = false;
                userData{rowIndex,1} = object;
                userData{rowIndex,2} = objectType;
                userData{rowIndex,3} = replaceValue;
                rowIndex = rowIndex+1;
            end
            propertyIndex = propertyIndex+1;
        end
    end
end

stateFlowParams = [{'','Name','Path'} additionalColumns {'LabelString','Source','Destination'}];
% Check if stateflow objects are empty
if ~isempty(fieldnames(stateFlowObjects))
    for ii = 1:length(stateFlowObjects.objects)
        object = stateFlowObjects.objects(ii);
        objectType = stateFlowObjects.objectType{ii};
        data{rowIndex,1} = false;
        for columnIndex = 1:length(stateFlowParams)
            if columnIndex == 1
                data{rowIndex,columnIndex+1} = objectType;
            else
                try
                    value = get(object,stateFlowParams{columnIndex});
                catch
                    value = '';
                end
                if ~ischar(value)
                    try
                        value = get(value,'Name');
                    catch
                        value = '';
                    end
                end
                data{rowIndex,columnIndex+1} = value;
            end
        end
        % Get stateflow params value from each objects and store in data
        % variable
        data{rowIndex,end} = false;
        userData{rowIndex,1} = object;
        userData{rowIndex,2} = objectType;
        userData{rowIndex,3} = [];
        rowIndex = rowIndex+1;
    end
end
% Set Table data and store each objects in userdata of table
set(handles.table,'UserData',userData);
set(handles.table,'Data',data);
findAndReplaceGuiResizeCallback([],[],handles);

end
%--------------------------------------------------------------------------
function refreshTableData(handles)
% Refresh Table Data
% To remove replaced object from the table

% Get Table data
tableData = get(handles.table,'Data');
tableUserData = get(handles.table,'UserData');
index = [];

% Remove rows with status value true
for rowIndex = 1:size(tableData,1)
    checkBoxStatus = tableData{rowIndex,end};
    if checkBoxStatus
        index = [index rowIndex];
    end
end
% Update Table Data and User data
tableData(index,:) = [];
tableUserData(index,:) = [];
set(handles.table,'Data',tableData);
set(handles.table,'UserData',tableUserData);

if isempty(tableData)
    set(handles.selectAllCheckBox,'Value',0)
end

end
%--------------------------------------------------------------------------
function figureUserData = highlightSystem(object,objectType)
% To Highlight the object

if strcmpi(objectType,'Line')
    hilite_system(object)
else
    simulinkID = Simulink.ID.getSID(object);
    Simulink.ID.hilite(simulinkID)
end
figureUserData{1,1} = object;
figureUserData{1,2} = objectType;

end
%--------------------------------------------------------------------------
function removeHighlightedSystem(figureUserData)
% To remove previously highlighted object

if strcmpi(figureUserData{1,2},'Line')
    hilite_system(figureUserData{1,1},'none')
else
    simulinkID = Simulink.ID.getSID(figureUserData{1,1});
    Simulink.ID.hilite(simulinkID,'none')
end

end
%--------------------------------------------------------------------------
function check = checkPropertyTag(objects)
% Check if a Simulink Object with tag 'Property' exists
check = false;
for ii = 1:size(objects,1)
    value = objects(ii,:);
    if any(strcmpi(value,'Property'))
        check = true;
        return
    end
end
end
%--------------------------------------------------------------------------
function settingsChangeFlag = checkFindParamValues(handles)
% Check if changes made in Find parameter values

settingsChangeFlag = false;
previousValues = get(handles.replaceButton,'UserData');
if isempty(previousValues)
    settingsChangeFlag = true;
    return
end
searchName = get(handles.findWhatEditField,'String');
matchCaseValue = get(handles.matchCaseCheckBox,'Value');
dropDownIndex = get(handles.searchModeMenu,'Value');
currentValues = {searchName;matchCaseValue;dropDownIndex};
if ~isequal(previousValues,currentValues)
    questValue = questdlg({'Settings used during Find are changed before Replace function.'
        'Press ''Yes'' to Restore the settings and then continue with Replace action.'
        'Press ''No'' to Abort and then use Find functionality again.'},'Settings Changed','Yes','No','Yes');
    if strcmpi(questValue,'Yes')
        set(handles.findWhatEditField,'String',previousValues{1});
        set(handles.matchCaseCheckBox,'Value',previousValues{2});
        set(handles.searchModeMenu,'Value',previousValues{3});
    elseif strcmpi(questValue,'No') || isempty(questValue)
        settingsChangeFlag = true;
    end
end

end