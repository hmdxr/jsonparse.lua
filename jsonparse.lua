-- locate datablock [] and {} in json content
-- findblock(content, "[", "]")
-- findblock(content, "{", "}")
function findblock(content, c1, c2)
    local flag, start, tail, s = 0, 0, 0, 1
    
    if type(content) ~= "string" then return false end
    
    while s <= #content do
        tmp = string.sub(content, s, s)
        if tmp == "\"" then
            -- ignore the entire "xxx"
            for i=s+1, #content, 1 do
                if string.sub(content, i, i) == "\"" and string.sub(content, i-1, i) ~= "\\" then
                    s = i+1
                    break
                end
            end
        else
            if tmp == c1 then
                flag = flag + 1
                if flag == 1 then start = s end
            elseif tmp == c2 then
                flag = flag -1
                if flag == 0 then
                    tail = s
                    break
                end
            end
            s = s+1
        end
    end

    if flag ~= 0 or start == 0 then
        return false
    else
        return string.sub(content, start, tail)
    end
end