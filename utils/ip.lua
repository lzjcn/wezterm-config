local wezterm = require('wezterm')
local platform = require('utils.platform')

local ip = {}

ip.local_ip = function()
   
    -- 获取本地 IP 地址（Linux/macOS）
    local local_ip = "unknown"
    if platform.is_mac then
        -- macOS 使用 ipconfig 命令获取 IP 地址
        local success, stdout, stderr = wezterm.run_child_process { "bash", "-c", [[ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}']] }
        local_ip = success and stdout:match("%S+") or local_ip

    elseif platform.is_linux then
        -- Linux 使用 hostname 命令获取 IP 地址
        local success, stdout, stderr = wezterm.run_child_process { "bash", "-c", "hostname -I" }
        local_ip = success and stdout:match("%S+") or local_ip

    elseif platform.is_win then
        -- Windows 使用 ipconfig 获取 IP 地址
        local success, stdout, stderr = wezterm.run_child_process { "cmd", "/c", "ipconfig" }
        local_ip = success and stdout:match("IPv4 地址[ .]+: ([%d%.]+)") or local_ip
    end
    return local_ip

end

ip.public_ip = function()
    -- local success, stdout, stderr = wezterm.run_child_process { "curl", "-s",  "https://api64.ipify.org" }
    -- local success, stdout, stderr = wezterm.run_child_process { "curl", "-s", "https://realip.cc/simple" }
    local success, stdout, stderr = wezterm.run_child_process { "curl", "-s", "https://4.ipw.cn" }

    local public_ip = success and stdout:match("%S+") or "N/A"

    return public_ip
end



return ip
