classdef SDUpdater < handle
    properties (Hidden)
        handles;            %Graphics objects
        BoardRDTable;       % Table of boards / reference designs
        VideoPSPDir;        % Root PSP directory
        SDList;             % List of SD objects
        BoardVariantTable = containers.Map();  % Table of boards / variants / zip files
    end
    
    properties (Hidden, Constant)
        FWMODE_ZIP = 'FAT32 ZIP';
        FWMODE_IMG = 'Disk Image';
        DEVICETYPE_ZYNQ = 'Zynq';
        DEVICETYPE_ALTERASOC = 'Altera SoC';
    end
    
    properties
        AppName = 'SD Updater'
        FWMode@hdlbsp.util.SDUpdater.FWModes = hdlbsp.util.SDUpdater.FWModes.FAT32_ZIP;
        DeviceType@hdlbsp.util.SDUpdater.DeviceTypes = hdlbsp.util.SDUpdater.DeviceTypes.ZYNQ;
        GUIEnabled@logical = true;
    end
    
    properties (Access = protected)
        FWUpdater
        privActiveVariant
        privActiveBoard
        privActiveSDDrive = 'N/A'
    end
    
    properties (Dependent)
        ActiveSDDrive
        ActiveZip
        ActiveVariant
        ActiveBoard
    end
    
    properties (Hidden, Dependent)
        WipeSD         % Preserve SD card contents on udpate
        ActiveBoardObj
        ActiveVariantList
        DriveList
    end
    
    methods (Hidden)
        function app = SDUpdater(varargin)
            % Configure the app
            app.configureApp;
            
            % Load the variants
            app.loadVariants;
            
            % Launch the app
            app.launchApp;
        end
        
        function delete(app)
            try %#ok
                delete(app.handles.Fig);
            end
        end
        
        function createGUI(app)
            LeftTextAlgin = 10;
            LeftMenuAlign = 150;
            MenuHeight = 27;
            LineSize = 40;
            CurrentVertPos = LineSize*7+10;
            CheckboxWidth = 50;
            
            
            % Create the GUI
            app.handles.Fig = figure(...
                'Color',[0.94 0.94 0.94],...        
                'Position',[532 624 500 CurrentVertPos],...        
                'MenuBar','none',...
                'Name',app.AppName,...
                'NumberTitle','off',...
                'Resize','off',...
                'Visible','on',...
                'CloseRequestFcn', @app.callback_closeApp);
            
            % Create the SD card list
            CurrentVertPos = CurrentVertPos - LineSize;
            
            app.handles.menuSDCard = app.uimenu(...
                'N/A', [LeftMenuAlign CurrentVertPos 61 MenuHeight],...
                @app.callback_menuSDCard);
            
            app.handles.txtSDCard = app.uitext(...
                'Drive', [LeftTextAlgin CurrentVertPos]);            
            
            app.handles.btnRefresh = uicontrol(...
                'Parent',app.handles.Fig,...
                'Callback',@app.callback_updateSDList,...
                'Position',[69 CurrentVertPos 60 MenuHeight],...
                'String','Refresh');           
            
            % Create the write button            
            app.handles.btnWrite = uicontrol(...
                'Parent',app.handles.Fig,...
                'Callback',@app.callback_WriteSD,...
                'Position',[390 CurrentVertPos 101 MenuHeight],...
                'String','Write SD');   
            
            % Create the board list
            CurrentVertPos = CurrentVertPos - LineSize;
            
            app.handles.menuBoard = app.uimenu(...
                'N/A', [LeftMenuAlign CurrentVertPos 337 MenuHeight],...
                @app.callback_menuBoard);

            app.handles.txtBrd = app.uitext(...
                'Board', [LeftTextAlgin CurrentVertPos]);
                        
            % Create the reference design list
            CurrentVertPos = CurrentVertPos - LineSize;
            
            app.handles.menuVariant = app.uimenu(...
                'N/A', [LeftMenuAlign CurrentVertPos 337 MenuHeight],...
                 @app.callback_menuVariant);

            app.handles.txtVariant = app.uitext(...
                'Variant', [LeftTextAlgin CurrentVertPos]);
            
            
            if isequal(app.FWMode, hdlbsp.util.SDUpdater.FWModes.FAT32_ZIP)       
                % Create the preserve SD checkbox
                CurrentVertPos = CurrentVertPos - LineSize;

                app.handles.txtWipeSD = app.uitext(...
                    'Wipe SD Card', [LeftTextAlgin CurrentVertPos]);
                
                app.handles.checkWipeSD = uicontrol(...
                    'Parent',app.handles.Fig,...
                    'Position',[LeftMenuAlign CurrentVertPos CheckboxWidth MenuHeight],...
                    'Callback',@app.callback_WipeSD,...    
                    'Style','checkbox',...
                    'Value',app.WipeSD);
            end
        
        end     
        
        function handle = uitext(app, Text, Position)
            % Set the width/height to 1
            Position(3:4) = 1;
            
            % Create the text control 
            handle = uicontrol(...
                'Parent',app.handles.Fig,...
                'Position',Position,...
                'HorizontalAlignment', 'Left',...
                'String',Text,...
                'Style','text');
            
            % Resize based on the string
            ext = get(handle, 'Extent');
            Position(3:4) = (ext(3:4))+3;
            set(handle, 'Position', Position);
            
        end
        
        function handle = uimenu(app, Text, Position, Callback)
            if nargin < 4
                Callback = {};
            end
            handle = uicontrol(...
                'Parent',app.handles.Fig,...
                'BackgroundColor', [1 1 1 ],...
                'Position',Position,...
                'String',Text,...
                'BusyAction', 'cancel',...
                'Callback',Callback,...
                'Style','popupmenu',...
                'Value',1);
        end
        
        function handle = uiedit(app, Text, Position, Callback)
            if nargin < 4
                Callback = {};
            end
            handle = uicontrol(...
                'Parent',app.handles.Fig,...
                'BackgroundColor', [1 1 1 ],...
                'Position',Position,...
                'String',Text,...
                'BusyAction', 'cancel',...
                'Callback',Callback,...
                'Style','edit',...
                'Value',1);
        end
        
    end
    %% GUI Callbacks
    % Syntax: method(app,hObject,eventdata)
    methods (Hidden)
        
        function callback_closeApp(app,varargin)
            delete(app.handles.Fig);
            delete(app);
        end
        
        function callback_WriteSD(app,varargin)
            app.enableUI(false);
            cleanup = onCleanup(@()app.enableUI(true));
            
            if isequal(app.getSelectedItem(app.handles.menuSDCard), 'N/A')
                error('You must select a valid drive to program the SD card');
            end          
            
            if app.WipeSD
                warnVal = 'wipe all';
            else
                warnVal = 'overwrite';
            end
            WarnStr = sprintf(['WARNING: Updating the SD Card will %s existing contents\n'...
                    'Are you sure you want to proceed?'], warnVal);
            
            ButtonName = questdlg(WarnStr, ...
                                     'Update SD Card', ...
                                     'No');
            if isequal(ButtonName, 'Yes')                     
                app.writeSDCard();
            end
        end
        
        function callback_updateSDList(app,varargin)
            app.enableUI(false);
            cleanup = onCleanup(@()app.enableUI(true));
            
            driveList = app.updateSDList;
            set(app.handles.menuSDCard, 'String', driveList)
        end
        
        
        function callback_menuSDCard(app,varargin)
            app.privActiveSDDrive = app.getSelectedItem(app.handles.menuSDCard);
        end
        
        function callback_menuBoard(app,varargin)
            app.ActiveBoard = app.getSelectedItem(app.handles.menuBoard);
            set(app.handles.menuVariant, 'String', app.ActiveVariantList);
        end
        
        function callback_menuVariant(app,varargin)
            app.ActiveVariant = app.getSelectedItem(app.handles.menuVariant);
        end
        
        function callback_WipeSD(app,varargin)
            app.WipeSD = get(app.handles.checkWipeSD, 'Value');
        end        
    end
    %% Set / Get Properties
    methods
        function val = get.WipeSD(app)
            if isequal(app.FWMode, hdlbsp.util.SDUpdater.FWModes.FAT32_ZIP)
                val = getpref('HDLBSP_COMMON', 'SDUpdater_WipeSD', 0);
            else
                val = 1;
            end
        end
        
        function set.WipeSD(app, val) %#ok
            if isequal(val, 0) || isequal(val, 1)
                setpref('HDLBSP_COMMON', 'SDUpdater_WipeSD', val);
            else
                error('Must specify 0 or 1 for WipeSD');
            end
        end
    
        function variantList = get.ActiveVariantList(app)
            boardObj = app.ActiveBoardObj();
            variantList = keys(boardObj.Variants);
        end

        function brdObj = get.ActiveBoardObj(app)
            brdObj = app.BoardVariantTable(app.ActiveBoard);
        end
        
        function set.ActiveVariant(app, varName)
            if ~ismember(varName, app.ActiveVariantList)
                error('%s is not an available variant.', varName);  
            end
            app.privActiveVariant = varName;
        end
        
        function varName = get.ActiveVariant(app)
            varName = app.privActiveVariant;
        end
        
        function set.ActiveBoard(app, boardName)
            if ~ismember(boardName, keys(app.BoardVariantTable))
                error('%s is not an available board.', boardName);  
            end
            app.privActiveBoard = boardName;
        end
        
        function boardName = get.ActiveBoard(app)
            boardName = app.privActiveBoard;
        end
        
        function zipFile = get.ActiveZip(app)
            brdObj = app.ActiveBoardObj;
            varName = app.ActiveVariant;
            zipFile = brdObj.Variants(varName);
        end
        
        function driveList = get.DriveList(app)
            driveList = app.FWUpdater.getDriveList;
            if isempty(driveList)
                driveList = {'N/A'};
            end
        end
        
        function set.ActiveSDDrive(app, sdDrive)
            if ~ismember(sdDrive, app.DriveList)
                error('%s is not an available SD card', sdDrive);
            end
            app.privActiveSDDrive = sdDrive;
        end
        
        function sdDrive = get.ActiveSDDrive(app)
            sdDrive = app.privActiveSDDrive;
        end
        
    end
    
    %% API Functions
    methods (Abstract, Access = protected)
        % Configure the App settings
        configureApp(app)
        % Load the SD card variants
        loadVariants(app)
    end
    
    methods
        % Update the SD card contents
        function writeSDCard(app)             
            app.FWUpdater.Drive = app.ActiveSDDrive;
            
            switch(app.FWMode)
                case hdlbsp.util.SDUpdater.FWModes.FAT32_ZIP
                    app.writeSDCard_FAT32;
                case hdlbsp.util.SDUpdater.FWModes.DISK_IMAGE
                    app.writeSDCard_IMG;
                otherwise
                    error('Invalid setting for FWMode');
            end
        end
    end
    
    methods (Access = protected)
        function addVariant(app, BoardName, VariantName, ZipFile)
            if app.BoardVariantTable.isKey(BoardName)
                tblObj = app.BoardVariantTable(BoardName);
            else
                tblObj.BoardName = BoardName;
                tblObj.Variants = containers.Map();
            end
            tblObj.Variants(VariantName) = ZipFile;  
            % if it's the first one, set it to active
            if isempty(app.privActiveBoard)
                app.privActiveBoard = BoardName;
                app.privActiveVariant = VariantName;
            end
            app.BoardVariantTable(BoardName) = tblObj;
        end
        
        function launchApp(app)                             
            % Load some parameters
            if isempty(app.FWUpdater)
                switch(app.DeviceType)
                    case hdlbsp.util.SDUpdater.DeviceTypes.ZYNQ
                        app.FWUpdater = zynq.setup.ZynqFirmwareUpdate;
                    case hdlbsp.util.SDUpdater.DeviceTypes.ALTERA_SOC
                        app.FWUpdater = codertarget.alterasoc.setup.AlteraSoCFirmwareUpdate;
                end
            end
            
            % Update the SD Card List
            driveList = app.updateSDList;
            
            % Create the GUI
            if app.GUIEnabled
                app.createGUI();
                % Update the list of SD cards
                set(app.handles.menuSDCard, 'String', driveList)

                % Setup the board list
                set(app.handles.menuBoard, 'String', app.BoardVariantTable.keys);
                app.setSelectedItem(app.handles.menuBoard, app.ActiveBoard);

                % Setup the variant list
                set(app.handles.menuVariant, 'String', app.ActiveVariantList);
                app.setSelectedItem(app.handles.menuVariant, app.ActiveVariant);
            end
        end
        
        % Update a FAT32 SD Card
        function writeSDCard_FAT32(app)
            hWaitbar = waitbar(0,['SD Card Update...' ...
                char(ones(1,30, 'like', uint8(0)).*uint8(' '))]);    
            cleanup = onCleanup(@()delete(hWaitbar));

            if app.WipeSD
                waitbar(0.25,hWaitbar,'Formatting SD Card...');
                app.FWUpdater.formatFATWindows;
            end
            
            % Program the SD Card
            waitbar(0.50,hWaitbar,'Updating SD Card Contents...');
            unzip(app.ActiveZip, [app.ActiveSDDrive filesep]);
            waitbar(0.75,hWaitbar,'Applying final updates...');
        end
        
        % Update a image SD Card
        function writeSDCard_IMG(app)
            fwDir = tempname;
            mkdir(fwDir);
            cleanup = onCleanup(@()rmdir(fwDir, 's'));
            % Get the info on the image file
            [~, fwFileName, ~] = fileparts(app.ActiveZip);
            
            % populate the FW Updater
            app.FWUpdater.DownloadFolder = fwDir;
            app.FWUpdater.FirmwareName = fwFileName;
            gunzip(app.ActiveZip, fwDir);
            
            % Determine the file size
            fileInfo = dir(fullfile(fwDir, fwFileName));
            app.FWUpdater.FirmwareSize = fileInfo.bytes;
            % Write the image
            app.FWUpdater.writeImage;
        end
    end
    
    %% Helper Functions
    methods (Access = protected)
        function driveList = updateSDList(app)
            driveList = app.DriveList;
            if ~ismember(app.ActiveSDDrive, driveList)
                app.privActiveSDDrive = driveList{1};
            end
        end
        function enableUI(app, en)
            elements = fields(app.handles);
            for ii = 1:numel(elements)
                handle = app.handles.(elements{ii});
                if ~isfield(get(handle), 'Enable')
                    continue;
                end
                if en
                    set(handle, 'Enable', 'on');
                else
                    set(handle, 'Enable', 'off');
                end
            end
        end
    end
    
    %% Static Methods
    methods (Hidden, Static)
        function item = getSelectedItem(menu)
            menuList = get(menu, 'String');
            item = menuList{get(menu, 'Value')};
        end
        function setSelectedItem(menu, item)
            menuList = get(menu, 'String');
            [is,Idx] = ismember(item, menuList);
            if ~is
                error('Could not find %s in list %s', item, menuList);
            end
            set(menu, 'Value', Idx);
        end
    end
end