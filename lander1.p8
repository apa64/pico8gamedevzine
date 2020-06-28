pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- cave diver / gamedev with pico-8 #1
-- minor modifications by apa

-- consts
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

-- session highscore
highscore = 0
-- random starfield for each execution
starseed = rnd()
-- debug on/off
debug = false

function _init()
    game_over = false
    win = false
    g = 0.025   -- gravity
    make_player()
    make_ground()
end

function _update()
    if (not game_over) then
        move_player()
        check_land()
    else
        if (btnp(fire2)) _init()
    end
end

function _draw()
    cls(black)
    draw_stars()
    draw_ground()
    draw_player()
    draw_debug()

    if (game_over) then
        if (win) then
            print("you win!", 48, 48, green)
        else
            print("game over!", 48,48, red)
        end
        print("press ❎ to play again", 20, 70, dark_gray)
    end
end

-- returns random int between low and high.
function rndb(low, high)
    return flr(rnd(high - low + 1) + low)
end

-- initializes player
function make_player()
    p = {}
    p.x = 60    -- position
    p.y = 8
    p.dx = 0    -- movement
    p.dy = 0
    p.sprite = 1
    p.alive = true
    p.thrust = 0.075
end

-- ground is a list of heights
function make_ground()
    -- create the ground
    gnd = {}
    local top = 96  -- highest point
    local btm = 120 -- lowest point

    -- set up the landing pad
    pad = {}
    pad.width = 15
    pad.x = rndb(0, 126 - pad.width)
    pad.y = rndb(top, btm)
    pad.sprite = 2

    -- create ground at pad
    for i = pad.x, pad.x + pad.width do
        gnd[i] = pad.y
    end

    -- create ground right of pad
    for i = pad.x + pad.width + 1, 127 do
        -- random but not too big change from previous
        local h = rndb(gnd[i-1] - 3, gnd[i-1] + 3)
        -- don't exceed limits
        gnd[i] = mid(top, h, btm)
    end

    -- create ground left of pad
    for i = pad.x - 1, 0, -1 do
        local h = rndb(gnd[i+1] - 3, gnd[i+1] + 3)
        gnd[i] = mid(top, h, btm)
    end
end

function move_player()
    p.dy += g   -- add gravity

    thrust()

    p.x += p.dx -- actually move the player
    p.y += p.dy

    stay_on_screen()
end

function stay_on_screen()
    if (p.x < 0) then   -- left side
        p.x = 0
        p.dx = 0
    end
    if (p.x > 119) then -- right side
        p.x = 119
        p.dx = 0
    end
    if (p.y < 0) then   -- top side
        p.y = 0
        p.dy = 0
    end
end

-- handles button presses
function thrust()
    -- add thrust to movement
    if (btn(left)) p.dx -= p.thrust
    if (btn(right)) p.dx += p.thrust
    if (btn(up)) p.dy -= p.thrust

    if (btn(left) or btn(right) or btn(up)) sfx(0)

    if (btn(down)) debug = not debug
end

-- checks for landing and victory/death
function check_land()
    l_x = flr(p.x)      -- left side of ship
    r_x = flr(p.x + 7)  -- right side of ship
    b_y = flr(p.y + 7)  -- bottom of ship

    over_pad = (l_x >= pad.x) and (r_x <= (pad.x + pad.width))
    on_pad = (b_y >= (pad.y - 1))
    slow = (p.dy < 1)

    if (over_pad and on_pad and slow) then
        end_game(true)
    elseif (over_pad and on_pad) then
        end_game(false)
    else
        for i = l_x, r_x do
            if (gnd[i] <= b_y) end_game(false)
        end
    end
end

-- updates game end state
function end_game(won)
    game_over = true
    win = won

    if (win) then
        sfx(1)
    else
        sfx(2)
    end
end

-- draws starfield
function draw_stars()
    -- seed to get always same randoms for stars
    srand(starseed)
    for i = 1,50 do
        -- dark grey, light grey or white stars
        pset(rndb(0,127), rndb(0, 127), rndb(5,7))
    end
    -- reseed for real randoms
    srand(time())
end

function draw_ground()
    for i = 0, 127 do
        line(i, gnd[i], i, 127, dark_green)
    end
    spr(pad.sprite, pad.x, pad.y, 2, 1)
end

function draw_player()
    spr(p.sprite, p.x, p.y)
    if (game_over and win) then
        spr(4, p.x, p.y-8)  -- flag
    elseif (game_over) then
        spr(5, p.x, p.y)    -- explosion
    end
end

function draw_debug()
    print("dy:"..p.dy, 2, 121, pink)
end
__gfx__
0000000000033000760dddddddddd766000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000330007666666666666666000000000899998000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000300300007666666666660055776000899aa99800000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000030030000000000000000005577600089aaaa9800000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000300003000000000000000007755600089aaaa9800000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070003033030000000000000000077556000899aa99800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333003330000000000000000000060000899998000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000300000030000000000000000000060000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000600000565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001a0501a020150501502010050100201a0501a02000000160501a0501a0200000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000
000400003e67039660316502b640256402163018630126300d6200962008620066200561004610036100261002610046000000000000000000000000000000000000000000000000000000000000000000000000
