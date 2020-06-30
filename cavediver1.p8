pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- cave diver / gamedev with pico-8 #1
-- minor modifications by apa64
highscore = 0
function _init()
    debug = false
    game_over = false
    make_cave()
    make_player()
end

function _update()
    if (not game_over) then
        update_cave()
        move_player()
        check_hit()
    else
        -- game is over
        if (btnp(5)) _init() -- restart
    end
end

function _draw()
    cls()
    draw_cave()
    draw_player()

    if (game_over) then
        if (player.score == highscore) then
            highscorecolor = 8
        else
            highscorecolor = 7
        end
        print("highscore:"..highscore, 38, 24, highscorecolor)
        print("game over!", 44, 44, 7)
        print("your score:"..player.score, 34, 54, 7)
        print("press ❎ to play again!", 18, 64, 6)
    end
    print("score:"..player.score, 2, 2, 7)
    if (debug) print ("dy:"..player.dy.." spd:"..player.speed, 2, 121, 14)
end
-->8
function make_player()
    player = {}
    player.x = 24       -- position
    player.y = 60
    player.dy = 0       -- fall speed
    player.rise = 1     -- sprites
    player.fall = 2
    player.dead = 3
    player.speed = 2    -- fly speed
    player.score = 0
end

function move_player()  -- and handle input
    gravity = 0.2           -- bigger = more gravity
    player.dy += gravity    -- add gravity to y pos

    -- jump
    if (btnp(2)) then
        player.dy -= 4.5
        sfx(0)
    end

    -- change speed
    if (btnp(1)) player.speed += 0.1
    if (btnp(0)) player.speed -= 0.1

    -- switch debug
    if (btnp(3)) debug = not debug

    -- move to new position
    player.y += player.dy

    -- update score
    player.score += player.speed
end

function check_hit()
    -- loop thru player left to right x pos...
    for i = player.x, player.x+7 do
        -- compare cave table top/btm coords with player top/btm pos
        if (cave[i+1].top > player.y
          or cave[i+1].btm < player.y + 7) then
            game_over = true
            sfx(1)
            if (player.score > highscore) highscore = player.score
        end
    end
end

function draw_player()
    if (game_over) then
        spr(player.dead,player.x,player.y)
    elseif (player.dy < 0) then
        spr(player.rise,player.x,player.y)
    else
        spr(player.fall,player.x,player.y)
    end
end
-->8
function make_cave()
    -- cave is table of top and bottom y positions
    cave = { { ["top"]=5, ["btm"]=119 } }
    top = 45    -- how low can the ceiling go?
    btm = 85    -- how high can the floor get?
end

function update_cave()
    -- remove the back of the cave
    if (#cave > player.speed) then
        for i = 1, player.speed do
            del(cave, cave[1])
        end
    end

    -- add more cave
    while (#cave < 128) do
        local col  = {}
        local up = flr(rnd(7)-3)
        local down = flr(rnd(7)-3)
        col.top = mid(3, cave[#cave].top + up, top)
        col.btm = mid(btm, cave[#cave].btm + down, 124)
        add(cave, col)
    end
end

function draw_cave()
    top_color = 5
    btm_color = 4
    -- draw cave table
    for i = 1, #cave do
        line(i-1, 0, i-1, cave[i].top, top_color)
        line(i-1, 127, i-1, cave[i].btm, btm_color)
    end
end
__gfx__
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aaaaaa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa1aa1aaaaaaaaaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaaaa1aa1aa88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aa1111aaaaaaaaaa88899888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aaa11aaaaaa11aaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aa11aa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400000e03012030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000280500000023050000001c0501c0000805008050080400804008020080200802008010080100801000000060000500004000000000400004000040000000000000000000000000000000000000000000
