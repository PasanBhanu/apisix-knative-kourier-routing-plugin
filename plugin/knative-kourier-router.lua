local core = require("apisix.core")
local plugin_name = "knative-kourier-router"


local schema = {
    type = "object",
    properties = {
        header_name = { 
            description = "Header name to be used for routing",
            type = "string",
            default = "x-knative-function"
        },
    },
    required = { "header_name" }
}


local _M = {
    version = 0.1,
    priority = 1010,
    name = plugin_name,
    schema = schema,
}


function _M.check_schema(conf)
    return core.schema.check(schema, conf)
end


function _M.before_proxy(conf, ctx)
    local headers = ngx.req.get_headers()
    local knative_function = headers[conf.header_name]

    if knative_function then
        ctx.var["upstream_host"] = knative_function
        core.log.info("[KNATIVE-KOURIER-ROUTER] Host header overridden to: ", knative_function)
    else
        core.log.info("[KNATIVE-KOURIER-ROUTER] ", conf.header_name, " header not found, Host header remains unchanged")
    end
end


return _M