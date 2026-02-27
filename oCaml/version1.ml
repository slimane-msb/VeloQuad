(****************************************************************************************
                                        Version 1   
****************************************************************************************)


(**
   Fonction de lecture du fichier d'entrée
     load: string -> (int * int) list * int

   L'appel  (load f)  lit le fichier dont le nom est donné par la 
   chaîne (f) et renvoie une paire  (murs, n)  où
   - (murs) est la liste des quadruplets (x, y, dx, dy) donnant les
     dimensions des r zones intraversables
   - (n) est la longueur du côté du terrain
   On suppose que le fichier (f) contient une description de terrain
   valide. Le résultat de (load) n'est pas spécifié sinon.
 *)
 open Scanf
 let load file =
   let c = Scanning.open_in file in
   let n = bscanf c "%d\n" (fun n -> n) in
   let r = bscanf c "%d\n" (fun r -> r) in
   let murs = ref [] in
   for _ = 1 to r do
     bscanf c "%d %d %d %d\n" (fun x y dx dy -> murs := (x, y, dx, dy) :: !murs)
   done;
   !murs, n


(*
   fonction pour remplir un rectangle, et donc pour qu'ils soit pas traversable sur la matrice
   0 pour non traversable 
*)
let remplieRect matrix x y l h =
  for i=x to x+l- 1 do 
    for j =y to y+h-1 do
      matrix.(i).(j) <- 0; 
    done
  done



(*
  une fonction qui, partant de n et de la liste des rectangles intraversables crée un tableau t représentant
  le terrain.
  return une matrice terrain a partir d'une list de rectangle 
*)
let repTerrain n listTerrain =
  let matrixRes = Array.make_matrix n n 1 in

  let rec repTerrainMatrix matrix listTerrain = 
   match listTerrain with
    [] -> ()
    |(x,y,l,h)::llistTerrain -> 
      remplieRect matrix x y l h ;
      repTerrainMatrix matrix llistTerrain
  in
  repTerrainMatrix matrixRes listTerrain ;
  matrixRes


(*
  afficher une array 2d   
*)

let printMatrixWithCoord matrix n =
  for i=0 to n-1 do 
    for j =0 to n-1 do
      Printf.printf "matrix.(%d).(%d)= %d\n" i j matrix.(i).(j); 
    done
  done



(*
  afficher une array 2d sous forme d'une grille  
*)

let printMatrix matrix n =
  for j=n-1 downto 0 do 
    for i =0 to n-1 do
      Printf.printf "%d " matrix.(i).(j); 
    done;
    Printf.printf "\n";
  done



(* 
  :param: 
    g (int array)  -> terrain 
    vus (bol array)-> matrice des case deja visitees
    n (int)        -> longeur des ces matrices
    x (int)        -> point.x
    y (int)        -> point.y
  :return: (int * int) list de toutes les cases voisine traversable et pas encore visitees
*)
let voisin g vus n x y =
  let res = [(x,y+1);(x,y-1);(x+1,y);(x-1,y)] in 
  let rec loop res=
    match res with 
      [] -> []
      |(x,y):: rres -> 
        if ( x>=n || x<0 || y>=n || y<0)  then loop rres
        else 
          if g.(x).(y) = 0 || vus.(x).(y) = true then loop rres
          else (x,y)::(loop rres)
    in
    loop res
 


(*
  :param: 
    voisin_path: (bol*(int*int)list) list de path de tous les voisins 
    paire: (int*int) coord du la case actuelle 
  :return: les path ayant bol=true ou (false,[]) sinon 

  une fonction d’exploration du terrain. Cette fonction doit prendre en entrée le tableau t, les coordon  nées d’un point de départ et d’un point d’arrivée, et renvoyer un itinéraire valide sous la forme d’une liste
  de paires de coordonnées, parcour en profondeur 
*)
let rec return_valid_path voisin_path paire =
  match voisin_path with 
  [] -> []
  |list::listlist ->  paire::list 


(*
  int->int->int->int->bol 
  :return: si point1 = point2
*)
let posCmp x y  x2 y2 = 
  ( (x=x2) && (y=y2) ) 
  


(* 
  :param: 
    terrain: int array -> matrice du terrain 
    x1 x2 y1 y2 : int->int->int->int : coord des point src et dist
  :return: valid path entre p1 et p2 
    vus: bol array -> case visitees 
    loop x y -> trouver un chemin de x y a x2 y2 , et mettre x y comme visitees
    1. trouver les voisins valides de x y 
    2. trouver un chemin entre chaque voisin et destination (true,chemin) ou (false, []) si aucun chemin 
    3. return valid_path : le premier chemin valid parmis les chemin des voisin auquel on ajout (x,y)
*)
let rec explore_find_path terrain x1 y1 x2 y2 =
  let n = Array.length terrain in
  let vus = Array.make_matrix n n false in
  let rec loop x y =
    if ( posCmp x y  x2 y2) then [(x,y)]
    else 
      begin  
        vus.(x).(y) <- true ;
        let voisin_path = List.map ( fun v ->  loop (fst v) (snd v) ) (voisin terrain vus n x y ) in
        (return_valid_path voisin_path (x,y)) 
      end 
  in
  loop x1 y1



(*
  afficher un chemin :  (int*int) list -> unit 
*)
let print_path_numInt p =
  List.iter (fun (x, y) -> Printf.printf "(%d, %d) " x y) p;
  Printf.printf "\n"

(*
  afficher un chemin :  (float*float) list -> unit 
*)
let print_path p =
  List.iter (fun (x, y) -> Printf.printf " ->   (%.1f, %.1f)" x y) p;
  Printf.printf "\n\n"

  


(*
  :return: true si (x,y) appartient a path 
  :param: 
    path (int*int) list 
    x int 
    y int 
*)
let rec path_contains path x y = 
  match path with 
  [] -> false
  | (x1,y1)::ppath -> 
    if x1 = x && y1 = y then true
      else path_contains ppath x y



(*
  afficher le chemin sur la matrice comme src ***** dest   
*)
let print_path_in_terrain matrix n path =
  for j = n-1 downto 0 do 
    for i = 0 to n-1 do
      if ( path_contains path i j ) then 
        Printf.printf "* " 
      else 
        Printf.printf "%d " matrix.(i).(j); 
    done;
    Printf.printf "\n";
  done



