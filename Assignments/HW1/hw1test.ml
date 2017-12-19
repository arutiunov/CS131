let my_subset_test0 = subset [8;7;6;1;2;4] [1]
let my_subset_test1 = subset [] []
let my_subset_test2 = subset [8;7;1] [10;11;12]

let my_equal_sets_test0 = equal_sets [7;8;9] [9;7;8]
let my_equal_sets_test1 = equal_sets [] []

let my_set_union_test0 = equal_sets (set_union [7;7;7] [7;7;7]) [7;7;7]
let my_set_union_test1 = equal_sets (set_union [13;14;15] [15;13;14]) [14;13;15]
let my_set_union_test2 = equal_sets (set_union [] [10]) [10]
let my_set_union_test3 = equal_sets (set_union [] []) []

let my_set_intersection_test0 = equal_sets (set_intersection [] []) []
let my_set_intersection_test1 = equal_sets (set_intersection [10;2] [3;18;13;5]) []
let my_set_intersection_test2 = equal_sets (set_intersection [9;13] [9;18;13;5]) [9;13]

let my_set_diff_test0 = equal_sets (set_diff [] []) []
let my_set_diff_test1 = equal_sets (set_diff [16] [16]) []

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x / 10000) 1000000 = 0

let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x / 2) 0 (3) = 3

let my_while_away_test0 = equal_sets (while_away ((+) 2) ((>) 10) 0) [0; 2; 4; 6; 8]

let my_rle_decode_test0 = equal_sets (rle_decode [4,"@"; 0,"100"; 5,"1"; 0,"60"; 2,"20"]) ["@";"@";"@";"@";"1";"1";"1";"1";"1";"20";"20"]