local wezterm = require('wezterm')
local platform = require('utils.platform')

local ip = {}

ip.local_ip = function()
   
    -- 获取本地 IP 地址（Linux/macOS）
    local local_ip = "unknown"
    if platform.is_mac then
    -- macOS 使用 ipconfig 命令获取 IP 地址
    local success, stdout, stderr = wezterm.run_child_process { "bash", "-c", "ipconfig getifaddr en0" }
    local_ip = stdout:match("%S+")

    elseif platform.is_linux then
    -- Linux 使用 hostname 命令获取 IP 地址
    local success, stdout, stderr = wezterm.run_child_process { "bash", "-c", "hostname -I" }
    local_ip = stdout:match("%S+")

    elseif platform.is_windows then
    -- Windows 使用 ipconfig 获取 IP 地址
    local success, stdout, stderr = wezterm.run_child_process { "cmd", "/c", "ipconfig" }
    local_ip = stdout:match("IPv4 地址[ .]+: ([%d%.]+)")
    end
    return local_ip

end

ip.public_ip = function()
    local success, stdout, stderr = wezterm.run_child_process { "curl", "-s", "https://api64.ipify.org" }
    -- local success, stdout, stderr = wezterm.run_child_process { "curl", "-s", "https://realip.cc/simple" }
    local public_ip=stdout

    if not public_ip then
    public_ip = 'N/A'
    end
    return public_ip
end



return ip
