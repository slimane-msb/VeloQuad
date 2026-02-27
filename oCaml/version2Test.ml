(****************************************************************************************
                                        version 2 partie A TEST    
****************************************************************************************)


open Version1;;
open Version2;;
open Dijkstra;;
open Printf;;

printf "******** testing version2 part 1 ********\n";
let file = Sys.argv.(1) in

(* ***************************************************************************************
                                        A. q1 q2 test    
****************************************************************************************)

let qt1 = mur2qtree 2 2 2 4 8 in 
let qt2 = mur2qtree 3 1 3 1 8 in 
let inter_qt1_qt2 = inter qt1 qt2 in 

printf "\n******** qt1 : 2 2 2 4 8 ********\n\n"; print_qtree (qt1);
printf "\n******** qt1 : 3 1 3 1 8 ********\n\n"; print_qtree (qt2);
printf "\n******** inter qt1 qt2 ********\n\n"; print_qtree (inter_qt1_qt2);




(****************************************************************************************
                                        A.q3 test    
****************************************************************************************)

let listTerrain, n = (load file) in 

let terrain = list2qtree n listTerrain in 

printf "\n******** Terrain a pleusieur rectangles: a partir de la list des rectangle *******\n\n"; print_qtree (terrain);

(****************************************************************************************
                                        A.q3 Bis test    
****************************************************************************************)
let qt3 = mur2qtree 2 4 4 1 8 in 
let terrain_qt = get_terrain_from_qt [qt1; qt2; qt3] in
printf "\n******** Terrain a pleusieur rectangles : a partir des qt list *******\n\n"; print_qtree (terrain_qt);


(****************************************************************************************
                                       partie B 
****************************************************************************************)

(****************************************************************************************
                                        B.q1   
****************************************************************************************)
let listTerrain, n = (load file) in 
let terrain = list2qtree n listTerrain in 

let terrain_num = num_quad terrain in
printf "\n******** Terrain avec numero *******\n\n"; print_qtree (terrain_num);


(****************************************************************************************
                                        B.q2   
****************************************************************************************)
let terrain_num,k = numerote terrain 0 in 
let tab_coord = mk_coords terrain_num k n in 
printf "\n******** g : coords des zones libres de ce dernier *******\n\n"; print_coords tab_coord k;

(****************************************************************************************
                                        B.q3q4   
****************************************************************************************)
let g =  mk_graph terrain_num tab_coord in 
let arretes = get_all_arrete_Vnon_optimise terrain_num in  
printf "\n******** arretes du graph  *******\n\n";print_arretes arretes ; 
printf "\n******** graph  *******\n\n";print_graph g ; 
printf "\n******** graph   -compact- *******\n\n";print_graph_compact g; 



(****************************************************************************************
                                       partie C 
****************************************************************************************)


(**
   Exemple d'ossature pour un programme complet, prenant un nom de fichier
   sur la ligne de commande et affichant le chemin trouvé, ainsi que quelques
   mesures de temps d'exécution.
   Note : la mesure des temps d'exécution peut ne pas fonctionner sous windows.
 *)
 printf "\n******** partie C -plus court chemin- *******\n\n";

let murs, n = load file in
let t1 = Unix.gettimeofday() in
let qt, k = numerote (list2qtree n murs) 0 in
let t2 = Unix.gettimeofday() in
let coords = mk_coords qt k n in
let g = mk_graph qt coords in
let t3 = Unix.gettimeofday() in
let path = find_path ((float(n)/.2.), 0.) ((float(n)/.2.), float(n)) (qt, n) (g, coords) in
let t4 = Unix.gettimeofday() in
printf "Temps:\n  construction du quadtree %fs\n  construction du graphe %fs\n  recherche de chemin %fs\n" (t2 -. t1) (t3 -. t2) (t4 -. t3);
printf "\n******** src(%.3f,%.3f) ----> dest(%.3f,%.3f) - *******\n\n"  (float(n)/.2.) (0.) (float(n)/.2.) (float(n));
printf "\n******** chemin- *******\n\n";print_path path;