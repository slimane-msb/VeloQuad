open Printf
open Scanf

(*****************************************************************)
(* TYPES                                *)
(*****************************************************************)

type qtree =
  | Libre of int
  | Mur
  | Quad of qtree * qtree * qtree * qtree

type graph = (int * float) list array

type tas =
  | E 
  | N of tas * (float * int) * tas  

(*****************************************************************)
(* PRIORITY QUEUE                         *)
(*****************************************************************)

let create () = ref E  

let is_empty tas = match tas with E -> true | _ -> false 

let rec add x t = 
  match t with
    | E -> N (E, x, E) 
    | N (l, n, r) -> 
        if fst x <= fst n then N (add n r, x, l)
        else N (add x r, n, l) 

let rec take_one tas = 
  match tas with 
    | E -> assert false
    | N (E, n, E) -> n, E
    | N (l, n, r) -> 
        let x, ll = take_one l in
        x, N (r, n, ll)

let rec merge t1 t2 = 
  match t1, t2 with
    | _, E -> t1
    | E, _ -> assert false
    | N (l1, n1, r1), N (l2, n2, r2) ->
          if fst n1 <= fst n2 then N (t2, n1, merge l1 r1)
          else let x, tt1 = take_one t1 in
            N (add x (merge l2 r2), n2, tt1)

let remove_min tas = 
  match tas with 
    | E -> assert false
    | N (l, n, r) -> (n, merge l r)

let insert (d, s) file_prio = file_prio := add (d, s) !file_prio 

let extract file_prio =
  let (n, tas) = remove_min !file_prio in 
  file_prio := tas; 
  n

(*****************************************************************)
(* QUADTREE LOGIC                         *)
(*****************************************************************)

let rec numerote qt k = match qt with
  | Libre _ -> Libre k, k + 1
  | Mur -> Mur, k
  | Quad (no, ne, so, se) ->
      let no, k = numerote no k in
      let ne, k = numerote ne k in
      let so, k = numerote so k in
      let se, k = numerote se k in
      Quad (no, ne, so, se), k

let rec simplifie qt = 
  match qt with 
  | Quad (qt1, qt2, qt3, qt4) -> 
      let qts = Quad (simplifie qt1, simplifie qt2, simplifie qt3, simplifie qt4) in 
      (match qts with 
      | Quad (Mur, Mur, Mur, Mur) -> Mur
      | Quad (Libre n1, Libre n2, Libre n3, Libre n4) when n1 = n2 && n2 = n3 && n3 = n4 -> Libre n1
      | _ -> qts)
  | _ -> qt

let appartient_rect x y dx dy xC yC =
  xC < (x + dx) && xC >= x && yC < (y + dy) && yC >= y

let rec mur2qtree_basique x y dx dy n xC yC = 
  if n = 1 then 
    if appartient_rect x y dx dy xC yC then Mur else Libre (-1)
  else 
    let half = n / 2 in
    Quad (mur2qtree_basique x y dx dy half xC (yC + half),
          mur2qtree_basique x y dx dy half (xC + half) (yC + half),
          mur2qtree_basique x y dx dy half xC yC,
          mur2qtree_basique x y dx dy half (xC + half) yC)

let mur2qtree x y dx dy n = simplifie (mur2qtree_basique x y dx dy n 0 0)

let rec inter qt1 qt2 = 
  match qt1, qt2 with 
  | _, Libre _ -> qt1
  | Libre _, _ -> qt2
  | _, Mur | Mur, _ -> Mur
  | Quad (a, b, c, d), Quad (e, f, g, h) -> Quad (inter a e, inter b f, inter c g, inter d h)

let rec list2qtree n = function
  | [] -> Mur
  | [m] -> let (x, y, dx, dy) = m in mur2qtree x y dx dy n
  | (x, y, dx, dy) :: rest -> inter (mur2qtree x y dx dy n) (list2qtree n rest)

(*****************************************************************)
(* GRAPH BUILDING                         *)
(*****************************************************************)

let mk_coords qt k n =
  let coords = Array.make k (0., 0.) in
  let rec aux qt n x y = 
    let nf = float n in
    match qt with 
    | Libre nb -> coords.(nb) <- (x +. (nf /. 2.), y +. (nf /. 2.))
    | Quad (qt1, qt2, qt3, qt4) -> 
        let h = n / 2 in
        aux qt1 h x (y +. nf /. 2.); aux qt2 h (x +. nf /. 2.) (y +. nf /. 2.);
        aux qt3 h x y; aux qt4 h (x +. nf /. 2.) y
    | Mur -> ()
  in aux qt n 0. 0.; coords

let distance_p1p2 (x1, y1) (x2, y2) = sqrt ((x2 -. x1) ** 2. +. (y2 -. y1) ** 2.)

