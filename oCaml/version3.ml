

(****************************************************************************************
                                        version 3 : dijkstra optimise   
****************************************************************************************)

open Version1;;
open Version2;;
open Printf;;

(*
  un tas est un arbre binaire dont chaque nœud contient un élément, et où le fst de l’élément
  porté par un nœud est inférieur ou égal aux fst des éléments portés par ses fils.
*)
type tas  =
  | E 
  | N of tas * (float*int) * tas  

(*
  initialiser le tas  () -> tas 
*)
let create () = ref E  

(*
  is_empty tas->bol 
  :return: vrai si la file est vide    
*)
let is_empty tas = 
  match tas with 
  | E -> true 
  | _ -> false 

(*
  extract_min file_prio : tas -> int 
*)
let min tas = 
  match tas with 
  | E -> assert false
  | N (l , n , r ) -> n

(*
  add x t : (float*int)->tas->tas
  ajouter x a la file t   
*)
let rec add x t = 
  match t with
    | E -> N (E , x , E ) 
    | N (l , n , r ) -> 
        if (fst(x)) <= (fst(n)) then N ( add n r , x , l )
        else N ( add x r , n , l ) 
 
(*
    take one : tas -> (flaot*int)*tas
    fonction aux de merge 
*)
let rec take_one tas = 
  match tas with 
    | E -> assert false
    | N (E , n , E ) -> n , E
    | N (l , n , r ) -> let x , ll = take_one l in
      x , N (r , n , ll)
  
(*
  merge t1 t2 : tas -> tas -> tas 
  fusioner le tas 1 avec tas 2    

*)
let rec merge t1 t2 = 
  match t1 , t2 with
    | _ , E -> t1
    | E , _ -> assert false
    | N ( l1 , n1 , r1 ) , N ( l2 , n2 , r2 ) ->
          if (fst(n1)) <= (fst(n2)) then N ( t2 , n1 , merge l1 r1 )
          else let x , tt1 = take_one t1 in
            N ( add x ( merge l2 r2 ) , n2 , tt1)

(*
    remove min : tas -> (flaot*int)*tas 
    renvoyer le min et le supprimer du tas 
*)
let remove_min tas = 
  match tas with 
    | E -> assert false
    | N (l , n , r ) -> (n,(merge l r))

(*
  insert (flaot*int)-> tas ref -> ()
*) 
let insert (d,s) file_prio =
  file_prio := add (d,s) !file_prio 

(*
  extract : tas ref -> (float*int )
  renvoyer le min tout en le supprimant du tas pointe par file_prio   
*)
let extract file_prio =
  let (n,tas) = remove_min !file_prio in 
  file_prio := tas; 
  n


    

(*
  calculer la longueur du chemin le plus court depuis la source vers 
  chaque sommet du graphe ET renvoyer un tableau des prédécesseurs, donnant pour chaque sommet atteignable 
  le sommet qui le  précède sur un chemin le plus court depuis la source. 
  :pre-cond: : cet algorithme ne fonctionne pas dans le cas où le graphe contient des arêtes dont 
                la « longueur » serait négative.
  dijkstra : graph -> int -> (float Array * int Array) 
*)
let dijkstra g s dest=
  let n = Array.length g in
  let preds = Array.make n (-1) in (* -1 for not yet added *)
  let vus = Array.make n false in
  let dist = Array.make n infinity in (*sinon 8888. as arbitrary max Int.min_int *)
  let file_prio = create () in
  let ajoute s a d = 
      dist.(s) <- d ; 
      preds.(s) <- a;
      insert (d,s) file_prio;  (*src et distance <-*)
  in
  ajoute s s 0.;
  while not ( is_empty !file_prio ) && s!=dest do
    let (ds, s) = extract file_prio in
    if (not vus.(s) ) then (
      vus.(s) <- true ;
      List.iter( fun (v, dsv) ->
                      let d = ds +. dsv in
                      if d < dist.(v) then ajoute v s d 
                ) g.(s)
    )
  done ;
  (dist,preds)




(*
  renvoi la case libre la plus proche a au point p(x,y) 
  get_case_libre : (float*float) -> (float*float) Array -> quad -> int   
*)
let get_case_libre (x, y) coords qt =
  let closest_zone = ref Int.min_int in
  let smallest_distance_to_p = ref Float.max_float in
  let rec get_case_libre_aux = function
    | Mur -> ()
    | Libre(nb) ->
        if distance_p1p2 (x, y) coords.(nb) < !smallest_distance_to_p then (
          closest_zone := nb;
          smallest_distance_to_p := distance_p1p2 (x, y) coords.(nb)
        )
    | Quad (no, ne, so, se) ->
        get_case_libre_aux no;
        get_case_libre_aux ne;
        get_case_libre_aux so;
        get_case_libre_aux se
  in
  get_case_libre_aux qt;
  !closest_zone



(**
   Fonction de recherche d'un chemin.
   Applique un algorithme de recherche et reconstruit le trouvé.
   Renvoie la liste des paires de coordonnées formant le chemin.

   Arguments :
   - (xDep, yDep) les coordonnées du point de départ
   - (xArr, yArr) les coordonnées du point d'arrivée
   - (qt, n) le quadtree et la longueur du côté du terrain
   - (g, coords) le graphe et le tableau des coordonnées

   find_path : (float*float) -> (float*float) -> (quad*int) -> (graph*(float*float)Array) -> (float*float) list 
 *)
let find_path (xDep, yDep) (xArr, yArr) (qt, n) (g, coords) =
  let src = get_case_libre (xDep, yDep) coords qt in
  let dest = get_case_libre (xArr, yArr) coords qt in
  let dist, preds = dijkstra g src dest in
  let rec find_path_aux pred path =
    if preds.(pred) == pred then
      path
    else
      find_path_aux preds.(pred) (coords.(pred) :: path)
  in
  (find_path_aux dest [])
 

