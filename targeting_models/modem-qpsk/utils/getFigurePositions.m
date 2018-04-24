function positions = getFigurePositions(tile, screenBorder)
    numRows   = tile(1);
    numCols   = tile(2);
    figBorder = [20, 60];

    screenSize = get(0,'screensize'); % Determine terminal size in pixels

    % Adjust to actual visible screen size
    screenSize(3:4) = screenSize(3:4) - (nargin == 2) * 2 * screenBorder;

    % Set figure width and height with border
    figWidth  = fix(screenSize(3)/numCols);
    figHeight = fix(screenSize(4)/numRows);

    % Calculate horizontal and vertical position for each figure
    horPos = screenSize(3) - (numCols:-1:1)*figWidth  + figBorder(1);
    verPos = screenSize(4) - (1:numRows)*figHeight    + figBorder(2);
    horPosAll = repmat(horPos', [numRows, 1]);
    verPosAll = repmat(verPos,  [numCols, 1]);
    
    % Return position
    positions = zeros(prod(tile), 4);
    positions(:,1) = horPosAll;
    positions(:,2) = verPosAll(:);
    positions(:,3) = figWidth  - 2 * figBorder(1);
    positions(:,4) = figHeight - 2 * figBorder(2);
end