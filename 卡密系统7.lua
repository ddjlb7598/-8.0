-- 卡密验证系统（本地+远程结合版）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- ======================== 配置区域 ========================
local CONFIG = {
    -- 有效卡密列表（可替换为远程获取，此处为本地示例）
    VALID_KEYS = {
        "183",
        "78",
        "91"
    },
    -- 最大验证尝试次数
    MAX_ATTEMPTS = 3,
    -- 授权信息本地存储路径
    SAVE_PATH = "AuthSystem/ValidUser.json",
    -- 验证成功后执行的脚本（替换为你的目标脚本）
    TARGET_SCRIPT_URL = "https://raw.githubusercontent.com/ddjlb7598/-2.0/refs/heads/main/%E8%BF%AA%E8%84%9A%E6%9C%AC.lua"
}

-- ======================== 本地存储功能 ========================
-- 保存授权状态
local function SaveAuthStatus()
    pcall(function()
        if not isfolder("AuthSystem") then
            makefolder("AuthSystem")
        end
        local authData = {
            PlayerName = player.Name,
            Authorized = true,
            AuthTime = os.time(),
            ExpireTime = os.time() + 86400 * 7 -- 授权有效期7天
        }
        writefile(CONFIG.SAVE_PATH, HttpService:JSONEncode(authData))
    end)
end

-- 读取授权状态
local function LoadAuthStatus()
    if not isfile(CONFIG.SAVE_PATH) then return nil end
    local success, data = pcall(function()
        local content = readfile(CONFIG.SAVE_PATH)
        return HttpService:JSONDecode(content)
    end)
    -- 检查授权是否过期
    if success and data then
        return data.Authorized and data.ExpireTime > os.time() and data.PlayerName == player.Name
    end
    return false
end

-- ======================== UI创建 ========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyAuthUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

-- 主窗口（支持拖拽）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Text = "卡密验证"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold

-- 卡密输入框
local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Parent = MainFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyInput.Position = UDim2.new(0.05, 0, 0.25, 0)
KeyInput.Size = UDim2.new(0.9, 0, 0, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "输入卡密（区分大小写）"
KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyInput.TextSize = 14
KeyInput.ClearTextOnFocus = false

-- 验证按钮
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Name = "VerifyBtn"
VerifyBtn.Parent = MainFrame
VerifyBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
VerifyBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
VerifyBtn.Size = UDim2.new(0.8, 0, 0, 35)
VerifyBtn.Text = "验证并进入"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 14
VerifyBtn.Font = Enum.Font.SourceSansBold

-- 状态提示
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Text = "请输入卡密"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans

-- ======================== 核心验证逻辑 ========================
local errorCount = 0
local isAuthorized = LoadAuthStatus()

-- 执行目标脚本
local function ExecuteTargetScript()
    pcall(function()
        loadstring(game:HttpGet(CONFIG.TARGET_SCRIPT_URL))()
    end)
end

-- 验证卡密
local function VerifyKey(inputKey)
    for _, validKey in ipairs(CONFIG.VALID_KEYS) do
        if inputKey == validKey then
            return true
        end
    end
    return false
end

-- 验证按钮点击事件
VerifyBtn.Mou
