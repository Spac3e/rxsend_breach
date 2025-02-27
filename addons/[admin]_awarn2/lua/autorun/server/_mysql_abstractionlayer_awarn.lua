--[[
    MySQLite - Abstraction mechanism for SQLite and MySQL by FPtje
    Why use this?
        - Easy to use interface for MySQL
        - No need to modify code when switching between SQLite and MySQL
        - Queued queries: execute a bunch of queries in order an run the callback when all queries are done
    License: LGPL V2.1 (read here: https://www.gnu.org/licenses/lgpl-2.1.html)
]]

local bit = bit
local debug = debug
local error = error
local ErrorNoHalt = ErrorNoHalt
local hook = hook
local include = include
local pairs = pairs
local require = require
local sql = sql
local string = string
local table = table
local timer = timer
local tostring = tostring
local GAMEMODE = GM or GAMEMODE
local mysqlOO
local TMySQL
local _G = _G
local print = print

local multistatements

local MySQLite_config = MySQLite_config or RP_MySQLConfig or FPP_MySQLConfig
local moduleLoaded

local function loadMySQLModule()
    if moduleLoaded or not MySQLite_config or not MySQLite_config.EnableMySQL then return end

    moduleLoaded = true

    require("mysqloo")

    multistatements = CLIENT_MULTI_STATEMENTS

    mysqlOO = mysqloo
    TMySQL = tmysql
end
loadMySQLModule()

module("MySQLite_AWarn")


function initialize(config)
    MySQLite_config = config or MySQLite_config

    if not MySQLite_config then
        ErrorNoHalt("Warning: No MySQL config!")
    end

    loadMySQLModule()

    if MySQLite_config.EnableMySQL then
        connectToMySQL(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
    else
        timer.Simple(0, function()
            --hook.Call("DatabaseInitialized", GAMEMODE)
        end)
    end
end

local CONNECTED_TO_MYSQL = false
local msOOConnect
databaseObject = nil

local queuedQueries
local cachedQueries

function isMySQL()
    return CONNECTED_TO_MYSQL
end

function begin()
    if not CONNECTED_TO_MYSQL then
        sql.Begin()
    else
        if queuedQueries then
            debug.Trace()
            error("Transaction ongoing!")
        end
        queuedQueries = {}
    end
end

function commit(onFinished)
    if not CONNECTED_TO_MYSQL then
        sql.Commit()
        if onFinished then onFinished() end
        return
    end

    if not queuedQueries then
        error("No queued queries! Call begin() first!")
    end

    if #queuedQueries == 0 then
        queuedQueries = nil
        return
    end

    -- Copy the table so other scripts can create their own queue
    local queue = table.Copy(queuedQueries)
    queuedQueries = nil

    -- Handle queued queries in order
    local queuePos = 0
    local call

    -- Recursion invariant: queuePos > 0 and queue[queuePos] <= #queue
    call = function(...)
        queuePos = queuePos + 1

        if queue[queuePos].callback then
            queue[queuePos].callback(...)
        end

        -- Base case, end of the queue
        if queuePos + 1 > #queue then
            if onFinished then onFinished() end -- All queries have finished
            return
        end

        -- Recursion
        local nextQuery = queue[queuePos + 1]
        query(nextQuery.query, call, nextQuery.onError)
    end

    query(queue[1].query, call, queue[1].onError)
end

function queueQuery(sqlText, callback, errorCallback)
    if CONNECTED_TO_MYSQL then
        table.insert(queuedQueries, {query = sqlText, callback = callback, onError = errorCallback})
        return
    end
    -- SQLite is instantaneous, simply running the query is equal to queueing it
    query(sqlText, callback, errorCallback)
end

local function msOOQuery(sqlText, callback, errorCallback, queryValue)
    local query = databaseObject:query(sqlText)
    local data
    query.onData = function(Q, D)
        data = data or {}
        data[#data + 1] = D
    end

    query.onError = function(Q, E)
        if databaseObject:status() == mysqlOO.DATABASE_NOT_CONNECTED then
            table.insert(cachedQueries, {sqlText, callback, queryValue})

            -- Immediately try reconnecting
            msOOConnect(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
            return
        end

        local supp = errorCallback and errorCallback(E, sqlText)
       -- if not supp then error(E .. " (" .. sqlText .. ")") end
    end

    query.onSuccess = function()
        local res = queryValue and data and data[1] and table.GetFirstValue(data[1]) or not queryValue and data or nil
        if callback then callback(res, query:lastInsert()) end
    end
    query:start()
end

local function tmsqlQuery(sqlText, callback, errorCallback, queryValue)
    local call = function(res)
        res = res[1] -- For now only support one result set
        if not res.status then
            local supp = errorCallback and errorCallback(res.error, sqlText)
            if not supp then error(res.error .. " (" .. sqlText .. ")") end
            return
        end

        if not res.data or #res.data == 0 then res.data = nil end -- compatibility with other backends
        if queryValue and callback then return callback(res.data and res.data[1] and table.GetFirstValue(res.data[1]) or nil) end
        if callback then callback(res.data, res.lastid) end
    end

    databaseObject:Query(sqlText, call)
end

local function SQLiteQuery(sqlText, callback, errorCallback, queryValue)
    local lastError = sql.LastError()
    local Result = queryValue and sql.QueryValue(sqlText) or sql.Query(sqlText)

    if sql.LastError() and sql.LastError() ~= lastError then
        local err = sql.LastError()
        local supp = errorCallback and errorCallback(err, sqlText)
        if not supp then error(err .. " (" .. sqlText .. ")") end
        return
    end

    if callback then callback(Result) end
    return Result
end

function query(sqlText, callback, errorCallback)
    local qFunc = (CONNECTED_TO_MYSQL and
            mysqlOO and msOOQuery or
            TMySQL and tmsqlQuery) or
        SQLiteQuery
    return qFunc(sqlText, callback, errorCallback, false)
end

function queryValue(sqlText, callback, errorCallback)
    local qFunc = (CONNECTED_TO_MYSQL and
            mysqlOO and msOOQuery or
            TMySQL and tmsqlQuery) or
        SQLiteQuery
    return qFunc(sqlText, callback, errorCallback, true)
end

local function onConnected()
    CONNECTED_TO_MYSQL = true

    -- Run the queries that were called before the connection was made
    for k, v in pairs(cachedQueries or {}) do
        cachedQueries[k] = nil
        if v[3] then
            queryValue(v[1], v[2])
        else
            query(v[1], v[2])
        end
    end
    cachedQueries = {}

    --hook.Call("DatabaseInitialized", GAMEMODE.DatabaseInitialized and GAMEMODE or nil)
end

msOOConnect = function(host, username, password, database_name, database_port)
    databaseObject = mysqlOO.connect(host, username, password, database_name, database_port)

    if timer.Exists("darkrp_check_mysql_status") then timer.Remove("darkrp_check_mysql_status") end

    databaseObject.onConnectionFailed = function(_, msg)
        timer.Simple(5, function()
            msOOConnect(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
        end)
        error("Connection failed! " .. tostring(msg) ..  "\nTrying again in 5 seconds.")
    end

    databaseObject.onConnected = onConnected

    databaseObject:connect()
end

local function tmsqlConnect(host, username, password, database_name, database_port)
    local db, err = TMySQL.initialize(host, username, password, database_name, database_port, nil, MySQLite_config.MultiStatements and multistatements or nil)
    if err then error("Connection failed! " .. err ..  "\n") end

    databaseObject = db
    onConnected()
end

function connectToMySQL(host, username, password, database_name, database_port)
    database_port = database_port or 3306
    local func = mysqlOO and msOOConnect or TMySQL and tmsqlConnect or function() end
    func(host, username, password, database_name, database_port)
end

function SQLStr(str)
    local escape =
        not CONNECTED_TO_MYSQL and sql.SQLStr or
        mysqlOO                and function(str) return "\"" .. databaseObject:escape(tostring(str)) .. "\"" end or
        TMySQL                 and function(str) return "\"" .. databaseObject:Escape(tostring(str)) .. "\"" end

    return escape(str)
end

function tableExists(tbl, callback, errorCallback)
    if not CONNECTED_TO_MYSQL then
        local exists = sql.TableExists(tbl)
        callback(exists)
        return exists
    end

    queryValue(string.format("SHOW TABLES LIKE %s", SQLStr(tbl)), function(v)
        callback(v ~= nil)
    end, errorCallback)
end