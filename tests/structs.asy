struct t_tests_structs_flat_structure {
    int field1;
    string field2;
    bool field3;
    real field4;
}
struct t_tests_structs_mega_struct_field_02 {
    int x;
    int y;
}
struct t_tests_structs_mega_struct_field_03 {
    string a;
    bool b;
}
struct t_tests_structs_mega_struct_field_06_st {
    int a;
    int b;
}
struct t_tests_structs_mega_struct_field_06 {
    string []arr;
    string s;
    string s2;
    t_tests_structs_mega_struct_field_06_st st;
    bool t;
    int x;
    string y;
    real z;
}
struct t_tests_structs_mega_struct {
    int field_01;
    t_tests_structs_mega_struct_field_02 field_02;
    t_tests_structs_mega_struct_field_03 field_03;
    string []field_04;
    int [][]field_05;
    t_tests_structs_mega_struct_field_06 [][][]field_06;
}
struct t_tests_structs_table {
    string same_name;
}
struct t_tests_structs {
    int []flat_array;
    t_tests_structs_flat_structure flat_structure;
    t_tests_structs_mega_struct mega_struct;
    string same_name;
    t_tests_structs_table table;
}
t_tests_structs tests_structs;
tests_structs.flat_array[1] = 10;
tests_structs.flat_array[2] = 20;
tests_structs.flat_array[3] = 30;
tests_structs.flat_array[4] = 40;
tests_structs.flat_structure.field1 = 42;
tests_structs.flat_structure.field2 = "fourty two";
tests_structs.flat_structure.field3 = true;
tests_structs.flat_structure.field4 = 3.1415926535898;
tests_structs.mega_struct.field_01 = 42;
tests_structs.mega_struct.field_02.x = 0;
tests_structs.mega_struct.field_02.y = 1;
tests_structs.mega_struct.field_03.a = "hi";
tests_structs.mega_struct.field_03.b = true;
tests_structs.mega_struct.field_04[1] = "one";
tests_structs.mega_struct.field_04[2] = "two";
tests_structs.mega_struct.field_04[3] = "three";
tests_structs.mega_struct.field_05[1] = new int [];
tests_structs.mega_struct.field_05[1][1] = 1;
tests_structs.mega_struct.field_05[1][2] = 2;
tests_structs.mega_struct.field_05[2] = new int [];
tests_structs.mega_struct.field_05[2][1] = 3;
tests_structs.mega_struct.field_05[2][2] = 4;
tests_structs.mega_struct.field_05[3] = new int [];
tests_structs.mega_struct.field_05[3][1] = 5;
tests_structs.mega_struct.field_05[3][2] = 6;
tests_structs.mega_struct.field_06[1] = new t_tests_structs_mega_struct_field_06 [][];
tests_structs.mega_struct.field_06[1][1] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[1][1][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[1][1][1].st.a = 1;
tests_structs.mega_struct.field_06[1][1][1].st.b = 2;
tests_structs.mega_struct.field_06[1][1][1].x = 1;
tests_structs.mega_struct.field_06[1][1][1].y = "one";
tests_structs.mega_struct.field_06[1][1][2] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[1][1][2].x = 2;
tests_structs.mega_struct.field_06[1][1][2].y = "two";
tests_structs.mega_struct.field_06[1][2] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[1][2][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[1][2][1].x = -1;
tests_structs.mega_struct.field_06[1][2][2] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[1][2][2].y = "N/A";
tests_structs.mega_struct.field_06[1][3] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[1][3][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[1][3][1].st.a = 3;
tests_structs.mega_struct.field_06[1][3][1].st.b = 4;
tests_structs.mega_struct.field_06[1][3][1].z = 0.1;
tests_structs.mega_struct.field_06[1][3][2] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[1][3][2].z = 0.2;
tests_structs.mega_struct.field_06[2] = new t_tests_structs_mega_struct_field_06 [][];
tests_structs.mega_struct.field_06[2][1] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[2][1][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[2][1][1].arr[1] = "a";
tests_structs.mega_struct.field_06[2][1][1].arr[2] = "b";
tests_structs.mega_struct.field_06[2][1][1].x = 10;
tests_structs.mega_struct.field_06[2][1][1].y = "ten";
tests_structs.mega_struct.field_06[2][1][2] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[2][1][2].x = 20;
tests_structs.mega_struct.field_06[2][1][2].y = "twenty";
tests_structs.mega_struct.field_06[2][2] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[2][2][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[2][2][1].x = -2;
tests_structs.mega_struct.field_06[2][2][2] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[2][2][2].y = "N/A";
tests_structs.mega_struct.field_06[2][3] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[2][3][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[2][3][1].arr[1] = "cd";
tests_structs.mega_struct.field_06[2][3][1].arr[2] = "efg";
tests_structs.mega_struct.field_06[2][3][1].z = 3.1415926535898;
tests_structs.mega_struct.field_06[2][3][2] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[2][3][2].z = 1.5707963267949;
tests_structs.mega_struct.field_06[3] = new t_tests_structs_mega_struct_field_06 [][];
tests_structs.mega_struct.field_06[3][1] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[3][1][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[3][1][1].s = "";
tests_structs.mega_struct.field_06[3][1][1].s2 = "---------------------------------------";
tests_structs.mega_struct.field_06[4] = new t_tests_structs_mega_struct_field_06 [][];
tests_structs.mega_struct.field_06[4][1] = new t_tests_structs_mega_struct_field_06 [];
tests_structs.mega_struct.field_06[4][1][1] = new t_tests_structs_mega_struct_field_06 ;
tests_structs.mega_struct.field_06[4][1][1].t = true;
tests_structs.same_name = "global";
tests_structs.table.same_name = "field";

