 
open Version1 ;;
open Printf;;

let file = Sys.argv.(1) in

printf "\n********* testing version1 ***********\n\n";

printf "\n********* rectangles ***********\n\n";
let listTerrain, n = (load file) in 
List.iter (fun (x, y, dx, dy) -> printf "%d %d %d %d\n" x y dx dy ) listTerrain;

printf "\n********* Matrice ***********\n\n";
let terrain = repTerrain n listTerrain in 
printMatrix terrain n; 

printf "\n********* chemin ***********\n\n";
printf "le chemin entre (%d,%d) et la dest (%d,%d) est : \n" 2 0 4 3;
let path = (explore_find_path terrain 2 0 4 3) in
print_path_numInt path;

printf "\n********* afficher le terrain avec chemin ***********\n\n";
print_path_in_terrain terrain n path;

