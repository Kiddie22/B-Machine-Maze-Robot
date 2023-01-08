/* Robot
 * Author: Rasula
 * Creation date: 06/01/2023
 */

MACHINE
    Robot
    
DEFINITIONS
    // Additional References
    // https://rasarathrilanka.medium.com/how-to-do-a-simple-animation-with-prob-a-step-by-step-guide-8e9e6b437aa
    
    // Animation
    ANIMATION_FUNCTION == ({ row, col, i | col:1..7 & row:1..5 & i=0 });
    ANIMATION_FUNCTION1 == ({ row, col, i | col:1..7 & row:1..5  & i=1 & (col, 6-row) : internal_walls });
    ANIMATION_FUNCTION2 == ({ row, col, i | col:1..7 & row:1..5 & i=2 & col=robotXPosition & row=(6-robotYPosition) });
   
    // Images
    ANIMATION_IMG0 == "/empty_square.gif";
    ANIMATION_IMG1 == "/wall.gif";
    ANIMATION_IMG2 == "/circle.gif";
    
SEES
    Maze
    
SETS
    MESSAGE = {Moved_North, Moved_East, Moved_South, Moved_West, Teleported, Out_Of_Bounds, Crashed, yes, no};
    isFound = {true, false}
    
VARIABLES
    robotXPosition,
    robotYPosition,
    currentPosition,
    visitedSquares,
    exitFound
    
INVARIANT
    // Robot x range
    robotXPosition : x_range &
    
    // Robot y range
    robotYPosition : y_range &
    
    // current position of the robot
    currentPosition : maze &
    
    // visited squares are kept as a sequence to keep track of the order and allow duplicate values
    visitedSquares : seq(maze) &

    // exitFound is kept as a boolean
    exitFound : isFound
    
INITIALISATION
    robotXPosition := 1 ||
    robotYPosition := 1 ||
    currentPosition := ( 1 |-> 1 ) ||
    visitedSquares := [( 1 |-> 1 )] ||
    exitFound := false
    
OPERATIONS
    
    message <-- MoveNorth = 
        PRE exitFound = false
        THEN
            // Checks whether the square above the current position is within the maze 
            IF (robotYPosition + 1 > max(y_range))
            THEN 
                message := Out_Of_Bounds
            // Checks whether the square above the current position is not an internal wall
            ELSIF ((robotXPosition |-> robotYPosition + 1) : internal_walls) 
            THEN 
                message := Crashed
            ELSE 
                IF ((robotXPosition |-> robotYPosition + 1) = exit_square)
                THEN
                    exitFound := true
                END ||
                robotYPosition := robotYPosition + 1 ||
                currentPosition := (robotXPosition |-> robotYPosition + 1) ||
                visitedSquares := (visitedSquares <- (robotXPosition |-> robotYPosition + 1)) ||
                message := Moved_North
            END
        END;

    message <-- MoveEast = 
        PRE exitFound = false
        THEN
            IF (robotXPosition + 1 > max(x_range))
            THEN 
                message := Out_Of_Bounds
            // Checks whether the square to the right of the current position is not an internal wall
            ELSIF ((robotXPosition + 1 |-> robotYPosition) : internal_walls) 
            THEN 
                message := Crashed
            ELSE 
                robotXPosition := robotXPosition + 1 ||          
                currentPosition := (robotXPosition + 1 |-> robotYPosition) ||
                visitedSquares := (visitedSquares <- (robotXPosition + 1 |-> robotYPosition)) ||
                message := Moved_East
            END
        END;

    message <-- MoveSouth = 
        PRE exitFound = false
        THEN
            IF (robotYPosition - 1 < min(y_range))
            THEN 
                message := Out_Of_Bounds
            // Checks whether the square below the current position is not an internal wall
            ELSIF ((robotXPosition |-> robotYPosition - 1) : internal_walls) 
            THEN 
                message := Crashed
            ELSE                 
                robotYPosition := robotYPosition - 1 ||
                currentPosition := (robotXPosition |-> robotYPosition - 1) ||
                visitedSquares := (visitedSquares <- (robotXPosition |-> robotYPosition - 1)) ||
                message := Moved_South
            END        
        END;

    message <-- MoveWest = 
        PRE exitFound = false
        THEN
            IF (robotXPosition - 1 < min(x_range))
            THEN 
                message := Out_Of_Bounds
            // Checks whether the square to the left of the current position is not an internal wall
            ELSIF ((robotXPosition - 1 |-> robotYPosition) : internal_walls) 
            THEN 
                message := Crashed
            ELSE 
                robotXPosition := robotXPosition - 1 ||          
                currentPosition := (robotXPosition - 1 |-> robotYPosition) ||
                visitedSquares := (visitedSquares <- (robotXPosition - 1 |-> robotYPosition)) ||
                message := Moved_West
            END
        END;

    message <-- Teleport(teleportXPosition, teleportYPosition) =
        PRE teleportXPosition : NAT1 & teleportYPosition : NAT1 & teleportXPosition : x_range & teleportYPosition : y_range &
            (teleportXPosition |-> teleportYPosition) /= currentPosition & exitFound = false
        THEN
            IF ((teleportXPosition |-> teleportYPosition) : internal_walls)
            THEN 
                message := Crashed
                                   
            // Check if robot is within the boundaries
            ELSIF ((teleportXPosition |-> teleportYPosition) /: maze)
            THEN
                message := Out_Of_Bounds
                
            ELSE
                IF ((teleportXPosition |-> teleportYPosition) = exit_square)
                THEN
                    exitFound := true
                END ||
                robotXPosition := teleportXPosition ||
                robotYPosition := teleportYPosition ||
                currentPosition := (teleportXPosition |-> teleportYPosition) ||
                visitedSquares := (visitedSquares <- (teleportXPosition |-> teleportYPosition)) ||              
                message := Teleported
            END
        END;

    position <-- getPosition =
        BEGIN 
            position := currentPosition
        END;

    query <-- foundExit = 
        BEGIN
            IF (currentPosition = exit_square)
            THEN 
                query := yes
            ELSE 
                query := no
            END
        END;

    hasVisited <-- hasVisitedSquare(visitedXPosition, visitedYPosition) =
        PRE
            visitedXPosition : NAT1 & visitedYPosition : NAT1 & ((visitedXPosition |-> visitedYPosition) : maze)
        THEN 
            IF ((visitedXPosition |-> visitedYPosition) : ran(visitedSquares))
            THEN 
                hasVisited := yes
            ELSE
                hasVisited := no
            END
        END;

    route <-- robotsRoute =
        BEGIN
            route := visitedSquares
        END;

    resetGrid =
        PRE 
            exitFound = true
        THEN
            robotXPosition := 1 ||
            robotYPosition := 1 ||
            currentPosition := ( 1 |-> 1 ) ||
            visitedSquares := [( 1 |-> 1 )] ||
            exitFound := false
        END
        
END