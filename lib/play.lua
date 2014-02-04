local Board = require("board")

local validate = function(board, a1, b1, x1, y1, x2, y2)
    if a1 ~= nil and not (a1 == x1 and b1 == y1) then
        return false, "incorrect placement"
    end
    for _, i in ipairs({x1, y1, x2, y2}) do
        if type(i) ~= "number" then
            return false, "number expected"
        end
        if not (i >= 1 and i <= 3) then
            return false, "number out of bounds"
        end
    end
    if board[x1][y1][x2][y2] then
        return false, "non-empty spot"
    end
    return true
end

-- Yields:
--   xo; state; {x1, y1, x2, y2} | errorstring; board
--   state:
--      * false (error)
--      * nil (continue)
--      * "x" ("x" won)
--      * "o" ("o" won)
--      * "draw"
local play = function(p1, p2)
    local board, state = Board.new(), nil
    local p, xo, a1, b1 = p1, "x", nil, nil

    while state == nil do
        pp = function() return p(xo, board:copy(), a1, b1) end
        local success, x1, y1, x2, y2 = pcall(pp)
        if not success then
            coroutine.yield(xo, false, x1, board)
            return
        end

        local valid, err = validate(board, a1, b1, x1, y1, x2, y2)
        if not valid then
            coroutine.yield(xo, false, err, board)
            return
        end

        board[x1][y1][x2][y2] = xo
        state = board:state()
        coroutine.yield(xo, state, {x1, y1, x2, y2}, board)
        p = p == p1 and p2 or p1
        xo = xo == "x" and "o" or "x"
        if board[x2][y2]:state() == nil then
            a1, b1 = x2, y2
        else
            a1, b1 = nil, nil
        end
    end
end

return function(p1, p2) return coroutine.wrap(function() play(p1, p2) end) end
