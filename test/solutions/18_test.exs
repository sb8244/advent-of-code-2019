defmodule EighteenTest do
  use ExUnit.Case

  test "example1" do
    input = """
    #########
    #b.A.@.a#
    #########
    """

    assert Eighteen.solve(input) == 8
  end

  test "example 2" do
    input = """
    ########################
    #f.D.E.e.C.b.A.@.a.B.c.#
    ######################.#
    #d.....................#
    ########################
    """

    assert Eighteen.solve(input) == 86
  end

  test "example 4" do
    input = """
    ########################
    #...............b.C.D.f#
    #.######################
    #.....@.a.B.c.d.A.e.F.g#
    ########################
    """

    assert Eighteen.solve(input) == 132
  end

  test "example 3" do
    input = """
    #################
    #i.G..c...e..H.p#
    ########.########
    #j.A..b...f..D.o#
    ########@########
    #k.E..a...g..B.n#
    ########.########
    #l.F..d...h..C.m#
    #################
    """

    assert Eighteen.solve(input) == 136
  end

  test "example 5" do
    input ="""
    ########################
    #@..............ac.GI.b#
    ###d#e#f################
    ###A#B#C################
    ###g#h#i################
    ########################
    """

    Eighteen.solve(input)
  end

  test "pt1" do
    input = """
    #################################################################################
    #.#...#.........#i........U.........#...#.........#.......#.............#.....E.#
    #.#.#.#.###.###Q#########.#########I#X#####.#####.#####.#.#.#######.###.#.#####.#
    #...#..u..#...#.#.........#l#...D.#.#...#...#...#.......#.#.#.......#.#.#.#...#.#
    #############.#.#.#########.#.###.#.###.#.###.#.#.#######.###.#######.#.#.#B#.#.#
    #...A.......#.#...#.#.....#...#...#...#.#.#.#.#...#...#......p#.......#.#.#.#.#.#
    #.#########.#.#####.#.#.#S#.###.#####.#.#.#.#.#####.#.#########.###.###.###.#.#.#
    #.#.........#...#...#.#.#.#...#.....#.#.#.#...#.#...#.......#.....#.#...#...#...#
    #.#########.#.#.###.#.#.#####.###.#.#.#.#.#.###.#.#########.#####.#.#.###.#####.#
    #.#.......#.#q#...#...#.#.....#.#.#.#...#.#.....#.#.....#.#.K.#...#.......#...#.#
    #.#.#####.#.#.###W#####.#.#####.#.#.###.#.#######.###.#.#.###.#.###########.#.#.#
    #...#...#.#y#...#.....#.#...L...#.#d#...#.....#...#...#.....#.#.#...#...#...#...#
    #####.#.#.#.#########.#.#######.#.###.#######.#.###.#########.###.#.#.#.#.#######
    #.....#...#.#.........#.N.....#n#...#x#.#.....#.#.....#.......#...#.#.#.#f#..o..#
    #.#########.#.#########.###.###.###.#.#.#.###.#.#.###.#.#######.###.#.###.#.###.#
    #...#.#.....#...#.....#.#.#...#.#.#.....#..t#.#.#...#.#...#...#...#.#.#...#...#.#
    ###O#.#.#####.#.#.#.###.#.###.#.#.#####.###.###.#####.###.#.#.#.###.#.#.#####.#.#
    #...#...#.....#.#.#.#..s#...#.....#..v#.#...#...........#.#.#...#...#.......#.#.#
    #.###.#########.#.#.#.###.#.#####.#.#.###.###.###########.#.#####.#########.###.#
    #.#..g..........#.#.......#.#...#.#.#...#.#...#.#.......#.......#.#...#.....#...#
    #.#.#############.#########.#.#.###.###.#.#.###.#.#####.#.#######.#.#.#.#####.#.#
    #.#.#...........#.#.#.#....z#.#.....#...#.#.....#...#.#.#.#.#...#.#.#.#.#.....#.#
    #.###.#########.#.#.#.#######.#######.###.#####.###.#.#.#.#.###.#.#.#.#.#####.#.#
    #.....#...#.....#...#.........#.....#...#.....#...#...#.#.....#.#...#.#.#.....#.#
    #.#####.#.#.#######.###########.#######.#.#######.###.#.###.###.#####.#.#.#####.#
    #.....#.#.#...#.Z.#.#....j..#.........#.#...#.......#.#.#...#...#.....#.#.#...#.#
    #######.#.###.#.###.#.#####.#.#####.###.#.#.#.#######.#.#####.###.#####.#.###.#.#
    #.......#.#...#.....#.#...#.#...#.#.....#.#.#.#.#.....#...#...#...#.....#...#.#.#
    #.#######.#.#.#####.#.###.#.###.#.#######.#.#.#.#.#######.#.###.#.###.#####.#.#.#
    #.#.#.....#.#.#...#.#...#.#...#...#.#...#.#...#.#.....#.#...#...#...#.......#...#
    #.#.#.#####.#.#.#.#####.#.###.###.#.#.#.#.#####.#####.#.#####.#####.#########.###
    #.#...#.....#.#.#.#...#...#.#.#...#...#.#.#...#.....#...#.#...#...#.....#...#.#.#
    #.###.###.#.###.#.#.#.###.#.#.#.#######.#.#.#.#####.###.#.#.###.#.#####.###.#.#.#
    #...#...#.#.#...#.#.#...#.#.#.#.#.......#...#.........#.#...#...#.#...#...#.#...#
    #.#.###.#.#.#.###.#.###.#.#.#.#.###.###.###########.###.#.###.###.###.###.#.###.#
    #.#...#.#.#.#...#...#...#.#.#.#.....#...#...#.....#.#...#.....#.....#.#...#..h#.#
    #.###.#.#.#####.#####.#.#.#.#.#######.###.#.#####.#.#.#############.#.#.###.#.#.#
    #...#.#.F.#...#.....#.#.#.#.#.#...#...#.#.#.......#.#.#...#...#...#...#.#.#.#...#
    ###.#.#####.#.#####.#.###.#.#.#.#.#.###.#.#########.#.#.#.#.#.#.#.#####.#.#.#####
    #...#.......#.......#.......#...#..................r#...#...#...#.......#.......#
    #######################################.@.#######################################
    #...........#.............#.#.....#...........#...........#...#.....#.....#.....#
    #########.#.#.###########.#.#.#.###.#.#.#.#.###.#####.#####.#.#####.#.###.#.#.###
    #...#.....#.#...#.......#.#.#.#.....#.#.#.#.....#.....#.....#.#...#....w#...#...#
    #.#.#.#####.###.#####.#.#.#.#.#####.#.###.#######.###.#.#####.#.#.#####.#######.#
    #.#.H.#...#...#.#...#.#.#.#...#...#.#...#.#.....#.#...#.....#...#...#...#.....#.#
    #.#.###.#.#####.#.#.#.###.#.###.#.###.#.#.###.#.#.#####.#######.###.#####.###.#.#
    #.#.#...#.......#.#...#...#.#...#...#.#.#...#.#.#.......#.....#.#...#.....#.#a#.#
    #.#.#.###########.#####.###R#.#####.###.###.###.#########.###.#.#.###.#####.#.#.#
    #.#.#.#.....#.....#...#.#...#.#...#...#.#.#...#.....#.....#...#.#.#.......#...#.#
    #.#.#.#.###.#.#.###.#.#.#####.#.#####.#.#.###.#.#.#.#.#####.#####.#.#####.#.###.#
    #.#.#.#...#...#.....#.#...#...#.....#...#.#...#.#.#.#.#...........#.#.....#...#.#
    #.#.#.###.###########.###.#.###.###.###.#.#.###.#.###.#############.#.#######.#Y#
    #.#.#.#.#.#.........#...#.#...#.#.#...#.#.#...#.#.#...#...#.#.....#.#.....#...#.#
    #.#.#.#.#.#########.#.###.###.#.#.#.#.#.#.###.###.#.###.#.#.#.#.###.#####.#.###.#
    #.#.#.#...#.........#.........#...#.#.#.#...#.....#.....#.#...#.........#.#.#...#
    #.###.#.###.#.#######.###########.#.###.#.#######.#######.#.#############.#.#.#.#
    #...#.#.#...#.#.....#.#.....#...J.#.....#...#...#...#.....#.#...#...#.....#...#.#
    ###.#.#.###.#.#.###.###.###.#.###########.#.#.#.###.#.#####.#.#.###.#.#########.#
    #...#.#.....#.#...#.....#...#.#...#.....#.#.#.#.....#.#.......#.....#.....#.....#
    #.###.###.#######.#######.###.#.###.#.#####.#.#######.###.#########.#####.#.#####
    #...#.#.#.#.......#.#.....#.#.#.....#...#.V.#.....#.#...#...#.#...#...#...#.....#
    ###.#.#.#.#.#######.#######.#.#########.#.#######.#.###.###.#.#.#####.#.#######.#
    #...#.#...#.#.......#.......#.......#...#.......#.#...#...#.#.#...#...#.#...#...#
    #.###.#####.#.#####.#.#.###.#######.#.#.#.#.###.#.#.#.###.###.###.#.###.#.#G#.###
    #...#.....#...#...#.#.#.#.#.#.....#...#.#.#.#...#.#.#b..#...#...#.#.#c..#.#.....#
    #.#.#####.#####.#.#.#.#.#.#.###.#######.#.#.#####.#####.###.###.#.#.#.###########
    #.#.C...#.......#...#.#.#.......#...#...#.#.#...#.#.....#.#.#...#...#...#......m#
    #.#####.#############.#.###.#####.#.#.###.#.#.#T#.#.###.#.#.#.#####.###.#.#####.#
    #...#.#.......#.....#.#...#.#.....#...#.#.#.#.#...#.#...#.#.#.....#...#.....#...#
    ###.#.#####.###.#.#.#.###.#.#.#########.#.#.#.#####.#.###.#.#####.###.#######.#.#
    #.#...#...#.#...#.#.#.#...#.#.....#.....#.#...#.....#.#...#.....#.#...#.#...#.#.#
    #.###.#.###M#.###.###.#.#########.###.#.#.#####.#.###.#.#.#.#####.###.#.#.#.#.#.#
    #.....#...#...#...#...#...#.......#...#.#.#...#.#...#.#.#.#.....#...#...#.#...#.#
    #.#######.#####.#.#.#####.#.#######.###.#.#.#.#####.#.#.#######.###.#####.#####.#
    #.#.........#...#.#.#.#...#.#.......#...#k#.#.......#.#.....#...#...#.....#.....#
    #.#.#######.#.###.#.#.#.###.###.#####.###.#.#########.#####.#.###.###.#####.#####
    #...#...#...#...#.#...#...#...#...#.#.#.#...#.#.....#.#e....#.....#...#...#.#...#
    #####.#.#.#####.#####.###P###.###.#.#.#.#####.#.#.###.#.###.#######.###.###.#.#.#
    #.....#.......#.........#.........#.....#.......#.......#...........#.........#.#
    #################################################################################
    """

    assert Eighteen.solve(input) == 2946
  end
end