function findblock(content, c1, c2)
    flag = 0
    start = 0
    tail = 0

    local s = 1
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
            --print(s)
            if tmp == c1 then
                flag = flag + 1
                if flag == 1 then start = s end
            elseif tmp ==  c2 then
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

function parsejsoncontent(t, content)
    local s = 1
    total = #content
    while s <= #content do
        local c = string.sub(content, s)
        if string.match(c, "^%s*%[") then
            -- browse each of element of this array, insert into table
            -- move index indicator to after [] block
            local blankspace = string.match(c, "^%s*")

            local curr_array_data = findblock(string.sub(c, #blankspace), "[", "]")

            s = s + #blankspace + #curr_array_data + 1 + 1

            -- s_cur indicates the start of curr_array_data (from 2nd character since the 1st is [)
            local s_cur = 2
            while s_cur <= #curr_array_data - 1 do
                local rest = string.sub(curr_array_data, s_cur)
                if string.match(rest, "^%s*%[") then
                    local blankspace2 = string.match(rest, "^%s*")
                    local subarraydata = findblock(string.sub(rest, #blankspace2), "[", "]")

                    if subarraydata ~= false then
                        s_cur = s_cur + #blankspace2 + #subarraydata + 1
                        local subtable = {}
                        parsejsoncontent(subtable, subarraydata)

                        table.insert(t, subtable)
                    end
                elseif string.match(rest, "^%s*%{") then
                        local blankspace2 = string.match(rest, "^%s*")
                        local subarraydata = findblock(string.sub(rest, #blankspace2), "{", "}")

                        if subarraydata ~= false then
                            s_cur = s_cur + #blankspace2 + #subarraydata + 1
                            local subtable = {}
                            parsejsoncontent(subtable, subarraydata)

                            table.insert(t, subtable)
                        end
                elseif string.match(rest, "^[%s,]*%d") then
                    local blankspace2 = string.match(rest, "^[%s,]*")
                    local value = string.match(rest, "^[%s,]*([%d.]+)")

                    table.insert(t, tonumber(value))
                    s_cur = s_cur + #blankspace2 + #value + 1
                elseif string.match(rest, "^%s*true") then
                    local blankspace2 = string.match(rest, "^%s*")
                    local value = true
                    table.insert(t, value)
                    s_cur = s_cur + #blankspace2 + 4 + 1
                elseif string.match(rest, "^%s*false") then
                    local blankspace2 = string.match(rest, "^%s*")
                    local value = false
                    table.insert(t, value)
                    s_cur = s_cur + #blankspace2 + 5 + 1
                elseif string.match(rest, "^%s*null") then
                    local blankspace2 = string.match(rest, "^%s*")
                    local value = "null"
                    --table.insert(t, value)
                    s_cur = s_cur + #blankspace2 + #value + 1
                elseif string.match(rest, "^%s*\"") then
                    local blankspace2 = string.match(rest, "^%s*")
                    local i = #blankspace2 + 2
                    while i <= #rest do
                        if string.sub(rest, i, i) == "\"" and string.sub(rest, i-1, i) ~= "\\" then
                            table.insert(t, string.sub(rest, #blankspace2+2, i-1))
                            s_cur = s_cur + i + 1
                            break
                        end
                        i = i + 1
                    end
                else
                    s_cur = s_cur + 1
                end
            end
        end

        if string.match(c, "^%s*{") then
            -- browse each of element of this object, insert into table
            -- move index indicator to after [] block
            local blankspace = string.match(c, "^%s*")
            local curr_array_data = findblock(string.sub(c, #blankspace), "{", "}")
            s = s + #blankspace + #curr_array_data + 1 + 1
            -- s_cur indicates the start of curr_array_data (from 2nd character since the 1st is [)
            local s_cur = 2
            while s_cur <= #curr_array_data - 1 do
                local rest = string.sub(curr_array_data, s_cur)

                -- find key
                local keystr = string.match(rest, "^[^\"]*\".-\"%s-:%s*")

                if keystr then
                    local key = string.match(rest, "^[^\"]*\"(.-)\"%s-:%s*")
                    s_cur = s_cur - 1 + #keystr

                    -- find value of the key
                    -- 1 string, number, null, true, false
                    -- 2 array
                    -- 3 object
                    local subcontent = string.sub(rest, #keystr + 1)
                    if string.match(subcontent, "^true") then
                        t[key] = true
                        s_cur = s_cur + 4 + 1
                    elseif string.match(subcontent, "^false") then
                        t[key] = false
                        s_cur = s_cur + 5 + 1
                    elseif string.match(subcontent, "^[%d.]+") then
                        t[key] = tonumber(string.match(subcontent, "^([%d.]+)"))
                        s_cur = s_cur + #(tostring(t[key])) + 1
                    elseif string.match(subcontent, "^\"") then
                        local i = 2
                        while i <= #subcontent do
                            if string.sub(subcontent, i, i) == "\"" and string.sub(subcontent, i-1, i) ~= "\\" then
                                t[key] = string.sub(subcontent, 1, i)
                                s_cur = s_cur + #(tostring(t[key])) + 1
                                break
                            end
                            i = i + 1
                        end
                    elseif string.match(subcontent, "^%[") then
                        local subarraydata = findblock(subcontent, "[", "]")

                        if subarraydata ~= false then
                            s_cur = s_cur + #subarraydata + 1
                            t[key] = {}
                            parsejsoncontent(t[key], subarraydata)
                        end
                    elseif string.match(subcontent, "^{") then
                        local subarraydata = findblock(subcontent, "{", "}")

                        if subarraydata ~= false then
                            s_cur = s_cur + #subarraydata + 1
                            t[key] = {}
                            parsejsoncontent(t[key], subarraydata)
                        end
                    end
                end
            end
        end

        if string.match(c, "^%s*true%s*$") then return true end
        if string.match(c, "^%s*false%s*$") then return false end
        if string.match(c, "^%s*null%s*$") then return nil end
        if string.match(c, "^%s*[%d.]+%s*$") then return tonumber(string.match(c, "^%s*([%d.]+)%s*$")) end
        if string.match(c, "^%s*.-%s*$") then return tostring(string.match(c, "^%s*(.-)%s*$")) end
     end
end