local materials = {}

local hadFirstThink = false
local downloadQueue = {}

file.CreateDir("nebulaimgur")


function NebulaFinance:GetImgur(id, callback)
    if not hadFirstThink then downloadQueue[id] = callback end

    if materials[id] then return callback(materials[id]) end

    if file.Exists("nebulaimgur/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/nebulaimgur/" .. id .. ".png", "noclamp smooth")
        return callback(materials[id])
    end

    http.Fetch("https://imgur.com/" .. id .. ".png",
        function(body, len, headers, code)
            file.Write("nebulaimgur/" .. id .. ".png", body)
            materials[id] = Material("../data/nebulaimgur/" .. id .. ".png", "noclamp smooth")
            return callback(materials[id])
        end,
        function(error)
            return NebulaFinance:GetImgur(id, callback, true)
        end
    )
end

hook.Add("Think", "NebulaFinance:ImgurThink", function()
    hadFirstThink = true

    for k, v in pairs(downloadQueue) do
        NebulaFinance:GetImgur(k, v)
    end

    hook.Remove("Think", "NebulaFinance:ImgurThink")
end)

local progressMat
NebulaFinance:GetImgur("635PPvg", function(mat) progressMat = mat end)

function NebulaFinance:DrawProgressWheel(x, y, w, h, col)
    local progSize = math.min(w, h)
    surface.SetMaterial(progressMat)
    surface.SetDrawColor(col)
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, progSize, progSize, -CurTime() * 250)
end

local grabbingMaterials = {}
local materials = {}

function NebulaFinance:DrawImgur(x, y, w, h, imgurId, col)
    if not materials[imgurId] then
        NebulaFinance:DrawProgressWheel(x, y, w, h, color_white)

        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        NebulaFinance:GetImgur(imgurId, function(mat)
            materials[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    surface.SetMaterial(materials[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRect(x, y, w, h)
end