-- locate datablock [] and {} in json content
-- findblock(content, "[", "]")
-- findblock(content, "{", "}")
-- return value:
-- false, "" if not matched
-- nil, errormsg: if not qualified parameter or json format
-- matched data, ""
function findblock(content, c1, c2)
    local flag, start, tail, s = 0, 0, 0, 1

    if type(content) ~= "string" then
        print("first argument must be a string")
        return nil, "argument error"
    end

    while s <= #content do
        local tmp = string.sub(content, s, s)
        if tmp == "\"" then
            -- ignore the entire "xxx"
            local x, y = string.find(string.sub(content, s + 1), ".-[^\\]\"")
            if x ~= nil and y > 0 then
                s = s + y + 1
            else
                print("malformed json format")
                return nil, "malformed json format"
            end
        else
            if tmp == c1 then
                flag = flag + 1
                if flag == 1 then start = s end
            elseif tmp == c2 then
                flag = flag -1
                if flag == 0 then tail = s break end
            end
            s = s+1
        end
    end

    if flag ~= 0 or start == 0 then
        return false
    else
        return string.sub(content, start, tail), ""
    end
end