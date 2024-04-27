
function pow(x, n)
    local res = 1
    for i = 1, n, 1 do
        res *= x
    end
    return res
end

function lshift(a: number, b: number): number
    return a * pow(2,b)
end

return {
    lshift = lshift
}