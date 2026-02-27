
(****************************************************************************************
                                        programme final   
****************************************************************************************)

open Version1;;
open Version2;;
open Version3;;
open Printf;;


(**
   Exemple d'ossature pour un programme complet, prenant un nom de fichier
   sur la ligne de commande et affichant le chemin trouvé, ainsi que quelques
   mesures de temps d'exécution.
   Note : la mesure des temps d'exécution peut ne pas fonctionner sous windows.
 *)
  
 let _ =
  let file = Sys.argv.(1) in
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
  printf "\n******** chemin- *******\n\n";print_path path
