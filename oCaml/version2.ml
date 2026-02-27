
(****************************************************************************************
                                        Version 2   
****************************************************************************************)
open Version1;;
open Printf;;
(****************************************************************************************
                                        Partie A   
****************************************************************************************)

(**
   Type de données pour représenter un quadtree dont les régions libres
   sont numérotées. Pendant la construction, affectez arbitrairement le
   numéro (-1) à toutes les régions. La fonction  (numerote)  fournie 
   donnera un numéro unique à chaque région une fois l'arbre complet. 
*)
type qtree =
  | Libre of int (* numéro *)
  | Mur
  | Quad of qtree * qtree * qtree * qtree (* no, ne, so, se *)

(**
   Fonction de numérotation des quadtrees
     numerote: qtree -> int -> qtree * int

   L'appel  (numerote qt k)  renvoie une paire  (qt', k')  où 
   - (qt') est un quadtree de même structure que (qt) mais dont les 
     régions libres sont numérotées consécutivement à partir de (k)
   - (k') est l'entier qui suit le dernier numéro utilisé
 *)
let rec numerote qt k = match qt with
  | Libre _ -> Libre k, k+1
  | Mur     -> Mur, k
  | Quad(no, ne, so, se) ->
     let no, k = numerote no k in
     let ne, k = numerote ne k in
     let so, k = numerote so k in
     let se, k = numerote se k in
     Quad(no, ne, so, se), k

(**
   Affichage d'un quadtree 
   (vue hiérarchique avec retrait proportionnel à la profondeur)
 *)     
open Printf
let print_qtree qt =
  let offset n = String.make n ' ' in
  let rec print o = function
    | Mur -> printf "%sMur\n" (offset o)
    | Libre k -> printf "%sLibre %d\n" (offset o) k
    | Quad(no, ne, so, se) ->
       printf "%sQuad\n" (offset o);
       print (o+2) no;
       print (o+2) ne;
       print (o+2) so;
       print (o+2) se
  in
  print 0 qt

(*
   simplifie: qtree -> qtree telle que simplifie at renvoie un nouveau quadtree simplifiant
at si possible : si un nœud interne ne contient que des sous-arbres intégralement blancs ou intégralement noirs,
ce nœud interne doit être remplacé par une feuille

  :param: qt : quad tree
  :return: qt: quad tree simplifie 
  on renvoi le nombre associe a la premiere zone : Libre (1),Libre (2),Libre (3),Libre (4)) -> Libre (1)
*)
let rec simplifie qt = 
    match qt with 
      | Libre (nb) -> Libre (nb)
      | Mur -> Mur
      | Quad(qt1,qt2,qt3,qt4) -> 
          let qts = Quad(simplifie qt1,simplifie qt2,simplifie qt3,simplifie qt4) in 
          match qts with 
            | Quad(Mur,Mur,Mur,Mur) -> Mur
            | Quad(Libre (nb),Libre (nb2),Libre (nb3),Libre (nb4)) -> Libre (nb)
            |  _ -> qts 


(*
     appartient_rect x y dx dy xCoord yCoord : int->int->int->int->int->int->bool
     :param: 
      x y dx dy representent le rectangle 
      xCoord yCoord representent les coordonnees d'une case dans la grille 
      :return: true si la case est dans le rectangle 
*)
let appartient_rect x y dx dy xCoord yCoord =
  (xCoord<(x+dx) && xCoord>=x && yCoord<(y+dy) && yCoord>=y)


(**
  signature: mur2atree_basique: int -> int -> int -> int -> int -> int -> int -> qtree
    :param: 
      x y dx dy : pour le rectangle 
      xCoord yCoord : les corrdonees du carree de taille n en rapport au carree initiale, 
    :return: qtree non simplifie d'un terrain 

*)
let rec mur2qtree_basique x y dx dy n xCoord yCoord = 
  if n=1 then begin 
      if (appartient_rect x y dx dy xCoord yCoord) then Mur
      else Libre (-1)
    end 
  else 
    Quad( mur2qtree_basique x y dx dy (n/2) (xCoord)       (yCoord + n/2) ,
          mur2qtree_basique x y dx dy (n/2) (xCoord + n/2) (yCoord + n/2) ,
          mur2qtree_basique x y dx dy (n/2) (xCoord)           (yCoord) ,
          mur2qtree_basique x y dx dy (n/2) (xCoord + n/2) (yCoord) )

(*
    mur2qtree: int -> int -> int -> int -> int -> qtree telle que mur2qtree x y dx dy  n
    renvoie un quadtree représentant un terrain de côté n, qui est libre à l’exclusion d’un rectangle décrit par les
    coordonnées (x,y) de son coin sud-ouest, sa largeur dx et sa hauteur dy
    à chaque feuille Libre on associe un nombre entier, qui permettra de l’identifer
    en tant que nœud du graphe < num =-1 > par defautl 

    :signature: mur2qtree: int -> int -> int -> int -> int -> qtree
    :param: 
      x : int : 

    1. construire l'arbre representant chaque case en fonction du rectangle 
    2. appeler la fonction simplifier arabre 
*)
let mur2qtree x y dx dy n =
  simplifie (mur2qtree_basique x y dx dy n 0 0)


(*
  Une fonction d’intersection qui, étant donnés deux quadtrees qt1 et qt2, calcule un nouveau quadtree faisant
  l’intersection des régions libres de qt1 et qt2.  
  :signature: quad -> quad -> quad 
  :param: 
    qt1, qt2 : quadtree avec region libre(nb)/Mur
  :return: intersection des deux quadtree
*)
let rec inter qt1 qt2 = 
  match (qt1,qt2) with 
  | ( _ , Libre(a))  -> qt1
  | (Libre(a), _  ) -> qt2
  | ( _ , Mur) | (Mur, _ ) -> Mur
  | (Quad(qt11,qt12,qt13,qt14),Quad(qt21,qt22,qt23,qt24) ) -> Quad(inter qt11 qt21,inter qt12 qt22,inter qt13 qt23,inter qt14 qt24)


(*
  Une fonction qui combine les deux précédentes pour faire l’intersection des quadtrees correspondant à
  chaque région intraversable   
  :signature: int -> (int*int*int*int) list -> Quad
  :param: 
    - n taille du terrain 
    - listTerrain : (int*int*int*int) list pour : < x y dx dy > list
  :return: qtree representes par cette liste de rectangles 
    - avoir une list de qtree pour chaque rectangle
    - avoir l'intersection de ces qtree
*)
let rec list2qtree n listTerrain = 
  match listTerrain with
  | [] -> failwith "listTerrain vide" 
  | (x, y, dx, dy)::[] -> (mur2qtree x y dx dy n)
  | (x, y, dx, dy)::llistTerrain -> ( inter (mur2qtree x y dx dy n) (list2qtree n llistTerrain) )

(*
  Une fonction qui combine les deux précédentes pour faire l’intersection des quadtrees correspondant à
  chaque région intraversable   
  :signature: Quad list -> Quad
  :param: 
    - listqt : Quad list pour chaque rectangle
  :return: qtree representes par cette liste de qt 
    - avoir une list de qtree pour chaque rectangle
    - avoir l'intersection de ces qtree
*)
let rec get_terrain_from_qt qt_list = 
  match qt_list with 
  | [] -> failwith "qt list est vide"
  | qt::[] -> qt
  | qt::qqt_list -> ( inter qt (get_terrain_from_qt qqt_list) )




(****************************************************************************************
                                        Partie B   
****************************************************************************************)
(*
  numeroter les zones libres du terrain de 0 au NbdeZonesLibres-1 
  :signature: Quad -> Quad
  :param: 
    - qt : quadtree representant le terrain 
  :return: 
    - quadtree numerote   
*)
let num_quad  qt = fst (numerote qt 0 ) 



(**
   Fonction de calcul des coordonnées des centres des régions libres.
   Renvoie un tableau de paires de coordonnées.
   
   Arguments :
   - (qt) le quadtree
   - (k) le nombre de régions libres
   - (n) la longueur du côté du terrain
   Pré-condition :
   - les régions doivent être numérotées de 0 à k-1
 *)
let mk_coords qt k n =
  let coords = Array.make k (0. ,0. )  in 
  let rec mk_coords_aux qt coords n x y = 
    let nf = float(n) in
    match qt with 
    | Mur -> ()
    | Libre (nb) -> coords.(nb) <- (x +. (nf/.2.) , y +. (nf/.2.) );
    | Quad (qt1, qt2, qt3, qt4) -> 
        mk_coords_aux qt1 coords (n/2) (x    ) (y+.nf/.2.) ;
        mk_coords_aux qt2 coords (n/2) (x+.nf/.2.) (y+.nf/.2.);
        mk_coords_aux qt3 coords (n/2) (x    ) (y    );
        mk_coords_aux qt4 coords (n/2) (x+.nf/.2.) (y    );
  in 
  mk_coords_aux qt coords n 0.  0.  ;
  coords 


(*
  afficher les coords de toutes les zones libres 
    print_coords coords k : (float*float) Array -> int -> unit 
    :param:
        - coords : array de paires de coords de chaque zones libre 
        - k : len(coords) 
    :pre-cond: k=len(coords)
*)
let print_coords coords k =
  for i = 0 to k-1 do 
    let x,y = coords.(i) in
    printf "%d -> (%.1f , %.1f) \n" i x y;
  done 
  
  

(**
  Type pour représenter un graphe pondéré dans la partie 2 : 
   tableau de listes d'adjacence

   Sous-entendu : les sommets d'un graphe sont numérotés consécutivement à
   partir de 0. Un graphe (g) et un numéro de sommet (i) étant donnés, g.(i)
   est une liste de paires, où chaque paire (v, d) contient
   - le numéro (v) d'un voisin
   - la distance (d) à ce voisin

   Deux fonctions d'affichage fournies
   (print_graph) donne une vue complète, longueurs des arêtes comprises
   (print_graph_compact) 
  :summary: 
        - Array -> tableau de list d'adjacence de tous les sommets       
        - Array index -> numero du sommet 
        - list -> list des voisin,distance
        - int * float -> numero du sommet voisin, distance a ce voisin              
*)
type graph = (int * float) list array

(*
  afficher un graph: Graph -> unit    
*)
let print_graph g =
  let n = Array.length g in
  printf "Graphe à %d sommets :\n" n;
  for i = 0 to n-1 do
    printf "Sommet %d:\n" i;
    List.iter (fun (v, d) -> printf "  voisin %d à distance %f\n" v d) g.(i)
  done
(*
  afficher un graph compact: Graph -> unit    
*)
let print_graph_compact g =
  for i = 0 to Array.length g - 1 do
    printf "%d:" i;
    List.iter (fun (v, _) -> printf " %d" v) g.(i);
    printf "\n"
  done


(*
  arrete (a,b) est une arrete entre le sommet a et le sommet b   
*)
type arrete = (int * int)  

(*
   arrete list -> unit 
   afficher la list d'arrete du graph 
*)
let print_arretes arretes = 
  List.iter (fun arrete -> printf "(%d,%d)\n" (fst(arrete)) (snd(arrete))) arretes


(*
   get_hori_arrete : quad -> quad -> arrete list entre qt1 qt2 
   tq: 
      (* no, ne, so, se *) du qt1 est (* qt11,qt12,qt13,qt14 *) 
      (* no, ne, so, se *) du qt2 est (* qt21,qt22,qt23,qt24 *) 
*)
let rec get_hori_arrete qt1 qt2 =    
  match (qt1, qt2) with 
  | ( _ ,Mur) | (Mur, _ ) -> [] 
  | (Libre(s1), Libre(s2)) -> [(s1, s2) ]
  | (Libre(s1), Quad(qt21,qt22,qt23,qt24)) -> 
        (get_hori_arrete qt1 qt21)@(get_hori_arrete qt1 qt23)
  | (Quad(qt11,qt12,qt13,qt14), Libre(s2) ) -> 
        (get_hori_arrete qt12 qt2)@(get_hori_arrete qt14 qt2)
  | (Quad(qt11,qt12,qt13,qt14),Quad(qt21,qt22,qt23,qt24) ) -> 
        (get_hori_arrete qt12 qt21)@(get_hori_arrete qt14 qt23)

(*
  Enumèrer les arêtes à l’interface entre deux quadtrees adjacents horizontalement,   
  interface_horizontale qt: quad -> arrete list 
*)
let rec interface_horizontale_all qt =
  match qt with 
  | Libre(_) | Mur -> [] 
  | Quad(qt1,qt2,qt3,qt4) -> 
    (get_hori_arrete qt1 qt2)@(get_hori_arrete qt3 qt4)
    @(interface_horizontale_all qt1)
    @(interface_horizontale_all qt2)
    @(interface_horizontale_all qt3)
    @(interface_horizontale_all qt4)


(*
   get_verti_arrete : quad -> quad -> arrete list entre qt1 qt2 
   tq: 
      (* no, ne, so, se *) du qt1 est (* qt11,qt12,qt13,qt14 *) 
      (* no, ne, so, se *) du qt2 est (* qt21,qt22,qt23,qt24 *) 
*)
let rec get_verti_arrete qt1 qt2 =    
  match (qt1, qt2) with 
  | ( _ ,Mur) | (Mur, _ ) -> [] 
  | (Libre(s1), Libre(s2)) -> [(s1, s2) ]
  | (Libre(s1), Quad(qt21,qt22,qt23,qt24)) -> 
        (get_verti_arrete qt1 qt21)@(get_verti_arrete qt1 qt22)
  | (Quad(qt11,qt12,qt13,qt14), Libre(s2) ) -> 
        (get_verti_arrete qt13 qt2)@(get_verti_arrete qt14 qt2)
  | (Quad(qt11,qt12,qt13,qt14),Quad(qt21,qt22,qt23,qt24) ) -> 
        (get_verti_arrete qt13 qt21)@(get_verti_arrete qt14 qt22)

(*
  Enumèrer les arêtes à l’interface entre deux quadtrees adjacents verticalement,   
  interface_verticale qt: quad -> arrete list 
*)
let rec interface_verticale_all qt =
  match qt with 
  | Libre(_) | Mur -> [] 
  | Quad(qt1,qt2,qt3,qt4) -> 
    (get_verti_arrete qt1 qt3)@(get_verti_arrete qt2 qt4)
    @(interface_verticale_all qt1)
    @(interface_verticale_all qt2)
    @(interface_verticale_all qt3)
    @(interface_verticale_all qt4)


(*
    get_all_arrete_non_optimise : quad -> arrete list
    :return: toutes les arretes entres les zones libres
    <version non pas encore optimisee>
*)
let get_all_arrete_Vnon_optimise qt = 
  (interface_verticale_all qt)@(interface_horizontale_all qt)


(*
  get_voisin : arrete list -> int -> int list 
  :param: 
    - arretes: list d'arretes d'un graph 
    - nb: sommet numero nb du graph 
  :return: la list des voisins du sommet nb    
*)
let rec get_voisins arretes nb = 
  match arretes with 
  | [] -> []
  | (s1,s2)::aaretes -> 
      if s1 = nb then s2::(get_voisins aaretes nb )
        else if  s2 = nb then s1::(get_voisins aaretes nb)
          else  (get_voisins aaretes nb )




(*
  int -> int -> (int*float)Array -> float 
*)
let distance s1 s2 coords = 
  let x1,y1 = coords.(s1) in 
  let x2,y2 = coords.(s2) in
  Float.sqrt((x2-.x1)*.(x2-.x1)+.(y2-.y1)*.(y2-.y1))

let distance_p1p2 p1 p2 = 
  let x1,y1 = p1 in 
  let x2,y2 = p2 in
  Float.sqrt((x2-.x1)*.(x2-.x1)+.(y2-.y1)*.(y2-.y1))

(*
    add_list_adjacence: graph -> int -> (int*(float*float) list -> int list -> void )
    :param: 
      - voisinList int list 
      - coords (float*float)Array
    :add: (int*float) list to g 
*)
let add_list_adjacence g nb coords voisin_list = 
  let rec get_list_adjacence nb coords voisin_list =
    match voisin_list with
    | [] -> []
    | s::vvoisin_list -> 
      (s, (distance nb s coords))::get_list_adjacence nb coords vvoisin_list 
  in 
  let list_adjNB = get_list_adjacence nb coords voisin_list in 
  g.(nb) <- list_adjNB
  

(**
  Fonction de construction d'un graphe pondéré à partir d'un quadtree.
  Renvoie un graphe.

  Arguments :
  - (qt) le quadtree
  - (coords) le tableau des coordonnées
  - (k) len(coords)
*)
let mk_graph qt coords =
  let k = Array.length coords in 
  let g = Array.make k [] in 
  let arretes = get_all_arrete_Vnon_optimise qt in
  let rec mk_graph_aux g qt coords = 
    match qt with 
    | Mur -> ()
    | Libre (nb) -> add_list_adjacence g nb coords (get_voisins arretes nb)
    | Quad(qt1, qt2, qt3, qt4) -> 
      mk_graph_aux g qt1 coords; 
      mk_graph_aux g qt2 coords; 
      mk_graph_aux g qt3 coords; 
      mk_graph_aux g qt4 coords; 
  in 
  mk_graph_aux g qt coords;
  g 