let rec get_hori_arrete qt1 qt2 = match qt1, qt2 with
  | _, Mur | Mur, _ -> []
  | Libre s1, Libre s2 -> [(s1, s2)]
  | Libre _, Quad (q, _, r, _) -> (get_hori_arrete qt1 q) @ (get_hori_arrete qt1 r)
  | Quad (_, q, _, r), Libre _ -> (get_hori_arrete q qt2) @ (get_hori_arrete r qt2)
  | Quad (_, q1, _, r1), Quad (q2, _, r2, _) -> (get_hori_arrete q1 q2) @ (get_hori_arrete r1 r2)

let rec interface_horizontale_all = function
  | Quad (q1, q2, q3, q4) -> 
      (get_hori_arrete q1 q2) @ (get_hori_arrete q3 q4) @ 
      List.concat (List.map interface_horizontale_all [q1; q2; q3; q4])
  | _ -> []

let rec get_verti_arrete qt1 qt2 = match qt1, qt2 with
  | _, Mur | Mur, _ -> []
  | Libre s1, Libre s2 -> [(s1, s2)]
  | Libre _, Quad (q, r, _, _) -> (get_verti_arrete qt1 q) @ (get_verti_arrete qt1 r)
  | Quad (_, _, q, r), Libre _ -> (get_verti_arrete q qt2) @ (get_verti_arrete r qt2)
  | Quad (_, _, q1, r1), Quad (q2, r2, _, _) -> (get_verti_arrete q1 q2) @ (get_verti_arrete r1 r2)

let rec interface_verticale_all = function
  | Quad (q1, q2, q3, q4) -> 
      (get_verti_arrete q1 q3) @ (get_verti_arrete q2 q4) @ 
      List.concat (List.map interface_verticale_all [q1; q2; q3; q4])
  | _ -> []

let mk_graph qt coords =
  let k = Array.length coords in
  let g = Array.make k [] in
  let edges = interface_horizontale_all qt @ interface_verticale_all qt in
  List.iter (fun (u, v) ->
    let d = distance_p1p2 coords.(u) coords.(v) in
    g.(u) <- (v, d) :: g.(u);
    g.(v) <- (u, d) :: g.(v)
  ) edges; g

(*****************************************************************)
(* DIJKSTRA                             *)
(*****************************************************************)

let dijkstra g s dest =
  let n = Array.length g in
  let preds = Array.make n (-1) in
  let vus = Array.make n false in
  let dist = Array.make n infinity in
  let pq = create () in
  dist.(s) <- 0.;
  preds.(s) <- s;
  insert (0., s) pq;
  while not (is_empty !pq) do
    let (d, u) = extract pq in
    if not vus.(u) then (
      vus.(u) <- true;
      if u = dest then pq := E (* Stop search *)
      else
        List.iter (fun (v, weight) ->
          let new_dist = d +. weight in
          if new_dist < dist.(v) then (
            dist.(v) <- new_dist;
            preds.(v) <- u;
            insert (new_dist, v) pq
          )
        ) g.(u)
    )
  done; (dist, preds)

let get_case_libre p coords qt =
  let closest = ref (-1) in
  let min_d = ref infinity in
  let rec aux = function
    | Libre nb ->
        let d = distance_p1p2 p coords.(nb) in
        if d < !min_d then (min_d := d; closest := nb)
    | Quad (no, ne, so, se) -> List.iter aux [no; ne; so; se]
    | Mur -> ()
  in aux qt; !closest

let find_path p_dep p_arr (qt, n) (g, coords) =
  let src = get_case_libre p_dep coords qt in
  let dest = get_case_libre p_arr coords qt in
  let _, preds = dijkstra g src dest in
  let rec rebuild curr path =
    if curr = -1 || preds.(curr) = -1 then []
    else if preds.(curr) = curr then coords.(curr) :: path
    else rebuild preds.(curr) (coords.(curr) :: path)
  in rebuild dest []

(*****************************************************************)
(* MAIN                                 *)
(*****************************************************************)

let load file =
  let c = Scanning.open_in file in
  let n = bscanf c "%d\n" (fun n -> n) in
  let r = bscanf c "%d\n" (fun r -> r) in
  let murs = ref [] in
  for _ = 1 to r do
    bscanf c "%d %d %d %d\n" (fun x y dx dy -> murs := (x, y, dx, dy) :: !murs)
  done; !murs, n

let print_path p =
  List.iter (fun (x, y) -> printf " -> (%.1f, %.1f)" x y) p;
  printf "\n"

let () =
  if Array.length Sys.argv < 2 then print_endline "Usage: ./vquad <map_file>"
  else
    let file = Sys.argv.(1) in
    let murs, n = load file in
    let qt_raw = list2qtree n murs in
    let qt, k = numerote qt_raw 0 in
    let coords = mk_coords qt k n in
    let g = mk_graph qt coords in
    let start_p = (float n /. 2., 0.) in
    let end_p = (float n /. 2., float n) in
    let path = find_path start_p end_p (qt, n) (g, coords) in
    printf "Path found:\n"; print_path path