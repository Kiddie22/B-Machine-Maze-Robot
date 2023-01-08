/* Maze
 * Author: Rasula
 * Creation date: 06/01/2023
 */
 
MACHINE
    Maze

CONSTANTS
    maze,
    height,
    width,
    x_range,
    y_range,
    internal_walls,
    entrance_square,
    exit_square
    
PROPERTIES
    // height of the maze is 5
    height = 5 & 
    
    // width of the maze is 7
    width = 7 &
    
    x_range <: NAT1 &
    x_range = 1..width & 
        
    y_range <: NAT1 &
    y_range = 1..height &
    
    // maze
    maze : x_range <-> y_range &
    maze = (x_range * y_range) &
    
    // internal walls
    internal_walls = {
        (1 |-> 3), (2 |-> 1), (2 |-> 3), (2 |-> 5), (3 |-> 3), (4 |-> 2), (4 |-> 3), (4 |-> 4), (6 |-> 1), (6 |-> 2), (6 |-> 4), (7 |-> 4)    
    } &
    
    // Defining entrance & exit squares 
    entrance_square : x_range * y_range &
    entrance_square = (1 |-> 1) &
    
    exit_square : x_range * y_range &
    exit_square = (1 |-> 5)   
END