-- Выводит содержимое переменной с типами и структурой. 
-- @param value any Переменная для дампа
-- @param depth? integer Максимальная глубина рекурсии (необязательный, по умолчанию 10)
-- @param indent? integer Текущий отступ (внутреннее)
-- @param seen? table Таблица для отслеживания циклических ссылок (внутреннее)
-- @return string Отформатированная строка дампа
-- @usage
--   -- Стандартное использование
--   Facade.support.debug.var_dump( { id = 1, name = "Test" } )
--   table(2) {
--     ["id"] => number(1)
--     ["name"] => string(4) "Test"
--   }

--   -- Обработка циклических ссылок
--   local t = {}
--   t.self = t
--   Facade.support.debug.var_dump( t )
--   table(1) {
--     ["self"] => *RECURSION*
--   }
function Facade.support.debug.var_dump( value, depth, indent, seen )
    depth = depth or 10
    indent = indent or 0
    seen = seen or {}
    
    local indent_str = string.rep( "  ", indent )
    local type_str = type( value )
    
    -- Работа с nil
    if value == nil then
        return indent_str .. "nil"
    end
    
    -- Работа со стандартными типами
    if type_str ~= "table" then
        local prefix = indent_str .. type_str
        
        if type_str == "string" then
            -- Экранируем спецсимволы чтоб не отформатировали нам лог красивым результатом
            local escaped = value:gsub( "[\a\b\f\n\r\t\v\\\"]", {
                ["\a"] = "\\a", ["\b"] = "\\b", ["\f"] = "\\f",
                ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t",
                ["\v"] = "\\v", ["\\"] = "\\\\", ["\""] = "\\\""
            } )
            
            return string.format( '%s(%d) "%s"', prefix, #value, escaped )
        elseif type_str == "number" then
            return string.format( "%s(%s)", prefix, tostring( value ) )
        elseif type_str == "boolean" then
            return string.format( "%s(%s)", prefix, value and "true" or "false" )
        elseif type_str == "function" then
			local dbg = rawget( _G, "debug" )
            local func_desc = tostring( value ) -- Фоллбэк по умолчанию (например, "function: 0x12345678")
            
            -- Если библиотека debug доступна, пытаемся получить информацию о функции
            if type( dbg ) == "table" and type( dbg.getinfo ) == "function" then
                local ok, info = pcall( dbg.getinfo, value, "S" )
                if ok and info then
                    func_desc = info.what == "C" and "[C]" or string.format( "%s:%d", info.short_src, info.linedefined )
                end
            end
            
            return string.format( "%s (%s)", prefix, func_desc )
        elseif type_str == "userdata" then
            local ok, str = pcall( tostring, value )
            return string.format( "%s(%s)", prefix, ok and str or "<invalid userdata>" )
        elseif type_str == "thread" then
            return prefix .. "(coroutine)"
        end
        return prefix
    end
    
    if seen[value] then
        return indent_str .. "*RECURSION*"
    end
    
    if depth <= 0 then
        return indent_str .. "table(...)"
    end
    
    seen[value] = true
    local parts = { indent_str .. string.format( "table(%d) {", #value ) }
    local new_depth = depth - 1
    local new_indent = indent + 1
    
    -- Сортировка ключей: сначала числа, потом строки, потом остальные
    local keys = {}
    for k in pairs( value ) do
        table.insert( keys, k )
    end
    
    table.sort( keys, function( a, b )
        local ta, tb = type( a ), type( b )
        if ta == "number" and tb == "number" then return a < b end
        if ta == "number" then return true end
        if tb == "number" then return false end
        if ta == "string" and tb == "string" then return a < b end
        return ta < tb
    end )
    
    for _, k in ipairs( keys ) do
        local v = value[k]
        local key_str
        
        if type( k ) == "string" and k:match( "^[%a_][%w_]*$" ) then
            key_str = string.format( '["%s"]', k )
        else
            key_str = string.format( "[%s]", tostring( k ) )
        end
        
        local dump = Facade.support.debug.var_dump( v, new_depth, new_indent, seen )
        table.insert( parts, string.format( "%s => %s", indent_str .. "  " .. key_str, dump:sub( #indent_str + 3 ) ) )
    end
    
    table.insert( parts, indent_str .. "}" )
    
    return table.concat( parts, "\n" )
end


-- Строгая проверка типов аргументов. Поддерживает необязательные параметры (можно не передавать) и кастомные валидаторы.
-- Проверяет, что переданные значения соответствуют ожидаемым типам или правилам валидации.
-- Поддерживает:
--   + Стандартные типы Lua: "nil", "boolean", "number", "string", "table", "function", "thread", "userdata"
--   + Необязательные типы через "?тип" (разрешает nil / можно не передавать)
--   + Кастомные валидаторы - функции для произвольной проверки структуры
-- @param name string Имя функции для ошибок
-- @param ... table[] Переменное число таблиц вида:
--   + {значение, "тип"} - строгая проверка типа
--   + {значение, "?тип"} - необязательный тип (можно не передавать / допустим nil)
--   + {значение, функция} - кастомный валидатор
-- @raise error Если типы не совпадают, структура аргументов кривая или валидатор упал.
--   Сообщение содержит:
--     - имя
--     - номер аргумента (#1 = имя, #2+ = параметры)
--     - контекст ошибки (для валидаторов - вложенное сообщение)
-- @usage
--   -- Стандартная проверка типов
--   Facade.support.debug.strictTypes( "CreateAuction",
--       { itemId, "number" },
--       { buyoutPrice, "?number" }
--   )
  
--   -- Кастомная валидация таблицы через функцию
--   Facade.support.debug.strictTypes( "SearchAuction",
--       { filter, function( t )
--           -- Вложенная проверка полей таблицы
--           Facade.support.debug.strictTypes( "SearchAuction.filter",
--               { t.name, "?string" },
--               { t.levelMin, "?number" },
--               { t.levelMax, "?number" },
--               { t.onlyMyAuctions, "?boolean" }
--           )
--       end },
--       { page, "number" }
--   )
function Facade.support.debug.strictTypes( name, ... )
    -- Проверка первого аргумента
    if type( name ) ~= "string" then
        error(string.format(
            "Facade.support.debug.strictTypes: Argument #1 must be of type 'string', got '%s'",
            type( name )
        ) )
    end

    local args = { ... }

    for i = 1, #args do
        local arg = args[i]
        local argNumber = i + 1  -- Нумерация: #1 = name, #2+ = параметры

        -- Проверка: аргумент должен быть таблицей {значение, спецификация типа}
        if type( arg ) ~= "table" then
            error( string.format(
                "Facade.support.debug.strictTypes: Argument #%d must be a table {value, spec}, got '%s'",
                argNumber,
                type( arg )
            ) )
        end

        -- Проверка минимальной структуры таблицы
        if #arg < 2 then
            error( string.format(
                "Facade.support.debug.strictTypes: Argument #%d table must contain at least 2 elements",
                argNumber
            ) )
        end

        local value = arg[1]
        local spec = arg[2]
        
        local specType = type( spec )

        if specType == "string" then
            local isOptional = false
            local expectedType = spec

            if spec:sub( 1, 1 ) == "?" then
                isOptional = true
                expectedType = spec:sub( 2 )
            end

            -- Валидация корректности имени типа
            local validTypes = {
                ["nil"] = true, ["boolean"] = true, ["number"] = true,
                ["string"] = true, ["table"] = true, ["function"] = true,
                ["thread"] = true, ["userdata"] = true
            }

            if not validTypes[expectedType] then
                error( string.format(
                    "Facade.support.debug.strictTypes: Argument #%d unknown type '%s' (valid: %s)",
                    argNumber,
                    expectedType,
                    table.concat( {
                        "nil", "boolean", "number", "string", "table", "function", "thread", "userdata"
                    }, ", " )
                ) )
            end

            -- Последняя проверка значения
            local actualType = type( value )
            if isOptional and actualType == "nil" then
                -- nil разрешён для необязательных типов
            elseif actualType ~= expectedType then
                if isOptional then
                    error( string.format(
                        "%s: Argument #%d value must be of type '%s' or nil, got '%s'",
                        name,
                        argNumber,
                        expectedType,
                        actualType
                    ) )
                else
                    error( string.format(
                        "%s: Argument #%d value must be of type '%s', got '%s'",
                        name,
                        argNumber,
                        expectedType,
                        actualType
                    ) )
                end
            end

        elseif specType == "function" then
            -- Кастомная валидация через функцию-валидатор
            local ok, err = pcall( spec, value )
            if not ok then
                -- Оборачиваем ошибку валидатора в контекст верхнего уровня
                error( string.format(
                    "%s: Argument #%d validation failed: %s",
                    name,
                    argNumber,
                    err
                ) )
            end

        else
            -- Если кастомная валидация "криво" построена
            error(string.format(
                "Facade.support.debug.strictTypes: Argument #%d spec must be string or function, got '%s'",
                argNumber,
                specType
            ) )
        end
    end
end