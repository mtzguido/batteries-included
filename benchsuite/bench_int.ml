(* cd .. && ocamlbuild benchsuite/test_int.native -- *)


external primitive_int_compare : int -> int -> int = "caml_int_compare" "noalloc"
[@@warning "-3"]

let std_compare = compare[@warning "-3"]

let test_compare () =

  let length = 1000 in

  let input =
    Array.init length (fun _ -> BatRandom.(full_range_int (), full_range_int ())) in

  let output = Array.map (fun (x, y) -> std_compare x y) input in

  let test cmp n =
    Array.iteri (fun i (x, y) ->
      assert (cmp x y = output.(i));
      for _i = 1 to n do
        ignore (cmp x y);
      done)
      input in

  let naive_compare x y =
    (* this code actually mirrors an implementation that has been used
       as BatInt.compare *)
    if x > y then 1
    else if y > x then -1
    else 0 in

  let mfp_compare (x : int) y =
    if x > y then 1
    else if y > x then -1
    else 0 in

  let samples = Bench.bench_n
    [
      "BatInt.compare", test BatInt.compare;
      "stdlib's compare", test std_compare;
      "external compare", test primitive_int_compare;
      "mfp's compare", test mfp_compare;
      "naive compare", test naive_compare;
    ]
  in
  print_endline "For comparing 1000 pairs of random integers";
  Bench.summarize samples

let () =
  test_compare ();
  ()
